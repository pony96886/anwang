// ignore_for_file: prefer_function_declarations_over_variables, prefer_final_fields

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:deepseek/util/cache/cache_manager.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/marquee.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:common_utils/common_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vibration/vibration.dart';

final logger = SimpleLogger();

class Utils {
  static Map _cacheJSON = {}; //全局使用
  //字符串转MD5
  static String toMD5(String data) {
    return EncryptUtil.encodeMd5(data);
  }

  //Safari浏览器
  static bool isSafariBrowser() {
    if (kIsWeb) {
      final ua = html.window.navigator.userAgent.toLowerCase();
      return ua.contains('iphone') &&
          ua.contains('safari') &&
          !ua.contains('crios') && // Chrome on iOS
          !ua.contains('fxios') && // Firefox on iOS
          !ua.contains('edg') && // Edge (new)
          !ua.contains('qqbrowser') && // QQ
          !ua.contains('micromessenger') && // wechat on ios
          !ua.contains('360browser') && // 360 on ios
          !ua.contains('baidubrowser') && // baidu on ios
          !ua.contains('huawei') && // hauwei on ios
          !ua.contains('miuibrowser') && // xaiomi on ios
          !ua.contains('quark') && // quark on ios
          !ua.contains('sogoumobilebrowser') && // sogo on ios
          !ua.contains('maxthon') && // aoyou on ios
          !ua.contains('cheetahbrowser') && // Cheetah on ios
          !ua.contains('ucbrowser'); // Uc on iOS
    }
    return false;
  }

  //苹果浏览器
  static bool isIPhoneWeb() {
    if (kIsWeb) {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      return userAgent.contains("iphone") || userAgent.contains("ipad");
    }
    return false;
  }

  //安卓浏览器
  static bool isAndroidWeb() {
    if (kIsWeb) {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      return userAgent.contains("android");
    }
    return false;
  }

  //下载APP
  static Future<void> downLoadApp(BuildContext context) async {
    String site =
        Provider.of<BaseStore>(context, listen: false).conf?.pwaDownloadUrl ??
            '';
    String apk =
        Provider.of<BaseStore>(context, listen: false).conf?.versionMsg?.apk ??
            '';
    Uri u = Uri.parse(html.window.location.href);
    String aff = u.queryParameters['dpk_aff'] ?? "";

    if (isIPhoneWeb()) {
      if (isSafariBrowser()) {
        await launchUrl(
            Uri.parse('$site/index.php/index/mobileConfig?aff_code=$aff'),
            webOnlyWindowName: '_self');
        await Future.delayed(const Duration(seconds: 2));
        bool flag = await launchUrl(
            Uri.parse('$site/js/embedded.mobileprovision?v=1'),
            webOnlyWindowName: '_self');
        if (!flag) {
          Utils.showDialog(
            setContent: () {
              return Text(
                Utils.txt("azbz"),
                style: StyleTheme.font_gray_150_14_medium,
                maxLines: 5,
                textAlign: TextAlign.center,
              );
            },
          );
        }
      } else {
        Utils.showDialog(
          setContent: () {
            return Text(
              Utils.txt("qsyxz"),
              style: StyleTheme.font_gray_150_14_medium,
              maxLines: 5,
              textAlign: TextAlign.center,
            );
          },
        );
      }
      return;
    }

    if (isAndroidWeb()) {
      copyToClipboard("dpk_aff:$aff", showToast: false);
      html.window.open(apk, "_blank"); //兼容所有浏览器下载
      return;
    }

    //其他浏览器直接去官网下载
    html.window.open(site, "_blank");
  }

  //通用剪切板
  static void copyToClipboard(String text,
      {bool showToast = true, String tip = ""}) {
    if (kIsWeb) {
      final tempTextArea = html.TextAreaElement();
      tempTextArea.value = text;
      html.document.body!.append(tempTextArea);
      tempTextArea.select();
      html.document.execCommand('copy');
      tempTextArea.remove();
    } else {
      Clipboard.setData(ClipboardData(text: text));
    }
    if (showToast) Utils.showText(tip.isEmpty ? Utils.txt('fzcgqxz') : tip);
  }

  //随机字符串
  static String randomId(int range) {
    String str = "";
    List<String> arr = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    for (int i = 0; i < range; i++) {
      int pos = Random().nextInt(arr.length - 1);
      str += arr[pos];
    }
    return str;
  }

