import 'dart:ui' as ui;
import 'dart:js_interop';
import 'package:deepseek/util/cache/cache_manager.dart';
import 'package:deepseek/util/cache/image_decrypt.dart';
import 'package:web/web.dart' as web;
import 'dart:async';
import 'package:flutter/painting.dart';
import 'dart:typed_data';

Future<ui.Codec> imageLoadAsync(
  NetworkImage key,
  String cacheKey,
  StreamController<ImageChunkEvent> chunkEvents,
  Future<ui.Codec> Function(Uint8List buffer) decode,
  String hivePath,
  String boxKey,
) async {
  try {
    final Uri resolved = Uri.base.resolve(key.url);

    final Completer<web.XMLHttpRequest> completer =
        Completer<web.XMLHttpRequest>();
    final web.XMLHttpRequest request = web.XMLHttpRequest();

    request.open('GET', key.url, true);
    request.responseType = 'arraybuffer';

    request.addEventListener(
        'load',
        (web.Event e) {
          final int status = request.status;
          final bool accepted = status >= 200 && status < 300;
          final bool fileUri = status == 0;
          final bool notModified = status == 304;
          final bool unknownRedirect = status > 307 && status < 400;
          final bool success =
              accepted || fileUri || notModified || unknownRedirect;

          if (success) {
            completer.complete(request);
          } else {
            completer.completeError(e);
            throw NetworkImageLoadException(statusCode: status, uri: resolved);
          }
        }.toJS);

    request.addEventListener(
        'error', ((JSObject e) => completer.completeError(e)).toJS);

    request.send();

    await completer.future;

    final Uint8List bytes =
        (request.response! as JSArrayBuffer).toDart.asUint8List();

    if (bytes.lengthInBytes == 0) {
      throw NetworkImageLoadException(
          statusCode: request.status, uri: resolved);
    }
    final decrypted = await imageDecrypt(bytes);
    await CacheManager.image.cache.upsert(cacheKey, decrypted);

    return decode(decrypted);
  } catch (e) {
    scheduleMicrotask(() {
      PaintingBinding.instance.imageCache.evict(key);
    });
    rethrow;
  } finally {
    chunkEvents.close();
  }
}

Future<Uint8List> downImageLoadAsync(String url, String cacheKey) async {
  try {
    final Uri resolved = Uri.base.resolve(url);

    final Completer<web.XMLHttpRequest> completer =
        Completer<web.XMLHttpRequest>();
    final web.XMLHttpRequest request = web.XMLHttpRequest();

    request.open('GET', url, true);
    request.responseType = 'arraybuffer';

    request.addEventListener(
        'load',
        (web.Event e) {
          final int status = request.status;
          final bool accepted = status >= 200 && status < 300;
          final bool fileUri = status == 0;
          final bool notModified = status == 304;
          final bool unknownRedirect = status > 307 && status < 400;
          final bool success =
              accepted || fileUri || notModified || unknownRedirect;

          if (success) {
            completer.complete(request);
          } else {
            completer.completeError(e);
            throw NetworkImageLoadException(statusCode: status, uri: resolved);
          }
        }.toJS);

    request.addEventListener(
        'error', ((JSObject e) => completer.completeError(e)).toJS);

    request.send();

    await completer.future;

    final Uint8List bytes =
        (request.response! as JSArrayBuffer).toDart.asUint8List();

    if (bytes.lengthInBytes == 0) {
      throw NetworkImageLoadException(
          statusCode: request.status, uri: resolved);
    }
    final decrypted = await imageDecrypt(bytes);
    return decrypted;
  } catch (e) {
    rethrow;
  } finally {}
}
