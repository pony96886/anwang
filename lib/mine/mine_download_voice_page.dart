import 'dart:io';

import 'package:deepseek/util/download_voice_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/download_utils.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineDownloadVoicePage extends StatefulWidget {
  MineDownloadVoicePage({
    super.key,
    this.isEdit = false,
    this.onTabDeleteFunc,
    this.onChooseItemsFunc,
    this.onResetFunc,
  });

  final bool isEdit;

  final Function? onTabDeleteFunc;

  final Function(List chooseList)? onChooseItemsFunc;
  final Function? onResetFunc;

  @override
  State<MineDownloadVoicePage> createState() => MineDownloadVoicePageState();
}

class MineDownloadVoicePageState extends State<MineDownloadVoicePage> {
  List<dynamic> videos = [];
  bool loading = true;
  bool isEdit = false;
  List chooseList = [];

  //获取视频下载信息
  void getVideoDownloadInfo() async {
    Box box = await Hive.openBox('deepseek_voice_box');
    videos = box.get('download_voice_tasks') ?? [];
    for (var i = 0; i < videos.length; i++) {
      videos[i]["choosed"] = false;
    }
    loading = false;
    if (mounted) setState(() {});
  }

  void onDelete() async {
    Box box = await Hive.openBox('deepseek_voice_box');
    for (var i = 0; i < chooseList.length; i++) {
      if (chooseList[i]["choosed"] == true) {
        DownloadVoiceUtils.removeTask(chooseList[i]["id"]);
        String path = chooseList[i]["url"];
        String dir = path.substring(0, path.lastIndexOf("/"));
        Directory directory = Directory(dir);
        bool isExists = await directory.exists();
        if (isExists) {
          directory.deleteSync(recursive: true);
        }
      }
    }
    videos.removeWhere((e) => e["choosed"] == true);
    box.put("download_voice_tasks", videos);
    chooseList = [];
    // isEdit = false;
    // setupNav();
    if (mounted) setState(() {});

    widget.onResetFunc?.call();
  }

  // @override
  // void onCreate() {
  //   // TODO: implement onCreate
  //   setupNav();
  //   getVideoDownloadInfo();
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVideoDownloadInfo();
  }

  @override
  void didUpdateWidget(covariant MineDownloadVoicePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    isEdit = widget.isEdit;
  }

  void setupNav() {
    // setAppTitle(
    //     titleW: Text(Utils.txt('xzhc'), style: StyleTheme.nav_title_font),
    //     rightW: GestureDetector(
    //       onTap: () {
    //         if (chooseList.isNotEmpty) {
    //           onDelete();
    //         } else {
    //           isEdit = !isEdit;
    //           setupNav();
    //           if (mounted) setState(() {});
    //         }
    //       },
    //       child: Text(
    //         chooseList.isEmpty
    //             ? Utils.txt('bj')
    //             : "${Utils.txt('sancu')}(${chooseList.length})",
    //         style: isEdit
    //             ? StyleTheme.font_blue52_14
    //             : StyleTheme.font_black_7716_14,
    //       ),
    //     ));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement pageBody
    return loading
        ? LoadStatus.showLoading(mounted)
        : videos.isEmpty
            ? LoadStatus.noData()
            : GridView.builder(
                padding: EdgeInsets.all(StyleTheme.margin),
                itemCount: videos.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20.w,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 100 / 82,
                ),
                itemBuilder: (context, index) {
                  dynamic e = videos[index];
                  return Stack(children: [
                    DownVideoCover(data: e),
                    isEdit
                        ? Positioned(
                            top: 0,
                            right: 0,
                            bottom: 0,
                            left: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                videos[index]["choosed"] =
                                    !videos[index]["choosed"];
                                int x = chooseList.indexWhere(
                                    (el) => el['id'] == videos[index]["id"]);
                                if (x == -1 &&
                                    videos[index]["choosed"] == true) {
                                  chooseList.add(videos[index]);
                                }
                                if (x != -1 &&
                                    videos[index]["choosed"] == false) {
                                  chooseList.remove(videos[index]);
                                }

                                // setupNav();
                                if (mounted) setState(() {});

                                widget.onChooseItemsFunc?.call(chooseList);
                              },
                              child: Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.only(top: 6.w, left: 6.w),
                                child: videos[index]["choosed"] == true
                                    ? Icon(Icons.check_circle,
                                        color: StyleTheme.blue52Color,
                                        size: 17.w)
                                    : Icon(Icons.circle_outlined,
                                        color: StyleTheme.blak7716_04_Color,
                                        size: 17.w),
                              ),
                            ))
                        : Container()
                  ]);
                });
  }
}

