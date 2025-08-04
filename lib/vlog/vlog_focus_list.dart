import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/vlog/vlog_find_sub_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class VlogFocusList extends StatefulWidget {
  VlogFocusList({
    Key? key,
    this.call,
  }) : super(key: key);

  final Function? call;

  @override
  State<VlogFocusList> createState() => _VlogFocusListState();
}

class _VlogFocusListState extends State<VlogFocusList> {
  bool netError = false;
  bool isHud = true;
  bool noMore = false;
  List focusArr = [];
  List recommendArr = [];
  List followArr = [];

  int page = 1;

  @override
  void initState() {
    super.initState();
    UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == 'refresh_focus') {
        focusArr.removeWhere((el) => el["aff"] == event.arg["aff"]);
        if (mounted) setState(() {});
      }
    });
    _getData();
  }

  Future<bool> _getData() {
   return reqMyFollowPageData(page: page).then((value) {
      if (value?.status != 1) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List tps = List.from(value?.data['recommend_blogger'] ?? []);

      List followTps = List.from(value?.data['blogger_mvs'] ?? []);

      if (page == 1) {
        focusArr = List.from(value?.data['my_follow'] ?? []);
        recommendArr = tps;

        followArr = followTps;
        noMore = false;
      } else if (tps.isNotEmpty) {
        recommendArr.addAll(tps);
        followArr.addAll(followTps);
      } else {
        noMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return noMore;
    });
  }

  NestedScrollView _followWidget() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: focusArr.isEmpty
                ? LoadStatus.noData(
                    w: 50,
                  )
                : SizedBox(
                    height: 78.w,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.w, horizontal: StyleTheme.margin),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: focusArr
                          .map((e) => GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Utils.navTo(context,
                                    '/mineotherusercenter/${e["aff"]}');
                              },
                              child: Container(
                                height: 48.w,
                                width: 48.w,
                                margin: EdgeInsets.only(right: 20.w),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: StyleTheme.blue52Color,
                                      width: 0.5.w),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24.w)),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  height: 40.w,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: StyleTheme.blue52Color,
                                        width: 1.5.w),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.w)),
                                  ),
                                  child: ImageNetTool(
                                      url: e["thumb"] ?? '',
                                      radius: BorderRadius.all(
                                          Radius.circular(20.w))),
                                ),
                              )))
                          .toList(),
                    ),
                  ),
          )
        ];
      },
      body: PullRefresh(
        onRefresh: () {
          page = 1;
          return _getData();
        },
        onLoading: () {
          page++;
          return _getData();
        },
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.w,
            crossAxisSpacing: 10.w,
            childAspectRatio: 167 / (238 + 30),
          ),
          scrollDirection: Axis.vertical,
          itemCount: followArr.length,
          itemBuilder: (context, index) {
            dynamic e = followArr[index];
            return Utils.vlogModuleUI(context, e, onTapFunc: () {
              AppGlobal.shortVideosInfo = {
                'list': followArr,
                'page': page,
                'index': index,
                'api': '/api/vlog/list_follow2',
                'params': {},
              };

              Utils.navTo(context, '/vlogsecondpage');
            });
          },
        ),
      ),
    );
  }

  ListView _recommendWidget() {
    return ListView.builder(
        itemCount: recommendArr.length,
        itemBuilder: (context, index) {
          dynamic e = recommendArr[index];
          List videolist = List.from(e["mvs"] ?? []);
          return Container(
            color: Colors.white,
            padding: EdgeInsets.all(StyleTheme.margin),
            margin: EdgeInsets.only(bottom: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Utils.navTo(context, '/mineotherusercenter/${e["aff"]}');
                  },
                  behavior: HitTestBehavior.translucent,
                  child: SizedBox(
                    height: 50.w,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 50.w,
                          width: 50.w,
                          child: ImageNetTool(
                              url: e["thumb"] ?? '',
                              radius: BorderRadius.all(Radius.circular(25.w))),
                        ),
                        SizedBox(width: 7.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e['nickname'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: StyleTheme.font_black_7716_15,
                              ),
                              SizedBox(height: 2.w),
                              Row(
                                children: [
                                  Text(
                                    '${Utils.renderFixedNumber(int.parse('${e['like_ct']}'))}' +
                                        Utils.txt('danzan'),
                                    maxLines: 1,
                                    style: StyleTheme.font_black_7716_04_13,
                                  ),
                                  SizedBox(width: 17.w),
                                  Text(
                                    '${Utils.renderFixedNumber(e['fans_ct'])}' +
                                        Utils.txt('fens'),
                                    maxLines: 1,
                                    style: StyleTheme.font_black_7716_04_13,
                                  ),
                                  SizedBox(width: 17.w),
                                  Text(
                                    '${Utils.renderFixedNumber(e['followed_count'])}' +
                                        Utils.txt('guanz'),
                                    maxLines: 1,
                                    style: StyleTheme.font_black_7716_04_13,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        e["is_follow"] == 1
                            ? SizedBox()
                            : SizedBox(
                                width: 60.w,
                                height: 25.w,
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      reqFollowUser(aff: e["aff"].toString())
                                          .then((value) {
                                        if (value?.status == 1) {
                                          e["is_follow"] =
                                              e["is_follow"] == 1 ? 0 : 1;
                                          if (mounted) {
                                            setState(() {
                                              if (e["is_follow"] == 1) {
                                                focusArr.insert(0, {
                                                  "aff": e["aff"],
                                                  "nickname": e["nickname"],
                                                  "thumb": e["thumb"],
                                                });
                                              } else {
                                                focusArr.removeWhere((el) =>
                                                    el["aff"] == e["aff"]);
                                              }
                                            });
                                          }
                                        } else {
                                          Utils.showText(value?.msg ?? "");
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: StyleTheme.blue52Color,
                                        borderRadius:
                                            BorderRadius.circular(12.5.w),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        Utils.txt('guanz'),
                                        style: StyleTheme.font_white_255_12,
                                      ),
                                    ))),
                      ],
                    ),
                  ),
                ),
                // SizedBox(height: 10.w),
                // Text(
                //   'data',
                //   textAlign: TextAlign.left,
                //   style: StyleTheme.font_black_7716_04_14,
                // ),
                SizedBox(height: 10.w),
                videolist.isEmpty
                    ? LoadStatus.noData(
                        w: 50,
                      )
                    : GridView.builder(
                        itemCount: videolist.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 10.w,
                          childAspectRatio: 167 / (238 + 45),
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          dynamic data = videolist[index];
                          return Utils.vlogModuleUI(context, data,
                              onTapFunc: () {
                            AppGlobal.shortVideosInfo = {
                              'list': videolist,
                              'page': 1,
                              'index': index,
                              'api': data["uri"] ?? '',
                              'params': {"aff": e["aff"] ?? ""}
                            };
                            Utils.navTo(context, '/vlogsecondpage');
                          });
                        },
                      )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: StyleTheme.navHegiht + 5.w),
        Expanded(
          child: netError
              ? LoadStatus.netError(onTap: () {
                  netError = false;
                  _getData();
                })
              : isHud
                  ? LoadStatus.showLoading(mounted)
                  : focusArr.isEmpty &&
                          followArr.isEmpty &&
                          recommendArr.isEmpty
                      ? LoadStatus.noData()
                      : PullRefresh(
                          onRefresh: () {
                            page = 1;
                            return _getData();
                          },
                          onLoading: () {
                            page++;
                            return _getData();
                          },
                          child: followArr.isNotEmpty //&& false
                              ? _followWidget()
                              : _recommendWidget(),
                        ),
        )
      ],
    );
  }
}
