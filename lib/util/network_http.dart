import 'dart:convert';
import 'dart:typed_data';

import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

//网络加载
class NetworkHttp {
  //是否因token失效跳转到登录页
  static bool _isJump = false;

  //获取token
  static String _getToken() {
    return AppGlobal.appBox?.get('deepseek_token') ?? "";
  }

  static final Dio _uploadDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static final Dio _novelDio = Dio(new BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 30),
    responseType: ResponseType.bytes,
    validateStatus: (status) {
      return (status ?? 0) < 500;
    },
  ));
  static final Dio apiDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return (status ?? 0) < 500;
      },
      contentType: Headers.formUrlEncodedContentType,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          Map _data = {};
          String _token = _getToken();
          if (_token.isNotEmpty) AppGlobal.apiToken = _token;
          _data.addAll(AppGlobal.appinfo);
          _data.addAll({'token': _token});
          if (options.data != null) _data.addAll(options.data);
          Utils.log("params: $_data");
          options.data = await EncDecrypt.encryptReqParams(
              jsonEncode(_data), (kIsWeb ? 'pwa' : 'android'));
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          if (response.data['data'] != null) {
            String _data = await EncDecrypt.decryptResData(response.data);
            response.data = jsonDecode(_data);
          }
          Utils.log(response.data);
          if (response.data["msg"] == "token无效" &&
              !_isJump &&
              AppGlobal.context != null) {
            Utils.showDialog(
              setContent: () {
                return RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: Utils.txt("dlsx"),
                      style: StyleTheme.font_gray_153_13),
                ]));
              },
              confirm: () {
                //清空数据
                AppGlobal.apiToken = '';
                AppGlobal.appBox?.delete('deepseek_token');
                reqUserInfo(AppGlobal.context!).then((value) {
                  UtilEventbus().fire(EventbusClass({"name": "logout"}));
                  AppGlobal.appRouter?.go("/mineloginpage");
                  _isJump = false;
                });
              },
            );
          }

          if (response.data['data'] is List && response.data['status'] == 0) {
            //报错后，返回[], 兼容上层解析
            response.data['data'] = null;
          }
          return handler.next(response);
        },
        onError: (DioError e, handler) async {
          return handler.next(e);
        },
      ),
    );

  //设置代理
  static setProxy() {
    // if (kIsWeb) return;
    // (_apiDio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   client.findProxy = AppGlobal.isProxy
    //       ? (uri) => "PROXY localhost:${AppGlobal.port}"
    //       : null;
    // };
  }

  static Future xfileUploadImage({
    XFile? file,
    String? id,
    String position = 'head',
    ProgressCallback? progressCallback,
  }) async {
    try {
      id ??= DateTime.now().millisecondsSinceEpoch.toString();
      var imgKey = AppGlobal.uploadImgKey.replaceFirst('head', '');
      var newKey = 'id=$id&position=$position$imgKey';
      var tmpSha256 = EncDecrypt.toSha256(newKey);
      var sign = Utils.toMD5(tmpSha256);
      var ext = file?.name.split(".").last;

      FormData formData = FormData.fromMap({
        'id': id,
        'position': position,
        'sign': sign,
        'cover': await MultipartFile.fromFile(
          file?.path ?? "",
          filename: file?.name ?? "",
          contentType: MediaType.parse('image/$ext'),
        ),
      });
      Response response = await _uploadDio.post(
        AppGlobal.uploadImgUrl,
        data: formData,
        onSendProgress: progressCallback,
        options: Options(contentType: 'multipart/form-data'),
      );
      return jsonDecode(response.data);
    } catch (e) {
      Utils.log(e);
      return null;
    }
  }

  static Future xfileHtmlUploadImage(
      {XFile? file,
      String? id,
      String position = 'head',
      Function(html.ProgressEvent)? progressCallback}) async {
    try {
      id ??= DateTime.now().millisecondsSinceEpoch.toString();
      var imgKey = AppGlobal.uploadImgKey.replaceFirst('head', '');
      var newKey = 'id=$id&position=$position$imgKey';
      var tmpSha256 = EncDecrypt.toSha256(newKey);
      var sign = Utils.toMD5(tmpSha256);
      var ext = file?.name.split(".").last;

      html.Blob? blob = html.Blob([await file?.readAsBytes()], "image/$ext");
      String url = html.Url.createObjectUrl(blob);
      final html.FormData formData = html.FormData()
        ..append('id', id)
        ..append('position', position)
        ..append('sign', sign)
        ..appendBlob(
          "cover",
          blob,
        );

      html.HttpRequest httpRequest = await html.HttpRequest.request(
          AppGlobal.uploadImgUrl,
          method: "POST",
          mimeType: "image/$ext",
          sendData: formData,
          onProgress: progressCallback);
      html.Url.revokeObjectUrl(url);
      return jsonDecode(httpRequest.response);
    } catch (e) {
      Utils.log(e);
      return null;
    }
  }

  static Future htmlBytesUploadMp4(
      {XFile? file,
      String position = 'head',
      CancelToken? cancelToken,
      Function(html.ProgressEvent)? progressCallback}) async {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var videoKey = AppGlobal.uploadMp4Key.replaceFirst('head', '');
      var newKey = '$timeStamp$videoKey';
      var sign = Utils.toMD5(newKey);

      html.Blob? blob = html.Blob([await file?.readAsBytes()], "video/mp4");
      String url = html.Url.createObjectUrl(blob);
      final html.FormData formData = html.FormData()
        ..append('timestamp', timeStamp)
        ..append('uuid', "9544f11ed4381ebcef5429b6f20e69c1")
        ..append('position', position)
        ..append('sign', sign)
        ..appendBlob(
          "video",
          blob,
        );

      html.HttpRequest httpRequest = await html.HttpRequest.request(
        AppGlobal.uploadMp4Url,
        method: "POST",
        mimeType: "video/mp4",
        sendData: formData,
        onProgress: progressCallback,
      );
      html.Url.revokeObjectUrl(url);
      return httpRequest.response;
    } catch (e) {
      Utils.log(e);
      return null;
    }
  }

  static Future xfileBytesUploadMp4(
      {XFile? file,
      String position = 'head',
      CancelToken? cancelToken,
      ProgressCallback? progressCallback}) async {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var videoKey = AppGlobal.uploadMp4Key.replaceFirst('head', '');
      var newKey = '$timeStamp$videoKey';
      var sign = Utils.toMD5(newKey);

      FormData formData = FormData.fromMap({
        'timestamp': timeStamp,
        'uuid': '9544f11ed4381ebcef5429b6f20e69c1',
        'sign': sign,
        'video': MultipartFile.fromBytes(
          await file?.readAsBytes() ?? [],
          filename: file?.name,
          contentType: MediaType.parse('video/mp4'),
        ),
      });

      Response response = await _uploadDio.post(
        AppGlobal.uploadMp4Url,
        data: formData,
        onSendProgress: progressCallback,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      Utils.log(e);
      return null;
    }
  }

  static Future xfileUploadMp4(
      {XFile? file,
      String position = 'head',
      CancelToken? cancelToken,
      ProgressCallback? progressCallback}) async {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var videoKey = AppGlobal.uploadMp4Key.replaceFirst('head', '');
      var newKey = '$timeStamp$videoKey';
      var sign = Utils.toMD5(newKey);
      var imageName = Utils.toMD5(timeStamp);

      var filename = '$imageName.mp4';
      FormData formData = FormData.fromMap({
        'timestamp': timeStamp,
        'uuid': '9544f11ed4381ebcef5429b6f20e69c1',
        'sign': sign,
        'video': await MultipartFile.fromFile(
          file?.path ?? "",
          filename: filename,
          contentType: MediaType.parse('video/mp4'),
        ),
      });
      Response response = await _uploadDio.post(AppGlobal.uploadMp4Url,
          data: formData,
          onSendProgress: progressCallback,
          cancelToken: cancelToken,
          options: Options(contentType: 'multipart/form-data'));
      return response.data;
    } catch (e) {
      Utils.log(e);
      return null;
    }
  }

  // 小说获取
  static Future getNovel(url) async {
    return kIsWeb
        ? html.HttpRequest.request(url, responseType: 'arraybuffer')
            .then((xhr) {
            if (xhr.response != null) {
              ByteBuffer bb = xhr.response;
              return utf8.decode(bb.asUint8List());
            }
            return '';
          }).onError((error, stackTrace) => '')
        : _novelDio.get(url).then((res) {
            print('object');
            // return res.data;
            return utf8.decode(res.data);
          }).onError((error, stackTrace) {
            print('');
            return '';
          });
  }

  //post请求
  static Future post(String path, {Map? data, CancelToken? cancelToken}) {
    // String api = (AppGlobal.replaceHostIp?.parse(AppGlobal.apiBaseURL) ??
    //         AppGlobal.apiBaseURL) +
    //     path;
    Utils.log("request url: ${AppGlobal.apiBaseURL + path}");
    return apiDio.post(
      AppGlobal.apiBaseURL + path,
      data: data,
      cancelToken: cancelToken,
    );
  }

  //get请求
  static Future get(String url) {
    Utils.log("request url: $url");
    return Dio().get(url);
  }

  static Future<Response> download(String urlPath, String savePath,
      {ProgressCallback? onReceiveProgress}) {
    return _uploadDio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
