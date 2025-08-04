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

class NovelReaderPage extends BaseWidget {
  NovelReaderPage({Key? key, this.chapterIndex = 0, this.novelInfo})
      : super(key: key);
  final int chapterIndex;
  dynamic novelInfo;
  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _NovelReaderPageState();
  }
}

class _NovelReaderPageState extends BaseWidgetState<NovelReaderPage> {
  int page = 1;
  bool noMore = false;
  bool netError = false;
  bool isHud = true;
  List<dynamic> banners = [];

  List<dynamic> array = [];

  String text = '';

  late List chapters;

  bool showBottom = false;

  void getData() async {
    dynamic chapter = chapters[widget.chapterIndex];
    String chapterText = chapter['txt'];

    // Utils.showDialog(
    //     // cancelShowGray: true,
    //     cancelTxt: Utils.txt('quxao'),
    //     confirmTxt: Utils.txt('kt'),
    //     cancel: () {
    //       Navigator.of(context).pop();
    //     },
    //     confirm: () {
    //       Utils.navTo(context, '/minevippage', replace: true);
    //     },
    //     setContent: () {
    //       return Text(
    //         Utils.txt('dqzjxhfajb').replaceAll('a', '${chapter['coins']}'),
    //         style: StyleTheme.font_black_31_14,
    //       );
    //     });
    // return;

    if (chapterText.isEmpty) {
      Utils.showAlertBuy(context, chapter,
          coinTip:
              Utils.txt('dqzjxhfajb').replaceAll('a', '${chapter['coins']}'),
          vipTip: Utils.txt('dqzjxykhy'),
          buyFunc: reqNovelChapterBuy, doneFunc: (resData) {
        chapter?['txt'] = resData["txt"];
        getData();
      });
      return;
    }

    dynamic decrypted = await EncDecrypt.decryptNovel(chapter['txt']);
    text = decrypted;

    if (text.isNotEmpty) isHud = false;
    setState(() {});

    AppGlobal.mediaReadingRecordBox
        ?.put(widget.novelInfo['id'], widget.chapterIndex);
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

    // if (chapter['txt'].toString().isEmpty) {
    //   if (chapter['type'] == 1) {
    //     // vip
    //   } else if (chapter['type'] == 2) {
    //     // coin
    //   }
    //   return;
    // }

    Utils.navTo(context, '/novelreaderpage/$index',
        extra: widget.novelInfo, replace: true);
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
                  SizedBox(
                    height: 27.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Utils.txt('ml'),
                            style: StyleTheme.font_white_255_15_medium),
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
                                ' ｜ ',
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
                title: Utils.txt('syz'),
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
                title: Utils.txt('xyz'),
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

  @override
  void onCreate() {
    chapters = List.from(widget.novelInfo['chapters']);
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
            : Scaffold(
                body: DefaultTextStyle(
                  style: StyleTheme.font_white_255_08_14,
                  child: Column(
                    children: [
                      Expanded(
                        //)  GestureDetector(
                        // onTap: () {
                        //   showBottom = !showBottom;
                        //   setState(() {});
                        // },
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20.w,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: StyleTheme.margin),
                                child: Text(
                                  text,
                                  maxLines: 99999,
                                  style: StyleTheme.font_black_7716_15_medium,
                                ),
                              ),
                              SizedBox(
                                height: 40.w,
                              )
                            ],
                          ),
                        ),
                      ),
                      bottomView(),
                      // AnimatedPositioned(
                      //     bottom: showBottom ? -0 : -(StyleTheme.bottom + 60.w),
                      //     left: 0,
                      //     right: 0,
                      //     child: bottomView(),
                      //     duration: Duration(milliseconds: 150))
                    ],
                  ),
                ),
              );
  }
}
