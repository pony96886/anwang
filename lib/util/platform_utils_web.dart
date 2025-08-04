import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:js_util' as js_util;
import 'package:crypto/crypto.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: camel_case_types
class platformViewRegistry {
  static disableUrlStrategy() {
    setUrlStrategy(null);
  }

  static registerViewFactory(String viewId, dynamic cb) {
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }

  //苹果PWA浏览器
  static bool isPWA() {
    if (kIsWeb) {
      final isStandalone =
          html.window.matchMedia('(display-mode: standalone)').matches;
      final isIOSStandalone =
          js_util.getProperty(html.window.navigator, 'standalone') as bool? ??
              false;
      return isStandalone || isIOSStandalone;
    }
    return false;
  }

  //生成封面
  static Future<Uint8List?> videoThumbnail(Object doc) async {
    html.File file = doc as html.File;

    final video = html.VideoElement()
      ..src = html.Url.createObjectUrl(file)
      ..crossOrigin = 'anonymous'
      ..muted = true
      ..autoplay = false
      ..preload = 'auto';
    final completer = Completer<Uint8List?>();
    video.onLoadedData.listen((_) async {
      video.currentTime = 1.0; // 设置到第1秒左右（第一帧有时是黑的）
      await video.onSeeked.first;
      final canvas = html.CanvasElement(
        width: video.videoWidth,
        height: video.videoHeight,
      );
      final context = canvas.context2D;
      context.drawImage(video, 0, 0);
      final dataUrl = canvas.toDataUrl('image/png');
      final base64String = dataUrl.split(',').last;
      final bytes = base64.decode(base64String);
      completer.complete(Uint8List.fromList(bytes));
      //删除
      html.Url.revokeObjectUrl(video.src);
      video.remove();
    });
    video.onError.listen((event) {
      completer.complete(null);
    });

    html.document.body!.append(video); // 必须添加到 DOM，否则有些浏览器不加载
    video.load();

    return completer.future;
  }

  //R2大文件分片上传
  static Future<Map<String, dynamic>> r2fileSliceUploadMp4(
    BuildContext context,
    Object doc, {
    CancelToken? cancelToken,
    ProgressCallback? progressCallback,
  }) async {
    void synchronized(Object lock, void Function() fn) {
      fn();
    }

    //控制任务数量
    Future<List<T>> runWithSync<T>(
        List<Future<T> Function()> tasks, int count) async {
      final results = List<T?>.filled(tasks.length, null, growable: false);
      int index = 0;
      final lock = Object();

      Future<void> schedule() async {
        while (true) {
          int taskIndex = 0;
          Future<T> Function()? task;
          // 保证线程安全地取任务
          synchronized(lock, () {
            if (index >= tasks.length) return;
            taskIndex = index;
            task = tasks[index];
            index++;
          });
          if (task == null) return;
          final result = await task!();
          results[taskIndex] = result;
        }
      }

      final runners = List.generate(count, (_) => schedule());
      await Future.wait(runners);
      return results.cast<T>();
    }

    final file = doc as html.File;
    ConfigModel? cf = Provider.of<BaseStore>(context, listen: false).conf;
    String urlStart = cf?.r2URL ??
        "https://r2.microservices.vip/multipart_upload"; //请求分片数据API
    String key = cf?.r2Key ?? "d2bf7126723ea8f6005ba141ea3c3e2c"; //请求分片数据key
    String urlEnd = cf?.r2CompleteURL ??
        "https://r2.microservices.vip/multipart_complete"; //合并分片API
    const int chunkSize = 5 * 1024 * 1024; // 5MB
    final int fileSize = file.size;
    final int numberOfChunks = (fileSize / chunkSize).ceil();
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String signature = md5.convert(utf8.encode('$timeStamp$key')).toString();

    //请求上传地址
    final Response response = await Dio().post(
      urlStart,
      data: FormData.fromMap({
        "sign": signature,
        "timestamp": timeStamp,
        "total": numberOfChunks,
      }),
      options: Options(contentType: 'multipart/form-data'),
    );
    final value = response.data;
    if (value == null || value["status"] != "success") {
      return {"code": 0, "msg": "request slice url failed"};
    }
    final result = value["data"];

    final uploadUrl = result["uploadUrl"].toString();
    final uploadName = result["UploadName"].toString();
    final uploadId = result["uploadId"].toString();
    final List<dynamic> slices = List.from(result["slices"] ?? []);
    final String chunkUploadUrl = uploadUrl
        .replaceAll("{UploadName}", uploadName)
        .replaceAll("{uploadId}", uploadId);
    final List<Map<String, dynamic>> sliceTags = [];
    int uploadedSize = 0;

    List<Future<Map<String, dynamic>> Function()> tasks =
        List.generate(slices.length, (k) {
      return () async {
        final int start = k * chunkSize;
        final int end = min(start + chunkSize, fileSize);
        final int sliceSize = end - start;
        final html.Blob chunkFile = file.slice(start, end);
        final urlK = chunkUploadUrl
            .replaceAll("{number}", slices[k]['number'].toString())
            .replaceAll("{signature}", slices[k]['signature'].toString());

        final reader = html.FileReader();
        final completer = Completer<Uint8List>();
        reader.readAsArrayBuffer(chunkFile);
        reader.onLoadEnd.listen((_) {
          completer.complete(reader.result as Uint8List);
          reader.onLoadEnd.drain();
          reader.abort();
        }, onError: (err) {
          completer.completeError(err);
          reader.onLoadEnd.drain();
          reader.abort();
        });
        Uint8List bytes = await completer.future;

        return Dio()
            .put(
          urlK,
          data: Stream.fromIterable([bytes]),
          cancelToken: cancelToken,
          options: Options(
            contentType: 'application/octet-stream',
            headers: {Headers.contentLengthHeader: sliceSize},
          ),
        )
            .then((value) {
          bytes = Uint8List(0);
          if (value.statusCode == 200) {
            sliceTags.add({
              'number': k + 1,
              'e_tag': value.headers['etag']![0].replaceAll('"', '')
            });
            uploadedSize += sliceSize;
            progressCallback?.call(uploadedSize, fileSize);
            return {"code": 1, "msg": "upload slice success"};
          } else {
            return {"code": 0, "msg": "upload slice failed"};
          }
        }, onError: (_) {
          bytes = Uint8List(0);
          return {"code": 0, "msg": "upload slice failed"};
        });
      };
    });

    return runWithSync(tasks, 5).then((t) {
      final d = t.firstWhere((e) => e["code"] == 0, orElse: () => {});
      if (d.isNotEmpty) {
        return d;
      }
      return Dio()
          .post(urlEnd,
              data: FormData.fromMap({
                'sign': signature,
                'timestamp': timeStamp,
                'upload_name': uploadName,
                'upload_id': uploadId,
                'slice_tag': jsonEncode(sliceTags),
              }),
              cancelToken: cancelToken,
              options: Options(contentType: 'multipart/form-data'))
          .then((v) {
        if (v.data["status"] == "success") {
          return {"code": 1, "msg": v.data["data"]["publicUrl"].toString()};
        } else {
          return {"code": 0, "msg": "upload merge failed"};
        }
      }, onError: (_) {
        return {"code": 0, "msg": "upload merge failed"};
      });
    });
  }
}
