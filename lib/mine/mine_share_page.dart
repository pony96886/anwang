import 'dart:io';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MineSharePage extends BaseWidget {
  MineSharePage({Key? key}) : super(key: key);

  @override
  _MineSharePageState cState() => _MineSharePageState();
}

class _MineSharePageState extends BaseWidgetState<MineSharePage> {
  GlobalKey rootWidgetKey = GlobalKey();
  bool isSaving = false;

  UserModel? user;
  int userInviteNumber = 0; // 用户邀请数量
  dynamic _data;

  _loadUserAgentData() async {
    // ResponseModel<dynamic>? res = await getProxyDetail({});
    // if (res.status == 1) {
    //   userInviteNumber = res.data['direct_proxy_num'];
    //   _data = res.data;

    //   if (mounted) {
    //     setState(() {});
    //   }
    // } else {
    //   // userInviteNumber = 0;
    //   // setState(() {});
    // }
  }

  _saveImgShare() async {
    if (kIsWeb) {
      Utils.showText(Utils.txt('zxjt'));
      setState(() {
        isSaving = false;
      });
    } else {
      PermissionStatus storageStatus = await Permission.camera.status;
      if (storageStatus == PermissionStatus.denied) {
        storageStatus = await Permission.camera.request();
        if (storageStatus == PermissionStatus.denied ||
            storageStatus == PermissionStatus.permanentlyDenied) {
          Utils.showText(
            Utils.txt('qdkqx'),
          );
          setState(() {
            isSaving = false;
          });
        } else {
          localStorageImage();
        }
        return;
      } else if (storageStatus == PermissionStatus.permanentlyDenied) {
        Utils.showText(
          Utils.txt('wfbc'),
        );
        setState(() {
          isSaving = false;
        });
        return;
      }
      localStorageImage();
    }
  }

