import 'dart:convert';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/community/community_usually.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ComicReaderPage extends BaseWidget {
  ComicReaderPage({Key? key, this.chapterIndex = 0, this.comicInfo})
      : super(key: key);
  final int chapterIndex;
  dynamic comicInfo;
  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _ComicReaderPageState();
  }
}

class _ComicReaderPageState extends BaseWidgetState<ComicReaderPage> {
  int page = 1;
  bool noMore = false;
  bool netError = false;
  bool isHud = true;
  List<dynamic> banners = [];

  List<dynamic> array = [];

  late List chapters;

  dynamic data = {};
  dynamic detailData = {};
  List<dynamic> pictures = [];

  bool showBottom = false;

  void getData() async {
    dynamic chapter = chapters[widget.chapterIndex];

    if (chapter['is_pay'] != 1) {
      Utils.showAlertBuy(context, chapter,
          coinTip:
              Utils.txt('dqtjxhfajb').replaceAll('a', '${chapter['coins']}'),
          vipTip: Utils.txt('dqzjxykhy'),
          buyFunc: reqComicChapterBuy, doneFunc: (resData) {
        chapter?['is_pay'] = 1;
        getData();
      });
      return;
    }

    reqComicChapterDetail(id: chapter['id']).then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return;
      }
      data = value?.data;
      pictures = List.from(data['pics']);
      isHud = false;
      if (mounted) setState(() {});
    });

    AppGlobal.mediaReadingRecordBox?.put(
        widget.comicInfo['id'],
        widget
            .chapterIndex); // AppGlobal.mediaReadingRecordBox?.put(widget.comicInfo['id'], widget.chapterIndex);
  }

  jumpToChater(int index) {
    if (index < 0) {
      Utils.showText(Utils.txt('qmmyl'));
      return;
    }
    if (index > chapters.length - 1) {
      Utils.showText(Utils.txt('hmmyl'));
      return;
    }
    dynamic chapter = chapters[index];

    Utils.navTo(context, '/comicreaderpage/$index',
        extra: widget.comicInfo, replace: true);
  }

  showCatalog() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          List catelogList = List.from(chapters);
          bool sortOriginal = true;
          return StatefulBuilder(builder: (context, ssState) {
            return Container(
              height: ScreenUtil().screenHeight * 0.6,
              width: ScreenUtil().screenWidth,
              padding: EdgeInsets.symmetric(
                  horizontal: StyleTheme.margin, vertical: 10.w),
              decoration: BoxDecoration(
                  color: StyleTheme.whiteColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.w),
                      topRight: Radius.circular(10.w))),
              child: Column(
                children: [
                  Container(
                    height: 27.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Utils.txt('ml'),
                            style: StyleTheme.font_black_7716_15_medium),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            sortOriginal = !sortOriginal;
                            // catelogList =
                            catelogList = List.from(catelogList.reversed);
                            ssState(() {});
                            // setState(() {});
                          },
                          child: Row(
                            children: [
                              Text(
                                Utils.txt('zex'),
                                style: sortOriginal
                                    ? StyleTheme.font_blue52_14
                                    : StyleTheme.font_black_7716_06_14,
                              ),
                              Text(
                                ' | ',
                                style: StyleTheme.font_blue52_14,
                              ),
                              Text(
                                Utils.txt('dx'),
                                style: !sortOriginal
                                    ? StyleTheme.font_blue52_14
                                    : StyleTheme.font_black_7716_06_14,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          children: catelogList.asMap().keys.map((e) {
                        dynamic chapter = catelogList[e];
                        return Utils.novelChapter(chapter,
                            isCurrent: chapters[widget.chapterIndex]['id'] ==
                                catelogList[e]['id'], func: () {
                          if (chapters[widget.chapterIndex]['id'] ==
                              catelogList[e]['id']) {
                            Navigator.of(context).pop();
                            return;
                          }

                          int index = chapters.indexOf(catelogList[e]);
                          jumpToChater(index);
                        });
                      }).toList()),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget iconButton(
      {String imageName = '',
      String title = '',
      double width = 25,
      double height = 25,
      Function? func}) {
    return GestureDetector(
      onTap: () {
        func?.call();
      },
      child: Column(
        children: [
          // Icon(Icons.play_arrow, size: 25.w, color: StyleTheme.whiteColor),
          LocalPNG(
            name: imageName,
            width: width.w,
            height: height.w,
          ),
          Text(
            title,
            style: StyleTheme.font_black_7716_14,
          )
        ],
      ),
    );
  }

  Widget bottomView() {
    return Container(
      color: StyleTheme.whiteColor,
      padding: EdgeInsets.only(bottom: StyleTheme.bottom),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.5.w),
        // height: 60.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            iconButton(
                imageName: 'ai_acg_chapter_previous',
                title: Utils.txt('syh'),
                width: 20,
                height: 22.5,
                func: () {
                  jumpToChater(widget.chapterIndex - 1);
                }),
            iconButton(
                imageName: 'ai_acg_chapter_catalog',
                title: Utils.txt('ml'),
                func: () {
                  showCatalog();
                }),
            iconButton(
                imageName: 'ai_acg_chapter_next',
                title: Utils.txt('xyh'),
                width: 20,
                height: 22.5,
                func: () {
                  jumpToChater(widget.chapterIndex + 1);
                }),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget appbar() {
  //   // TODO: implement appbar
  //   return isHud ? super.appbar() : Container();
  // }

  @override
  void onCreate() {
    caculateScreenNeededMultiple();
    chapters = List.from(widget.comicInfo['chapters']);
    dynamic chapter = chapters[widget.chapterIndex];
    setAppTitle(
        titleW: Container(
            width: 270.w,
            child: Center(
                child:
                    Text(chapter['title'], style: StyleTheme.nav_title_font))));
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : Column(
                children: [
                  Expanded(
                    // GestureDetector(
                    // behavior: HitTestBehavior.translucent,
                    // onTap: () {
                    //   showBottom = !showBottom;
                    //   setState(() {});
                    // },
                    child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: StyleTheme.margin * 0),
                        itemCount: pictures.length,
                        itemBuilder: (context, index) {
                          dynamic e = pictures[index];
                          double w = ScreenUtil().screenWidth;
                          double h = w;
                          num heightInt = w.toInt();
                          try {
                            h = w * e['thumb_h'] / e['thumb_w'];
                            heightInt = numberWith(
                                number: h,
                                intNumber: screenNeededMultipleNumber);
                            Utils.log('h = $h \nheightInt = $heightInt');
                            // Utils.showText(
                            //     'h = $h \nheightInt = $heightInt');
                          } catch (e) {
                            Utils.log(e);
                          }
                          return Container(
                            width: w,
                            // height: h, // heightInt.toDouble(),

                            height: heightInt.toDouble(),
                            // margin: EdgeInsets.only(bottom: 10.w),
                            // clipBehavior: Clip.hardEdge,
                            // decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(5.w)),
                            child: Builder(builder: (context) {
                              Widget ww = GestureDetector(
                                // onTap: () {
                                //   // List picList = List.from(pictures);
                                //   // if (detailData['is_pay'] != 1 &&
                                //   //     picList.length > 3) {
                                //   //   picList = picList.sublist(0, 3);
                                //   // }
                                //   // Map picMap = {
                                //   //   'resources': picList,
                                //   //   'index': index
                                //   // };
                                //   // String url =
                                //   //     EncDecrypt.encry(jsonEncode(picMap));
                                //   // Utils.navTo(context,
                                //   //     '/comichorizontalreaderpage/$url');
                                // },
                                child: ImageNetTool(
                                  url: Utils.getPICURL(e),
                                ),
                              );
                              return ww;
                            }),
                          );
                        }),
                  ),
                  bottomView(),

                  // AnimatedPositioned(
                  //     top: showBottom
                  //         ? 0
                  //         : -(StyleTheme.topHeight + StyleTheme.navHegiht),
                  //     left: 0,
                  //     right: 0,
                  //     child: Builder(builder: (context) {
                  //       dynamic chapter = chapters[widget.chapterIndex];
                  //       return Utils.createNav(
                  //         navColor: StyleTheme.navColor,
                  //         left: GestureDetector(
                  //           child: Container(
                  //             alignment: Alignment.centerLeft,
                  //             width: 40.w,
                  //             height: 40.w,
                  //             child: LocalPNG(
                  //               name: 'ai_nav_back_w',
                  //               width: 17.w,
                  //               height: 17.w,
                  //               fit: BoxFit.contain,
                  //             ),
                  //           ),
                  //           behavior: HitTestBehavior.translucent,
                  //           onTap: () {
                  //             finish();
                  //           },
                  //         ),
                  //         titleW: Container(
                  //             width: 270.w,
                  //             child: Center(
                  //                 child: Text(chapter['title'],
                  //                     style: StyleTheme.nav_title_font))),
                  //       );
                  //     }),
                  //     duration: Duration(milliseconds: 150)),
                  // AnimatedPositioned(
                  //     bottom: showBottom ? -0 : -(StyleTheme.bottom + 60.w),
                  //     left: 0,
                  //     right: 0,
                  //     child: bottomView(),
                  //     duration: Duration(milliseconds: 150))
                ],
              );
  }

  dynamic numberWith({double number = 1, int intNumber = 1}) {
    dynamic dad = (number ~/ intNumber);
    dynamic dd = dad.roundToDouble() * intNumber;
    return dd;
  }

  int screenNeededMultipleNumber = 1;
  // 屏幕需要的倍数 比如 2 3倍屏幕就是1 2.75倍屏幕就要让0.75乘之后为整数的最小数 4
  caculateScreenNeededMultiple() {
    final double scale = ScreenUtil().pixelRatio ?? 1;
    int intNumber = 1;
    if (scale - scale.floor() == 0) {
    } else {
      double lastDouble = scale - scale.floor();
      for (int i = 1; i < 5; i++) {
        double res = (lastDouble * i);
        if (res == res.toInt()) {
          intNumber = i;
          break;
        }
      }
    }
    screenNeededMultipleNumber = intNumber;
  }
}
