// ignore: camel_case_types
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:provider/provider.dart';

class platformViewRegistry {
  static disableUrlStrategy() {}
  static registerViewFactory(String viewId, dynamic cb) {}
  static isPWA() => false;
  //生成封面
  static Future<Uint8List?> videoThumbnail(Object doc) async {
    XFile file = doc as XFile;
    final uint8list = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.PNG,
    );
    return uint8list;
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

    final xfile = doc as XFile;
    ConfigModel? cf = Provider.of<BaseStore>(context, listen: false).conf;
    String urlStart = cf?.r2URL ??
        "https://r2.microservices.vip/multipart_upload"; //请求分片数据API
    String key =
        cf?.r2Key ?? "d2bf7126723ea8f6005ba141ea3c3e2c"; //请求分片数据key
    String urlEnd = cf?.r2CompleteURL ??
        "https://r2.microservices.vip/multipart_complete"; //合并分片API
    const int chunkSize = 5 * 1024 * 1024; // 5MB
    final int fileSize = await xfile.length();
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
        final Stream<List<int>> chunkFile = xfile.openRead(start, end);
        final urlK = chunkUploadUrl
            .replaceAll("{number}", slices[k]['number'].toString())
            .replaceAll("{signature}", slices[k]['signature'].toString());
        return Dio()
            .put(
          urlK,
          data: chunkFile,
          cancelToken: cancelToken,
          options: Options(
            contentType: 'application/octet-stream',
            headers: {Headers.contentLengthHeader: sliceSize},
          ),
        )
            .then((value) {
          chunkFile.drain();
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
          chunkFile.drain();
          return {"code": 0, "msg": "upload slice failed"};
        });
      };
    });

    return runWithSync(tasks, 20).then((t) {
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