  void localStorageImage() async {
    RenderRepaintBoundary boundary = rootWidgetKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final result =
        await ImageGallerySaverPlus.saveImage(pngBytes); //这个是核心的保存图片的插件
    if (result['isSuccess']) {
      Utils.showText(
        Utils.txt('xxcgwd'),
      );
    } else if (Platform.isAndroid) {
      if (result.length > 0) {
        Utils.showText(
          Utils.txt('xxcgwd'),
        );
      }
    }
    isSaving = false;
    if (mounted) setState(() {});
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement initState
    user = Provider.of<BaseStore>(context, listen: false).user;
    _loadUserAgentData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  //复制链接分享
  void _copyLinkShare() {
    Utils.copyToClipboard('${user?.share?.share_text}', showToast: true, tip: Utils.txt('fzcgqxz'));
  }

  List textsWithMiddleKey({String text = '', String key = ''}) {
    var results = text.split(key);
    List list = [];
    for (var i = 0; i < results.length; i++) {
      list.add({'type': 0, 'word': results[i]});
      if (i != results.length - 1) {
        list.add({'type': 1, 'word': key});
      }
    }
    return list;
  }

  List textsWithList(List inputList, String key) {
    List list = [];
    for (var item in inputList) {
      if (item['type'] == 1) {
        list.add(item);
      } else {
        list.addAll(textsWithMiddleKey(text: item['word'], key: key));
      }
    }
    return list;
  }

  @override
  Widget pageBody(BuildContext context) {
    BconfModel? config =
        Provider.of<BaseStore>(context, listen: false).conf?.config;
    return Stack(
      children: [
        Positioned(
          child: Center(
            child: SizedBox(
              width: 375.w,
              height: 667.w,
              child: RepaintBoundary(
                key: rootWidgetKey,
                child: Stack(
                  children: [
                    Positioned.fill(
                      // top: 0
                      child: LocalPNG(
                        name: 'ai_mine_share_pic_bg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                        left: 20.w,
                        top: 13.w,
                        child: LocalPNG(
                          name: 'ai_mine_share_logo',
                          width: 170.w,
                          height: 54.w,
                        )),
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 190.w,
                            ),
                            SizedBox(
                              width: 315.w,
                              height: 369.w,
                              // padding: EdgeInsets.symmetric(horizontal: 20.w),
                              // color: Colors.red,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: LocalPNG(
                                          name: 'ai_mine_share_code_bg_1')),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 106.w,
                                      ),
                                      Container(
                                        width: 183.w,
                                        height: 183.w,
                                        // padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                            color: Colors.white
                                                .withAlpha((0.2 * 255).toInt()),
                                            borderRadius: BorderRadius.all(
                                                ui.Radius.circular(10.w))),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                                child: LocalPNG(
                                                    // width: 183.w,
                                                    // height: 183.w,
                                                    name:
                                                        'ai_mine_share_pic_code_frame')),
                                            Positioned.fill(
                                              child: Container(
                                                alignment: Alignment.center,
                                                // color: Colors.white,
                                                child: QrImage(
                                                  data:
                                                      '${user?.share?.share_url}',
                                                  version: 3,
                                                  size: 160.w,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 60.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              Utils.txt('apwd') +
                                                  Utils.txt('tgm'),
                                              style:
                                                  StyleTheme.font_black_31_20,
                                            ),
                                            Text(
                                              user?.share?.aff_code as String,
                                              style:
                                                  StyleTheme.font_yellow_255_25,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 104.w,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 2.w),
                                  Text(
                                    Utils.txt('gwdz') +
                                        '：${config?.office_site}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.none,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.normal),
                                    textAlign: ui.TextAlign.center,
                                  ),
                                  SizedBox(height: ScreenUtil().setWidth(11)),
                                  RichText(
                                      maxLines: 3,
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: Utils.txt('qwsy1'),
                                            style: StyleTheme.font_blue_52_12),
                                        TextSpan(
                                            text: Utils.txt('qwsy2'),
                                            style:
                                                StyleTheme.font_white_255_12),
                                        TextSpan(
                                            text: Utils.txt('qwsy3'),
                                            style: StyleTheme.font_blue_52_12),
                                        TextSpan(
                                            text: Utils.txt('qwsy4'),
                                            style:
                                                StyleTheme.font_white_255_12),
                                        TextSpan(
                                            text: Utils.txt('qwsy5'),
                                            style: StyleTheme.font_blue_52_12),
                                        TextSpan(
                                            text: Utils.txt('qwsy6'),
                                            style:
                                                StyleTheme.font_white_255_12),
                                      ])),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: true,
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenHeight,
                color: StyleTheme.bgColor,
              )),
              // Positioned(
              //     child: LocalPNG(
              //   name: 'ai_mine_topbg',
              //   width: ScreenUtil().screenWidth,
              //   height: 337.w,
              // )),
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: StyleTheme.navHegiht +
                                StyleTheme.topHeight +
                                20.w),
                        SizedBox(
                          width: 325.w,
                          height: 355.w,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                  child: LocalPNG(
                                name: 'ai_mine_share_code_background',
                                fit: BoxFit.fill,
                              )),
                              Positioned(
                                top: 20.w,
                                left: 0,
                                right: 0,
                                child: Text(
                                  Utils.txt('apbt'),
                                  style: StyleTheme.font_white_255_19_medium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                top: 50.w,
                                left: 0,
                                right: 0,
                                child: Text(
                                  Utils.txt('apbtdsc'),
                                  style: StyleTheme.font_white_255_04_14,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                bottom: 30.w,
                                left: 0,
                                right: 0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 146.w,
                                      height: 146.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: const Color.fromRGBO(
                                                255, 102, 0, 1),
                                            width: 1.w),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.w)),
                                      ),
                                      padding: EdgeInsets.all(5.w),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: QrImage(
                                          data: '${user?.share?.share_url}',
                                          version: 3,
                                          size: 136.w,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.w),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Utils.txt('apwd') +
                                              Utils.txt('tgm') +
                                              '：',
                                          style: StyleTheme
                                              .font_white_255_17_medium,
                                        ),
                                        Text(
                                          user?.share?.aff_code as String,
                                          style: StyleTheme
                                              .font_white_255_17_medium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 34.w),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ActionShareButton(
                                  text: Utils.txt('bctp'),
                                  onTap: isSaving
                                      ? null
                                      : () {
                                          isSaving = true;
                                          setState(() {});
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) {
                                            _saveImgShare();
                                          });
                                        },
                                  isLoadding: isSaving,
                                ),
                                SizedBox(height: 10.w),
                                ActionShareButton(
                                  text: Utils.txt('fzlj'),
                                  onTap: _copyLinkShare,
                                  isLoadding: false,
                                  image: null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30.w),
                        Text(
                          '邀请步骤',
                          style: StyleTheme.font_black_7716_20_medium,
                        ),
                        LocalPNG(
                          name: 'ai_mine_share_progress',
                          width: 272.7.w,
                          height: 522.3.w,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(height: 20.w),
                      ]),
                ),
              ),
              Container(
                color: Colors.transparent,
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  height: StyleTheme.navHegiht,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: SizedBox(
                            height: double.infinity,
                            child: LocalPNG(
                              name: "ai_nav_back_w",
                              width: 17.w,
                              height: 17.w,
                              fit: BoxFit.contain,
                            )),
                        onTap: () {
                          context.pop();
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          Utils.navTo(context, "/mineagentinviterecordpage");
                        },
                        child: Text(
                          Utils.txt('yqjl'),
                          style: StyleTheme.font_gray_153_13,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ActionShareButton extends StatelessWidget {
  final String? text;
  final GestureTapCallback? onTap;
  final bool isLoadding;
  final AssetImage? image;
  const ActionShareButton(
      {Key? key,
      this.text = '',
      required this.onTap,
      required this.isLoadding,
      this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165.w,
        height: 40.w,
        decoration: image == null
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20.w),
                color: StyleTheme.blue52Color)
            : BoxDecoration(image: DecorationImage(image: image!)),
        child: Center(
          child: isLoadding
              ? SizedBox(
                  width: ScreenUtil().setWidth(23),
                  height: ScreenUtil().setWidth(23),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: StyleTheme.blak7716_07_Color,
                  ))
              : Text(
                  text!,
                  style: StyleTheme.font_white_255_15_medium,
                ),
        ),
      ),
    );
  }
}
