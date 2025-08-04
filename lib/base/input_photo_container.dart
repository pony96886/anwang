import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:deepseek/base/xfile_progresstoast.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ImgLib;
import 'package:video_player/video_player.dart';

//带图片、视频的输入框
class InputPhotoContainer extends StatefulWidget {
  InputPhotoContainer({
    Key? key,
    this.child,
    this.onEditingCompleteText,
    this.onSelectPicComplete,
    this.onOutEventComplete,
    this.onCollectEventComplete,
    this.labelText,
    this.bg = Colors.white,
    this.focusNode,
    this.isCollect = false,
    this.isMedia = false,
  }) : super(key: key);

  final bool isCollect;
  final Color bg;
  final Widget? child;
  final String? labelText;
  final TextEditingController controller = TextEditingController();
  final Function? onEditingCompleteText;
  final Function? onSelectPicComplete;
  final Function? onOutEventComplete;
  final Function? onCollectEventComplete;
  final FocusNode? focusNode;
  final bool isMedia;

  @override
  State<InputPhotoContainer> createState() => _InputPhotoContainerState();
}

class _InputPhotoContainerState extends State<InputPhotoContainer> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? controller;
  Future? initializeVideoPlayerFuture;
  bool isPhoto = true;
  bool showKeyBoard = false;
  int limit = 3;
  List<Map<String, dynamic>> medias = [];

  bool getFocusBool() {
    return kIsWeb
        ? showKeyBoard && widget.isMedia
        : (widget.focusNode?.hasFocus ?? false) && widget.isMedia;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                widget.onOutEventComplete?.call();
                showKeyBoard = false;
                Utils.unFocusNode(context);
              },
              child: widget.child ?? Container(),
            ),
          ),
          Divider(
            height: 0.5.w,
            color: StyleTheme.devideLineColor,
          ),
          Container(
            color: widget.bg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.w),
                Row(
                  children: [
                    SizedBox(width: StyleTheme.margin),
                    Expanded(
                        child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(StyleTheme.margin),
                            decoration: BoxDecoration(
                              color: StyleTheme.gray244Color,
                              borderRadius: getFocusBool()
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(5.w),
                                      topRight: Radius.circular(5.w))
                                  : BorderRadius.all(Radius.circular(5.w)),
                            ),
                            child: TextField(
                              focusNode: widget.focusNode,
                              controller: widget.controller,
                              style: StyleTheme.font_black_31_14,
                              cursorColor: StyleTheme.blue52Color,
                              decoration: InputDecoration(
                                hintText: widget.labelText,
                                hintStyle: StyleTheme.font_black_7716_14,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: const OutlineInputBorder(
                                  gapPadding: 0,
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                              minLines: 1,
                              maxLines: 3,
                              onTap: () {
                                showKeyBoard = true;
                                FocusScope.of(context)
                                    .requestFocus(widget.focusNode);
                                if (mounted) setState(() {});
                              },
                              onSubmitted: (_) {},
                            )),
                        getFocusBool()
                            ? Builder(
                                builder: (context) {
                                  double w = (ScreenUtil().screenWidth -
                                          70.w -
                                          StyleTheme.margin * 3 -
                                          30.w) /
                                      4;
                                  return Container(
                                    height: w + 10.w,
                                    decoration: BoxDecoration(
                                      color: StyleTheme.gray244Color,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(5.w),
                                          bottomRight: Radius.circular(5.w)),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: StyleTheme.margin, bottom: 10.w),
                                    child: GridView.count(
                                        crossAxisSpacing: 10.w,
                                        mainAxisSpacing: 10.w,
                                        crossAxisCount: 4,
                                        childAspectRatio: 1,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: medias.map<Widget>((e) {
                                          return SizedBox(
                                            width: w,
                                            height: w,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                    left: 0,
                                                    bottom: 0,
                                                    child: SizedBox(
                                                      width: w - 10.w,
                                                      height: w - 10.w,
                                                      child: e['type'] == 1
                                                          ? ImageNetTool(
                                                              url: e['cover'] ??
                                                                  '')
                                                          : FutureBuilder(
                                                              //显示缩略图
                                                              future:
                                                                  initializeVideoPlayerFuture,
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (snapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .done) {
                                                                  e["thumb_width"] =
                                                                      controller!
                                                                          .value
                                                                          .size
                                                                          .width
                                                                          .round();
                                                                  e["thumb_height"] =
                                                                      controller!
                                                                          .value
                                                                          .size
                                                                          .height
                                                                          .round();
                                                                  return Stack(
                                                                    children: [
                                                                      Center(
                                                                        child:
                                                                            AspectRatio(
                                                                          aspectRatio: controller!
                                                                              .value
                                                                              .aspectRatio,
                                                                          child:
                                                                              VideoPlayer(controller!),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                          child: LocalPNG(
                                                                              name: 'ai_play_n',
                                                                              width: 20.w,
                                                                              height: 20.w))
                                                                    ],
                                                                  );
                                                                } else {
                                                                  return Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          1.w,
                                                                      backgroundColor:
                                                                          StyleTheme
                                                                              .blue52Color,
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                    )),
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () {
                                                      medias.remove(e);
                                                      if (mounted) {
                                                        setState(() {});
                                                      }
                                                    },
                                                    child: LocalPNG(
                                                      name: "ai_post_delete",
                                                      width: 15.w,
                                                      height: 15.w,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        }).toList()
                                          ..add(medias.length == limit
                                              ? const SizedBox.shrink()
                                              : GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  onTap: () {
                                                    if (isPhoto) {
                                                      imagePickerAssets();
                                                    } else {
                                                      imagePickerVideoAssets();
                                                    }
                                                    showKeyBoard = false;
                                                    widget.focusNode?.unfocus();
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: StyleTheme
                                                                .blak7716_07_Color,
                                                            width: 1.w),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    3.w))),
                                                    child: Icon(
                                                        Icons.add_a_photo,
                                                        size: 15.w,
                                                        color: StyleTheme
                                                            .blak7716_07_Color),
                                                  ),
                                                ))),
                                  );
                                },
                              )
                            : Container()
                      ],
                    )),
                    SizedBox(width: StyleTheme.margin),
                    Column(
                      children: [
                        getFocusBool()
                            ? Container(
                                padding: EdgeInsets.only(bottom: 15.w),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        isPhoto = true;
                                        limit = isPhoto ? 3 : 1;
                                        medias = [];
                                        if (mounted) setState(() {});
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                              isPhoto
                                                  ? Icons.check_box
                                                  : Icons
                                                      .check_box_outline_blank,
                                              size: 15.w,
                                              color: isPhoto
                                                  ? StyleTheme.blue52Color
                                                  : StyleTheme
                                                      .blak7716_07_Color),
                                          SizedBox(width: 2.w),
                                          Text(Utils.txt('tppl'),
                                              style:
                                                  StyleTheme.font_gray_153_13),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5.w),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        isPhoto = false;
                                        limit = isPhoto ? 3 : 1;
                                        medias = [];
                                        if (mounted) setState(() {});
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                              !isPhoto
                                                  ? Icons.check_box
                                                  : Icons
                                                      .check_box_outline_blank,
                                              size: 15.w,
                                              color: !isPhoto
                                                  ? StyleTheme.blue52Color
                                                  : StyleTheme
                                                      .blak7716_07_Color),
                                          SizedBox(width: 2.w),
                                          Text(Utils.txt('sppl'),
                                              style:
                                                  StyleTheme.font_gray_153_13),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                showKeyBoard = false;
                                Utils.unFocusNode(context);
                                widget.onCollectEventComplete?.call();
                              },
                              child: LocalPNG(
                                name: widget.isCollect
                                    ? "ai_collect_h"
                                    : "ai_collect_n",
                                width: 26.w,
                                height: 26.w,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                showKeyBoard = false;
                                Utils.unFocusNode(context);
                                widget.onEditingCompleteText?.call(
                                    widget.controller.text,
                                    json.encode(medias));
                                widget.controller.text = "";
                                medias = [];
                              },
                              child: LocalPNG(
                                name: "ai_mine_send",
                                width: 30.w,
                                height: 30.w,
                              ),
                            ),
                            SizedBox(width: 1.w),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: StyleTheme.margin),
                  ],
                ),
                SizedBox(height: 10.w),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> imagePickerAssets() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.pngLimitSize(file);
      if (flag) return;
      uploadFileImg(file);
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
    Utils.log(data);
    Utils.closeGif();
    if (data['code'] == 1) {
      var image = ImgLib.decodeImage(await file?.readAsBytes() ?? []);
      String orgURL = data['msg'] ?? '';
      medias.add({
        'media_url': orgURL,
        'cover': AppGlobal.imgBaseUrl + orgURL,
        'thumb_width': image?.width ?? 100,
        'thumb_height': image?.height ?? 100,
        'type': 1,
      });
      showKeyBoard = true;
      FocusScope.of(context).requestFocus(widget.focusNode);
    } else {
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  //上传视频
  Future<void> imagePickerVideoAssets() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.videoLimitSize(file);
      if (flag) return;
      String ext = file.name.split(".").last.toLowerCase();
      if (ext == "mp4" || file.mimeType == 'video/quicktime') {
        uploadVideo(file);
      } else {
        Utils.showText(Utils.txt("qxzmpf"));
      }
    }
  }

  void uploadVideo(XFile? file) {
    BotToast.showCustomLoading(
      backgroundColor: Colors.black.withOpacity(0.7),
      toastBuilder: (cancel) => XFileProgressToast(
        file: file,
        response: (data) {
          BotToast.closeAllLoading();
          if (data.isEmpty) return;
          if (data['code'] == 1) {
            String orgURL = data['msg'] ?? '';
            if (kIsWeb) {
              controller = VideoPlayerController.network(file?.path ?? '');
            } else {
              controller = VideoPlayerController.file(File(file?.path ?? ''));
            }
            initializeVideoPlayerFuture = controller?.initialize();
            medias.add({
              'media_url': orgURL,
              'cover': '',
              'thumb_width': 1600,
              'thumb_height': 900,
              'type': 2,
            });
            showKeyBoard = true;
            FocusScope.of(context).requestFocus(widget.focusNode);
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
}
