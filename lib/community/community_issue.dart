import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/base/xfile_progresstoast.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/util/xfile_multipart_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image/image.dart' as imgLib;
import 'package:deepseek/util/platform_utils_native.dart'
    if (dart.library.html) 'package:deepseek/util/platform_utils_web.dart'
    as ui;

class CommunityIssue extends BaseWidget {
  CommunityIssue({Key? key, this.type = 0}) : super(key: key);
  final int type; //0发布图片 1发布视频 2发布图文

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _CommunityIssueState();
  }
}

class _CommunityIssueState extends BaseWidgetState<CommunityIssue> {
  Map setLabel = {};
  List<dynamic> labels = [];
  VideoPlayerController? controller;
  Future? initializeVideoPlayerFuture;
  var discrip;
  String title = '';
  String content = '';
  String coins = '0';
  String contact = '';

  int picLimit = 9;
  int videoLimit = 1;
  List<Map> upList = [];
  Map video = {};

  int money = 0;
  int aipay = 0;
  int isOpen = 1;

  final ImagePicker picker = ImagePicker();

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
      titleW: Text(Utils.txt("fbtz"), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          uploadData();
        },
        child: Container(
          decoration: BoxDecoration(
            color: StyleTheme.blue52Color,
            borderRadius: BorderRadius.all(Radius.circular(14.w)),
          ),
          height: 28.w,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Center(
            child: Text(
              Utils.txt("fb"),
              style: StyleTheme.font_white_255_14,
            ),
          ),
        ),
      ),
    );
    money = Provider.of<BaseStore>(context, listen: false).user?.money ?? 0;
    aipay =
        Provider.of<BaseStore>(context, listen: false).conf?.config?.pay_ai ??
            0;
    discrip = UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == 'tagsall') {
        setLabel = event.arg["data"];
        Utils.log(setLabel);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    discrip.cancel();
  }

  Future<void> imagePickerVideoAssets() async {
    Utils.pickerVideoAssets(picker: picker).then((file) {
      if (file != null) {
        uploadVideo(file);
      }
    });
  }

  void uploadVideo(Object file) {
    BotToast.showCustomLoading(
      backgroundColor: Colors.black.withOpacity(0.7),
      toastBuilder: (cancel) => XfileMultipartToast(
        //XFileProgressToast改用分片上传方法XfileMultipartToast
        file: file,
        response: (data) {
          BotToast.closeAllLoading();
          if (data['code'] == 1) {
            String url = data['msg'].toString();
            initializeVideoPlayerFuture =
                ui.platformViewRegistry.videoThumbnail(file);
            video = {
              "media_url": url,
              "thumb_width": 1600,
              "thumb_height": 900,
            };
            if (mounted) setState(() {});
          } else {
            Utils.showText(data['msg'] ?? "failed");
          }
        },
        cancel: () {
          BotToast.closeAllLoading();
        },
      ),
    );
  }

  Future<void> imagePickerAssets() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.pngLimitSize(file);
      if (flag) return;
      uploadPNG(file);
    }
  }

  void uploadPNG(XFile file) async {
    Utils.startGif(tip: Utils.txt('scz'));
    var data;
    if (kIsWeb) {
      data = await NetworkHttp.xfileHtmlUploadImage(
          file: file, position: 'upload');
    } else {
      data = await NetworkHttp.xfileUploadImage(file: file, position: 'upload');
    }
    BotToast.closeAllLoading();
    if (data['code'] == 1) {
      String url = data['msg'].toString();
      var image = imgLib.decodeImage(await file.readAsBytes());
      upList.add({
        "media_url": url,
        "url": AppGlobal.imgBaseUrl + url,
        "thumb_width": image?.width ?? 100,
        "thumb_height": image?.height ?? 100,
      });
      if (mounted) setState(() {});
    } else {
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  void uploadData() {
    List<Map> tp = List.from(upList);
    if (setLabel.isEmpty) {
      Utils.showText(Utils.txt("xzht"));
      return;
    }
    if (title.isEmpty) {
      Utils.showText(Utils.txt("qtxxbt"));
      return;
    }
    if (widget.type == 0) {
      if (upList.isEmpty) {
        Utils.showText(Utils.txt("qsctp"));
        return;
      }
    }
    if (widget.type == 1) {
      if (setLabel['type'] == 1 && contact.isEmpty) {
        Utils.showText(Utils.txt("srlxfs"));
        return;
      }
      if (upList.isEmpty) {
        Utils.showText(Utils.txt("qsctp"));
        return;
      }
      if (video.isEmpty && setLabel['is_ai'] != 1 && setLabel['type'] != 1) {
        Utils.showText(Utils.txt("qscsp"));
        return;
      }
      //设置默认第一张图为封面
      int index = upList.indexWhere((el) => el['media_url'].contains('.mp4'));
      if (index == -1 && video.isNotEmpty) {
        tp.add(video);
      }
    }
    if (widget.type == 2) {
      if (content.isEmpty) {
        Utils.showText(Utils.txt("qtxnrong"));
        return;
      }
    }

    Utils.startGif();
    reqPublishPost(
      context,
      topic_id: setLabel["id"].toString(),
      title: title,
      content: content,
      medias: json.encode(tp),
      coins: coins,
      is_public: isOpen,
      money: money - aipay,
      contact: contact,
    ).then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        Utils.showDialog(
          confirmTxt: Utils.txt('quren'),
          setContent: () {
            return Text(
              Utils.txt("fbcgdsh"),
              style: StyleTheme.font_gray_153_13,
              maxLines: 10,
            );
          },
          confirm: () {
            finish();
          },
        );
      } else {
        Utils.showText(value?.msg ?? '');
      }
    });
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Utils.unFocusNode(context);
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding:
            EdgeInsets.symmetric(vertical: 20.w, horizontal: StyleTheme.margin),
        child: Column(
          children: [
            setLabel['is_ai'] == 1
                ? Padding(
                    padding: EdgeInsets.only(bottom: 20.w),
                    child: Text(
                      Utils.txt('mtxq')
                          .replaceAll("00", setLabel['name'])
                          .replaceAll("11", "$aipay"),
                      style: StyleTheme.font_blue52_14,
                      maxLines: 5,
                    ),
                  )
                : Container(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Utils.navTo(context,
                    "/communityseltagpage/${setLabel['id'] ?? 0}/${widget.type == 1 ? 0 : 1}");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                height: 50.w,
                decoration: BoxDecoration(
                  color: StyleTheme.whiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        setLabel.isEmpty
                            ? "#${Utils.txt("xzht")}"
                            : "#${setLabel["name"]}",
                        style: setLabel.isEmpty
                            ? StyleTheme.font_black_7716_04_14
                            : StyleTheme.font_black_7716_14),
                    Icon(Icons.keyboard_arrow_right_outlined,
                        size: 20.w, color: StyleTheme.blak7716_07_Color),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.w),
            SizedBox(
              height: 40.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                ),
                child: TextField(
                  autofocus: false,
                  onChanged: (value) {
                    title = value;
                  },
                  style: StyleTheme.font_black_7716_14,
                  cursorColor: StyleTheme.blue52Color,
                  textInputAction: TextInputAction.done,
                  decoration: Utils.customInputStyle(),
                ),
              ),
            ),
            SizedBox(height: 20.w),
            widget.type == 1
                ? Column(
                    children: [
                      SizedBox(
                        height: 150.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.w)),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 10,
                            autofocus: false,
                            onChanged: (value) {
                              content = value;
                            },
                            style: StyleTheme.font_black_7716_14,
                            cursorColor: StyleTheme.blue52Color,
                            textInputAction: TextInputAction.done,
                            decoration: Utils.customInputStyle(
                              hit: "[${Utils.txt('xutie')}]" +
                                  Utils.txt('qtxnrong'),
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.w),
                      setLabel['is_ai'] == 1
                          ? SizedBox(
                              height: 40.w,
                              child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: StyleTheme.gray235Color,
                                        width: 0.5.w),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.w)),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        Utils.txt('sffbmzxx') + "：",
                                        style: StyleTheme.font_black_7716_14,
                                      ),
                                      SizedBox(width: 10.w),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          isOpen = 1;
                                          if (mounted) setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              Utils.txt('qwmzxx'),
                                              style:
                                                  StyleTheme.font_black_7716_14,
                                            ),
                                            SizedBox(width: 2.w),
                                            Icon(
                                              isOpen == 1
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              size: 16.w,
                                              color: isOpen == 1
                                                  ? StyleTheme.blue52Color
                                                  : StyleTheme
                                                      .blak7716_07_Color,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          isOpen = 0;
                                          if (mounted) setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              Utils.txt('qwmzsm'),
                                              style:
                                                  StyleTheme.font_black_7716_14,
                                            ),
                                            SizedBox(width: 2.w),
                                            Icon(
                                              isOpen == 0
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              size: 16.w,
                                              color: isOpen == 0
                                                  ? StyleTheme.blue52Color
                                                  : StyleTheme
                                                      .blak7716_07_Color,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )))
                          : SizedBox(
                              height: 40.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.w)),
                                ),
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp("[0-9]"),
                                        allow: true),
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  style: StyleTheme.font_black_7716_14,
                                  cursorColor: StyleTheme.blue52Color,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (value) {
                                    coins = value.isEmpty ? '0' : value;
                                  },
                                  decoration: Utils.customInputStyle(
                                      hit: Utils.txt(setLabel['type'] == 1
                                          ? 'szjsjg'
                                          : 'szspjg')),
                                ),
                              ),
                            ),
                      setLabel['type'] == 1
                          ? Column(
                              children: [
                                SizedBox(height: 20.w),
                                SizedBox(
                                  height: 40.w,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.w)),
                                    ),
                                    child: TextField(
                                      style: StyleTheme.font_black_7716_14,
                                      cursorColor: StyleTheme.blue52Color,
                                      textInputAction: TextInputAction.done,
                                      onChanged: (value) {
                                        contact = value;
                                      },
                                      decoration: Utils.customInputStyle(
                                          hit: Utils.txt('srlxfs')),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : const SizedBox()
                    ],
                  )
                : widget.type == 2
                    ? SizedBox(
                        height: 150.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.w)),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 10,
                            minLines: 1,
                            autofocus: false,
                            onChanged: (value) {
                              content = value;
                            },
                            style: StyleTheme.font_black_7716_14,
                            cursorColor: StyleTheme.blue52Color,
                            textInputAction: TextInputAction.done,
                            decoration: Utils.customInputStyle(
                                hit: Utils.txt('qtxnrong')),
                          ),
                        ),
                      )
                    : Container(),
            widget.type == 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      RichText(
                          maxLines: 2,
                          text: TextSpan(children: [
                            TextSpan(
                                text: Utils.txt("sctp"),
                                style: StyleTheme.font_black_7716_14_blod),
                            TextSpan(
                                text: " " + Utils.txt("zdjzbkb"),
                                style: StyleTheme.font_gray_153_12)
                          ])),
                      SizedBox(height: 10.w),
                      GridView.count(
                        padding: EdgeInsets.zero,
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                        children: upList.map((e) {
                          Widget w = Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 9.w, right: 9.w),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                  ),
                                  child: ImageNetTool(
                                    fit: BoxFit.contain,
                                    url: e["url"] ?? '',
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    upList.remove(e);
                                    if (mounted) setState(() {});
                                  },
                                  child: LocalPNG(
                                    name: "ai_post_delete",
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                ),
                              )
                            ],
                          );
                          return w;
                        }).toList()
                          ..add(
                            upList.length == picLimit
                                ? Container()
                                : GestureDetector(
                                    onTap: imagePickerAssets,
                                    child: LocalPNG(name: "ai_post_add"),
                                  ),
                          ),
                      ),
                      SizedBox(height: 20.w),
                      Row(
                        children: [
                          Text(
                            Utils.txt("scsp"),
                            style: StyleTheme.font_black_7716_14_blod,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            Utils.txt("zdybm"),
                            style: StyleTheme.font_gray_153_12,
                          )
                        ],
                      ),
                      SizedBox(height: 10.w),
                      GridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 10.w,
                          children: [
                            Container(
                              color: Colors.transparent,
                              child: Stack(
                                children: [
                                  Center(
                                      child: video.isNotEmpty
                                          ? Stack(
                                              children: [
                                                Center(
                                                  child: FutureBuilder(
                                                    //显示缩略图
                                                    future:
                                                        initializeVideoPlayerFuture,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        return Stack(
                                                          children: [
                                                            Positioned.fill(
                                                              child: ImageNetTool(
                                                                  bytes: snapshot
                                                                      .data),
                                                            ),
                                                            Center(
                                                              child: LocalPNG(
                                                                name:
                                                                    'ai_play_n',
                                                                width: 20.w,
                                                                height: 20.w,
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      } else {
                                                        return Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 1.w,
                                                            backgroundColor:
                                                                StyleTheme
                                                                    .blue52Color,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () {
                                                      video = {};
                                                      upList.removeWhere((el) =>
                                                          el['media_url']
                                                              .contains(
                                                                  '.mp4'));
                                                      if (mounted)
                                                        setState(() {});
                                                    },
                                                    child: LocalPNG(
                                                      name: "ai_post_delete",
                                                      width: 18.w,
                                                      height: 18.w,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          : GestureDetector(
                                              onTap: imagePickerVideoAssets,
                                              child:
                                                  LocalPNG(name: "ai_post_add"),
                                            )),
                                ],
                              ),
                            )
                          ]),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(height: 20.w),
                      Row(
                        children: [
                          Text(
                            Utils.txt("sctp"),
                            style: StyleTheme.font_black_7716_14_blod,
                          ),
                          SizedBox(width: 10.w),
                          Text(Utils.txt("zdjzbkb"),
                              style: StyleTheme.font_gray_153_12)
                        ],
                      ),
                      SizedBox(height: 10.w),
                      GridView.count(
                        padding: EdgeInsets.zero,
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                        children: upList.map((e) {
                          Widget w = Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 9.w, right: 9.w),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                  ),
                                  child: ImageNetTool(
                                      fit: BoxFit.contain, url: e["url"]),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    upList.remove(e);
                                    if (mounted) setState(() {});
                                  },
                                  child: LocalPNG(
                                    name: "ai_post_delete",
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                ),
                              )
                            ],
                          );
                          return w;
                        }).toList()
                          ..add(
                            upList.length == picLimit
                                ? Container()
                                : GestureDetector(
                                    onTap: imagePickerAssets,
                                    child: LocalPNG(name: "ai_post_add"),
                                  ),
                          ),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
