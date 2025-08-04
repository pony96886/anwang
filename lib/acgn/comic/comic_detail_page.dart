// ignore_for_file: prefer_if_null_operators

import 'package:deepseek/base/base_comment_page.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ComicDetailPage extends BaseWidget {
  ComicDetailPage({Key? key, this.id = '0'}) : super(key: key);
  final String id;
  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _ComicDetailPageState();
  }
}

class _ComicDetailPageState extends BaseWidgetState<ComicDetailPage> {
  int page = 1;
  bool noMore = false;
  bool netError = false;
  bool isHud = true;
  List<dynamic> banner = [];

  dynamic data = {};

  late bool useAppsList =
      Provider.of<BaseStore>(context, listen: false).conf?.adVersion == 1;

  void getData() {
    reqComicDetail(id: widget.id).then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return;
      }
      data = value?.data;

      banner = List.from(data["banner"] ?? []);

      isHud = false;
      if (mounted) setState(() {});
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    String title = '';

    setAppTitle(titleW: Text(title, style: StyleTheme.nav_title_font));
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
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.w),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: StyleTheme.margin),
                            height: 117.w,
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 88.w,
                                    height: 117.w,
                                    child: Stack(
                                      children: [
                                        ImageNetTool(
                                          url: Utils.getPICURL(data['detail']),
                                          radius: BorderRadius.circular(6.w),
                                        ),
                                        // Positioned(
                                        //   right: 5.w,
                                        //   bottom: 10.w,
                                        //   child: Container(
                                        //     padding: EdgeInsets.all(1),
                                        //     decoration: BoxDecoration(
                                        //         color: StyleTheme.blackColor
                                        //             .withOpacity(0.4),
                                        //         borderRadius:
                                        //             BorderRadius.circular(2)),
                                        //     child: Text(
                                        //       Utils.renderFixedNumber(
                                        //               data['detail']
                                        //                   ['view_fct']) +
                                        //           Utils.txt('ll'),
                                        //       style:
                                        //           StyleTheme.font_white_255_10,
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    )),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      data['detail']['title'],
                                      style: StyleTheme
                                          .font_black_7716_16_medium
                                          .toHeight(1.2),
                                      maxLines: 2,
                                    ),
                                    // Builder(builder: (context) {
                                    //   if (data['detail']['tag']
                                    //       .toString()
                                    //       .isEmpty) {
                                    //     return Container();
                                    //   }
                                    //   List tags =
                                    //       '${data['detail']['tag']}'.split(',');
                                    //   if (tags.length > 3) {
                                    //     tags = tags.sublist(0, 3);
                                    //   }
                                    //   return Wrap(
                                    //     runSpacing: 10.w,
                                    //     spacing: 2.w,
                                    //     children: tags
                                    //         .map(
                                    //           (tag) => true
                                    //               ? Text(
                                    //                   tag,
                                    //                   style: StyleTheme
                                    //                       .font_black_7716_06_13,
                                    //                 )
                                    //               : InkWell(
                                    //                   onTap: () {
                                    //                     Utils.log('点击标签：$tag');
                                    //                     Utils.navTo(context,
                                    //                         "/homesearchpage?searchStr=$tag&index=7");
                                    //                   },
                                    //                   child: Container(
                                    //                     // margin: EdgeInsets.only(
                                    //                     //     left: 2.w),
                                    //                     padding: EdgeInsets
                                    //                         .symmetric(
                                    //                             horizontal:
                                    //                                 8.5.w,
                                    //                             vertical: 5.w),
                                    //                     decoration:
                                    //                         BoxDecoration(
                                    //                       // color: StyleTheme
                                    //                       //     .blue52Color
                                    //                       //     .withOpacity(0.2),
                                    //                       gradient: StyleTheme
                                    //                           .gradBlue,
                                    //                       borderRadius:
                                    //                           BorderRadius
                                    //                               .circular(
                                    //                                   2.w),
                                    //                     ),
                                    //                     child: Text(
                                    //                       tag,
                                    //                       style: StyleTheme
                                    //                           .font_black_7716_06_13,
                                    //                     ),
                                    //                   ),
                                    //                 ),
                                    //         )
                                    //         .toList(),
                                    //   );
                                    // }),
                                    Text(
                                      Utils.txt('gkl') +
                                          ': ' +
                                          Utils.renderFixedNumber(
                                              data['detail']['view_fct']),
                                      style: StyleTheme.font_black_7716_06_13,
                                    ),
                                    Text(
                                      (data['detail']['is_end'] == 1
                                          ? Utils.txt("wj")
                                          : Utils.txt("lzz")),
                                      style: StyleTheme.font_black_7716_06_13,
                                    ),

                                    // Text(
                                    //   Utils.txt('zze') +
                                    //       ': ' +
                                    //       data['detail']['author'],
                                    //   style: StyleTheme.font_white_255_04_12,
                                    //   maxLines: 5,
                                    // ),
                                    Text(
                                      Utils.txt('zhgx') +
                                          ': ' +
                                          '${data['detail']['renewed_at']}',
                                      style: StyleTheme.font_black_7716_06_13,
                                      maxLines: 5,
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: StyleTheme.margin, vertical: 10.w),
                            child: Text(
                              data['detail']['intro'],
                              style: StyleTheme.font_black_7716_12,
                              maxLines: 999,
                            ),
                          ),

                          Builder(builder: (context) {
                            if (data['detail']['tag'].toString().isEmpty) {
                              return Container();
                            }
                            List tags = '${data['detail']['tag']}'.split(',');
                            if (tags.length > 3) {
                              tags = tags.sublist(0, 3);
                            }
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: StyleTheme.margin),
                              child: Row(
                                children: [
                                  Wrap(
                                    runSpacing: 10.w,
                                    spacing: 5.w,
                                    children: tags
                                        .map(
                                          (tag) => InkWell(
                                            // onTap: () {
                                            //   Utils.log('点击标签：$tag');
                                            //   Utils.navTo(context,
                                            //       "/homesearchpage?searchStr=$tag&index=5");
                                            // },
                                            child: Container(
                                              // margin: EdgeInsets.only(
                                              //     left: 2.w),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.5.w,
                                                  vertical: 5.w),
                                              decoration: BoxDecoration(
                                                color: StyleTheme.blue52Color,
                                                // gradient: StyleTheme.gradBlue,
                                                borderRadius:
                                                    BorderRadius.circular(2.w),
                                              ),
                                              child: Text(
                                                tag,
                                                style: StyleTheme
                                                    .font_white_255_11,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            );
                          }),

                          banner.isEmpty
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(
                                    top: StyleTheme.margin,
                                    bottom: 10.w,
                                    left: StyleTheme.margin,
                                    right: StyleTheme.margin,
                                  ),
                                  child: useAppsList
                                      ? GeneralBannerAppsListWidget(
                                      width: 1.sw - 26.w, data: banner)
                                      : Utils.bannerSwiper(
                                    width: ScreenUtil().screenWidth - StyleTheme.margin * 2,
                                    whRate: 2 / 7,
                                    radius: 3,
                                    data: banner,
                                  ),
                                ),
                          // Container(
                          //   padding: EdgeInsets.symmetric(
                          //     horizontal: StyleTheme.margin,
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       Text(
                          //         Utils.txt('ll') +
                          //             ' ' +
                          //             Utils.renderFixedNumber(
                          //                 data['detail']['view_fct']),
                          //         style: StyleTheme.font_black_7716_06_13,
                          //       ),
                          //       SizedBox(width: 10.w),
                          //       Text(
                          //         Utils.txt('socang') +
                          //             ' ' +
                          //             Utils.renderFixedNumber(
                          //                 data['detail']['favorite_fct']),
                          //         style: StyleTheme.font_black_7716_06_13,
                          //       ),
                          //     ],
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ];
                },
                body: GenCustomNav(
                  labelPadding: 60.w,
                  // isEquallyDivide: true,
                  isCenter: true,
                  titles: [Utils.txt('xq'), Utils.txt('pl')],
                  // titles: [Utils.txt('zp'), Utils.txt('ml')],
                  pages: [
                    ComicDetailInfoPage(
                      data: data,
                    ),
                    BaseCommentPage(
                      id: widget.id,
                      type: 'comic',
                    ),
                  ],
                  type: GenCustomNavType.line,
                  selectStyle: StyleTheme.font_blue52_14,
                  defaultStyle: StyleTheme.font_black_7716_07_14,
                ),
              );
  }
}