class DownVideoCover extends StatefulWidget {
  DownVideoCover({Key? key, this.data}) : super(key: key);
  final dynamic data;

  @override
  State<DownVideoCover> createState() => _DownVideoCoverState();
}

class _DownVideoCoverState extends State<DownVideoCover> {
  double progress = 0;
  bool downloading = false;
  bool downloadError = false;
  bool isWaiting = false;
  var discrip;

  void setupData() {
    if (widget.data["progress"] != null) {
      progress = widget.data["progress"] + .0;
      downloading = widget.data["downloading"];
      isWaiting = widget.data["isWaiting"];
      if (mounted) setState(() {});
    }
    discrip = UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == "DOWNLOADVIDEO_PROGRESS_${widget.data["id"]}") {
        dynamic e = event.arg["data"];
        progress = e["progress"] ?? progress;
        downloading = e["downloading"] ?? true;
        downloadError = e["downloadError"] ?? false;
        isWaiting = false;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setupData();
  }

  @override
  void didUpdateWidget(covariant DownVideoCover oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.data["id"] != oldWidget.data["id"]) {
      progress = widget.data["progress"] + .0;
      downloading = widget.data["downloading"];
      isWaiting = widget.data["isWaiting"];
      downloadError = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    discrip.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = (ScreenUtil().screenWidth - StyleTheme.margin * 2 - 10.w) / 2;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (progress.toInt() == 1) {
          // AppGlobal.mediaMap = widget.data;
          Utils.navTo(context, "/voiceplayerlocalpage", extra: widget.data);
        } else if (!downloading && !isWaiting) {
          DownloadVoiceUtils.createDownloadTask(widget.data);
        }
      },
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: StyleTheme.whiteColor, width: 0.5.w),
              borderRadius: BorderRadius.all(Radius.circular(5.w))),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: StyleTheme.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.w),
                    topRight: Radius.circular(5.w),
                  ),
                ),
                width: w,
                height: w / 16 * 9,
                child: Stack(
                  children: [
                    ImageNetTool(
                      url: widget.data['cover_thumb'],
                      radius: BorderRadius.only(
                          topLeft: Radius.circular(5.w),
                          topRight: Radius.circular(5.w)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: progress.toInt() == 1
                            ? Colors.transparent
                            : Colors.black54,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.w),
                          topRight: Radius.circular(5.w),
                        ),
                      ),
                    ),
                    progress.toInt() == 1
                        ? Container()
                        : Center(
                            child: Text(
                                downloadError
                                    ? Utils.txt('xsbcs')
                                    : isWaiting
                                        ? Utils.txt('ddxz')
                                        : progress == 0
                                            ? Utils.txt('djxz')
                                            : downloading
                                                ? Utils.txt('xzjd') +
                                                    " ${(progress * 100).toInt()}%"
                                                : Utils.txt('ztxz'),
                                style: StyleTheme.font_white_255_12),
                          ),
                    progress.toInt() != 1
                        ? Positioned(
                            right: 0,
                            bottom: 0,
                            left: 0,
                            child: LinearProgressIndicator(
                              backgroundColor:
                                  StyleTheme.blak7716_07_Color.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation(
                                  StyleTheme.blue52Color.withOpacity(0.8)),
                              value: progress,
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
              SizedBox(height: 10.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Text(widget.data['title'],
                    style: StyleTheme.font_black_7716_14),
              ),
              SizedBox(height: 10.w),
            ],
          )),
    );
  }
}
