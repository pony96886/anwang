import 'dart:io';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/base/xfile_progresstoast.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ImgLib;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class FacePicMatePage extends BaseWidget {
  FacePicMatePage({Key? key, this.type = 0}) : super(key: key);
  int type;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _FacePicMatePageState();
  }
}

class _FacePicMatePageState extends BaseWidgetState<FacePicMatePage> {
  String title = "";
  String imgURL = "";
  String video = "";
  int kW = 0;
  int kH = 0;
  int id = 0;

  BconfModel? config =
      Provider.of<BaseStore>(AppGlobal.context!, listen: false).conf?.config;
  List<dynamic> array = [];

  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? controller;
  Future? initializeVideoPlayerFuture;

  Future<void> imagePickerAssets() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.pngLimitSize(file);
      if (flag) return;
      uploadFileImg(file);
    } else {
      // User canceled the picker
    }
  }

  void uploadFileImg(XFile? file) async {
    Utils.startGif(tip: Utils.txt('scz'));
    var data;
    if (kIsWeb) {
      data = await NetworkHttp.xfileHtmlUploadImage(
          file: file, position: 'upload');
    } else {
      data = await NetworkHttp.xfileUploadImage(file: file, position: 'upload');
    }
    Utils.closeGif();
    if (data['code'] == 1) {
      var image = ImgLib.decodeImage(await file?.readAsBytes() ?? []);
      imgURL = data['msg'].toString();
      kW = image?.width ?? 100;
      kH = image?.height ?? 100;
      if (mounted) setState(() {});
    } else {
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  //上传视频
  Future<void> imagePickerVideoAssets() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.videoLimitSize(file, size: 50);
      if (flag) return;
      String ext = file.name.split(".").last.toLowerCase();
      if (ext == "mp4" || file.mimeType == 'video/quicktime') {
        uploadVideo(file);
      } else {
        Utils.showText(Utils.txt("qxzmpf"));
      }
    } else {
      // User canceled the picker
    }
  }

  void uploadVideo(XFile? file) {
    BotToast.showCustomLoading(
      backgroundColor: Colors.black54,
      toastBuilder: (cancel) => XFileProgressToast(
        file: file,
        response: (data) {
          BotToast.closeAllLoading();
          if (data.isEmpty) return;
          if (data['code'] == 1) {
            video = data['msg'].toString();
            if (kIsWeb) {
              controller = VideoPlayerController.network(file?.path ?? "");
            } else {
              controller = VideoPlayerController.file(File(file?.path ?? ""));
            }
            initializeVideoPlayerFuture = controller?.initialize();
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

  void uploadData() {
    if (title.isEmpty) {
      Utils.showText(Utils.txt("qsrbt"));
      return;
    }
    if (id == 0) {
      Utils.showText(Utils.txt("qxzfhbq"));
      return;
    }
    if (imgURL.isEmpty) {
      Utils.showText(Utils.txt(widget.type == 0 ? "qxzfwxm" : "scfm"));
      return;
    }
    if (widget.type == 1 && video.isEmpty) {
      Utils.showText(Utils.txt("qxzbmbv")
          .replaceAll("100", "${config?.upload_max ?? 30}"));
      return;
    }

    Utils.startGif(tip: Utils.txt("scz"));
    (widget.type == 0
            ? reqMatePics(
                cate_id: id,
                thumb: imgURL,
                width: kW,
                height: kH,
                title: title,
              )
            : reqMateVideos(
                cate_id: id,
                thumb: imgURL,
                width: kW,
                height: kH,
                title: title,
                video: video,
              ))
        .then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        Utils.showDialog(
            confirmTxt: Utils.txt('quren'),
            setContent: () {
              return Text(
                Utils.txt('qztjcg'),
                style: StyleTheme.font_black_7716_14,
                maxLines: 5,
              );
            },
            confirm: () {
              finish();
            });
        return;
      }
      Utils.showText(value?.msg ?? "", time: 2);
    });
  }

  void setupData() {
    ConfigModel? conf = Provider.of<BaseStore>(context, listen: false).conf;
    array = List.from(
        widget.type == 0 ? (conf?.face_nav ?? []) : (conf?.video_nav ?? []));
    array.removeWhere((el) => el["name"] == Utils.txt('jx'));
    if (mounted) setState(() {});
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('tj'), style: StyleTheme.nav_title_font),
        rightW: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            widget.type = widget.type == 0 ? 1 : 0;
            setupData();
          },
          child: Icon(
            Icons.swap_calls,
            color: StyleTheme.blak7716_07_Color,
            size: 20.w,
          ),
        ));
    setupData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
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
        padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 10.w),
            // Text(
            //   Utils.txt("rzmz"),
            //   style: StyleTheme.font_gray_102_14,
            //   maxLines: 5,
            // ),
            SizedBox(height: 20.w),
            Container(
              height: 40.w,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: StyleTheme.blak7716_07_Color, width: 1.w),
                  borderRadius: BorderRadius.all(Radius.circular(3.w))),
              child: TextField(
                style: StyleTheme.font_black_7716_14,
                decoration: InputDecoration(
                  hintText: Utils.txt('qsrbt'),
                  hintStyle: StyleTheme.font_black_7716_14,
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  title = value;
                },
              ),
            ),
            SizedBox(height: 15.w),
            Container(
              padding: EdgeInsets.all(10.w),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: StyleTheme.blak7716_07_Color, width: 1.w),
                  borderRadius: BorderRadius.all(Radius.circular(3.w))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Utils.txt("qxzfhbq"),
                        style: StyleTheme.font_black_7716_14),
                    SizedBox(height: 10.w),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 15.w,
                      children: array.map((e) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (Utils.unFocusNode(context)) {
                              id = e["id"];
                              if (mounted) setState(() {});
                            }
                          },
                          child: Container(
                            height: 28.w,
                            decoration: BoxDecoration(
                                color: id == e["id"]
                                    ? StyleTheme.blue52Color
                                    : StyleTheme.whiteColor,
                                borderRadius: BorderRadius.circular(15.w)),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  e["name"] ?? "",
                                  style: id == e["id"]
                                      ? StyleTheme.font_white_255_12
                                      : StyleTheme.font_black_7716_06_12,
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
            ),
            SizedBox(height: 15.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(2.w),
              child: DottedBorder(
                dashPattern: const [3, 1],
                strokeWidth: 1.w,
                padding: EdgeInsets.all(1.w),
                borderPadding: EdgeInsets.zero,
                color: StyleTheme.blak7716_07_Color,
                child: Container(
                  width: double.infinity,
                  height: 150.w,
                  decoration: BoxDecoration(color: StyleTheme.whiteColor),
                  child: imgURL.isEmpty
                      ? GestureDetector(
                          onTap: () {
                            if (Utils.unFocusNode(context)) {
                              imagePickerAssets();
                            }
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo,
                                  size: 40.w, color: StyleTheme.blue52Color),
                              SizedBox(height: 5.w),
                              Text(
                                  Utils.txt(
                                      widget.type == 0 ? "qxzbkbp" : "lqxd"),
                                  style:
                                      StyleTheme.font_black_7716_06_11_medium)
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            Center(
                                child: ImageNetTool(
                                    url: AppGlobal.imgBaseUrl + imgURL,
                                    fit: BoxFit.contain)),
                            Positioned(
                              right: 5.w,
                              top: 5.w,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  imgURL = "";
                                  kW = 0;
                                  kH = 0;
                                  if (mounted) setState(() {});
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
            SizedBox(height: widget.type == 0 ? 0.w : 15.w),
            widget.type == 0
                ? Container()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(2.w),
                    child: DottedBorder(
                      dashPattern: const [3, 1],
                      strokeWidth: 1.w,
                      padding: EdgeInsets.all(1.w),
                      borderPadding: EdgeInsets.zero,
                      color: StyleTheme.blak7716_07_Color,
                      child: Container(
                        width: double.infinity,
                        height: 150.w,
                        decoration: BoxDecoration(color: StyleTheme.whiteColor),
                        child: video.isEmpty
                            ? GestureDetector(
                                onTap: () {
                                  if (Utils.unFocusNode(context)) {
                                    imagePickerVideoAssets();
                                  }
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo,
                                        size: 40.w,
                                        color: StyleTheme.blue52Color),
                                    SizedBox(height: 5.w),
                                    Text(
                                        Utils.txt("qxzbmbv")
                                            .replaceAll("2048", "50"),
                                        style: StyleTheme
                                            .font_black_7716_06_11_medium)
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  Center(
                                      child: FutureBuilder(
                                    //显示缩略图
                                    future: initializeVideoPlayerFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return AspectRatio(
                                          aspectRatio:
                                              controller!.value.aspectRatio,
                                          child: Stack(
                                            children: [
                                              VideoPlayer(controller!),
                                              Center(
                                                child: LocalPNG(
                                                  name: "ai_play_n",
                                                  width: 30.w,
                                                  height: 30.w,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor:
                                                StyleTheme.blue52Color,
                                          ),
                                        );
                                      }
                                    },
                                  )),
                                  Positioned(
                                    right: 5.w,
                                    top: 5.w,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        video = "";
                                        if (mounted) setState(() {});
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
            SizedBox(height: 30.w),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (Utils.unFocusNode(context)) {
                  uploadData();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    gradient: StyleTheme.gradBlue,
                    borderRadius: BorderRadius.all(Radius.circular(4.w))),
                height: 40.w,
                alignment: Alignment.center,
                child: Text(Utils.txt('srhffm'),
                    style: StyleTheme.font_white_255_15),
              ),
            ),
            SizedBox(height: 50.w),
          ],
        ),
      ),
    );
  }
}
