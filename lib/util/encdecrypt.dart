import 'dart:convert';
import 'dart:typed_data';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:crypto/crypto.dart';
import 'package:deepseek/util/utils.dart';
import 'package:encrypt/encrypt.dart';
import 'package:convert/convert.dart';

final key = Key.fromUtf8("e6400bae034c60fb");
final iv = IV.fromUtf8("6a0c917b9f7149f5");
const appkey = "b9b6cb49e0cd7195a08ca6a05f971950";

final novelKey = Key.fromUtf8("f5d965df75336270");
final novelIv = IV.fromUtf8("97b60394abc2fbe1");

final mediaKey = Key.fromUtf8("f5d965df75336270");
final mediaIv = IV.fromUtf8("97b60394abc2fbe1");

const secretKey = '0cd8091ddd83a5a8';
const secretIv = 'c5546fcdd6f004b2';

class EncDecrypt {
  //签名
  static String toSign(Map obj) {
    String md5Text;
    List keyValues = [];
    keyValues.add("client=${obj['client']}");
    keyValues.add("data=${obj['data']}");
    keyValues.add("timestamp=${obj['timestamp']}");
    String text = '${keyValues.join('&')}$appkey';
    Digest _digest = sha256.convert(utf8.encode(text));
    md5Text = md5.convert(utf8.encode(_digest.toString())).toString();
    return md5Text;
  }

  static Future<dynamic> encryptReqParams(String word, String client) async {
    Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    Encrypted encrypted = encrypter.encryptBytes(utf8.encode(word), iv: iv);
    String data = utf8.decode(encrypted.base64.codeUnits);
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String sign =
        toSign({"client": client, "data": data, "timestamp": timestamp});
    return "client=$client&timestamp=$timestamp&data=$data&sign=$sign";
  }

  static Future<String> decryptResData(dynamic data) async {
    Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    Encrypted encrypted = Encrypted.fromBase64(data['data']);
    String decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  //获取小说
  static Future<String> decryptNovel(String url) async {
    dynamic base64 = await NetworkHttp.getNovel(url);
    if (base64 != null) {
      dynamic decrypted = decryptText(base64);
      if (decrypted is List<int> && decrypted.isNotEmpty) {
        // decrypted = base64Decode(decrypted);
        String data = utf8.decode(decrypted);
        return data;
      }
    }
    return "";
  }

  static Uint8List? decryptText(data) {
    try {
      Encrypter encrypter = Encrypter(AES(novelKey, mode: AESMode.cbc));
      Encrypted encrypted = Encrypted.fromBase64(data);
      // final stopwatch = Stopwatch()..start();
      List<int> decrypted = encrypter.decryptBytes(encrypted, iv: novelIv);
      return Uint8List.fromList(decrypted);
    } catch (err) {
      Utils.log(err);
      return null;
    }
  }

  static Uint8List? decryptImage(data) {
    try {
      Encrypter encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
      Encrypted encrypted = Encrypted.fromBase64(base64Encode(data));
      // final stopwatch = Stopwatch()..start();
      List<int> decrypted = encrypter.decryptBytes(encrypted, iv: mediaIv);
      return Uint8List.fromList(decrypted);
    } catch (err) {
      Utils.log(err);
      return null;
    }
  }

  static dynamic decryptM3U8(data) {
    try {
      Encrypter encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
      Encrypted encrypted = Encrypted.fromBase64(data);
      // final stopwatch = Stopwatch()..start();
      String decrypted = encrypter.decrypt(encrypted, iv: mediaIv);
      return decrypted;
    } catch (err) {
      return null;
    }
  }

  static String toSha256(String data) {
    var content = const Utf8Encoder().convert(data);
    var digest = sha256.convert(content);
    var text = hex.encode(digest.bytes);
    return text;
  }

  static String encry(plainText) {
    try {
      final encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: mediaIv);
      return encrypted.base16;
    } catch (err) {
      Utils.log("aes encode error:$err");
      return plainText;
    }
  }

  static String decry(encrypted) {
    try {
      final encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt16(encrypted, iv: mediaIv);
      return decrypted;
    } catch (err) {
      Utils.log("aes decode error:$err");
      return encrypted;
    }
  }

  static String secretValue({
    String fdsKey = '',
  }) {
    final key = EncDecrypt.decryptSecret(
        fdsKey.isEmpty ? AppGlobal.defaultFdsKey : fdsKey);
    final value = EncDecrypt.encryptSecret(key);
    return value;
  }

  static String decryptSecret(String data) {
    final encrypter =
        Encrypter(AES(Key.fromUtf8(secretKey), mode: AESMode.cbc));
    final encrypted = Encrypted.fromBase64(data);
    final decrypted = encrypter.decrypt(encrypted, iv: IV.fromUtf8(secretIv));
    return decrypted;
  }

  static String encryptSecret(String key) {
    final serect = key.split('_').first;
    final interval = int.tryParse(key.split('_').last) ?? 3600;
    final ct =
        (DateTime.now().millisecondsSinceEpoch / 1000 / interval).floor();
    final cal = (sha1.convert(utf8.encode(serect + ct.toString()))).toString();
    final sha = sha1.convert(utf8.encode(serect + cal));
    final str = md5.convert(utf8.encode(sha.toString())).toString();
    return str.substring(0, 16);
  }

  //IM加密专用
  static Future<String> encryptReqParamsWithKey(
      String word, String key, String iv) async {
    Encrypter encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
    Encrypted encrypted =
        encrypter.encryptBytes(utf8.encode(word), iv: IV.fromUtf8(iv));
    String data = utf8.decode(encrypted.base64.codeUnits);
    return data;
  }

  //IM解密专用
  static Future<String> decryptResDataWithKey(
    dynamic data,
    String key,
    String iv,
  ) async {
    Encrypter encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
    Encrypted encrypted = Encrypted.fromBase64(data['data']);
    String decrypted = encrypter.decrypt(encrypted, iv: IV.fromUtf8(iv));
    return decrypted;
  }
}
