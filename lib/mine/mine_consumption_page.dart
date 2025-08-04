import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineConsumptionPage extends BaseWidget {
  MineConsumptionPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineConsumptionPageState();
  }
}

class _MineConsumptionPageState extends BaseWidgetState<MineConsumptionPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  int page = 1;
  List tps = [];

  Future<bool> getData() {
   return reqConsumption(page: page).then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List tp = List.from(value?.data);
      if (page == 1) {
        noMore = false;
        tps = tp;
      } else if (tp.isNotEmpty) {
        tps.addAll(tp);
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
        titleW: Text(Utils.txt('xfmx'), style: StyleTheme.nav_title_font));
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
            : tps.isEmpty
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
                      itemCount: tps.length,
                      itemBuilder: (BuildContext contenxt, int index) {
                        dynamic e = tps[index];
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: StyleTheme.whiteColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.w))),
                              padding: EdgeInsets.all(StyleTheme.margin),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${e["source_str"] ?? Utils.txt('zwsj')}",
                                        style: StyleTheme.font_black_7716_14,
                                      ),
                                      Text(
                                          '${e["type"] == 1 ? '+' : '-'} ${e["coin"]}',
                                          style: e["type"] == 1
                                              ? StyleTheme.font_blue_30_14
                                              : StyleTheme.font_blue52_14),
                                    ],
                                  ),
                                  SizedBox(height: 10.w),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(e['desc'] ?? '',
                                              style:
                                                  StyleTheme.font_gray_153_12,
                                              textAlign: TextAlign.left,
                                              maxLines: 5)),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                          child: Text('${e['created_at']}',
                                              style:
                                                  StyleTheme.font_gray_153_12,
                                              textAlign: TextAlign.right)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 20.w),
                          ],
                        );
                      },
                    ),
                  );
  }
}
