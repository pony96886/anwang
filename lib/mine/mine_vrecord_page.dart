import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineVrecordPage extends BaseWidget {
  MineVrecordPage({Key? key, this.type = "1"}) : super(key: key);
  final String type;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineVrecordPageState();
  }
}

class _MineVrecordPageState extends BaseWidgetState<MineVrecordPage> {
  bool isHud = true;
  bool netError = false;
  List orders = [];
  int page = 1;
  bool noMore = false;

  Future<bool> getData() {
   return reqOrderList(page: page, type: widget.type).then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return false;
      }
      List tp = List.from(value?.data);
      if (page == 1) {
        noMore = false;
        orders = tp;
      } else if (tp.isNotEmpty) {
        orders.addAll(tp);
      } else {
        noMore = true;
      }
      isHud = false;
      setState(() {});
      return noMore;
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
      titleW: Text(Utils.txt('czjl'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/mineservicepage");
        },
        child: Text(
          Utils.txt('zuxkf'),
          style: StyleTheme.font_black_7716_06_14,
        ),
      ),
    );
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
            : orders.isEmpty
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
                      itemCount: orders.length,
                      itemBuilder: (BuildContext contenxt, int index) {
                        dynamic e = orders[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 16.w),
                          padding: EdgeInsets.symmetric(
                              vertical: 18.5.w, horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Utils.txt('ddbh') + '：${e["id"]}',
                                    style: StyleTheme.font_blue_30_12,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Utils.copyToClipboard('${Utils.txt('ddbh')}：${e["id"]}', showToast: true, tip: Utils.txt('fzcgl'));
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.copy,
                                          size: 15.w,
                                          color: StyleTheme.blue25Color,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          Utils.txt('fzdh'),
                                          style: StyleTheme.font_blue_30_12,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10.w),
                              Container(
                                height: 1.w,
                                color: const Color.fromRGBO(153, 153, 153, .1),
                              ),
                              SizedBox(height: 14.w),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${e["descp"]}',
                                    style: StyleTheme.font_black_7716_06_16,
                                  ),
                                  Text('${e["amount"]}',
                                      style: StyleTheme.font_black_7716_06_16),
                                ],
                              ),
                              SizedBox(height: 12.w),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${e["created_at"]}',
                                      style: StyleTheme.font_gray_102_12),
                                  Text('${e["status_text"]}',
                                      style: StyleTheme.font_gray_102_12),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
  }
}
