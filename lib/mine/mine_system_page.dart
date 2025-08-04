import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineSystemPage extends BaseWidget {
  const MineSystemPage({Key? key}) : super(key: key);

  @override
  _MineSystemPageState cState() => _MineSystemPageState();
}

class _MineSystemPageState extends BaseWidgetState<MineSystemPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  int page = 1;
  List<dynamic> array = [];

  Future<bool> getData() {
    return reqSystemNoticeList(page: page).then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List tp = List.from(value?.data ?? []);
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
        titleW: Text(Utils.txt("tzxx"), style: StyleTheme.nav_title_font));
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
            : array.isEmpty
                ? LoadStatus.noData()
                : PullRefresh(
                    onRefresh: () {
                      page = 1;
                      return getData();
                    },
                    onLoading: () {
                      page += 1;
                      return getData();
                    },
                    child: ListView.builder(
                        padding: EdgeInsets.all(StyleTheme.margin),
                        itemCount: array.length,
                        itemBuilder: (context, index) {
                          dynamic e = array[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.w),
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                                color: StyleTheme.whiteColor,
                                borderRadius: BorderRadius.circular(5.w)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e["title"] ?? '',
                                    style: StyleTheme.font_black_7716_15,
                                    maxLines: 100,
                                  ),
                                  SizedBox(height: 10.w),
                                  Text(
                                    e["content"] ?? "",
                                    style: StyleTheme.font_black_7716_07_14,
                                    maxLines: 100,
                                  ),
                                  SizedBox(height: 10.w),
                                  Text(e["created_at"] ?? '',
                                      style: StyleTheme.font_black_7716_04_12),
                                ]),
                          );
                        }),
                  );
  }
}
