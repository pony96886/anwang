import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunitySeltagPage extends BaseWidget {
  CommunitySeltagPage({Key? key, this.id = 0, this.type = 0}) : super(key: key);
  int id;
  int type;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _CommunitySeltagPageState();
  }
}

class _CommunitySeltagPageState extends BaseWidgetState<CommunitySeltagPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  List<dynamic> tops = [];
  int page = 1;

  Future<bool> getData() {
   return reqTopicsAll(page: page).then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List tp = List.from(value?.data ?? []);
      if (page == 1) {
        noMore = false;
        tops = tp;
      } else if (tp.isNotEmpty) {
        tops.addAll(tp);
      } else {
        noMore = true;
      }
      isHud = false;
      if (widget.type == 1) {
        tops.removeWhere((el) => el["is_ai"] == 1 || el["type"] == 1);
      }
      if (mounted) setState(() {});
      return noMore;
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('xzht'), style: StyleTheme.nav_title_font));
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : tops.isEmpty
                ? LoadStatus.noData()
                : PullRefresh(
                    onRefresh: () {
                      page = 1;
                      return getData();
                    },
                    onLoading: () {
                      page++;
                      return getData();
                    },
                    child: ListView.builder(
                        padding: EdgeInsets.all(StyleTheme.margin),
                        itemCount: tops.length,
                        itemBuilder: (cx, index) {
                          dynamic e = tops[index];
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              UtilEventbus().fire(EventbusClass(
                                  {"name": "tagsall", "data": e}));
                              finish();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              margin: EdgeInsets.only(bottom: 10.w),
                              height: 70.w,
                              decoration: BoxDecoration(
                                color: StyleTheme.whiteColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.w)),
                                border: e['id'] == widget.id
                                    ? Border.all(color: StyleTheme.blue52Color)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 46.w,
                                    height: 46.w,
                                    child: ImageNetTool(
                                      url: Utils.getPICURL(e),
                                      radius: BorderRadius.all(
                                          Radius.circular(23.w)),
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('#${e['name']}',
                                            style:
                                                StyleTheme.font_black_7716_14),
                                        SizedBox(height: 5.w),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${Utils.renderFixedNumber(e["post_num"])}${Utils.txt("tiez")}",
                                              style:
                                                  StyleTheme.font_gray_153_12,
                                            ),
                                            Text(
                                              "${Utils.renderFixedNumber(e["view_num"])}${Utils.txt("llan")}",
                                              style:
                                                  StyleTheme.font_gray_153_12,
                                            ),
                                            Text(
                                              "${Utils.renderFixedNumber(e["follow_num"])}${Utils.txt("guanz")}",
                                              style:
                                                  StyleTheme.font_gray_153_12,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
    ;
  }
}
