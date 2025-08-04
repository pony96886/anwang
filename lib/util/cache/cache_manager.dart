import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/cache/cache.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  CacheManager._internal();
  factory CacheManager() => instance;
  static final CacheManager instance = CacheManager._internal();

  static ImageCacheManager get image => ImageCacheManager.instance;

  late final ICache chatBox;

  bool _isInitialized = false;
  String get _imageKey => 'deepseekbox_ImageCache';
  String get _imageSalt => 'MxqtSeXnRz';

  final _fdsKey = 'fds_key';

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    // 初始化数据库，必须放在最前面
    await ImageCacheManager.instance.init(_imageKey, salt: _imageSalt); //图片缓存
    AppGlobal.appBox = await Hive.openBox('deepseekbox'); // 用于存储一些简单的键值对
    AppGlobal.mediaReadingRecordBox =
        await Hive.openBox('deepseek_media_record_box'); // 用于存储小说漫画阅读进度

    // AppGlobal.chatBox = await Hive.openBox('deepseekchatbox'); // 用于chat

    chatBox = HiveBoxCache(await Hive.openLazyBox('deepseekchatbox'));
  }

  Future<String?> readFdsKey() async =>
      (await AppGlobal.appBox?.get(_fdsKey))?.toString();

  Future<void>? upsertFdsKey(String value) =>
      AppGlobal.appBox?.put(_fdsKey, value);

  Future<String> readAIChats({required String key}) async {
    if (await chatBox.read(key) case final data?) {
      return data;
    }
    return '';
  }

  Future<void> upsertAIChats({required String chats, required String key}) =>
      chatBox.upsert(key, chats);
}
