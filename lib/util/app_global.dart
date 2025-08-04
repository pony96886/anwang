// ignore_for_file: non_constant_identifier_names
import 'package:deepseek/base/custom_https_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
// import 'package:replace_host_ip/replace_host_ip.dart';

class AppGlobal {
  //全局路由实例
  static GoRouter? appRouter;
  static bool isRegisterJs = false;

  // static bool isProxy = false;
  // static CustomHttpsProxy? proxy;
  // static int port = 4041;
  // static ReplaceHostIp? replaceHostIp = kIsWeb ? null : ReplaceHostIp();

  static bool isPostVideoURL = false;
  static bool isPostImgURL = false;

  static Map<String, dynamic> appinfo = {};
  static String apiBaseURL = "";

  static String defaultFdsKey =
      'P/D/+MulHay6Jzah0AnECON76PVOS4idWjlv/W9FmBnsXsGE+wXTI/uP4UpmvvPD';

  static List<String> apiLines = kIsWeb
      ? [
          'https://wapi.ai11.me/api.php',
        ]
      : [
          'https://api1.ai11.me/api.php',
          'https://api2.ai11.me/api.php',
          'https://api3.ai11.me/api.php',
        ];

  static String gitLine =
      "https://raw.githubusercontent.com/ailiu258099-blip/master/main/deepseek_app.txt";

  static List<String> fdsKeyApi = [
    'https://wvseee.jsbacjr.com/fds.txt',
    'https://gitee.com/fdsaw/ffewelmcxww/raw/master/hj.txt',
  ];

  static String uploadImgUrl = "";
  static String uploadImgKey = "";
  static String imgBaseUrl = "";
  static String uploadMp4Url = "";
  static String uploadMp4Key = "";
  static String apiToken = "";

  static Box? appBox;
  static Box? imageCacheBox;

  static Box? mediaReadingRecordBox;

  static Map? mediaMap;

  static int vipLevel = 0;
  static BuildContext? context;

  static String m3u8_encrypt = "0";

  static int maxLines = 1000; //纯txt最大行
  static String rules = ""; //上传规则

  // 约炮gilr class 类型
  static List girlClassList = [];

  // 短视频带入的信息 list index api 等
  static Map shortVideosInfo = {'list': [], 'page': 0, 'index': 0, 'api': ''};
}
