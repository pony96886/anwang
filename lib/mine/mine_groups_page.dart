import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineGroupsPage extends BaseWidget {
  MineGroupsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineGroupsPageState();
  }
}

class _MineGroupsPageState extends BaseWidgetState<MineGroupsPage> {
  List dataList = [];
  bool isHud = true;

  Future<bool> getData() {
   return reqContactList().then((value) {
      if (value?.status == 1) {
        dataList = value?.data?["office_contact"]["data"];
      } else {
        Utils.showText(value?.msg ?? "");
      }
      isHud = false;
      setState(() {});
      return false;
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('gfjlq'), style: StyleTheme.nav_title_font));
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return isHud
        ? LoadStatus.showLoading(mounted)
        : dataList.isNotEmpty
            ? PullRefresh(
                onRefresh: () {
                  return getData();
                },
                child: ListView(
                  padding: EdgeInsets.all(StyleTheme.margin),
                  // itemCount: dataList.length,
                  children: dataList.asMap().keys.map((index) {
                    dynamic e = dataList[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${e['name']}',
                          style: StyleTheme.font_black_7716_16_blod,
                        ),
                        SizedBox(height: 10.w),
                        Text(
                          '${e['decs']}',
                          style: StyleTheme.font_black_7716_12,
                        ),
                        SizedBox(height: 10.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 24.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.w),
                              color: StyleTheme.whiteColor,
                              shape: BoxShape.rectangle,
                              boxShadow: [
                                BoxShadow(
                                    color: StyleTheme.whiteColor,
                                    offset: const Offset(0, 0),
                                    blurStyle: BlurStyle.normal,
                                    spreadRadius: 1.w,
                                    blurRadius: 1.w),
                              ]),
                          child: Column(
                            children: List.from(e['list'])
                                .map((x) => GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Utils.openURL(x['url']);
                                      },
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5.w),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              // height: 49.w,
                                              child: Row(
                                                children: [
                                                  LocalPNG(
                                                    name:
                                                        x['type'] == 'Telegram'
                                                            ? 'ai_mine_tg'
                                                            : 'ai_mine_potato',
                                                    width: 49.w,
                                                    height: 49.w,
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  Expanded(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${x['name']}',
                                                        style: StyleTheme
                                                            .font_black_7716_14_medium,
                                                      ),
                                                      SizedBox(height: 4.w),
                                                      Text(
                                                        '${x['decs']}',
                                                        style: StyleTheme
                                                            .font_black_7716_06_12,
                                                        maxLines: 2,
                                                      ),
                                                    ],
                                                  )),
                                                  SizedBox(width: 10.w),
                                                  Container(
                                                    width: 70.w,
                                                    height: 25.w,
                                                    decoration: BoxDecoration(
                                                      color: StyleTheme
                                                          .blue52Color,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12.5.w)),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        Utils.txt('ljjr'),
                                                        style: StyleTheme
                                                            .font_white_255_12,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            // SizedBox(
                                            //   height: 10.w,
                                            // )
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 40.w),
                      ],
                    );
                  }).toList()
                    ..insert(
                        0,
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.w),
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: Utils.txt('jqfqv')
                                          .split(Utils.txt('jqfqv1'))
                                          .first,
                                      // textAlign: TextAlign.center,
                                      style: StyleTheme.font_black_7716_16,
                                      children: [
                                        TextSpan(
                                            text: Utils.txt('jqfqv1'),
                                            // textAlign: TextAlign.center,
                                            style: StyleTheme.font(
                                                color: StyleTheme.blue52Color)),
                                        TextSpan(
                                          text: Utils.txt('jqfqv')
                                              .split(Utils.txt('jqfqv1'))
                                              .last,
                                          style: StyleTheme.font_black_7716_16,
                                        )
                                      ])),
                            )
                          ],
                        )),
                ))
            : LoadStatus.noData();
  }
}
