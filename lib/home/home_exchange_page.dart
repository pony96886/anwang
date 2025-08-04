import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/marquee.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeExchangePage extends BaseWidget {
  const HomeExchangePage({Key? key}) : super(key: key);

  @override
  _HomeExchangePageState cState() => _HomeExchangePageState();
}

class _HomeExchangePageState extends BaseWidgetState<HomeExchangePage> {
  BconfModel? config;
  UserModel? user;
  bool netError = false;
  bool isHud = true;
  dynamic map;

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt("dzfw"), style: StyleTheme.nav_title_font),
        bgColor: Colors.transparent);
    user = Provider.of<BaseStore>(context, listen: false).user;

    getData();
  }

  Future<bool> getData() {
   return reqExpList().then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
      }
      if (value?.status == 1) {
        map = value?.data;
        isHud = false;
        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) finish();
          });
        });
      }
      return true;
    });
  }

  _redeemPoint(dynamic data) {
    Utils.startGif(tip: Utils.txt('dhz'));

    reqExpExchange(id: data['id']).then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        getData();
      } else {
        Utils.showText(value?.msg ?? '');
      }
    });
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
            : PullRefresh(
                onRefresh: () {
                 return getData();
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  child: Column(
                    children: [
                      SizedBox(height: StyleTheme.margin),
                      // MyMarqueeTipsWidget(tips: [
                      //   {'title': 'dda' * 8},
                      //   {'title': 'cc' * 8},
                      //   {'title': 'z' * 8},
                      //   {'title': '9' * 8},
                      // ]),
                      SizedBox(
                        height: 60.w,
                        child: Row(
                          children: [
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35.w),
                                  border: Border.all(
                                      width: 1.w,
                                      color: StyleTheme.blue52Color)),
                              child: ImageNetTool(
                                url: user?.thumb ?? '',
                                radius: BorderRadius.all(Radius.circular(30.w)),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(user?.nickname ?? '',
                                          style: StyleTheme.font_black_7716_18),
                                      SizedBox(width: 5.w),
                                      Utils.memberVip(
                                        user?.vip_str ?? "",
                                        h: 14,
                                        fontsize: 8,
                                        margin: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.w),
                                Text(
                                    Utils.txt('wdjfb')
                                        .replaceAll('b', '${map['exp']}'),
                                    style: StyleTheme.font_black_7716_07_13),
                              ],
                            )),
                          ],
                        ),
                      ),
                      SizedBox(height: StyleTheme.margin),
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(10.w)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(Utils.txt('vdh'),
                                    style: StyleTheme.font_black_7716_16_blod),
                              ],
                            ),
                            SizedBox(height: 10.w),
                            List.from(map['list'] ?? []).isEmpty
                                ? LoadStatus.noData()
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      dynamic data =
                                          List.from(map['list'] ?? [])[index];
                                      return SizedBox(
                                        height: 44.w,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${data['title']}',
                                                    style: StyleTheme
                                                        .font_black_7716_13,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            GestureDetector(
                                              onTap: () async {
                                                _redeemPoint(List.from(
                                                    map['list'] ?? [])[index]);
                                              },
                                              child: Container(
                                                width: 76.w,
                                                height: 28.w,
                                                decoration: BoxDecoration(
                                                    color:
                                                        StyleTheme.blue52Color,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                14.w))),
                                                child: Center(
                                                  child: Builder(
                                                      builder: (context) {
                                                    String text =
                                                        Utils.txt('dh');

                                                    return Text(
                                                      text,
                                                      style: StyleTheme
                                                          .font_white_255_13,
                                                    );
                                                  }),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount:
                                        List.from(map['list'] ?? []).length,
                                  )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
  }
}