class ComicDetailInfoPage extends StatefulWidget {
  ComicDetailInfoPage({Key? key, required this.data}) : super(key: key);
  final Map data;
  @override
  State<ComicDetailInfoPage> createState() => _ComicDetailCataloguePageState();
}

class _ComicDetailCataloguePageState extends State<ComicDetailInfoPage> {
  dynamic data;

  List chapters = [];
  List<dynamic> banner = [];
  List recommends = [];
  int lastReadChapter = -1;

  //收藏
  void postCollectData() {
    reqUserFavorite(type: 16, id: data['detail']['id']).then((value) {
      if (value?.status == 1) {
        data['detail']["is_favorite"] = value?.data["is_favorite"];
        int favoriteCt = data['detail']['favorite_fct'];
        favoriteCt += data['detail']["is_favorite"] == 1 ? 1 : -1;
        if (favoriteCt < 0) {
          favoriteCt = 0;
        }
        data['detail']['favorite_fct'] = favoriteCt;
        setState(() {});
      } else {
        Utils.showText(value?.msg ?? "");
      }
    });
  }

  Widget iconButton(
      {String imageName = '', String title = '', Function? func}) {
    return GestureDetector(
      onTap: () {
        func?.call();
      },
      child: Container(
        // color: Colors.red,
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocalPNG(
              name: imageName,
              width: 20.w,
              height: 20.w,
            ),
            SizedBox(
              width: 7.5.w,
            ),
            Container(
              height: 30.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: StyleTheme.font_blue52_15,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomView() {
    return Container(
      height: 50.w,
      color: StyleTheme.blue52Color.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: Container(
              // padding: EdgeInsets.only(bottom: StyleTheme.bottom),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 7.5.w),
                // height: 60.w,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          iconButton(
                              imageName: data['detail']['is_favorite'] == 1
                                  ? 'ai_acg_favorite_on'
                                  : 'comic_colloction',
                              title: Utils.txt(
                                  'socang'), // '${data['detail']['favorite_fct']}',
                              func: () {
                                postCollectData();
                              }),
                          // iconButton(
                          //     imageName: 'hls_album_share',
                          //     title: Utils.txt('fenx'),
                          //     func: () {
                          //       Utils.navTo(context, '/minesharepage');
                          //     }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              jumpToChater(lastReadChapter > -1 ? lastReadChapter : 0);
            },
            child: Container(
              width: 155.w,
              height: 60.w,
              // padding: EdgeInsets.symmetric(horizontal: 70.w),
              decoration: BoxDecoration(
                color: StyleTheme.blue52Color,
                // gradient: StyleTheme.gradBlue,
              ),
              alignment: Alignment.center,
              child: Center(
                  child: RichText(
                      text: TextSpan(children: [
                TextSpan(
                  text: lastReadChapter > -1
                      ? Utils.txt('jxyd')
                      : Utils.txt('ksyd'),
                  style: StyleTheme.font_white_255_15_medium,
                )
              ]))),
            ),
          )
        ],
      ),
    );
  }

