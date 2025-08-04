import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:deepseek/model/alert_ads_model.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_installer/app_installer.dart';
import 'package:path_provider/path_provider.dart';

class UpdateSysAlert {
  //弹窗AD
  static void showAvtivetysAlert({
    VoidCallback? cancel,
    VoidCallback? confirm,
    AlertAdsModel? ads,
  }) {
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => GestureDetector(
        onTap: () {
          cancelFunc();
          cancel?.call();
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().screenHeight,
          ),
          width: ScreenUtil().screenWidth,
          decoration: const BoxDecoration(color: Colors.black38),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    cancelFunc();
                    confirm?.call();
                  },
                  child: SizedBox(
                    width: (ads?.width ?? 200).w,
                    height: (ads?.height ?? 200).w,
                    child: ImageNetTool(
                      url: ads?.img_url ?? "",
                      radius: BorderRadius.all(Radius.circular(5.w)),
                    ),
                  ),
                ),
                SizedBox(height: 20.w),
                GestureDetector(
                  onTap: () {
                    cancelFunc();
                    cancel?.call();
                  },
                  child: SizedBox(
                    width: 35.w,
                    height: 35.w,
                    child: LocalPNG(name: "ai_alert_close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //系统公告
  static void showAnnounceAlert({
    VoidCallback? cancel,
    VoidCallback? confirm,
    String? text,
  }) {
    var tips = text?.split('#');
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              cancelFunc();
              cancel?.call();
            },
            child: Container(
              decoration: const BoxDecoration(color: Colors.black38),
            ),
          ),
          Positioned(
            child: Center(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 35.w),
                    height: 430.w,
                    child: Stack(
                      children: [
                        LocalPNG(
                          name: 'ai_system_notice',
                          width: ScreenUtil().screenWidth - 70.w,
                          height: (ScreenUtil().screenWidth - 70.w) / 305 * 112,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: (ScreenUtil().screenWidth - 70.w) /
                                      305 *
                                      112 -
                                  2.w),
                          decoration: BoxDecoration(
                              color: StyleTheme.whiteColor,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(15.w),
                                  bottomLeft: Radius.circular(15.w))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 20.w),
                              Expanded(
                                child: SingleChildScrollView(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: tips?.map((e) {
                                            return Utils.getContentSpan(e);
                                          }).toList() ??
                                          [],
                                    )),
                              ),
                              SizedBox(height: 15.w),
                              Container(
                                padding: EdgeInsets.only(
                                  left: StyleTheme.margin,
                                  right: StyleTheme.margin,
                                  bottom: 15.w,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        cancelFunc();
                                        confirm?.call();
                                      },
                                      child: Container(
                                        width: ScreenUtil().screenWidth -
                                            70.w -
                                            StyleTheme.margin * 2,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: StyleTheme.blue52Color,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.w)),
                                        ),
                                        child: Center(
                                            child: RichText(
                                                text: TextSpan(children: [
                                          TextSpan(
                                            text: Utils.txt('quren'),
                                            style: StyleTheme.font_white_255_15,
                                          ),
                                        ]))),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  //版本更新
  static void showUpdateAlert({
    VoidCallback? cancel,
    VoidCallback? confirm,
    VoidCallback? site,
    VoidCallback? guide,
    String? version,
    String? text,
    bool mustupdate = false,
  }) {
    var tips = text?.split('#');
    BotToast.showWidget(
        toastBuilder: (cancelFunc) => Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.black38),
                ),
                Positioned(
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 35.w),
                          height: 440.w,
                          child: Stack(
                            children: [
                              LocalPNG(
                                name: 'ai_update_up_bg',
                                width: ScreenUtil().screenWidth - 70.w,
                                height: (ScreenUtil().screenWidth - 70.w) /
                                    305 *
                                    130,
                                fit: BoxFit.fill,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: (ScreenUtil().screenWidth - 70.w) /
                                            305 *
                                            130 -
                                        2.w),
                                decoration: BoxDecoration(
                                  color: StyleTheme.whiteColor,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15.w),
                                    bottomRight: Radius.circular(15.w),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8.w),
                                    Center(
                                      child: RichText(
                                        text: TextSpan(
                                          text: Utils.txt('fxxbb'),
                                          style: StyleTheme.font_black_31_18,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.w),
                                    Expanded(
                                        child: SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: tips?.map((e) {
                                              return Utils.getContentSpan(e);
                                            }).toList() ??
                                            [],
                                      ),
                                    )),
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: StyleTheme.margin,
                                        right: StyleTheme.margin,
                                      ),
                                      child: Column(children: [
                                        Platform.isAndroid
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        StyleTheme.margin / 2),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () {
                                                      guide?.call();
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          Utils.txt("bbtl"),
                                                          style: StyleTheme
                                                              .font_gray_102_14,
                                                        ),
                                                        Text(
                                                          Utils.txt("gxqbkzn"),
                                                          style:
                                                              StyleTheme.font(
                                                            size: 14,
                                                            color: const Color(
                                                                0xFF5ABBF9),
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              mustupdate
                                                  ? Container()
                                                  : GestureDetector(
                                                      onTap: () {
                                                        if (mustupdate) return;
                                                        cancelFunc();
                                                        cancel?.call();
                                                      },
                                                      child: Container(
                                                        width: 110.w,
                                                        height: 36.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: StyleTheme
                                                              .gray91Color,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          18.w)),
                                                        ),
                                                        child: Center(
                                                            child: RichText(
                                                          text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: Utils.txt(
                                                                      'zbgx'),
                                                                  style: StyleTheme.font(
                                                                      color: StyleTheme
                                                                          .blak7716_07_Color,
                                                                      size: 13),
                                                                ),
                                                              ]),
                                                        )),
                                                      ),
                                                    ),
                                              mustupdate
                                                  ? Container()
                                                  : const Spacer(),
                                              GestureDetector(
                                                onTap: () {
                                                  if (!mustupdate) {
                                                    cancelFunc();
                                                  } else if (mustupdate &&
                                                      Platform.isAndroid) {
                                                    cancelFunc();
                                                  }
                                                  confirm?.call();
                                                },
                                                child: Container(
                                                  width: 110.w,
                                                  height: 36.w,
                                                  padding: EdgeInsets.zero,
                                                  decoration: BoxDecoration(
                                                      color: StyleTheme
                                                          .blue52Color,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  18.w))),
                                                  alignment: Alignment.center,
                                                  child: Center(
                                                      child: RichText(
                                                          text: TextSpan(
                                                              children: [
                                                        TextSpan(
                                                          text:
                                                              Utils.txt('ljgx'),
                                                          style:
                                                              StyleTheme.font(
                                                                  size: 13),
                                                        )
                                                      ]))),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 15.w,
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: GestureDetector(
                                              onTap: () {
                                                site?.call();
                                              },
                                              child: Center(
                                                child: Text(
                                                  Utils.txt('gwgx'),
                                                  style: StyleTheme.font(
                                                    size: 15,
                                                    color:
                                                        const Color(0xFF5ABBF9),
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ));
  }

  static void androidUpdateAlert({
    VoidCallback? cancel,
    String? url = "",
    String? version,
  }) {
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => _DownLoadApk(
        url: url,
        version: version,
        onTap: () {
          cancelFunc();
          cancel?.call();
        },
      ),
    );
  }

  //应用弹窗
  static void showAppAlert(
    List<dynamic> apps, {
    VoidCallback? cancel,
    VoidCallback? confirm,
  }) {
    // apps = List.from(apps)
    //   ..addAll(apps)
    //   ..addAll(apps);
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => GestureDetector(
        onTap: () {
          cancelFunc();
          cancel?.call();
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().screenHeight,
          ),
          width: ScreenUtil().screenWidth,
          decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.3)),
          child: GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LocalPNG(
                //   name: "91_app_top_bg",
                //   width: ScreenUtil().screenWidth - 50.w,
                //   height: (ScreenUtil().screenWidth - 50.w) / 305 * 70,
                // ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25.w),
                  constraints: BoxConstraints(
                      maxHeight: ScreenUtil().screenHeight * 0.59),
                  decoration: BoxDecoration(
                      color: StyleTheme.blackColor.withOpacity(0.8),
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10.w),
                          bottom: Radius.circular(10.w))),
                  // padding:
                  //     EdgeInsets.symmetric(vertical: 20.w, horizontal: 20.w),
                  child: Builder(builder: (context) {
                    int perAppsCount = 6;
                    List tribleColumeApps = apps.length >= perAppsCount
                        ? apps.sublist(0, perAppsCount)
                        : apps;

                    List lasteApps = apps.length >= perAppsCount
                        ? apps.sublist(perAppsCount)
                        : [];

                    double widthDivideBy3 =
                        (ScreenUtil().screenWidth - 120.w) / 3;
                    double widthDivideBy4 =
                        (ScreenUtil().screenWidth - 120.w) / 4;

                    Widget itemWidget(dynamic e,
                        {double width = 100,
                        int fontSize = 10,
                        FontWeight fontWeight = FontWeight.normal}) {
                      return GestureDetector(
                        onTap: () {
                          //上报点击量
                          reqAdClickCount(
                              id: e['report_id'], type: e['report_type']);
                          Utils.openURL(e["link_url"] ?? "");
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width,
                              height: width,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: width * 1,
                                height: width * 1,
                                child: ImageNetTool(
                                  url: e['img_url'],
                                  // CommonUtils.getThumb(e),
                                  radius:
                                      BorderRadius.all(Radius.circular(10.w)),
                                ),
                              ),
                            ),
                            SizedBox(height: 3.w),
                            Text(
                              e["title"] ?? "",
                              style: StyleTheme.font(
                                  size: fontSize, weight: fontWeight),
                            )
                          ],
                        ),
                      );
                    }

                    return RawScrollbar(
                      thumbColor: const Color.fromRGBO(255, 255, 255, 0.4),
                      thickness: 4.w,
                      radius: Radius.circular(2.w),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.w, horizontal: 20.w),
                          child: Column(
                            children: [
                              GridView.count(
                                padding: EdgeInsets.zero,
                                crossAxisCount: 3,
                                mainAxisSpacing: 10.w,
                                crossAxisSpacing: 23.w,
                                childAspectRatio: 1 / 1.34,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: tribleColumeApps
                                    .map((e) => itemWidget(e,
                                        width: widthDivideBy3,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600))
                                    .toList(),
                              ),
                              SizedBox(height: 10.w),
                              GridView.count(
                                padding: EdgeInsets.zero,
                                crossAxisCount: 4,
                                mainAxisSpacing: 10.w,
                                crossAxisSpacing: 10.w,
                                childAspectRatio: 1 / 1.32,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: lasteApps
                                    .map((e) =>
                                        itemWidget(e, width: widthDivideBy4))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20.w),
                GestureDetector(
                  onTap: () {
                    cancelFunc();
                    cancel?.call();
                  },
                  child: SizedBox(
                    width: 35.w,
                    height: 35.w,
                    child: LocalPNG(name: "ai_alert_close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownLoadApk extends StatefulWidget {
  const _DownLoadApk({
    Key? key,
    this.onTap,
    this.url,
    this.version,
  }) : super(key: key);

  final GestureTapCallback? onTap;
  final String? url;
  final String? version;

  @override
  __DownloadApkState createState() => __DownloadApkState();
}

class __DownloadApkState extends State<_DownLoadApk> {
  int progress = 0;

  Future<void> _installApk(savePath) async {
    try {
      await Utils.checkRequestInstallPackages();
      await Utils.checkStoragePermission();
      AppInstaller.installApk(savePath)
          .then((result) {})
          .catchError((error) {});
    } on Exception catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    getExternalStorageDirectory().then((documents) {
      String savePath =
          '${documents?.path}/deepseekk.${DateTime.now().millisecondsSinceEpoch}.apk';
      NetworkHttp.download(widget.url ?? "", savePath,
          onReceiveProgress: (int count, int total) {
        var tmp = (count / total * 100).toInt();
        if (tmp % 1 == 0) {
          setState(() {
            progress = tmp;
          });
        }
        if (count >= total) {
          _installApk(savePath);
        }
      }).catchError((err) {
        BotToast.cleanAll();
        Utils.showText(Utils.txt('xzsb'));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Stack(
        children: [
          Positioned(
              child: Center(
            child: SizedBox(
              width: 345.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.w))),
                    padding:
                        EdgeInsets.symmetric(vertical: 15.w, horizontal: 20.w),
                    child: Column(
                      children: [
                        Text(
                          Utils.txt('zzgx') + " V${widget.version}",
                          style: StyleTheme.font_black_31_18,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Text(
                          Utils.txt('sjlts'),
                          style: StyleTheme.font_gray_102_12,
                          textAlign: TextAlign.left,
                          maxLines: 5,
                        ),
                        SizedBox(
                          height: 25.w,
                        ),
                        SizedBox(
                          width: 185.w,
                          height: 4.w,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.w)),
                                child: Stack(
                                  children: <Widget>[
                                    Opacity(
                                      opacity: 0.3,
                                      child: Container(
                                        width: 185.w,
                                        height: 4.w,
                                        decoration: BoxDecoration(
                                          color: StyleTheme.blue52Color,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.w)),
                                        child: Container(
                                          width: progress / 100 * 185.w,
                                          height: 4.w,
                                          decoration: BoxDecoration(
                                            color: StyleTheme.blue52Color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.w,
                        ),
                        Center(
                          child: Text(
                            '$progress%',
                            style: StyleTheme.font_yellow_255_18,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
