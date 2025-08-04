import 'dart:io';

import 'package:deepseek/util/cache/cache_manager.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:convert' as convert;

class PreviewViewPage extends StatefulWidget {
  PreviewViewPage({Key? key, this.url = ""}) : super(key: key);
  String url;

  @override
  _HomePreviewViewPageState createState() => _HomePreviewViewPageState();
}

class _HomePreviewViewPageState extends State<PreviewViewPage> {
  late PageController _controller;
  List<GlobalKey> keyList = [];
  List<TransformationController> transformationControllerList = [];
  int _selectedIndex = 0;
  PhotoViewScaleState scaleState = PhotoViewScaleState.initial;
  bool hasPop = false;
  Map mediaMap = {};
  bool isSaving = false;

  void setupData() {
    if (widget.url.isEmpty) return;
    mediaMap = convert.jsonDecode(EncDecrypt.decry(widget.url));
    mediaMap['resources'].forEach((item) {
      GlobalKey _key = GlobalKey();
      TransformationController transformationController =
          TransformationController();
      transformationControllerList.add(transformationController);
      keyList.add(_key);
    });
    _controller = PageController(initialPage: mediaMap['index']);
    _selectedIndex = mediaMap['index'];
    setState(() {});
  }

  void saveImgToDisk(String url) async {
    if (kIsWeb) {
      Utils.showText(Utils.txt('zxjt'));
      isSaving = false;
      if (mounted) setState(() {});
    } else {
      PermissionStatus storageStatus = await Permission.camera.status;
      if (storageStatus == PermissionStatus.denied) {
        storageStatus = await Permission.camera.request();
        if (storageStatus == PermissionStatus.denied ||
            storageStatus == PermissionStatus.permanentlyDenied) {
          Utils.showText(Utils.txt('qdkqx'));
          isSaving = false;
          if (mounted) setState(() {});
        } else {
          localStorageImage(url);
        }
        return;
      } else if (storageStatus == PermissionStatus.permanentlyDenied) {
        Utils.showText(Utils.txt('wfbc'));
        isSaving = false;
        if (mounted) setState(() {});
        return;
      }
      localStorageImage(url);
    }
  }

  void localStorageImage(String url) async {
    Uint8List imageBytes = await CacheManager.image.downLoadImage(url);
    final result =
        await ImageGallerySaverPlus.saveImage(imageBytes); //这个是核心的保存图片的插件
    if (result['isSuccess']) {
      Utils.showText(Utils.txt('xxcgwd'));
    } else if (Platform.isAndroid) {
      if (result.length > 0) {
        Utils.showText(Utils.txt('xxcgwd'));
      }
    }
    isSaving = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setupData();
    Utils.setStatusBar(isLight: true);
  }

  @override
  void dispose() {
    super.dispose();
    Utils.setStatusBar(isLight: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: widget.url.isEmpty
          ? Container()
          : Stack(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (e) {},
                      onTap: () {
                        if (scaleState == PhotoViewScaleState.initial) {
                          context.pop();
                        }
                      },
                      onVerticalDragUpdate: (e) {
                        if (scaleState == PhotoViewScaleState.initial) {
                          if (e.delta.dy > 5 && hasPop == false) {
                            hasPop = true;
                            context.pop();
                          }
                        }
                      },
                      child: PhotoViewGallery.builder(
                        scrollPhysics: const BouncingScrollPhysics(),
                        pageController: _controller,
                        itemCount: mediaMap['resources'].length,
                        onPageChanged: (index) {
                          _selectedIndex = index;
                          setState(() {});
                        },
                        scaleStateChangedCallback: (value) {
                          scaleState = value;
                        },
                        builder: (context, index) {
                          var e = mediaMap['resources'][index];
                          Widget tp = ImageNetTool(fit: BoxFit.contain, url: e);
                          return PhotoViewGalleryPageOptions.customChild(
                            initialScale: 1.0,
                            minScale: 1.0,
                            maxScale: 10.0,
                            child: tp,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 80.w,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(0, 0, 0, 0.6),
                                Color.fromRGBO(0, 0, 0, 0.0)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: Column(
                      children: [
                        Container(height: StyleTheme.topHeight),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: StyleTheme.margin),
                          height: StyleTheme.navHegiht,
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: LocalPNG(
                                        name: "ai_close_n",
                                        width: 14.w,
                                        height: 14.w,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    onTap: () {
                                      context.pop();
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${_selectedIndex + 1} / ${mediaMap['resources'].length}",
                                        style: StyleTheme.font_white_255_16,
                                      ),
                                      SizedBox(width: 10.w),
                                      Container(
                                        width: 58.w,
                                        height: 20.w,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.w),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(2.w))),
                                        alignment: Alignment.center,
                                        child: isSaving
                                            ? SizedBox(
                                                width: 10.w,
                                                height: 10.w,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 1.w,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  isSaving = true;
                                                  if (mounted) setState(() {});
                                                  saveImgToDisk(
                                                      mediaMap['resources']
                                                          [_selectedIndex]);
                                                },
                                                child: Text(
                                                  Utils.txt("bctp"),
                                                  style: StyleTheme
                                                      .font_white_255_11,
                                                ),
                                              ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              ],
            ),
    );
  }
}