  jumpToChater(int index) {
    dynamic chapter = chapters[index];

    // if (chapter['txt'].toString().isEmpty) {
    //   if (chapter['type'] == 1) {
    //     // vip
    //   } else if (chapter['type'] == 2) {
    //     // coin
    //   }

    //   return;
    // }

    Utils.navTo(context, '/comicreaderpage/$index', extra: data['detail']);
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

                        return Utils.novelChapter(chapter, func: () {
                          int index = chapters.indexOf(catelogList[e]);
                          jumpToChater(index);
                        });
                      }).toList() as List<Widget>),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lastReadChapter =
        AppGlobal.mediaReadingRecordBox?.get(widget.data['detail']['id']) ?? -1;

    data = widget.data;
    chapters = List.from(data['detail']['chapters']);
    banner = List.from(data["banner"] ?? []);
    recommends = List.from(data["recommend"] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: StyleTheme.margin, vertical: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 27.w,
                            child: Text(Utils.txt('ml'),
                                style: StyleTheme.font_black_7716_15),
                          ),
                          // chapters.length > 4
                          //     ? GestureDetector(
                          //         onTap: () {
                          //           // cancelFunc();
                          //           // confirm?.call();
                          //         },
                          //         child: Container(
                          //           margin: EdgeInsets.only(
                          //               left: StyleTheme.margin),
                          //           // height: 80.w,
                          //           child: GestureDetector(
                          //             onTap: () {
                          //               showCatalog();
                          //             },
                          //             child: Center(
                          //                 child: RichText(
                          //                     text: TextSpan(children: [
                          //               TextSpan(
                          //                 text: Utils.txt('ckqbzj'),
                          //                 style: StyleTheme.font(
                          //                     size: 12,
                          //                     color: StyleTheme.blue52Color),
                          //               )
                          //             ]))),
                          //           ),
                          //         ),
                          //       )
                          //     : Container(),
                        ],
                      ),
                      Column(
                          children: (chapters.length > 4
                                  ? chapters.sublist(0, 4)
                                  : chapters)
                              .asMap()
                              .keys
                              .map((e) {
                        dynamic chapter = chapters[e];
                        return Utils.novelChapter(chapter, func: () {
                          jumpToChater(e);
                        });
                      }).toList() as List<Widget>),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [

                      //   ],
                      // )
                      chapters.length > 4
                          ? GestureDetector(
                              onTap: () {
                                showCatalog();
                              },
                              child: Container(
                                height: 40.w,
                                margin: EdgeInsets.only(top: 10.w),
                                decoration: BoxDecoration(
                                    color: StyleTheme.blue52Color,
                                    borderRadius: BorderRadius.circular(20.w)),
                                // height: 80.w,
                                child: Center(
                                    child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // LocalPNG(
                                    //   name: 'ai_acg_check_catalog',
                                    //   width: 14.w,
                                    //   height: 14.w,
                                    // ),
                                    SizedBox(width: 5.w),
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: Utils.txt('ckqbml'),
                                          style: StyleTheme.font_white_255_16)
                                    ])),
                                  ],
                                )),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                recommends.isNotEmpty
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        child: Column(
                          children: [
                            Container(
                              height: 30.w,
                              // margin: EdgeInsets.symmetric(vertical: 10.w),
                              alignment: Alignment.centerLeft,
                              child: Text(Utils.txt('xgtj'),
                                  style: StyleTheme.font_black_7716_16_blod),
                            ),
                            Utils.comicListView(context, recommends,
                                scrollEnable: false,
                                useHoriMargin: false,
                                replace: true),
                          ],
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
        bottomView()
      ],
    );
  }
}
