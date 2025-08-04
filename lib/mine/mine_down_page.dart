import 'dart:io';

import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/mine/mine_download_video_page.dart';
import 'package:deepseek/mine/mine_download_voice_page.dart';
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

class MineDownPage extends BaseWidget {
  MineDownPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineDownPageState();
  }
}

class _MineDownPageState extends BaseWidgetState<MineDownPage> {
  List<dynamic> videos = [];
  bool loading = true;
  bool isEdit = false;
  List _chooseList = [];

  int _selectedIndex = 0;
  final GlobalKey<MineDownloadVideoPageState> _videoKey = GlobalKey();
  final GlobalKey<MineDownloadVoicePageState> _voiceKey = GlobalKey();

  // //获取视频下载信息
  // void getVideoDownloadInfo() async {
  //   Box box = await Hive.openBox('deepseek_video_box');
  //   videos = box.get('download_video_tasks') ?? [];
  //   for (var i = 0; i < videos.length; i++) {
  //     videos[i]["choosed"] = false;
  //   }
  //   loading = false;
  //   if (mounted) setState(() {});
  // }

  void _onDelete() async {
    if (_selectedIndex == 0) {
      _videoKey.currentState?.onDelete();
    } else if (_selectedIndex == 1) {
      _voiceKey.currentState?.onDelete();
    }
  }

  _onRest() {
    _chooseList = [];

    isEdit = false;
    setupNav();
    if (mounted) setState(() {});
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setupNav();
    // getVideoDownloadInfo();
  }

  void setupNav() {
    setAppTitle(
        titleW: Text(Utils.txt('xzhc'), style: StyleTheme.nav_title_font),
        rightW: GestureDetector(
          onTap: () {
            if (_chooseList.isNotEmpty) {
              _onDelete();
            } else {
              isEdit = !isEdit;
              setupNav();
              if (mounted) setState(() {});
            }
          },
          child: Text(
            _chooseList.isEmpty
                ? Utils.txt('bj')
                : "${Utils.txt('sanchu')}(${_chooseList.length})",
            style: isEdit
                ? StyleTheme.font_blue52_14
                : StyleTheme.font_black_7716_14,
          ),
        ));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return GenCustomNav(
        inedxFunc: (index) {
          _selectedIndex = index;
          _onRest();
        },
        titles: [
          Utils.txt('sping'),
          Utils.txt('as'),
        ],
        pages: [
          MineDownloadVideoPage(
            key: _videoKey,
            isEdit: isEdit,
            onTabDeleteFunc: () {},
            onChooseItemsFunc: (chooseList) {
              _chooseList = chooseList;

              setupNav();
              setState(() {});
            },
            onResetFunc: _onRest,
          ),
          MineDownloadVoicePage(
            key: _voiceKey,
            isEdit: isEdit,
            onTabDeleteFunc: () {},
            onChooseItemsFunc: (chooseList) {
              _chooseList = chooseList;

              setupNav();
              setState(() {});
            },
            onResetFunc: _onRest,
          ),
        ]);

    // loading
    //     ? LoadStatus.showLoading(mounted)
    //     : videos.isEmpty
    //         ? LoadStatus.noData()
    //         : GridView.builder(
    //             padding: EdgeInsets.all(StyleTheme.margin),
    //             itemCount: videos.length,
    //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //               crossAxisCount: 2,
    //               mainAxisSpacing: 20.w,
    //               crossAxisSpacing: 10.w,
    //               childAspectRatio: 100 / 82,
    //             ),
    //             itemBuilder: (context, index) {
    //               dynamic e = videos[index];
    //               return Stack(children: [
    //                 DownVideoCover(data: e),
    //                 isEdit
    //                     ? Positioned(
    //                         top: 0,
    //                         right: 0,
    //                         bottom: 0,
    //                         left: 0,
    //                         child: GestureDetector(
    //                           behavior: HitTestBehavior.translucent,
    //                           onTap: () {
    //                             videos[index]["choosed"] =
    //                                 !videos[index]["choosed"];
    //                             int x = chooseList.indexWhere(
    //                                 (el) => el['id'] == videos[index]["id"]);
    //                             if (x == -1 &&
    //                                 videos[index]["choosed"] == true) {
    //                               chooseList.add(videos[index]);
    //                             }
    //                             if (x != -1 &&
    //                                 videos[index]["choosed"] == false) {
    //                               chooseList.remove(videos[index]);
    //                             }
    //                             setupNav();
    //                             if (mounted) setState(() {});
    //                           },
    //                           child: Container(
    //                             alignment: Alignment.topLeft,
    //                             padding: EdgeInsets.only(top: 6.w, left: 6.w),
    //                             child: videos[index]["choosed"] == true
    //                                 ? Icon(Icons.check_circle,
    //                                     color: StyleTheme.blue52Color,
    //                                     size: 17.w)
    //                                 : Icon(Icons.circle_outlined,
    //                                     color: StyleTheme.blak7716_07_Color,
    //                                     size: 17.w),
    //                           ),
    //                         ))
    //                     : Container()
    //               ]);
    //             });
  }
}
