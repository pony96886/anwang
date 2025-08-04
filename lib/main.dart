import 'dart:io';

import 'package:deepseek/ai/ai_chat_notifier.dart';
import 'package:deepseek/util/cache/cache_manager.dart';
import 'package:android_id/android_id.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/go_routers.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
// import "package:universal_html/js.dart" as js;
import 'package:deepseek/util/platform_utils_native.dart'
if (dart.library.html) 'package:deepseek/util/platform_utils_web.dart' as ui;

void main() async {
  ui.platformViewRegistry.disableUrlStrategy();
  //让初始化执行完再执行下一步
  await _initData();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BaseStore()),
      ChangeNotifierProxyProvider<BaseStore, AIChatNotifier?>(
        lazy: false,
        update: (context, value, previous) {
          if (value.user == null) {
            return null;
          }
          return previous?.user.uuid == value.user?.uuid
              ? previous!
              : AIChatNotifier(user: value.user!);
        },
        create: (BuildContext context) => null,
      ),
    ],
    child: const deepseekPage(),
  ));
  Utils.setStatusBar(isLight: false);
}

Future<void> _initData() async {
  await CacheManager.instance.init();
  // 初始化APP基础信息
  AppGlobal.apiToken = AppGlobal.appBox?.get('deepseek_token') ?? "";
  // final bool isSafari = js.context.callMethod("checkSafari") as bool;
  String? authid = AppGlobal.appBox?.get('oauth_id');
  authid = authid == null
      ? Utils.toMD5(
          '${Utils.randomId(16)}_${DateTime.now().millisecondsSinceEpoch.toString()}')
      : authid;
  AppGlobal.appinfo = {
    // "oauth_id": isSafari
    //     ? Utils.toMD5(AppGlobal.appBox?.get('oauth_id') ??
    //         '${Utils.randomId(16)}_${DateTime.now().millisecondsSinceEpoch.toString()}')
    //     : (AppGlobal.appBox?.get('oauth_id') ??
    //         Utils.toMD5(
    //             '${Utils.randomId(16)}_${DateTime.now().millisecondsSinceEpoch.toString()}')),
    "oauth_id": authid,
    "bundleId": "com.pwa.deepseek",
    "version": "1.1.0",
    "oauth_type": "web",
    "language": 'zh',
    "via": 'pwa',
  };
  //设备ID统一32位
  if (!kIsWeb) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      const androidIdPlugin = AndroidId();
      final unique = await androidIdPlugin.getId();
      String idmd5 = unique == null ? authid : Utils.toMD5(unique);
      AppGlobal.appinfo = {
        "oauth_id": idmd5,
        "bundleId": packageInfo.packageName,
        "version": packageInfo.version,
        "oauth_type": "android",
        // "build_affcode": "",
      };
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final unique = iosInfo.identifierForVendor;
      String idmd5 = unique == null ? authid : Utils.toMD5(unique);
      AppGlobal.appinfo = {
        "oauth_id": idmd5,
        "bundleId": packageInfo.packageName,
        "version": "1.1.0",
        "oauth_type": "ios",
      };
    }
  } else {
    AppGlobal.appBox?.put('oauth_id', AppGlobal.appinfo['oauth_id']);
  }

  //本地JSON初始化
  await Utils.loadJSON();

  //初始化路由
  AppGlobal.appRouter = GoRouters.init();

  //test doh
  // if (kIsWeb) return;
  // final hostMap = {
  //   'www.baidu.com': '112.80.248.75',
  // };
  // AppGlobal.port = 4041;
  // AppGlobal.proxy = CustomHttpsProxy(hosts: hostMap, port: AppGlobal.port);
  // AppGlobal.isProxy = (await AppGlobal.proxy?.init()) != null;
  // Utils.log("open proxy : ${AppGlobal.isProxy}");
  // NetworkHttp.setProxy();

  //method 2
  // if (kIsWeb) return;
  // Utils.log(AppGlobal.replaceHostIp);
  // await AppGlobal.replaceHostIp?.init();
  // // AppGlobal.replaceHostIp?.addHostIp("www.a.shifen.com.", "153.3.238.102");
  // AppGlobal.replaceHostIp?.addHostIp("api1.chgapi2.com", "104.21.79.143");
}

class deepseekPage extends StatelessWidget {
  const deepseekPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: kIsWeb ? 430 : double.infinity,
            ),
            child: ScreenUtilInit(
              designSize: const Size(375, 667),
              builder: (context, child) => MaterialApp.router(
                localeListResolutionCallback: (locales, supportedLocales) {
                  return const Locale('zh');
                },
                localeResolutionCallback: (locale, supportedLocales) {
                  return const Locale('zh');
                },
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('zh', 'CH'),
                  Locale('en', 'US'),
                ],
                debugShowCheckedModeBanner: false,
                builder: (context, widget) {
                  widget = botToastBuilder(context, widget);
                  widget = MediaQuery(
                    //设置文字大小不随系统设置改变
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: widget,
                  );
                  return widget;
                },
                title: Utils.txt("apbt"),
                theme: ThemeData(
                  colorScheme: const ColorScheme.dark(
                      surface: Color.fromRGBO(52, 136, 255, 1)),
                  // const ColorScheme.dark(surface: Colors.white),
                  scaffoldBackgroundColor: StyleTheme.bgColor,
                  primarySwatch: const MaterialColor(
                    0xFF000000, //
                    <int, Color>{
                      50: Color(0xFF000000),
                      100: Color(0xFF000000),
                      200: Color(0xFF000000),
                      300: Color(0xFF000000),
                      400: Color(0xFF000000),
                      500: Color(0xFF000000),
                      600: Color(0xFF000000),
                      700: Color(0xFF000000),
                      800: Color(0xFF000000),
                      900: Color(0xFF000000),
                    },
                  ),
                ),
                routeInformationParser:
                    AppGlobal.appRouter!.routeInformationParser,
                routerDelegate: AppGlobal.appRouter!.routerDelegate,
                routeInformationProvider:
                    AppGlobal.appRouter!.routeInformationProvider,
              ),
            )),
      );
    });
  }
}