  //选择图片
  static Future<XFile?> pickerImageAssets({ImagePicker? picker}) async {
    final XFile? file = await picker?.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.pngLimitSize(file);
      if (flag) return null;
      return file;
    }
    return null;
  }

  //选择视频
  static Future<Object?> pickerVideoAssets({ImagePicker? picker}) async {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()
        ..accept = 'video/*'
        ..multiple = false
        ..style.display = 'none';
      html.document.body?.append(input);
      input.click();
      await input.onChange.first;
      final file = input.files?.first;
      BotToast.closeAllLoading();
      if (file != null) {
        bool flag = Utils.videoLimitSizeHtml(file);
        if (!flag) {
          String ext = file.type.toLowerCase();
          if (ext == "video/mp4" || ext == 'video/quicktime') {
            return file;
          } else {
            Utils.showText(Utils.txt("qxzmpf"));
            return null;
          }
        }
        return null;
      }
      return null;
    } else {
      final XFile? file = await picker?.pickVideo(source: ImageSource.gallery);
      if (file != null) {
        bool flag = await Utils.videoLimitSize(file);
        if (!flag) {
          String ext = file.name.split(".").last.toLowerCase();
          if (ext == "mp4" || file.mimeType == 'video/quicktime') {
            return file;
          } else {
            Utils.showText(Utils.txt("qxzmpf"));
            return null;
          }
        }
        return null;
      }
      return null;
    }
  }

  //html.file限制视频大小
  static bool videoLimitSizeHtml(html.File file, {int size = 2048}) {
    int length = file.size;
    if (length / (1024 * 1024) > size) {
      Utils.showText(Utils.txt("qxzbmbv"));
      return true;
    }
    return false;
  }

  //xfile限制视频大小
  static Future<bool> videoLimitSize(XFile file, {int size = 2048}) async {
    int length = await file.length();
    if (length / (1024 * 1024) > size) {
      Utils.showText(Utils.txt("qxzbmbv").replaceAll("2048", size.toString()));
      return true;
    }
    return false;
  }

  //xfile限制图片大小
  static Future<bool> pngLimitSize(XFile file) async {
    bool isImage(XFile f) {
      final mimeType = kIsWeb ? f.mimeType : lookupMimeType(f.path);
      return mimeType == "image/png" ||
          mimeType == "image/jpeg" ||
          mimeType == "image/jpg";
    }

    if (!isImage(file)) {
      Utils.showText(Utils.txt("qxztpgs"));
      return true;
    }
    int length = await file.length();
    if (length / 1024 > 1024 * 5) {
      Utils.showText(Utils.txt("qxzbkbp"));
      return true;
    }
    return false;
  }

  //初始化加载本地JSON
  static Future<void> loadJSON() async {
    if (_cacheJSON.isEmpty) {
      ByteData data = await rootBundle.load("assets/file/ext.json");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      _cacheJSON = jsonDecode(utf8.decode(bytes));
    }
  }

  //加载本地文字
  static String txt(String key) {
    return _cacheJSON[key] ?? "未知";
  }

  //自定义输入框
  static InputDecoration customInputStyle({
    String? hit,
    TextStyle? style,
    double horizontal = 8,
    double vertical = 0,
  }) {
    //边框
    OutlineInputBorder outline() {
      return OutlineInputBorder(
          borderRadius: BorderRadius.circular(0.0),
          borderSide: const BorderSide(color: Colors.transparent, width: 0));
    }

    return InputDecoration(
      hintText: hit ?? Utils.txt('qtxxbt'),
      hintStyle: style ?? StyleTheme.font_black_7716_04_14,
      contentPadding:
          EdgeInsets.symmetric(horizontal: horizontal.w, vertical: vertical.w),
      disabledBorder: outline(),
      focusedBorder: outline(),
      border: outline(),
      enabledBorder: outline(),
    );
  }

  //设置状态栏颜色
  static setStatusBar({bool isLight = true, bool isLanch = true}) {
    if (kIsWeb) {
      return SystemChrome.setSystemUIOverlayStyle(
          isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    } else if (Platform.isAndroid) {
      if (isLanch) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //全局设置透明
        statusBarIconBrightness: isLight ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.black,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    } else if (Platform.isIOS) {
      if (isLanch) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
      //导航栏状态栏文字颜色
      SystemChrome.setSystemUIOverlayStyle(
          isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    }
  }

  static var _isDebug = !(const bool.fromEnvironment("dart.vm.product"));

  //日志输出
  static log(dynamic object) {
    if (_isDebug) {
      logger.formatter = (info) => 'INFO: ${info.message}';
      logger.info(object);
    }
  }

  static Widget memberVip(
    String value, {
    double h = 16,
    int fontsize = 10,
    double margin = 0,
  }) {
    return value.isEmpty
        ? Container()
        : Container(
            height: h.w,
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            margin: EdgeInsets.only(right: margin.w),
            decoration: BoxDecoration(
                gradient: StyleTheme.gradBlue,
                borderRadius: BorderRadius.all(Radius.circular(3.w))),
            child: Center(
                child: Text(value, style: StyleTheme.font(size: fontsize))),
          );
  }

  //视频模块UI复用
  static Widget videoModuleUI(BuildContext context, dynamic data,
      {double imageRatio = 171 / 96,
      bool replace = false,
      int maxLine = 1,
      bool noRadius = false}) {
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data);
    }
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, '/homevideodetailpage/${data["id"]}',
              replace: replace);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: _w / imageRatio,
                    child: ImageNetTool(
                        url: getPICURL(data),
                        radius: noRadius
                            ? BorderRadius.zero
                            : BorderRadius.all(Radius.circular(5.w))),
                  ),
                  Positioned.fill(
                      child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        height: 36.w,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0.7),
                              Color.fromRGBO(0, 0, 0, 0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 15.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${Utils.renderFixedNumber(data["play_ct"] ?? 0)}${Utils.txt('cbf')}",
                                    style: StyleTheme.font_white_255_11),
                                const Spacer(),
                                Text(
                                    "${Utils.getHMTime(data["duration"] ?? 0)}",
                                    style: StyleTheme.font_white_255_11),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )),
                ],
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              (data["title"] ?? ""),
                              style: StyleTheme.font_black_7716_14,
                              maxLines: 2,
                            )),
                        SizedBox(height: 5.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (data['created_at'] != null
                                  ? format(
                                      DateTime.parse(data["created_at"] ?? ""))
                                  : ''),
                              style: StyleTheme.font_gray_153_11,
                            ),
                            const Spacer(),
                            Text(
                              Utils.txt('pl') +
                                  ' ' +
                                  '${data['count_comment']}',
                              style: StyleTheme.font_gray_153_11,
                            ),
                            SizedBox(width: 5.w)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //视频模块UI复用2
  static Widget videoModuleUI2(
    BuildContext context,
    dynamic data, {
    double imageRatio = 171 / 96,
    bool replace = false,
    int maxLine = 1,
    bool noRadius = false,
    bool isCartoon = false,
  }) {
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data);
    }
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (isCartoon) {
            Utils.navTo(context, '/cartoondetailpage/${data["id"]}',
                replace: replace);
          } else {
            Utils.navTo(context, '/homevideodetailpage/${data["id"]}',
                replace: replace);
          }
        },
        child: Container(
          // color: Colors.red,
          // clipBehavior: Clip.hardEdge,
          // decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5.w),
          //     border: Border.all(
          //         color: StyleTheme
          //             .whiteColor, // const Color.fromRGBO(235, 235, 235, 0.9),
          //         width: 0.5.w)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: _w / imageRatio,
                    child: ImageNetTool(
                        url: getPICURL(data),
                        radius: noRadius
                            ? BorderRadius.zero
                            : BorderRadius.all(Radius.circular(5.w))),
                  ),
                  Positioned.fill(
                      child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        height: 36.w,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0.7),
                              Color.fromRGBO(0, 0, 0, 0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 15.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${Utils.renderFixedNumber(isCartoon ? data["view_fct"] : data["play_ct"] ?? 0)}${Utils.txt('cbf')}",
                                    style: StyleTheme.font_white_255_11),
                                const Spacer(),
                                Text(
                                    "${Utils.getHMTime(data["duration"] ?? 0)}",
                                    style: StyleTheme.font_white_255_11),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )),
                ],
              ),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              (data["title"] ?? ""),
                              style: StyleTheme.font_black_7716_14,
                              maxLines: 1,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget contentWidget(
    BuildContext context,
    dynamic data, {
    Function? showAlert,
    Function? like, //点赞
    Function? collect, //收藏
    Function? comment, //评论
    Function? follow, //关注
    Function? enterUserCenter, //进用户空间
    bool keepBottomBlank = false,
  }) {
    Widget dgt = Container();

    // "ktvgkwza": "开通VIP观看完整视频 a",
    // "zfajbjsspb": "支付a金币解锁完整视频 b",
    var vflag = false;
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    if (user == null) return dgt;
    if (data['source_240'].toString().isEmpty) {
      if (user.vip_level! < 1 && data['isfree'] == 1) {
        //需要VIP
        dgt = Container(
          // height: 20.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
          decoration: BoxDecoration(
            color: StyleTheme.red253Color,
            // gradient: StyleTheme.gradBlue,
            borderRadius: BorderRadius.circular(10.0.w),
          ),
          child: Text(
            Utils.txt('ktvgkwza')
                .replaceAll('a', '${Utils.getHMTime(data["duration"] ?? 0)}'),
            style: StyleTheme.font_white_255_12.toHeight(1),
          ),
        );

        vflag = true;
      } else if (data['isfree'] == 2) {
        // 创建一个TextPainter对象
        TextPainter textPainter = TextPainter(
          textDirection: TextDirection.ltr,
        );
        String tempStr = "${data['coins'] ?? 0}" + Utils.txt('jbgm');
        // 设置文本样式
        textPainter.text = TextSpan(
          text: tempStr,
          style: StyleTheme.font_black_31_11,
        );
        // 布局文本
        textPainter.layout();
        // 获取文本宽度
        double textWidth = textPainter.size.width + 20;

        dgt = Container(
          // height: 20.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
          decoration: BoxDecoration(
            gradient: StyleTheme.gradOrange,
            borderRadius: BorderRadius.circular(10.0.w),
          ),
          child: Text(
            Utils.txt('zfajbjsspb')
                .replaceAll('a', '${data['coins'] ?? 0}')
                .replaceAll('b', '${Utils.getHMTime(data["duration"] ?? 0)}'),
            style: StyleTheme.font_white_255_12.toHeight(1.2),
          ),
        );

        vflag = true;
      }
    }
    return Positioned(
      left: 15.w,
      right: 10.w,
      bottom: kIsWeb
          ? 20.w +
              (keepBottomBlank ? (StyleTheme.botHegiht + StyleTheme.bottom) : 0)
          : (keepBottomBlank
              ? (StyleTheme.botHegiht + StyleTheme.bottom)
              : 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                '${data["member"]?["nickname"] ?? ""}'.isEmpty
                    ? Container()
                    : Text(
                        "@${data["member"]?["nickname"] ?? ""}",
                        style: TextStyle(
                          color: StyleTheme.whiteColor,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(color: Colors.black54, offset: Offset(1, 1))
                          ],
                        ),
                      ),
                SizedBox(height: 7.5.w),
                Text("${data["title"] ?? ""}",
                    style: TextStyle(
                      color: StyleTheme.whiteColor,
                      fontSize: 15.sp,
                      shadows: const [
                        Shadow(color: Colors.black54, offset: Offset(1, 1))
                      ],
                    )),
                SizedBox(height: 7.5.w),
                List.from(data["tag_list"] ?? []).isNotEmpty
                    ? Wrap(
                        runSpacing: 5.w,
                        spacing: 5.w,
                        children: List.from(data["tag_list"])
                            .map(
                              (tag) => InkWell(
                                onTap: () {
                                  Utils.navTo(context,
                                      "/homesearchpage?searchStr=$tag&index=1");
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 3.w),
                                  decoration: BoxDecoration(
                                      color: StyleTheme.blackColor
                                          .withOpacity(0.3),
                                      borderRadius:
                                          BorderRadius.circular(10.w)),
                                  child: Text(
                                    '#' + tag,
                                    style: StyleTheme.font_white_255_12
                                        .toHeight(1),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : Container(),
                SizedBox(height: 7.5.w),
                vflag
                    ? GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showAlert?.call();
                        },
                        child: dgt,
                      )
                    : Container(),
                SizedBox(height: 7.5.w),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 40.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 46.w,
                  child: Stack(children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        enterUserCenter?.call();
                      },
                      child: data["member"] == null
                          ? Container(
                              decoration: BoxDecoration(
                                  color: StyleTheme.black45Color,
                                  borderRadius: BorderRadius.circular(18.w)),
                              width: 36.w,
                              height: 36.w,
                              child: Center(
                                child: LocalPNG(
                                  name: 'ai_app_placeholder',
                                  width: 36.w,
                                  height: 36.w,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 36.w,
                              height: 36.w,
                              child: ImageNetTool(
                                url: data["member"]?["thumb"] ?? "",
                                radius: BorderRadius.all(Radius.circular(18.w)),
                              ),
                            ),
                    ),
                    data["member"] == null
                        ? Container()
                        : (data["member"]?["is_follow"] ?? 0) == 1
                            ? Container()
                            : Positioned(
                                bottom: 3.w,
                                left: 12.w,
                                right: 14.w,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    follow?.call();
                                  },
                                  child: LocalPNG(
                                      name: "ai_vlog_follow",
                                      fit: BoxFit.fill,
                                      width: 13.w,
                                      height: 13.w),
                                )),
                  ]),
                ),
                SizedBox(height: 15.w),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    like?.call();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LocalPNG(
                          name: data['is_like'] == 1
                              ? "ai_vlog_like_on"
                              : "ai_vlog_like_off",
                          width: 28.w,
                          height: 28.w),
                      Text(
                        renderFixedNumber(
                            // 如果用户点赞了 但是 favorites == 0 就直接显示1
                            data['is_like'] == 1 && data['count_like'] == 0
                                ? 1
                                : data['count_like']),
                        style: StyleTheme.font_white_255_12,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.w),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    collect?.call();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LocalPNG(
                          name: data['is_favorite'] == 1
                              ? "ai_vlog_favorite_on"
                              : "ai_vlog_favorite_off",
                          width: 28.w,
                          height: 28.w),
                      Text(
                        renderFixedNumber(
                            // 如果用户点赞了 但是 favorites == 0 就直接显示1
                            data['is_favorite'] == 1 && data['favorites'] == 0
                                ? 1
                                : data['favorites']),
                        style: StyleTheme.font_white_255_12,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.w),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    comment?.call();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LocalPNG(
                          name: "ai_vlog_comment", width: 25.w, height: 25.w),
                      Text(
                        renderFixedNumber(data['count_comment']),
                        style: StyleTheme.font_white_255_12,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.w),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Utils.navTo(context, "/minesharepage");
                    },
                    child: Column(
                      children: [
                        LocalPNG(
                            name: "ai_vlog_share", width: 25.w, height: 25.w),
                        Text(
                          Utils.txt('fenx'),
                          style: StyleTheme.font_white_255_11,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 音频 模块UI复用
  static Widget audioGridModuleUI(BuildContext context, dynamic data,
      {double imageRatio = 171 / 96,
      bool replace = false,
      int maxLine = 1,
      bool noRadius = false}) {
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data);
    }
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, '/voiceplayerpage',
              extra: data, replace: replace);
        },
        child: Container(
          // clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.w),
            color: StyleTheme.whiteColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: _w / imageRatio,
                    child: ImageNetTool(
                        url: getPICURL(data),
                        radius: noRadius
                            ? BorderRadius.zero
                            : BorderRadius.all(Radius.circular(5.w))),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: LocalPNG(
                          name: 'ai_audio_list_play_large',
                          width: 26.w,
                          height: 26.w),
                      // Icon(Icons.list, color: Colors.white, size: 30.w),
                    ),
                  ),
                  Positioned(
                    right: 6.w,
                    top: 6.w,
                    child: LocalPNG(
                        name: 'ai_audio_list_playlist',
                        width: 15.w,
                        height: 12.w),
                    // Icon(Icons.list, color: Colors.white, size: 30.w),
                  ),
                  Positioned(
                    left: 6.w,
                    top: 6.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                      decoration: BoxDecoration(
                        gradient: data['type'] == 2
                            ? StyleTheme.gradOrange
                            : StyleTheme.gradBlue,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Text(
                          data['type'] == 2 ? '${data['coins']}金币' : 'VIP',
                          style: StyleTheme.font_white_255_10),
                    ),
                    // Icon(Icons.list, color: Colors.white, size: 30.w),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.5.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            (data["title"] ?? ""),
                            style: StyleTheme.font_black_7716_14,
                            maxLines: 1,
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${Utils.getHMTime(data["duration"] ?? 0)}",
                              style: StyleTheme.font_black_7716_04_10),

                          Spacer(),
                          Row(
                            children: [
                              LocalPNG(
                                name: 'ai_audio_list_collect',
                                width: 13.w,
                                height: 13.w,
                              ),
                              SizedBox(width: 2.w),
                              // Icon(Icons.star, color: Colors.white, size: 15.w),
                              Text(
                                  "${Utils.renderFixedNumber(data["favorite_fct"] ?? 0)}",
                                  style: StyleTheme.font_black_7716_04_10),
                            ],
                          ),
                          SizedBox(width: 10.w),
                          Row(
                            children: [
                              LocalPNG(
                                name: 'ai_audio_list_play',
                                width: 13.w,
                                height: 13.w,
                              ),
                              SizedBox(width: 2.w),
                              // Icon(Icons.play_circle_fill,
                              //     color: Colors.white, size: 15.w),
                              Text(
                                  "${Utils.renderFixedNumber(data["play_fct"] ?? 0)}",
                                  style: StyleTheme.font_black_7716_04_10),
                            ],
                          ),
                          // const Spacer(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 音频 模块UI复用
  static Widget audioListModuleUI(BuildContext context, dynamic data,
      {bool replace = false, int maxLine = 1, bool noRadius = false}) {
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data);
    }
    return Container(
      margin: EdgeInsets.only(bottom: 10.w),
      height: 70.w,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, '/voiceplayerpage',
              extra: data, replace: replace);
        },
        child: Container(
          decoration: BoxDecoration(
            color: StyleTheme.whiteColor,
            borderRadius: BorderRadius.circular(5.w),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 60.w,
                child: ImageNetTool(
                    url: getPICURL(data),
                    radius: noRadius
                        ? BorderRadius.zero
                        : BorderRadius.all(Radius.circular(5.w))),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            (data["title"] ?? ""),
                            style: StyleTheme.font_black_7716_15.toHeight(1),
                            maxLines: 1,
                          )),
                      // Column(children: [
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         '00:00:00',
                      //         style: StyleTheme.font_white_255_10,
                      //         maxLines: 1,
                      //       ),
                      //       Text(
                      //         '00:00:00',
                      //         style: StyleTheme.font_white_255_10,
                      //         maxLines: 1,
                      //       )
                      //     ],
                      //   ),
                      //   LinearProgressIndicator(
                      //       value: 0.5,
                      //       minHeight: 2.w,
                      //       backgroundColor: StyleTheme.white25502Color,
                      //       borderRadius: BorderRadius.circular(1.w),
                      //       valueColor: AlwaysStoppedAnimation(Colors.white)),
                      // ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text("${Utils.getHMTime(data["duration"] ?? 0)}",
                          //     style: StyleTheme.font_white_255_11),
                          Row(
                            children: [
                              // Icon(Icons.star, color: Colors.white, size: 15.w),

                              //  Text(
                              //     "${Utils.txt('fbsj')}：${Utils.format(DateTime.parse(data["created_at"] ?? ""))}",
                              //     style: StyleTheme.font_gray_95_12)
                              Text(
                                  "${Utils.format(DateTime.parse(data["created_at"] ?? ""))}",
                                  style: StyleTheme.font_black_7716_04_10),
                            ],
                          ),
                          Row(
                            children: [
                              LocalPNG(
                                name: 'ai_audio_list_collect',
                                width: 13.w,
                                height: 13.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                  "${Utils.renderFixedNumber(data["favorite_fct"] ?? 0)}",
                                  style: StyleTheme.font_black_7716_04_10),
                            ],
                          ),
                          Row(
                            children: [
                              LocalPNG(
                                name: 'ai_audio_list_play',
                                width: 13.w,
                                height: 13.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                  "${Utils.renderFixedNumber(data["play_fct"] ?? 0)}",
                                  style: StyleTheme.font_black_7716_04_10),
                            ],
                          ),

                          LocalPNG(
                              name: 'ai_audio_list_playlist_gray',
                              width: 15.w,
                              height: 12.w),
                          // Row(
                          //   children: [
                          //     Text(
                          //         "${Utils.renderFixedNumber(data["play_ct"] ?? 0)}",
                          //         style: StyleTheme.font_white_255_11),
                          //   ],
                          // ),
                          // Icon(Icons.list, color: Colors.white, size: 15.w),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              LocalPNG(
                  name: 'ai_audio_list_play_large', width: 32.w, height: 32.w),
              // Icon(Icons.play_circle_fill, color: Colors.white, size: 45.w),
            ],
          ),
        ),
      ),
    );
  }

  //漫画模块UI复用
  static Widget comicModuleUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 120 / 155,
    bool replace = false,
    int maxLine = 1,
    bool noRadius = false,
  }) {
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data);
    }
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, '/comicdetailpage/${data["id"]}',
              replace: replace);
        },
        child: Container(
          // color: Colors.red,
          // clipBehavior: Clip.hardEdge,
          // decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5.w),
          //     border: Border.all(
          //         color: StyleTheme
          //             .whiteColor, // const Color.fromRGBO(235, 235, 235, 0.9),
          //         width: 0.5.w)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: _w / imageRatio,
                    child: ImageNetTool(
                        url: getPICURL(data),
                        radius: noRadius
                            ? BorderRadius.zero
                            : BorderRadius.all(Radius.circular(5.w))),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              (data["title"] ?? ""),
                              style: StyleTheme.font_black_7716_14.toHeight(1),
                              maxLines: 2,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //游戏模块UI复用
  static Widget gameModuleUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 172 / 99,
    bool replace = false,
    int maxLine = 1,
    bool noRadius = false,
  }) {
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data);
    }
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, '/gamedetailpage/${data["id"]}',
              replace: replace);
        },
        child: Container(
          // color: Colors.red,
          // clipBehavior: Clip.hardEdge,
          // decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5.w),
          //     border: Border.all(
          //         color: StyleTheme
          //             .whiteColor, // const Color.fromRGBO(235, 235, 235, 0.9),
          //         width: 0.5.w)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: _w / imageRatio,
                    child: ImageNetTool(
                        url: getPICURL(data),
                        radius: noRadius
                            ? BorderRadius.zero
                            : BorderRadius.all(Radius.circular(5.w))),
                  ),
                  Positioned.fill(
                      child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        height: 35.w,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0.7),
                              Color.fromRGBO(0, 0, 0, 0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        // alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${Utils.renderFixedNumber(data['like_fct'])}' +
                                      Utils.txt('danzan'),
                                  style:
                                      StyleTheme.font_white_255_10.toHeight(1),
                                  maxLines: 1,
                                ),
                                Text(
                                  '${Utils.renderFixedNumber(data['pay_fct'])}' +
                                      Utils.txt('js'),
                                  style:
                                      StyleTheme.font_white_255_10.toHeight(1),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8.w,
                            )
                          ],
                        ),
                      )
                    ],
                  )),
                ],
              ),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              (data["title"] ?? ""),
                              style: StyleTheme.font_black_7716_14,
                              maxLines: 1,
                            )),
                        Builder(builder: (context) {
                          List tags = data['categories'].toString().split(',');
                          if (tags.length > 2) {
                            tags = tags.sublist(0, 2);
                          }
                          return Row(
                            children: tags
                                .map(
                                  (e) => Container(
                                    margin: EdgeInsets.only(right: 10.w),
                                    child: Text(
                                      e,
                                      style: StyleTheme.font_white_255_10
                                          .toColor(
                                              StyleTheme.blak7716_04_Color),
                                      maxLines: 1,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }),
                        // Align(
                        //     alignment: Alignment.topLeft,
                        //     child: Text(
                        //       (data["title"] ?? ""),
                        //       style: StyleTheme.font_black_7716_14,
                        //       maxLines: 1,
                        //     )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //小说模块List UI复用
  static Widget novelListModuleUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 91 / 118,
    bool replace = false,
    int maxLine = 1,
    bool noRadius = false,
  }) {
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adListUI(context, data);
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Utils.navTo(context, '/noveldetailpage/${data["id"]}',
            replace: replace);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: StyleTheme.margin),
        height: 91.w / imageRatio,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 91.w,
              height: 91.w / imageRatio,
              child: ImageNetTool(
                  url: getPICURL(data),
                  radius: noRadius
                      ? BorderRadius.zero
                      : BorderRadius.all(Radius.circular(5.w))),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Container(
                // margin: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  // mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // color: Colors.red,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (data["title"] ?? ""),
                            style: StyleTheme.font_black_7716_16_medium
                                .toHeight(1.2),
                            maxLines: 2,
                          ),
                          SizedBox(height: 7.w),
                          Text(
                            (data["intro"] ?? ""),
                            style:
                                StyleTheme.font_black_7716_06_12.toHeight(1.2),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Utils.renderFixedNumber(data['view_fct']) +
                              Utils.txt('cgk'),
                          style: StyleTheme.font_black_7716_06_12,
                        ),
                        Text(
                          (data['is_end'] == 1
                              ? Utils.txt("wj")
                              : Utils.txt("lzz")),
                          style: StyleTheme.font_blue52_12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //小说模块UI复用
  static Widget novelGridModuleUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 120 / 155,
    bool replace = false,
    int maxLine = 1,
    bool noRadius = false,
  }) {
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data);
    }
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, '/noveldetailpage/${data["id"]}',
              replace: replace);
        },
        child: Container(
          // color: Colors.red,
          // clipBehavior: Clip.hardEdge,
          // decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5.w),
          //     border: Border.all(
          //         color: StyleTheme
          //             .whiteColor, // const Color.fromRGBO(235, 235, 235, 0.9),
          //         width: 0.5.w)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: _w / imageRatio,
                    child: ImageNetTool(
                        url: getPICURL(data),
                        radius: noRadius
                            ? BorderRadius.zero
                            : BorderRadius.all(Radius.circular(5.w))),
                  ),
                  Positioned.fill(
                      child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        height: 30.w,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0.7),
                              Color.fromRGBO(0, 0, 0, 0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        // alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Utils.renderFixedNumber(data['view_fct']) +
                                      Utils.txt('gk'),
                                  style: StyleTheme.font_white_255_11,
                                ),
                                Text(
                                  (data['is_end'] == 1
                                      ? Utils.txt("wj")
                                      : Utils.txt("lzz")),
                                  style: StyleTheme.font_white_255_11,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4.w,
                            )
                          ],
                        ),
                      )
                    ],
                  )),
                ],
              ),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              (data["title"] ?? ""),
                              style: StyleTheme.font_black_7716_14,
                              maxLines: 1,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget novelChapter(dynamic chapter,
      {bool isCurrent = false, Function? func}) {
    return GestureDetector(
      onTap: () {
        func?.call();
      },
      child: SizedBox(
        height: 40.w,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        chapter['title'],
                        style: isCurrent
                            ? StyleTheme.font_blue52_14
                            : StyleTheme.font_black_7716_06_16,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Utils.isFreeBadge(chapter),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0.5.w,
              color: StyleTheme.devideLineColor,
            ),
          ],
        ),
      ),
    );
  }

  static Widget isFreeBadge(dynamic item) {
    Border? border;
    Color? bgColor;
    Gradient? grad;
    Widget ww;
    EdgeInsets padding;

    // item['type'] = 2;
    if (item['type'] == 0) {
      padding = EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w);
      // grad = StyleTheme.gradRed;
      border = Border.all(width: 1, color: StyleTheme.blue52Color);
      // bgColor =
      ww = Text(
        Utils.txt('manfei'),
        style: StyleTheme.font_blue_52_12.toHeight(1.2),
        textAlign: TextAlign.center,
      );
    } else if (item['type'] == 1) {
      padding = EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.w);
      // grad = StyleTheme.gradBlue;
      bgColor = StyleTheme.blue52Color;
      ww = Text(
        'VIP',
        style: StyleTheme.font_white_255_12,
        textAlign: TextAlign.center,
      );
    } else if (item['type'] == 2) {
      padding = EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 2.w);
      grad = StyleTheme.gradOrange;

      ww = FittedBox(
        fit: BoxFit.fitHeight,
        child: Text(
          Utils.renderFixedNumber(item['coins']) + Utils.txt('jinb'),
          style: StyleTheme.font_white_255_10,
          textAlign: TextAlign.center,
        ),
      );
      // ww = Row(
      //   children: [
      //     Text(
      //       Utils.renderFixedNumber(item['coins']) + Utils.txt('jinb'),
      //       style: StyleTheme.font_white_255_12,
      //     ),
      //     // SizedBox(width: 2.w),

      //     // Icon(Icons.money, color: Colors.white, size: 12.w),
      //     // LocalPNG(
      //     //   name: 'hls_icon_coin_small',
      //     //   width: 12.w,
      //     //   height: 12.w,
      //     // )
      //   ],
      // );
    } else {
      return Container();
    }
    return Container(
      width: 35.w, height: 16.w,
      // padding: padding,
      // margin: EdgeInsets.only(right: margin.w),
      decoration: BoxDecoration(
        gradient: grad,
        color: bgColor,
        border: border,
        borderRadius: BorderRadius.all(Radius.circular(2.w)),
      ),
      child: ww,
    );
  }

  //广告模块UI复用
  static Widget adListViewModuleUI(BuildContext context, dynamic data,
      {double imageRatio = 171 / 96, int maxLine = 1}) {
    return Container(
      height: 250.w,
      child: adModuleUI(context, data),
    );
  }

  //  短视频模块UI复用
  static Widget vlogModuleUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 167 / 238,
    bool replace = false,
    int maxLine = 1,
    bool noRadius = false,
    Function? onTapFunc,
  }) {
    //兼容提示
    data["type"] = data["isfree"];
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data,
          imageRatio: 167 / 238, maxLine: 1, isForLongVideo: false);
    }
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onTapFunc?.call();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: _w / imageRatio,
                  child: ImageNetTool(
                      url: getPICURL(data),
                      radius: noRadius
                          ? BorderRadius.circular(0)
                          : BorderRadius.circular(4.w)),
                ),
                Positioned.fill(
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        height: 36.w,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0.7),
                              Color.fromRGBO(0, 0, 0, 0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 15.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // LocalPNG(
                                //   name: 'hls_vlog_play_little',
                                //   width: 11.w,
                                //   height: 11.w,
                                // ),
                                // SizedBox(
                                //   width: 2.5.w,
                                // ),
                                Text(
                                    "${Utils.renderFixedNumber(data["play_ct"] ?? 0)}" +
                                        Utils.txt('bf'),
                                    style: StyleTheme.font_white_255_11),
                                // const Spacer(),
                                // Text(
                                //     "${Utils.getHMTime(data["duration"] ?? 0)}",
                                //     style: StyleTheme.font_white_255_12),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Positioned(right: 0, top: 0, child: videoType(data)),
              ],
            ),
            SizedBox(height: 4.w),
            Text(
              (data["title"] ?? ""),
              style: StyleTheme.font_black_7716_14,
              maxLines: 1,
            ),
            // SizedBox(height: 5.w),
          ],
        ),
      );
    });
  }

  //广告模块UI复用
  static Widget adModuleUI(BuildContext context, dynamic data,
      {double imageRatio = 171 / 96,
      int maxLine = 1,
      bool isForLongVideo = true}) {
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          // border: Border.all(
          //   color: StyleTheme.whiteColor,
          // )
        ), // const Color.fromRGBO(235, 235, 235, 0.9), width: 0.5.w)),
        child: GestureDetector(
          onTap: () {
            openRoute(context, data);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: _w / imageRatio,
                    child: ImageNetTool(
                        url: getPICURL(data),
                        radius: BorderRadius.only(
                            topLeft: Radius.circular(3.w),
                            topRight: Radius.circular(3.w))),
                  ),
                  Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 38.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: StyleTheme.blue52Color,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3.w),
                              bottomRight: Radius.circular(3.w)),
                        ),
                        child: Center(
                            child: Text(
                          Utils.txt('gangao'),
                          style: StyleTheme.font_white_255_12,
                        )),
                      ))
                ],
              ),
              // SizedBox(height: ScreenUtil().setWidth(10)),
              Expanded(
                child: isForLongVideo
                    ? Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          data["title"] ?? "",
                          style: StyleTheme.font_black_7716_14,
                          maxLines: 2,
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Column(
                          // mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 7.w),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                data["title"] ?? "",
                                style: StyleTheme.font_black_7716_14,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              data["description"] ?? data['sub_title'] ?? "",
                              style: StyleTheme.font_black_7716_06_14,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //广告模块UI复用
  static Widget adListUI(BuildContext context, dynamic data,
      {double imageRatio = 350 / 100}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.w),
      child: LayoutBuilder(builder: (context, constrains) {
        double _w = constrains.maxWidth;
        return SizedBox(
          height: _w / imageRatio,
          child: GestureDetector(
            onTap: () {
              openRoute(context, data);
            },
            child: Stack(
              children: [
                SizedBox(
                  height: _w / imageRatio,
                  child: ImageNetTool(
                      url: getPICURL(data), radius: BorderRadius.circular(3.w)),
                ),
                Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 38.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: StyleTheme.blue52Color,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(3.w),
                            bottomRight: Radius.circular(3.w)),
                      ),
                      child: Center(
                          child: Text(
                        Utils.txt('gangao'),
                        style: StyleTheme.font_white_255_12,
                      )),
                    ))
              ],
            ),
          ),
        );
      }),
    );
  }

  //广告模块UI复用
  static Widget adModuleInShortFlowUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 9 / 16,
  }) {
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return Center(
        child: GestureDetector(
          onTap: () {
            openRoute(context, data);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: _w / imageRatio,
                    child: ImageNetTool(
                      url: getPICURL(data),
                      fit: BoxFit.contain,
                      radius: BorderRadius.all(Radius.circular(5.w)),
                    ),
                  ),
                  Positioned(
                    left: 15.w,
                    top: 15.w,
                    child: Container(
                      width: 36.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.w),
                          bottomRight: Radius.circular(5.w),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          Utils.txt('gangao'),
                          style: StyleTheme.font_white_255_12,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: [
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.only(
                                left: StyleTheme.margin,
                                right: StyleTheme.margin),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  // Colors.red,
                                  Color.fromRGBO(0, 0, 0, 0),
                                  Color.fromRGBO(0, 0, 0, 0.8),
                                  // Colors.red
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        (data["title"] ?? ""),
                                        style: TextStyle(
                                          color: StyleTheme.whiteColor,
                                          fontSize: 15.sp,
                                          shadows: const [
                                            Shadow(
                                                color: Colors.black54,
                                                offset: Offset(1, 1))
                                          ],
                                        ),
                                        maxLines: 999,
                                      )),
                                  Text(
                                    data["description"] ??
                                        data['sub_title'] ??
                                        "",
                                    style: StyleTheme.font(
                                      size: 14,
                                      weight: FontWeight.normal,
                                      shadows: const [
                                        Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 1))
                                      ],
                                    ),
                                    maxLines: 999,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 345.w,
                                        height: 45.w,
                                        decoration: BoxDecoration(
                                          gradient: StyleTheme.gradBlue,
                                          borderRadius:
                                              BorderRadius.circular(10.w),
                                        ),
                                        child: Center(
                                          child: Text(
                                            Utils.txt('djtz'),
                                            style:
                                                StyleTheme.font_white_255_08_14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  //裸聊UI复用
  static Widget nackedChatModuleUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 172 / 230,
    bool disalbleTap = false,
  }) {
    //兼容提示
    data["type"] = data["isfree"];
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data, imageRatio: imageRatio);
    }
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (disalbleTap) {
            return;
          }
          Utils.navTo(
            context,
            '/homenakedchatdetailpage/${data["id"]}',
          );
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  List.from(data['medias']).isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            // borderRadius: BorderRadius.vertical(
                            //     top: Radius.circular(5.w)),
                          ),
                          width: _w,
                          height: _w / imageRatio,
                          child: Center(
                            child: LocalPNG(
                              name: 'hls_common_image_placehoplder_small',
                              width: 37.w,
                              height: 33.w,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: _w / imageRatio,
                          child: ImageNetTool(
                              url: getPICURL(List.from(data['medias']).first),
                              radius: BorderRadius.vertical(
                                  top: Radius.circular(5.w))),
                        ),
                  Positioned(
                      left: 5.w,
                      top: 5.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                            gradient: StyleTheme.gradBlue,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: Text(
                            renderFixedNumber(data['pay_ct']) +
                                Utils.txt('rlg'),
                            style: StyleTheme.font_white_255_12),
                      )),
                  // Positioned(left: 0, top: 0, child: videoType(data)),
                ],
              ),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              (data["name"] ?? ""),
                              style: StyleTheme.font_black_7716_15_medium,
                              maxLines: 1,
                            )),
                        SizedBox(height: 2.w),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${data["age"]}' +
                                  Utils.txt('sold') +
                                  '/' +
                                  '${data["height"]}' +
                                  Utils.txt('c') +
                                  '/' +
                                  '${data["weight"]}' +
                                  Utils.txt('k') +
                                  '/' +
                                  '${data["cup"]}' +
                                  Utils.txt('bzcup'),
                              style: StyleTheme.font_black_7716_04_10,
                              maxLines: 1,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //约炮UI复用
  static Widget dateModuleUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 165 / 213,
    bool disalbleTap = false,
  }) {
    //兼容提示
    data["type"] = data["isfree"];
    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return adModuleUI(context, data, imageRatio: imageRatio);
    }

    List girlClassList = AppGlobal.girlClassList;
    return LayoutBuilder(builder: (context, constrains) {
      double _w = constrains.maxWidth;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (disalbleTap) {
            return;
          }
          Utils.navTo(
            context,
            '/homedatedetailpage/${data["id"]}',
          );
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  List.from(data['medias']).isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            // borderRadius: BorderRadius.vertical(
                            //     top: Radius.circular(5.w)),
                          ),
                          width: _w,
                          height: _w / imageRatio,
                          child: Center(
                            child: LocalPNG(
                              name: 'hls_common_image_placehoplder_small',
                              width: 37.w,
                              height: 33.w,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: _w / imageRatio,
                          child: ImageNetTool(
                              url: getPICURL(List.from(data['medias']).first),
                              radius: BorderRadius.vertical(
                                  top: Radius.circular(5.w))),
                        ),
                  Positioned(
                      left: 5.w,
                      top: 5.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 1.w),
                        decoration: BoxDecoration(
                            color: StyleTheme.blue52Color,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: Text(
                            renderFixedNumber(data['pay_fct']) +
                                Utils.txt('ryg'),
                            style: StyleTheme.font_white_255_12),
                      )),
                  // Positioned(
                  //   left: 0,
                  //   right: 0,
                  //   bottom: 0,
                  //   child: Container(
                  //       height: 45.w,
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  //       alignment: Alignment.centerRight,
                  //       decoration: const BoxDecoration(
                  //         gradient: LinearGradient(
                  //           colors: [
                  //             Color.fromRGBO(0, 0, 0, 0.0),
                  //             Color.fromRGBO(0, 0, 0, 0.6),
                  //           ],
                  //           begin: Alignment.topCenter,
                  //           end: Alignment.bottomCenter,
                  //         ),
                  //       ),
                  //       child: Text(
                  //         '¥' + data['price'],
                  //         style: StyleTheme.font_blue52_15,
                  //       )),
                  // ),
                  // Positioned(left: 0, top: 0, child: videoType(data)),
                ],
              ),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            maxLines: 1,
                            text: TextSpan(children: [
                              TextSpan(
                                text: data["title"] ?? "",
                                style: StyleTheme.font_black_7716_15_medium,
                              )
                            ])),
                        // Align(
                        //     alignment: Alignment.topLeft,
                        //     child: Text(
                        //       data["name"] ?? "",
                        //       style: StyleTheme.font_white_255_14_medium,
                        //       maxLines: 1,
                        //     )),
                        SizedBox(height: 2.w),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${data["age"]}' +
                                  Utils.txt('sold') +
                                  '/' +
                                  '${data["height"]}' +
                                  Utils.txt('c') +
                                  // '/' +
                                  // '${data["weight"]}' +
                                  // Utils.txt('k') +
                                  '/' +
                                  '${data["cup"]}' +
                                  Utils.txt('bzcup'),
                              style: StyleTheme.font_black_7716_04_10,
                              maxLines: 1,
                            )),
                        SizedBox(height: 2.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '¥' + data['price'],
                              style: StyleTheme.font_blue52_15,
                            ),
                            RichText(
                              text:
                                  WidgetSpan(child: Builder(builder: (context) {
                                String classString = '';

                                if (girlClassList.isNotEmpty) {
                                  for (var element in girlClassList) {
                                    if (element['value'] ==
                                        (data["class"] ?? "")) {
                                      classString = element['name'];
                                      break;
                                    }
                                  }
                                }
                                return classString.isEmpty
                                    ? Container()
                                    : Container(
                                        height: 15.w,
                                        margin: EdgeInsets.only(right: 5.w),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7.w, vertical: 2.w),
                                        decoration: BoxDecoration(
                                            color: StyleTheme.blue52Color,
                                            borderRadius:
                                                BorderRadius.circular(3.w)),
                                        child: Text(
                                          classString,
                                          style: StyleTheme.font_white_255_9
                                              .toHeight(1.2),
                                          maxLines: 1,
                                        ),
                                      );
                              })),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //AI女友 UI复用
  static Widget aiGirlModuleUI(
    BuildContext context,
    dynamic data, {
    double imageRatio = 165 / 213,
    bool disalbleTap = false,
  }) {
    return GestureDetector(
      onTap: () {
        Utils.navTo(context, '/aigirldetailpage/${data['id']}');
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.5.w),
        child: Row(
          children: [
            Container(
              width: 63.w,
              height: 84.w,
              child: ImageNetTool(
                url: getPICURL(data),
                radius: BorderRadius.circular(4.w),
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: StyleTheme.font_black_7716_15_medium,
                ),
                Text(
                  data['desc'],
                  style: StyleTheme.font_black_7716_07_13,
                  maxLines: 3,
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  static getHMTime(int time) {
    int s = (time / 60).truncate();
    int h = (time - (s * 60)).truncate();
    String timeStr(int numb) {
      return numb < 10 ? '0$numb' : numb.toString();
    }

    return '${timeStr(s)}:${timeStr(h)}';
  }

  static Widget homeNaviBarModuleUI(BuildContext context, dynamic data) {
    List values = data;
    return Container(
        padding: EdgeInsets.only(
          left: StyleTheme.margin,
          right: StyleTheme.margin,
          bottom: 10.w,
        ),
        child: Column(
          children: [
            GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: values.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 80 / 30,
                    mainAxisSpacing: 10.w,
                    crossAxisSpacing: 10.w),
                itemBuilder: (context, index) {
                  dynamic e = values[index];
                  return GestureDetector(
                    onTap: () {
                      if (e['link_url'] == null || e['link_url'].length == 0) {
                        return;
                      }
                      if (e['redirect_type'] < 3) {
                        openRoute(context, e);
                      } else if (e['redirect_type'] == 3) {
                        if (e['open_type'] == 0) {
                          UtilEventbus().fire(EventbusClass(
                              {"name": "IndexNavTapItem", 'item': e}));
                        } else if (e['open_type'] == 1) {
                          Utils.navTo(context, '/homemorevideopage', extra: e);
                        }
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.w),
                      child: SizedBox(
                          height: 30.w,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                  child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: StyleTheme.whiteColor)),
                              Center(
                                child: Text(e["name"],
                                    style: StyleTheme.font_black_7716_07_13,
                                    maxLines: 1),
                              ),
                            ],
                          )),
                    ),
                  );
                }),
          ],
        ));
  }

  static Widget homeNaviModuleUI(BuildContext context, dynamic data) {
    List values = data;
    return Container(
        padding: EdgeInsets.only(
          left: StyleTheme.margin,
          right: StyleTheme.margin,
          // bottom: 10.w,
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: values.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: min(values.length, 5),
                    childAspectRatio: 80 / 80,
                    mainAxisSpacing: 10.w,
                    crossAxisSpacing: 10.w),
                itemBuilder: (context, index) {
                  dynamic e = values[index];
                  return GestureDetector(
                    onTap: () {
                      if (e['router'] == 'aiServer') {
                        UtilEventbus().fire(EventbusClass(
                            {"name": "IndexNavJump", 'index': 1}));

                        Utils.navTo(context, '/homedartnetpage');

                        return;
                      } else if (e['router'] == 'girlAI') {
                        UtilEventbus().fire(EventbusClass(
                            {"name": "IndexNavJump", 'index': 1}));

                        Future.delayed(const Duration(milliseconds: 200), () {
                          UtilEventbus().fire(EventbusClass(
                              {"name": "AI_IndexNavJump", 'index': 3}));
                        });

                        return;
                      }

                      int type = int.parse(e['type']);
                      e['redirect_type'] = type;
                      // if (e['link_url'] == null || e['link_url'].length == 0) {
                      //   return;
                      // }

                      openRoute(context, e);

                      // if (e['redirect_type'] < 3) {
                      //   openRoute(context, e);
                      // } else if (e['redirect_type'] == 3) {
                      //   if (e['open_type'] == 0) {
                      //     UtilEventbus().fire(EventbusClass(
                      //         {"name": "IndexNavTapItem", 'item': e}));
                      //   } else if (e['open_type'] == 1) {
                      //     Utils.navTo(context, '/homemorevideopage', extra: e);
                      //   }
                      // }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.w),
                      child: SizedBox(
                          // height: 35.w,
                          child: Column(
                        children: [
                          SizedBox.square(
                            dimension: 35.w,
                            child: ImageNetTool(
                              url: e['icon'],
                              radius: BorderRadius.only(
                                  topLeft: Radius.circular(2.w),
                                  topRight: Radius.circular(2.w)),
                            ),
                          ),
                          Center(
                            child: Text(e["title"],
                                style: StyleTheme.font_black_7716_14),
                          ),
                        ],
                      )),
                    ),
                  );
                }),
          ],
        ));
  }

  static tipsWidget(BuildContext context, List tips) {
    return SizedBox(
      // height: 50.w,
      child: SwiperTips(
          tips: tips,
          radius: 5,
          // aspectRatio: 3 / 7,
          onTap: (index) {
            Utils.openRoute(context, tips[index]);
          }),
    );
    // return MyMarqueeTipsWidget(
    //   tips: tips,
    //   onTap: (index) {
    //     Utils.openRoute(context, tips[index]);
    //   },
    // );
  }

  //提示alert
  static showText(String text, {int time = 1, Function()? call}) {
    BotToast.showCustomText(
      toastBuilder: (_) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: StyleTheme.whiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(5.w))),
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: EdgeInsets.all(20.w),
              child: Text(
                text.isEmpty ? Utils.txt('wzxx') : text,
                style:
                    StyleTheme.font(size: 13, color: StyleTheme.black019Color),
                maxLines: 100,
              ),
            )
          ],
        );
      },
      duration: Duration(seconds: time),
      onClose: call,
    );
  }

  static openURL(String url) async {
    try {
      await launchUrl(
        Uri.base.resolve(url),
        mode: LaunchMode.externalNonBrowserApplication,
        webOnlyWindowName: "_blank",
      );
    } catch (e) {
      Utils.showText(Utils.txt('wzcw'));
    }
  }

  static Future<String> getFdsKey() async {
    const duration = Duration(seconds: 5);
    for (String fdsApi in AppGlobal.fdsKeyApi) {
      try {
        final resp = await Dio(
                BaseOptions(connectTimeout: duration, receiveTimeout: duration))
            .get(fdsApi);
        if (resp.statusCode == 200) {
          final fdsKey = resp.data.toString().replaceAll('\n', '');
          CacheManager.instance.upsertFdsKey(fdsKey);
          return fdsKey;
        }
      } catch (_) {
        return "";
      }
    }

    final fdsKey = await CacheManager.instance.readFdsKey();
    return fdsKey ?? '';
  }

  static void checkline({Function? onSuccess, Function? onFailed}) async {
    Box? box = AppGlobal.appBox;
    List<String> unChecklines = box?.get('lines_url') == null
        ? AppGlobal.apiLines
        : List<String>.from(box?.get('lines_url'));
    // List<String> unChecklines = ["https://apiai.dyclub.co/api.php"];

    if (!kIsWeb) {
      final fdsKey = await Utils.getFdsKey();
      final secretValue = EncDecrypt.secretValue(fdsKey: fdsKey);
      NetworkHttp.apiDio.options.headers = {'Cf-Ray-Xf': secretValue}; //
    }

    List<Map> errorLines = [];
    Function checkGit;
    Function doCheck;
    Function handleResult;
    Dio _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5)));

    Function reportErrorLines = () async {
      // 上报错误线路&保存服务端推荐线路到本地
      if (errorLines.isEmpty) return;
      await reqReportLine(list: errorLines);
    };

    handleResult = (String line) async {
      if (line.isNotEmpty) {
        AppGlobal.apiBaseURL = line;
        await reportErrorLines();
        onSuccess?.call();
      } else {
        onFailed?.call();
      }
    };

    checkGit = () async {
      String? git = box?.get("github_url") == null
          ? AppGlobal.gitLine
          : box?.get("github_url").toString();
      dynamic result;
      if (kIsWeb) {
        result = await html.HttpRequest.request(git ?? "", method: "GET")
            .then((value) => value.response)
            .timeout(const Duration(milliseconds: 5 * 1000));
      } else {
        result = await _dio.get(git ?? "");
      }

      handleResult(result.toString().trim());
    };

    doCheck = ({String line = ""}) async {
      if (line.isEmpty) return;
      int code = 0;
      try {
        if (kIsWeb) {
          code = await html.HttpRequest.request('$line/api/callback/checkLine',
                  method: "POST")
              .then((value) => value.status ?? 0)
              .timeout(const Duration(milliseconds: 5 * 1000));
        } else {
          code = await _dio
              .post('$line/api/callback/checkLine')
              .then((value) => value.statusCode ?? 0);
        }
      } catch (err) {
        Utils.log("================================$err");
        code = 0;
      }
      Utils.log(code);
      if (code == 200) {
        handleResult(line);
      } else {
        errorLines.add({'url': line});
        //启用备用github线路
        if (errorLines.length == unChecklines.length &&
            unChecklines.length > 1) {
          checkGit();
        }
      }
    };

    //无网络
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      onFailed?.call();
    } else {
      for (var i = 0; i < unChecklines.length; i++) {
        if (AppGlobal.apiBaseURL.isEmpty) {
          await doCheck(line: unChecklines[i]);
        } else {
          break;
        }
      }
    }
  }

  //检查安装未知安装包
  static checkRequestInstallPackages() async {
    if (Platform.isAndroid) {
      PermissionStatus _status = await Permission.requestInstallPackages.status;
      if (_status == PermissionStatus.granted) {
        return true;
      } else if (_status == PermissionStatus.permanentlyDenied) {
        Utils.showText(Utils.txt('jjazqq'));
        return false;
      } else {
        await Permission.requestInstallPackages.request();
        return true;
      }
    }
  }

  //检查是否已有读写内存权限
  static checkStoragePermission() async {
    if (Platform.isAndroid) {
      PermissionStatus storageStatus = await Permission.storage.status;
      if (storageStatus == PermissionStatus.granted) {
        return true;
      } else if (storageStatus == PermissionStatus.permanentlyDenied) {
        Utils.showText(Utils.txt('jjqxts'));
        return false;
      } else {
        await Permission.storage.request();
        return true;
      }
    }
  }

  static getPICURL(dynamic data) {
    if (data == null) return '';
    if (data['media_url'] != null && data['media_url'] != '') {
      return data['media_url'];
    } else if (data['img_url'] != null && data['img_url'] != '') {
      return data['img_url'];
    } else if (data['resource_url'] != null && data['resource_url'] != '') {
      return data['resource_url'];
    } else if (data['thumb_horizontal'] != null &&
        data['thumb_horizontal'] != '') {
      return data['thumb_horizontal'];
    } else if (data['thumb_vertical'] != null && data['thumb_vertical'] != '') {
      return data['thumb_vertical'];
    } else if (data['cover_thumb_horizontal'] != null &&
        data['cover_thumb_horizontal'] != '') {
      return data['cover_thumb_horizontal'];
    } else if (data['cover_thumb_vertical'] != null &&
        data['cover_thumb_vertical'] != '') {
      return data['cover_thumb_vertical'];
    } else if (data['cover_vertical'] != null && data['cover_vertical'] != '') {
      return data['cover_vertical'];
    } else if (data['cover_horizontal'] != null &&
        data['cover_horizontal'] != '') {
      return data['cover_horizontal'];
    } else if (data['thumb_horizontal_url'] != null &&
        data['thumb_horizontal_url'] != '') {
      return data['thumb_horizontal_url'];
    } else if (data['cover'] != null && data['cover'] != '') {
      return data['cover'];
    } else if (data['thumb'] != null && data['thumb'] != '') {
      return data['thumb'];
    } else if (data['bg_thumb'] != null && data['bg_thumb'] != '') {
      return data['bg_thumb'];
    } else if (data['thumb_vertical_url'] != null &&
        data['thumb_vertical_url'] != '') {
      return data['thumb_vertical_url'] ?? "";
    } else if (data['small_cover'] != null && data['small_cover'] != '') {
      return data['small_cover'] ?? "";
    } else if (data['avatar_url'] != null && data['avatar_url'] != '') {
      return data['avatar_url'] ?? "";
    } else {
      return data["url"] ?? "";
    }
  }

  static renderFixedNumber(int value) {
    var tips;
    if (value >= 10000) {
      var newvalue = (value / 1000) / 10.round();
      tips = formatNum(newvalue, 1) + Utils.txt('w');
    } else if (value >= 1000) {
      var newvalue = (value / 100) / 10.round();
      tips = formatNum(newvalue, 1) + Utils.txt('qa');
    } else {
      tips = value.toString().split('.')[0];
    }
    return tips;
  }

  static renderByteNumber(int value) {
    var tips;
    if (value >= 1024 * 1024) {
      var newvalue = (value / (1024 * 1024));
      tips = formatNum(newvalue, 1) + 'M';
    } else if (value >= 1024) {
      var newvalue = (value / 1024);
      tips = formatNum(newvalue, 1) + 'K';
    } else {
      tips = value.toString().split('.')[0];
    }
    return tips;
  }

  static formatNum(double number, int postion) {
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) <
        postion) {
      //小数点后有几位小数
      return number
          .toStringAsFixed(postion)
          .substring(0, number.toString().lastIndexOf(".") + postion + 1)
          .toString();
    } else {
      return number
          .toString()
          .substring(0, number.toString().lastIndexOf(".") + postion + 1)
          .toString();
    }
  }

  static openRoute(BuildContext context, dynamic data) {
    if (data == null || data['url_str'].isEmpty) return;

    if (data['report_id'] != null) {
      //上报点击量
      reqAdClickCount(id: data['report_id'], type: data['report_type']);
    }

    if (data['redirect_type'] == 1) {
      String linkUrl = data['url_str'];
      List urlList = linkUrl.split('??');
      Map<String, dynamic> pramas = {};
      if (urlList.first == "web") {
        pramas["url"] = urlList.last.toString().substring(4);
        Utils.navTo(context, "/${urlList.first}/${pramas.values.first}");
        // Utils.navTo(context, "/${urlList.first}/http:g");
      } else {
        if (urlList.length > 1 && urlList.last != "") {
          urlList[1].split("&").forEach((item) {
            List stringText = item.split('=');
            pramas[stringText[0]] =
                stringText.length > 1 ? stringText[1] : null;
          });
        }
        String pramasStrs = "";
        if (pramas.values.isNotEmpty) {
          pramas.forEach((key, value) {
            pramasStrs += "/${Uri.decodeComponent(value)}";
          });
        }
        Utils.navTo(context, "/${urlList.first}$pramasStrs", extra: data);
      }
    } else {
      Utils.openURL(data['url_str'].trim());
    }
  }

  //帖子通用模块
  static Widget postModuleUI(BuildContext context, dynamic e,
      {bool isTime = false}) {
    List medias = e["medias"] ?? [];
    List tmp = medias.length > 3 ? medias.sublist(0, 3) : medias;
    String content = "${e["content_word"] ?? ""}";
    String title = "${e["title"] ?? ""}".isEmpty
        ? Utils.txt("bzhlwbt")
        : e["title"].toString();
    content = content == title ? "" : content;
    return StatefulBuilder(builder: (context, setState) {
      return isTime
          ? Container(
              margin: EdgeInsets.symmetric(
                  horizontal: StyleTheme.margin, vertical: 8.w),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (e["status"] == 1 && e["is_finished"] == 1) {
                    Utils.navTo(context, "/communitypostdetail/${e['id']}");
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Utils.format(DateTime.parse(e["created_at"] ?? "")),
                        style: StyleTheme.font_gray_153_12),
                    Offstage(
                      offstage: false,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
                        child: Container(
                          padding: EdgeInsets.only(left: 10.w),
                          decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                              color: StyleTheme.blue52Color,
                              width: 2.w,
                            )),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(
                                      text: Utils.convertEmojiAndHtml(title),
                                      style: StyleTheme.font_black_7716_15)),
                              content.isEmpty
                                  ? Container()
                                  : Padding(
                                      padding: EdgeInsets.only(top: 10.w),
                                      child: RichText(
                                        text: TextSpan(children: [
                                          e["is_best"] == 1
                                              ? WidgetSpan(
                                                  alignment:
                                                      PlaceholderAlignment
                                                          .middle,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 2.w),
                                                    child: Container(
                                                      height: 17.w,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.w),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              Utils.txt("jhua"),
                                                              style: StyleTheme
                                                                  .font_white_255_11)
                                                        ],
                                                      ),
                                                      decoration: BoxDecoration(
                                                          gradient: StyleTheme
                                                              .gradBlue,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          2.w))),
                                                    ),
                                                  ))
                                              : const TextSpan(),
                                          TextSpan(
                                              text: Utils.convertEmojiAndHtml(
                                                  content),
                                              style:
                                                  StyleTheme.font_black_7716_14)
                                        ]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                              tmp.isNotEmpty
                                  ? GridView.count(
                                      padding: EdgeInsets.only(top: 12.w),
                                      shrinkWrap: true,
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 7.w,
                                      crossAxisSpacing: 7.w,
                                      childAspectRatio: 1.0,
                                      scrollDirection: Axis.vertical,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: tmp
                                          .asMap()
                                          .keys
                                          .map((x) => Stack(
                                                children: [
                                                  ImageNetTool(
                                                    url: tmp[x]["type"] == 2
                                                        ? tmp[x]["cover"] ?? ""
                                                        : tmp[x]["media_url"] ??
                                                            "",
                                                    radius: BorderRadius.all(
                                                        Radius.circular(
                                                            ScreenUtil()
                                                                .setWidth(5))),
                                                  ),
                                                  tmp[x]["type"] == 2
                                                      ? Center(
                                                          child: LocalPNG(
                                                              name: "ai_play_n",
                                                              width: 30.w,
                                                              height: 30.w),
                                                        )
                                                      : Container(),
                                                  //大于3张图并且最后一图显示剩余多少张
                                                  x == 2 && medias.length > 3
                                                      ? Positioned(
                                                          right: 6.w,
                                                          bottom: 6.w,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.w),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromRGBO(
                                                                  0, 0, 0, 0.5),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          2.w)),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "+${medias.length - 3}",
                                                                style: StyleTheme
                                                                    .font_white_255_12,
                                                              ),
                                                            ),
                                                          ))
                                                      : Container()
                                                ],
                                              ))
                                          .toList(),
                                    )
                                  : Container(),
                              SizedBox(height: 15.w),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        "${Utils.renderFixedNumber(e["comment_num"] ?? 0)}${Utils.txt("tpl")} ｜ ${Utils.renderFixedNumber(e["view_num"] ?? 0)}${Utils.txt("yulan")} ｜ ${Utils.renderFixedNumber(e["like_num"] ?? 0)}${Utils.txt("danzan")}",
                                        style: StyleTheme.font_gray_95_12),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Utils.navTo(context,
                                            "/communitytagdetail/${e["topic"]["id"]}");
                                      },
                                      child: Text(
                                        "#${e["topic"]["name"] ?? ""}",
                                        style: StyleTheme.font_blue_52_12,
                                      ),
                                    ),
                                  ]),
                              e["status"] == 2
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10.w),
                                        RichText(
                                            text: TextSpan(
                                                text: Utils.txt("bjyy") + "：",
                                                style:
                                                    StyleTheme.font_gray_102_11,
                                                children: [
                                              TextSpan(
                                                  text: e["refuse_reason"],
                                                  style: StyleTheme
                                                      .font_red_255_11),
                                            ]))
                                      ],
                                    )
                                  : (e["status"] == 0
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 10.w),
                                            RichText(
                                                text: TextSpan(
                                                    text:
                                                        Utils.txt("shzt") + "：",
                                                    style: StyleTheme
                                                        .font_gray_102_11,
                                                    children: [
                                                  TextSpan(
                                                      text: Utils.txt('pdz'),
                                                      style: StyleTheme
                                                          .font_red_255_11),
                                                ]))
                                          ],
                                        )
                                      : Container())
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 10.w),
              padding: EdgeInsets.symmetric(
                  horizontal: StyleTheme.margin, vertical: 8.w),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Utils.navTo(context, "/communitypostdetail/${e['id']}");
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50.w,
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              gradient: StyleTheme.gradBlue,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.w)),
                            ),
                            padding: EdgeInsets.all(1.w),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Utils.navTo(context,
                                    "/mineotherusercenter/${e["user"]?["aff"]}");
                              },
                              child: ImageNetTool(
                                url: e["user"]?["thumb"] ?? "",
                                radius: BorderRadius.all(Radius.circular(19.w)),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      e["user"]?["nickname"] ?? "",
                                      style: StyleTheme.font_black_7716_13,
                                    ),
                                    SizedBox(width: 1.w),
                                    e["user"]?['agent'] == 1
                                        ? Icon(Icons.verified_sharp,
                                            size: 14.w,
                                            color: StyleTheme.blue52Color)
                                        : Container(),
                                  ],
                                ),
                                SizedBox(height: 2.w),
                                Text(
                                  Utils.format(
                                      DateTime.parse(e["created_at"] ?? "")),
                                  style: StyleTheme.font_black_7716_05_11,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.w),
                    RichText(
                        text: TextSpan(
                            text: Utils.convertEmojiAndHtml(title),
                            style: StyleTheme.font_black_7716_15)),
                    content.isEmpty
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(top: 10.w),
                            child: RichText(
                              text: TextSpan(children: [
                                e["is_best"] == 1
                                    ? WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 2.w),
                                          child: Container(
                                            height: 17.w,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.w),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(Utils.txt("jhua"),
                                                    style: StyleTheme
                                                        .font_white_255_11)
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                gradient: StyleTheme.gradBlue,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(2.w))),
                                          ),
                                        ))
                                    : const TextSpan(),
                                TextSpan(
                                    text: Utils.convertEmojiAndHtml(content),
                                    style: StyleTheme.font_black_7716_14)
                              ]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                    tmp.isNotEmpty
                        ? GridView.count(
                            padding: EdgeInsets.only(top: 15.w),
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            mainAxisSpacing: 7.w,
                            crossAxisSpacing: 7.w,
                            childAspectRatio: 1.0,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            children: tmp
                                .asMap()
                                .keys
                                .map((x) => Stack(
                                      children: [
                                        ImageNetTool(
                                          url: tmp[x]["type"] == 2
                                              ? tmp[x]["cover"] ?? ""
                                              : tmp[x]["media_url"] ?? "",
                                          radius: BorderRadius.all(
                                              Radius.circular(5.w)),
                                        ),
                                        tmp[x]["type"] == 2
                                            ? Center(
                                                child: LocalPNG(
                                                    name: "ai_play_n",
                                                    width: 30.w,
                                                    height: 30.w),
                                              )
                                            : Container(),
                                        //大于3张图并且最后一图显示剩余多少张
                                        x == 2 && medias.length > 3
                                            ? Positioned(
                                                right: 6.w,
                                                bottom: 6.w,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5.w),
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(
                                                        0, 0, 0, 0.5),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                2.w)),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "+${medias.length - 3}",
                                                      style: StyleTheme
                                                          .font_white_255_12,
                                                    ),
                                                  ),
                                                ))
                                            : Container()
                                      ],
                                    ))
                                .toList(),
                          )
                        : Container(),
                    SizedBox(height: 10.w),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              LocalPNG(
                                  name: "ai_community_comment",
                                  // color: StyleTheme.blak7716_04_Color,
                                  width: 25.w,
                                  height: 25.w),
                              SizedBox(width: 2.w),
                              Text(
                                "${Utils.renderFixedNumber(e["comment_num"] ?? 0)}",
                                style: StyleTheme.font_black_7716_06_12,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              LocalPNG(
                                  name: "ai_community_see",
                                  // color: StyleTheme.blak7716_07_Color,
                                  width: 25.w,
                                  height: 25.w),
                              SizedBox(width: 2.w),
                              Text(
                                "${Utils.renderFixedNumber(e["view_num"] ?? 0)}",
                                style: StyleTheme.font_black_7716_06_12,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              LocalPNG(
                                  name: "ai_community_like_list_off",
                                  // color: StyleTheme.blak7716_07_Color,
                                  width: 25.w,
                                  height: 25.w),
                              SizedBox(width: 2.w),
                              Text(
                                "${Utils.renderFixedNumber(e["like_num"] ?? 0)}",
                                style: StyleTheme.font_black_7716_06_12,
                              ),
                            ],
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Utils.navTo(context,
                                  "/communitytagdetail/${e["topic"]["id"]}");
                            },
                            child: Text(
                              "#${e["topic"]?["name"] ?? ""}",
                              style: StyleTheme.font_blue_52_12,
                            ),
                          )
                        ]),
                    // SizedBox(height: 5.w),
                    // Container(height: 0.5.w, color: StyleTheme.devideLineColor),
                  ],
                ),
              ),
            );
    });
  }

  //格子广告
  static Widget appsListWidget({
    double width = 380,
    double whRate = 1.0,
    List<dynamic>? data,
    double radius = 0,
    bool useMargin = true,
  }) {
    double _childAspectRatio = 57 / 76;
    int _ColumeNumber = 5;
    List<List<dynamic>> pages = [];
    List<dynamic> page = [];
    for (var element in data ?? []) {
      if (page.length >= _ColumeNumber * 2) {
        pages.add(page);
        page = [];
      }
      page.add(element);
    }

    if (page.isNotEmpty) {
      pages.add(page);
    }

    return Container(
        child: data == null || data.isEmpty
            ? Container()
            : LayoutBuilder(builder: (context, constrains) {
                double width = constrains.maxWidth;
                double itemWidth =
                    (width - (_ColumeNumber - 1) * 10.w) / _ColumeNumber;
                double itemHeight = itemWidth / _childAspectRatio;
                double bannerHeight = (itemHeight *
                        (pages.first.length <= _ColumeNumber ? 1 : 2)) +
                    (pages.first.length > _ColumeNumber ? 10.w : 0);

                return Container(
                  // color: Colors.amberAccent,
                  width: width,
                  height: bannerHeight + 10.w,
                  child: data.isEmpty
                      ? Container()
                      : Swiper(
                          autoplay: pages.length > 1,
                          loop: pages.length > 1,
                          itemBuilder: (BuildContext context, int index) {
                            double w = itemWidth;
                            return SizedBox(
                                width: width,
                                child: GridView.count(
                                    padding: EdgeInsets.only(bottom: 10.w),
                                    crossAxisCount: _ColumeNumber,
                                    mainAxisSpacing: 10.w,
                                    crossAxisSpacing: 10.w,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    childAspectRatio: _childAspectRatio,
                                    shrinkWrap: true,
                                    children: pages[index].map((e) {
                                      return GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            Utils.openRoute(context, e);
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: w,
                                                height: w,
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: ImageNetTool(
                                                    url: Utils.getPICURL(e),
                                                    radius:
                                                        BorderRadius.circular(
                                                            6.w),
                                                  ),
                                                ),
                                              ),
                                              // SizedBox(height: 8.w),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  // color: Colors.blue,
                                                  child: Text(
                                                    e['title'] ??
                                                        e['name'] ??
                                                        '',
                                                    style: TextStyle(
                                                        color: StyleTheme
                                                            .blak7716Color,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        decoration:
                                                            TextDecoration.none,
                                                        height: 1,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 11.sp),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ));
                                    }).toList()));
                          },
                          itemCount: pages.length,
                          pagination: pages.length > 1 || true
                              ? SwiperPagination(
                                  margin: EdgeInsets.zero,
                                  builder: SwiperCustomPagination(
                                      builder: (context, config) {
                                    int count = pages.length;
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(count, (index) {
                                        return config.activeIndex == index
                                            ? Container(
                                                width: 10.w,
                                                height: 4.w,
                                                margin:
                                                    EdgeInsets.only(right: 4.w),
                                                decoration: BoxDecoration(
                                                  // color: StyleTheme.white255Color,
                                                  gradient: StyleTheme.gradBlue,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(2.w)),
                                                ),
                                              )
                                            : Container(
                                                width: 4.w,
                                                height: 4.w,
                                                margin:
                                                    EdgeInsets.only(right: 4.w),
                                                decoration: BoxDecoration(
                                                  color:
                                                      StyleTheme.gray150Color,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(2.w)),
                                                ),
                                              );
                                      }),
                                    );
                                  }))
                              : null,
                        ),
                );
              }));
  }

  //点击广告统一路径
  static Widget bannerSwiper({
    double width = 380,
    double whRate = 1.0,
    List<dynamic>? data,
    double radius = 0,
  }) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius.w)),
        child: Container(
          color: StyleTheme.whiteColor,
          width: width,
          height: width * whRate,
          child: data == null
              ? Container()
              : Swiper(
                  autoplay: data.length > 1,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        if (Utils.unFocusNode(context)) {
                          openRoute(context, data[index]);
                        }
                      },
                      child: ImageNetTool(url: Utils.getPICURL(data[index])),
                    );
                  },
                  itemCount: data.length,
                  pagination: SwiperPagination(builder:
                      SwiperCustomPagination(builder: (context, config) {
                    int count = data.length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(count, (index) {
                        return config.activeIndex == index
                            ? Container(
                                width: 9.w,
                                height: 3.w,
                                margin: EdgeInsets.only(right: 5.w),
                                decoration: BoxDecoration(
                                  color: StyleTheme.black31Color,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0.w)),
                                ),
                              )
                            : Container(
                                width: 9.w,
                                height: 3.w,
                                margin: EdgeInsets.only(right: 5.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0.w)),
                                ),
                              );
                      }),
                    );
                  })),
                ),
        ));
  }

  //统一跳转指定页面
  static navTo(BuildContext context, String path,
      {Map? extra, bool replace = false}) {
    if (replace) {
      AppGlobal.appRouter?.pop();
      AppGlobal.appRouter?.push(path, extra: extra);
    } else {
      AppGlobal.appRouter?.push(path, extra: extra);
    }
  }

  //加载动画
  static startGif({String tip = "发布中"}) {
    BotToast.showCustomLoading(
      // backgroundColor: Colors.black.withOpacity(0.7),
      toastBuilder: ((cancelFunc) =>
          Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
                height: 20.w,
                width: 20.w,
                child: CircularProgressIndicator(
                  color: StyleTheme.blue52Color,
                  strokeWidth: 2,
                )),
            SizedBox(height: 12.w),
            Text(tip, style: StyleTheme.font_black_7716_07_12)
          ])),
    );
  }

  //导航栏搜索
  static Widget searchWidget(BuildContext context, {String tips = "srsgjz"}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36.w,
            decoration: BoxDecoration(
                color: StyleTheme.whiteColor,
                borderRadius: BorderRadius.all(Radius.circular(18.w))),
            alignment: Alignment.center,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Utils.navTo(context, "/homesearchpage");
              },
              child: Row(
                children: [
                  SizedBox(width: 10.w),
                  Expanded(
                      child: Text(Utils.txt(tips),
                          style: StyleTheme.font_black_7716_04_14)),
                  SizedBox(width: 10.w),
                  LocalPNG(name: "ai_nav_search", width: 20.w, height: 20.w),
                  SizedBox(width: 10.w),
                ],
              ),
            ),
          ),
        ),
        // SizedBox(width: 5.w),
        // GestureDetector(
        //   behavior: HitTestBehavior.translucent,
        //   onTap: () {
        //     navTo(context, "/homewelfarepage");
        //   },
        //   child: LocalPNG(name: "ai_nav_logo", width: 32.w, height: 32.w),
        // ),
      ],
    );
  }

  //关闭动画
  static closeGif() {
    BotToast.closeAllLoading();
  }

  //自定义对话框
  static showDialog({
    String? cancelTxt,
    String? confirmTxt = "确定",
    Color? backgroundColor,
    VoidCallback? cancel,
    VoidCallback? confirm,
    VoidCallback? backgroundReturn,
    Function? setContent,
  }) {
    return BotToast.showAnimationWidget(
      clickClose: false,
      allowClick: false,
      onlyOne: false,
      crossPage: true,
      backButtonBehavior: BackButtonBehavior.none,
      wrapToastAnimation: (controller, cancel, child) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              cancel();
              backgroundReturn?.call();
            },
            //The DecoratedBox here is very important,he will fill the entire parent component
            child: AnimatedBuilder(
              builder: (_, child) => Opacity(
                opacity: controller.value,
                child: child,
              ),
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black38),
                child: SizedBox.expand(),
              ),
              animation: controller,
            ),
          ),
          AnimatedBuilder(
            child: child,
            animation: controller,
            builder: (context, child) {
              Tween<Offset> tweenOffset = Tween<Offset>(
                begin: const Offset(0.0, 0.8),
                end: Offset.zero,
              );
              Tween<double> tweenScale = Tween<double>(begin: 0.3, end: 1.0);
              Animation<double> animation =
                  CurvedAnimation(parent: controller, curve: Curves.decelerate);
              return FractionalTranslation(
                translation: tweenOffset.evaluate(animation),
                child: ClipRect(
                  child: Transform.scale(
                    scale: tweenScale.evaluate(animation),
                    child: Opacity(
                      child: child,
                      opacity: animation.value,
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
      toastBuilder: (cancelFunc) {
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
                color: backgroundColor ?? StyleTheme.whiteColor,
                borderRadius: BorderRadius.all(Radius.circular(5.w))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                      text: Utils.txt('wxts'),
                      style: StyleTheme.font_black_7716_16_blod),
                  maxLines: 1,
                ),
                SizedBox(height: 15.w),
                setContent?.call(),
                SizedBox(height: 15.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cancelTxt == null
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              cancelFunc();
                              cancel?.call();
                            },
                            child: Container(
                              height: 32.w,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: StyleTheme.gray198Color,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.w)),
                              ),
                              child: Center(
                                  child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: cancelTxt,
                                    style: StyleTheme.font(
                                        size: 14,
                                        color: const Color.fromRGBO(
                                            10, 11, 13, 0.6)),
                                  ),
                                ]),
                              )),
                            ),
                          ),
                    SizedBox(width: cancelTxt == null ? 0 : 30.w),
                    confirmTxt == null
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              cancelFunc();
                              confirm?.call();
                            },
                            child: Container(
                              height: 32.w,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                  color: StyleTheme.blue52Color,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.w))),
                              alignment: Alignment.center,
                              child: Center(
                                  child: RichText(
                                      text: TextSpan(children: [
                                TextSpan(
                                  text: confirmTxt,
                                  style: StyleTheme.font(
                                      size: 14, color: StyleTheme.whiteColor),
                                )
                              ]))),
                            ),
                          )
                  ],
                ),
              ],
            ),
          ),
        );
      },
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  //弹出支付
  static showAlertBuy(BuildContext context, dynamic e,
      {bool goby = false,
      String? coinTip,
      String? vipTip,
      bool cancelQuit = true, // 点击取消就退出去
      Function(BuildContext context, {dynamic id, int money})? buyFunc,
      Function(dynamic data)? doneFunc}) {
    UserModel? user =
        Provider.of<BaseStore>(AppGlobal.context!, listen: false).user;
    if (user == null) return;
    int money = user.money ?? 0;
    int needmoney = e?['coins'] ?? 0;
    bool isInsufficient = money < needmoney;
    if (goby && !isInsufficient) {
      buyRes(e, money - needmoney, buyFunc: buyFunc, doneFunc: doneFunc); //直接购买
      return;
    }
    if (e?['type'] == 2) {
      Utils.showDialog(
          backgroundReturn: () {
            if (cancelQuit) Navigator.of(context).pop();
          },
          cancel: () {
            if (cancelQuit) Navigator.of(context).pop();
          },
          cancelTxt: Utils.txt('quxao'),
          confirmTxt: isInsufficient ? Utils.txt('qwcz') : Utils.txt('gmgk'),
          setContent: () {
            return Column(
              children: [
                Text(
                    coinTip ??
                        Utils.txt('dqzjxhfajb')
                            .replaceAll('a', '${e['coins']}'),
                    style: StyleTheme.font_black_7716_14,
                    maxLines: 3),
                SizedBox(height: 15.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(Utils.txt('ktvpzk') + "：$money",
                        style: StyleTheme.font_black_7716_14),
                  ],
                ),
              ],
            );
          },
          confirm: () {
            if (isInsufficient) {
              Utils.navTo(AppGlobal.context!, "/minegoldcenterpage",
                  replace: true);
            } else {
              buyRes(e, money - needmoney,
                  buyFunc: buyFunc, doneFunc: doneFunc); //直接购买
            }
          });
    } else {
      Utils.showDialog(
          cancel: () {
            // if (cancelQuit) Navigator.of(context).pop();
            Utils.navTo(AppGlobal.context!, "/minesharepage",
                replace: cancelQuit);
          },
          cancelTxt: Utils.txt('fxlvip'),
          confirmTxt: Utils.txt('czvip'),
          setContent: () {
            return Text(vipTip ?? Utils.txt('dqzjxykhy'),
                style: StyleTheme.font_black_7716_14);
          },
          backgroundReturn: () {
            if (cancelQuit) Navigator.of(context).pop();
          },
          confirm: () {
            Utils.navTo(AppGlobal.context!, "/minevippage",
                replace: cancelQuit);
          });
    }
  }

  static buyRes(dynamic e, int money,
      {Function(BuildContext context, {dynamic id, int money})? buyFunc,
      Function(dynamic data)? doneFunc}) {
    Utils.startGif(tip: Utils.txt("gmzz"));
    buyFunc
        ?.call(AppGlobal.context!, id: e['id'] ?? 0, money: money)
        .then((value) {
      //关闭加载动画
      Utils.closeGif();
      if (value?.status == 1) {
        doneFunc?.call(value?.data);
      } else {
        Utils.showText(value?.msg ?? '');
      }
    });
  }

  static Size boundingTextSize(
    BuildContext context,
    String text,
    TextStyle style, {
    int maxLines = 2 ^ 31,
    double maxWidth = double.infinity,
  }) {
    if (text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        locale: Localizations.localeOf(context),
        text: TextSpan(text: text, style: style),
        maxLines: maxLines)
      ..layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  //0图片-1视频模块处理结果UI复用
  static Widget materialDealUI(
    BuildContext context,
    dynamic e, {
    int type = 0,
    Function(int, bool)? okfun,
    Function()? editfun,
    bool isEdit = false,
    bool isSelect = false,
    bool isLongPress = false,
  }) {
    int status = e["status"] ?? 0;
    int w = e["thumb_w"] ?? 150;
    int h = e["thumb_h"] ?? 150;
    double w1 = (ScreenUtil().screenWidth - StyleTheme.margin * 2 - 20.w) / 3;
    double h1 = w1 / w * h;
    double txtH = boundingTextSize(
      context,
      "${Utils.txt('dqshjd')}${e['reason'] ?? ''}",
      StyleTheme.font_red_255_12,
      maxWidth: w1,
    ).height;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () async {
        if (isLongPress) {
          if (!kIsWeb && await Vibration.hasVibrator() == true) {
            Vibration.vibrate();
          }
          editfun?.call();
        }
      },
      onTap: () {
        if (isEdit) {
          okfun?.call(status, true);
        } else {
          okfun?.call(status, false);
        }
      },
      child: SizedBox(
        height: h1 + (status == 3 ? (8.w + txtH) : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: h1,
              child: Stack(children: [
                ImageNetTool(
                  url: e["thumb"],
                  radius: BorderRadius.all(Radius.circular(2.w)),
                ),
                type == 1
                    ? Center(
                        child: LocalPNG(
                            name: "ai_play_n", width: 30.w, height: 30.w))
                    : Container(),
                isEdit
                    ? Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  StyleTheme.blak7716_07_Color.withOpacity(0.5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2.w)),
                            ),
                          ),
                          Positioned(
                            right: 3.w,
                            top: 3.w,
                            child: Icon(
                              Icons.check_circle,
                              color: isSelect
                                  ? const Color.fromRGBO(246, 197, 117, 1)
                                  : Colors.white,
                              size: 20.w,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ]),
            ),
            status == 3 //代表处理失败
                ? Column(
                    children: [
                      SizedBox(height: 8.w),
                      SizedBox(
                        height: txtH,
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: Utils.txt('dqshjd'),
                                style: StyleTheme.font_gray_102_12),
                            TextSpan(
                                text: e['reason'] ?? '',
                                style: StyleTheme.font_red_255_12),
                          ]),
                        ),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  //0图片-1视频模块UI复用
  static Widget materialModuleUI(BuildContext context, dynamic e,
      {int type = 0, // 0图片 1视频
      Function(Function(String, int, int))? imgfun,
      Function(String, int, int)? okfun}) {
    int w = e["thumb_w"] ?? 150;
    int h = e["thumb_h"] ?? 200;
    if (w == 0) {
      w = 150;
    }
    if (h == 0) {
      h = 200;
    }
    double w1 = (ScreenUtil().screenWidth - StyleTheme.margin * 2 - 10.w) / 2;
    double h1 = w1 / w * h;
    String tipTxt = Utils.txt("manfei");
    if (e["type"] == 1) {
      tipTxt = "VIP";
    }
    if (e["type"] == 2 && e["coins"] > 0) {
      tipTxt = "${e['coins'] ?? 0}${Utils.txt('jinb')}";
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _sheetAlert(
          context,
          e,
          type: type,
          imgfun: imgfun,
          okfun: okfun,
        );
      },
      child: SizedBox(
        width: w1,
        height: h1 + 8.w + 20.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: h1,
              child: Stack(children: [
                ImageNetTool(
                  url: e["thumb"],
                  radius: BorderRadius.all(Radius.circular(4.w)),
                ),
                type == 1
                    ? Center(
                        child: LocalPNG(
                            name: "ai_pic_play_n", width: 30.w, height: 30.w))
                    : Container(),
                // Positioned(
                //   left: 0,
                //   top: 0,
                //   child: Container(
                //     height: 18.w,
                //     decoration: BoxDecoration(
                //       // gradient: const LinearGradient(
                //       //   colors: [
                //       //     Color.fromRGBO(246, 197, 117, 0.9),
                //       //     Color.fromRGBO(253, 160, 9, 0.9),
                //       //   ],
                //       //   begin: Alignment.centerLeft,
                //       //   end: Alignment.centerRight,
                //       // ),
                //       gradient: StyleTheme.gradOrange,
                //       // color: StyleTheme.blue52Color,
                //       borderRadius: BorderRadius.only(
                //         topLeft: Radius.circular(4.w),
                //         bottomRight: Radius.circular(4.w),
                //       ),
                //     ),
                //     alignment: Alignment.center,
                //     padding: EdgeInsets.symmetric(horizontal: 5.w),
                //     child: Text(tipTxt, style: StyleTheme.font_white_255_10),
                //   ),
                // )
              ]),
            ),
            SizedBox(height: 5.w),
            SizedBox(
              height: 20.w,
              child:
                  Text(e["title"] ?? "", style: StyleTheme.font_black_7716_14),
            ),
          ],
        ),
      ),
    );
  }

  static void _sheetAlert(
    BuildContext context,
    dynamic e, {
    int type = 0, // 0图片 1视频
    Function(Function(String, int, int))? imgfun,
    Function(String, int, int)? okfun,
  }) {
    // int w = e["thumb_w"] ?? 150;
    // int h = e["thumb_h"] ?? 150;
    // double w1 = (ScreenUtil().screenWidth - StyleTheme.margin) / 3;
    // double h1 = w1 / w * h;
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    int remainFaceValue =
        type == 0 ? (user?.img_face_value ?? 0) : (user?.video_face_value ?? 0);

    // bool pass = Provider.of<BaseStore>(context, listen: false).user?.pass == 1;

    String btnTxt = remainFaceValue > 0
        ? Utils.txt('ljscsyac').replaceAll('aa', '$remainFaceValue')
        : Utils.txt("xqxq");
    if (AppGlobal.vipLevel == 0 && e["type"] == 1 && remainFaceValue <= 0) {
      btnTxt = Utils.txt('ktvpxs');
    }

    int coins = e["coins"];
    if (type == 0) {
      //图片
      coins = Provider.of<BaseStore>(context, listen: false)
              .conf
              ?.config
              ?.img_coins ??
          0;
    } else if (type == 1) {
      //视频
      coins = Provider.of<BaseStore>(context, listen: false)
              .conf
              ?.config
              ?.video_coins ??
          0;
    }

    if (e["type"] == 2 && e["coins"] > 0 && remainFaceValue <= 0) {
      UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
      btnTxt = Utils.txt('ddjs')
          .replaceAll("00", coins.toString())
          .replaceAll("##", (user?.money ?? 0).toString());
    }
    // if (pass) {
    //   btnTxt = Utils.txt("xqxq");//立即生成
    // }

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          String url = "";
          int kw = 0;
          int kh = 0;
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
              decoration: BoxDecoration(
                color: StyleTheme.whiteColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.w),
                    topLeft: Radius.circular(5.w)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.w),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${e["title"] ?? ""}  ",
                          style: StyleTheme.font_black_7716_14_medium,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.close,
                          size: 20.w,
                          color: StyleTheme.blak7716_07_Color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.w),
                  Center(
                    child: SizedBox(
                      height: 120.w,
                      // width: w1,
                      child: GestureDetector(
                        onTap: () {
                          if (type == 0) {
                            Map picMap = {
                              'resources': [e["thumb"]],
                              'index': 0
                            };
                            String url = EncDecrypt.encry(jsonEncode(picMap));
                            Utils.navTo(context, '/previewviewpage/$url');
                            return;
                          }
                          if (type == 1) {
                            Utils.navTo(context,
                                "/unplayerpage/${Uri.encodeComponent(e["thumb"] ?? "")}/${Uri.encodeComponent(e["m3u8"] ?? "")}");
                            return;
                          }
                        },
                        child: Stack(children: [
                          Center(
                            child: ImageNetTool(
                              url: e["thumb"],
                              radius: BorderRadius.all(Radius.circular(2.w)),
                              fit: BoxFit.contain,
                            ),
                          ),
                          type == 1
                              ? Center(
                                  child: LocalPNG(
                                      name: "ai_pic_play_n",
                                      width: 30.w,
                                      height: 30.w))
                              : Container(),
                        ]),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.w),
                  Text(
                    Utils.txt('sptpgzr'),
                    style: StyleTheme.font_black_7716_14_medium,
                  ),
                  SizedBox(height: 10.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.w),
                    child: DottedBorder(
                      // dashPattern: const [3, 1],
                      strokeWidth: 2.w,
                      radius: Radius.circular(4.w),
                      borderType: BorderType.Rect,
                      padding: EdgeInsets.zero,
                      borderPadding: EdgeInsets.zero,
                      color: StyleTheme.blak7716_04_Color,
                      child: Container(
                        width: double.infinity,
                        height: 100.w,
                        // decoration: const BoxDecoration(
                        //     color: Color.fromRGBO(249, 255, 254, 1)),
                        child: url.isEmpty
                            ? GestureDetector(
                                onTap: () {
                                  imgfun?.call((x, w, h) {
                                    setBottomSheetState(() {
                                      url = x;
                                      kw = w;
                                      kh = h;
                                    });
                                  });
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo,
                                        size: 40.w,
                                        color: StyleTheme.blue52Color),
                                    SizedBox(height: 5.w),
                                    Text(Utils.txt("qxzbkbp"),
                                        style: StyleTheme.font_black_7716_07_12)
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  Center(
                                      child: ImageNetTool(
                                          url: AppGlobal.imgBaseUrl + url,
                                          fit: BoxFit.contain)),
                                  Positioned(
                                    right: 5.w,
                                    top: 5.w,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setBottomSheetState(() {
                                          url = "";
                                          kw = 0;
                                          kh = 0;
                                        });
                                      },
                                      child: LocalPNG(
                                          name: "ai_post_delete",
                                          width: 15.w,
                                          height: 15.w),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.w),
                  Text(
                    Utils.txt("djzsmdesc"),
                    style: StyleTheme.font_black_7716_07_12,
                    maxLines: 10,
                  ),
                  SizedBox(height: 10.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          LocalPNG(
                              name: "ai_material_ok",
                              width: 50.w,
                              height: 50.w),
                          SizedBox(height: 2.w),
                          Text(Utils.txt("ljyy"),
                              style: StyleTheme.font_black_7716_07_12)
                        ],
                      ),
                      Column(
                        children: [
                          LocalPNG(
                              name: "ai_material_lter_face",
                              width: 50.w,
                              height: 50.w),
                          SizedBox(height: 2.w),
                          Text(Utils.txt("ryueg"),
                              style: StyleTheme.font_black_7716_07_12)
                        ],
                      ),
                      Column(
                        children: [
                          LocalPNG(
                              name: "ai_material_lter_eye",
                              width: 50.w,
                              height: 50.w),
                          SizedBox(height: 2.w),
                          Text(Utils.txt("tysj"),
                              style: StyleTheme.font_black_7716_07_12)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20.w),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // bool pass = Provider.of<BaseStore>(context, listen: false).user?.pass == 1;
                      // if (pass) {
                      //   okfun?.call(url, kw, kh);
                      //   return;
                      // }
                      int remainFaceValue = type == 0
                          ? (user?.img_face_value ?? 0)
                          : (user?.video_face_value ?? 0);

                      if (AppGlobal.vipLevel == 0 &&
                          e["type"] == 1 &&
                          remainFaceValue <= 0) {
                        Navigator.of(context).pop();
                        navTo(context, "/minevippage");
                        return;
                      }
                      int my = user?.money ?? 0;
                      if (e["type"] == 2 &&
                          my - coins < 0 &&
                          remainFaceValue <= 0) {
                        Navigator.of(context).pop();
                        navTo(context, "/minegoldcenterpage");
                        return;
                      }
                      okfun?.call(url, kw, kh);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: StyleTheme.gradBlue,
                          borderRadius: BorderRadius.all(Radius.circular(5.w))),
                      padding:
                          EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      height: 40.w,
                      alignment: Alignment.center,
                      child: Text(btnTxt, style: StyleTheme.font_white_255_14),
                    ),
                  ),
                  SizedBox(height: 30.w),
                ],
              ),
            );
          });
        });
  }

  //关闭键盘
  static bool unFocusNode(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    if (currentFocus.focusedChild == null && kIsWeb) {
      return true;
    } else if (currentFocus.hasPrimaryFocus) {
      return true;
    } else {
      return false;
    }
  }

  //导航栏
  static Widget createNav(
      {Widget? left,
      Widget? right,
      Widget? titleW,
      Color? navColor,
      Color? lineColor}) {
    return Column(
      children: [
        Container(
          height: StyleTheme.topHeight,
          color: navColor ?? StyleTheme.gray128Color,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
          height: StyleTheme.navHegiht,
          width: ScreenUtil().screenWidth,
          decoration: BoxDecoration(
              color: navColor ?? StyleTheme.gray128Color,
              border: Border(
                  bottom: BorderSide(
                      width: 0.5.w, color: lineColor ?? Colors.transparent))),
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    left ?? SizedBox(width: 20.w, height: 20.w),
                    right ?? SizedBox(width: 20.w, height: 20.w),
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: titleW),
            ],
          ),
        )
      ],
    );
  }

  static comicListView(
    BuildContext context,
    List array, {
    bool shrinkWrap = true,
    bool scrollEnable = true,
    bool useHoriMargin = true,
    bool replace = false,
  }) {
    return GridView.builder(
        cacheExtent: ScreenUtil().screenHeight * 5,
        shrinkWrap: shrinkWrap,
        physics:
            scrollEnable ? ScrollPhysics() : NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
            horizontal: useHoriMargin ? StyleTheme.margin : 0,
            vertical: ScreenUtil().setWidth(10)),
        itemCount: array.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.w,
          crossAxisSpacing: 10.w,
          childAspectRatio: 120 / 200,
        ),
        itemBuilder: (context, index) {
          var e = array[index];
          return Utils.comicModuleUI(context, e, replace: replace);
        });
  }

  static novelListView(
    BuildContext context,
    List array, {
    bool shrinkWrap = true,
    bool scrollEnable = true,
    bool useHoriMargin = true,
  }) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: scrollEnable
          ? const ScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: useHoriMargin ? StyleTheme.margin : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
        childAspectRatio: 130 / 195,
      ),
      scrollDirection: Axis.vertical,
      itemCount: array.length,
      itemBuilder: (context, index) {
        dynamic e = array[index];
        return Utils.novelGridModuleUI(context, e);
      },
    );
  }

  static gameListView(
    BuildContext context,
    List array, {
    bool shrinkWrap = true,
    bool scrollEnable = true,
    bool useHoriMargin = true,
  }) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: scrollEnable
          ? const ScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: useHoriMargin ? StyleTheme.margin : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
        childAspectRatio: 172 / 140,
      ),
      scrollDirection: Axis.vertical,
      itemCount: array.length,
      itemBuilder: (context, index) {
        dynamic e = array[index];
        return Utils.gameModuleUI(context, e);
      },
    );
  }

  static String convertEmojiAndHtml(String str) {
    // 转 html
    var unescape = HtmlUnescape();
    str = unescape.convert(str);
    // 转 emoji
    final Pattern unicodePattern = RegExp(r'\\\\u([0-9A-Fa-f]{4})');
    final String newStr =
        str.replaceAllMapped(unicodePattern, (Match unicodeMatch) {
      final int hexCode = int.parse(unicodeMatch.group(1) ?? "0", radix: 16);
      final unicode = String.fromCharCode(hexCode);
      return unicode;
    });
    return newStr;
  }

  //时间转换
  static num _oneMinute = 60000;
  static num _oneHour = 3600000;
  static num _oneDay = 86400000;
  static num _oneWeek = 604800000;

  static final String _oneSecondAgo = Utils.txt('mq');
  static final String _oneMinuteAgo = Utils.txt('fq');
  static final String _oneHourAgo = Utils.txt('sq');
  static final String _oneDayAgo = Utils.txt('tq');
  static final String _oneMonthAgo = Utils.txt('yq');
  static final String _oneYearAgo = Utils.txt('nq');

  //时间转换
  static String format(DateTime date) {
    num delta =
        DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;

    if (delta < 1 * _oneMinute) {
      num seconds = _toSeconds(delta);
      return (seconds <= 0 ? 1 : seconds).toInt().toString() + _oneSecondAgo;
    }
    if (delta < 60 * _oneMinute) {
      num minutes = _toMinutes(delta);
      return (minutes <= 0 ? 1 : minutes).toInt().toString() + _oneMinuteAgo;
    }
    if (delta < 24 * _oneHour) {
      num hours = _toHours(delta);
      return (hours <= 0 ? 1 : hours).toInt().toString() + _oneHourAgo;
    }
    if (delta < 48 * _oneHour) {
      return Utils.txt('zut');
    }
    if (delta < 30 * _oneDay) {
      num days = _toDays(delta);
      return (days <= 0 ? 1 : days).toInt().toString() + _oneDayAgo;
    }
    if (delta < 12 * 4 * _oneWeek) {
      num months = _toMonths(delta);
      return (months <= 0 ? 1 : months).toInt().toString() + _oneMonthAgo;
    } else {
      num years = _toYears(delta);
      return (years <= 0 ? 1 : years).toInt().toString() + _oneYearAgo;
    }
  }

  static num _toSeconds(num date) {
    return date / 1000;
  }

  static num _toMinutes(num date) {
    return _toSeconds(date) / 60;
  }

  static num _toHours(num date) {
    return _toMinutes(date) / 60;
  }

  static num _toDays(num date) {
    return _toHours(date) / 24;
  }

  static num _toMonths(num date) {
    return _toDays(date) / 30;
  }

  static num _toYears(num date) {
    return _toMonths(date) / 12;
  }

  static String getCurrentTimer() {
    // 获取当前时间
    DateTime now = DateTime.now();

    return DateUtil.formatDate(now, format: "yyyy-MM-dd HH:mm:ss");
    // 定义日期格式
    // DateFormats formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    // // 转换为指定格式
    // String formattedDate = formatter.format(now);
    // return formattedDate;
  }

  //特殊字符处理
  static Widget getContentSpan(
    String text, {
    bool isCopy = false,
    TextStyle? style,
    TextStyle? lightStyle,
  }) {
    style = style ?? StyleTheme.font_black_31_14;
    lightStyle = lightStyle ??
        StyleTheme.font(size: 14, color: const Color.fromRGBO(25, 103, 210, 1));
    List<InlineSpan> _contentList = [];
    RegExp exp = RegExp(
        r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    int index = 0;
    for (var match in matches) {
      /// start 0  end 8
      /// start 10 end 12
      String c = text.substring(match.start, match.end);
      if (match.start == index) {
        index = match.end;
      }
      if (index < match.start) {
        String a = text.substring(index, match.start);
        index = match.end;
        _contentList.add(
          TextSpan(text: a, style: style),
        );
      }
      if (RegexUtil.isURL(c)) {
        _contentList.add(TextSpan(
            text: c,
            style: lightStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Utils.openURL(text.substring(match.start, match.end));
              }));
      } else {
        _contentList.add(
          TextSpan(text: c, style: style),
        );
      }
    }
    if (index < text.length) {
      String a = text.substring(index, text.length);
      _contentList.add(
        TextSpan(text: a, style: style),
      );
    }
    if (isCopy) {
      return SelectableText.rich(
        TextSpan(children: _contentList),
        strutStyle:
            const StrutStyle(forceStrutHeight: true, height: 1, leading: 0.5),
      );
    }
    return RichText(
        textAlign: TextAlign.left,
        text: TextSpan(children: _contentList),
        strutStyle:
            const StrutStyle(forceStrutHeight: true, height: 1, leading: 0.5));
  }

  static Page<void> buildSlideTransitionPage({
    required GoRouterState state,
    required Widget child,
    Duration transitionDuration = const Duration(milliseconds: 250),
  }) {
    bool isWebOrIOS = kIsWeb || (defaultTargetPlatform == TargetPlatform.iOS);

    if (isWebOrIOS) {
      // iOS/web系统上使用默认的页面过渡动画（支持滑动返回）
      return CupertinoPage(
        key: state.pageKey,
        child: child,
      );
    } else {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionDuration: transitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Define the transition animation here (slide from right to left)
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      );
    }
  }
}

extension FluroRouterE on BuildContext {
  void pop([dynamic result]) => AppGlobal.appRouter?.pop();
}
