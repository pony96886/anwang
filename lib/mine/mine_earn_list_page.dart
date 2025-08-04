import 'package:deepseek/util/pull_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';

class MineEarnListPage extends BaseWidget {
  cState() => _MineEarnListPageState();
}

class _MineEarnListPageState extends BaseWidgetState {
  int page = 1;
  bool noMore = false;
  bool networkErr = false;
  bool isHud = true;
  List array = [];

  Future<bool> _getData() {
    return getEarnProfitList(reqdata: {'source': "", 'page': page, 'limit': 10})
        .then((value) {
      if (value?.data == null) {
        networkErr = true;
        if (mounted) setState(() {});
        return false;
      }
      List tp = List.from(value?.data["list"] ?? []);
      if (page == 1) {
        noMore = false;
        array = tp;
      } else if (tp.isNotEmpty) {
        array.addAll(tp);
      } else {
        noMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return noMore;
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('symx'), style: StyleTheme.nav_title_font));
    _getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
  @override
  Widget pageBody(BuildContext context) {
    return networkErr
        ? LoadStatus.netError(onTap: _getData)
        : isHud
            ? LoadStatus.showLoading(mounted)
            : array.isEmpty
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
                    child: Wrap(
                      // runSpacing: ScreenUtil().setWidth(10),
                      spacing: 10.w,
                      children: array
                          .map(
                            (e) => Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(StyleTheme.margin),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${e['nickname']}',
                                              style:
                                                  StyleTheme.font_black_31_14),
                                          Text(
                                              (e['type'] == 1
                                                      ? '+'
                                                      : e['type'] == 2
                                                          ? '-'
                                                          : '') +
                                                  '${e['coinCnt']}',
                                              style: e['type'] == 1
                                                  ? StyleTheme.font_blue_30_14
                                                  : StyleTheme.font_blue52_14),
                                        ],
                                      ),
                                      SizedBox(height: 5.w),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(e['desc'] ?? '',
                                                  style: StyleTheme
                                                      .font_gray_153_12,
                                                  textAlign: TextAlign.left,
                                                  maxLines: 5)),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                              child: Text('${e['created_at']}',
                                                  style: StyleTheme
                                                      .font_gray_153_12,
                                                  textAlign: TextAlign.right)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: StyleTheme.margin),
                                  height: 0.5.w,
                                  color: StyleTheme.devideLineColor,
                                )
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  );
  }
}
