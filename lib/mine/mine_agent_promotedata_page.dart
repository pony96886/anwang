import 'package:deepseek/model/response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';

class MineAgentPromoteDataPage extends BaseWidget {
  cState() => _MineAgentPromoteDataPageState();
}

class _MineAgentPromoteDataPageState extends BaseWidgetState {
  bool networkErr = false;
  bool isHud = true;

  dynamic _data;

  List<String> dataTitleList = [
    "dysy",
    "dyyj",
    "dytgs",
    "jrsy",
    "jryj",
    "jrtgs",
  ];

  List<dynamic> dataTitleValueList = [];

  List<String> statisticsList = [
    "ztysh",
    "ztffyh",
    "zsxjdl",
  ];

  List<String> statisticsValueList = [
    "direct_proxy_num", // 直推代理
    "direct_pay_num", // 直推付费
    "direct_xiajidaili", // 直属下级代理
  ];

  List<String> levelList = [
    'dld',
    'zs',
    'bj',
    'hj',
    'by',
    'qt',
    'pt',
  ];

  _getData() async {
    try {
      ResponseModel<dynamic>? res = await getProxyDetail();
      if (res?.status != 1) {
        Utils.showText(res!.msg as String);
        isHud = false;
        networkErr = true;
        setState(() {});
      } else {
        isHud = false;
        networkErr = false;
        _data = res?.data;

        dataTitleValueList.clear();

        dataTitleValueList.add(_data['curMonth']['reward'] ?? '');
        dataTitleValueList.add(_data['curMonth']['sell'] ?? '');
        // dataTitleValueList.add(_convertValue(_data['curMonth']['sell'] ?? ''));
        dataTitleValueList.add(_data['curMonth']['invited_num'] ?? '');

        dataTitleValueList.add(_data['today']['reward'] ?? '');
        dataTitleValueList.add(_data['today']['sell'] ?? '');
        // dataTitleValueList.add(_convertValue(_data['today']['sell'] ?? ''));
        dataTitleValueList.add(_data['today']['invited_num'] ?? '');

        setState(() {});
      }
    } catch (e) {
      isHud = false;
      networkErr = true;
      setState(() {});
    }
  }

  String _convertValue(value) {
    String number = '$value';
    if (number.contains('.')) {
      double dd = double.parse(number);

      number = dd.toStringAsFixed(2);
    }

    return number;
  }

  @override
  void onCreate() {
    setAppTitle(
      titleW: Text(Utils.txt('tgsj'), style: StyleTheme.nav_title_font),
      navColor: Colors.transparent,
    );
    _getData();
  }

  @override
  Widget backGroundView() {
    return Container();
  }

  @override
  Widget appbar() {
    return isHud
        ? super.appbar()
        : Stack(children: [
            super.appbar(),
            Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  alignment: Alignment.centerRight,
                  height: StyleTheme.navHegiht,
                  child: GestureDetector(
                    onTap: () {
                      Utils.navTo(context, "/mineagentprofitlistpage");
                    },
                    child: Text(Utils.txt('symx'),
                        style: StyleTheme.font_black_7716_14),
                  ),
                ))
          ]);
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return networkErr
        ? LoadStatus.netError(onTap: _getData)
        : isHud == true
            ? LoadStatus.showLoading(mounted)
            : Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setHeight(17.5),
                    vertical: ScreenUtil().setHeight(18)),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: ScreenUtil().setWidth(157),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(ScreenUtil().setWidth(5))),
                              // gradient: StyleTheme.gradBlue,
                              color: StyleTheme.whiteColor),
                        ),
                        Positioned.fill(
                          top: ScreenUtil().setWidth(22),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Column(
                                children: [
                                  Text(Utils.txt('ktx'),
                                      style: StyleTheme.font_black_7716_16),
                                  SizedBox(height: ScreenUtil().setWidth(5)),
                                  Text('${_data['proxy_money'] ?? ''}',
                                      style: StyleTheme.font_black_7716_16),
                                ],
                              )),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                    width: 0.5.w,
                                    height: 35.w,
                                    color: StyleTheme.blak7716_07_Color),
                              ),
                              Expanded(
                                  child: Column(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(Utils.txt('zsy'),
                                      style: StyleTheme.font_black_7716_16),
                                  SizedBox(height: 5.w),
                                  Text('${_data['all_reward'] ?? ''}',
                                      style: StyleTheme.font_black_7716_16),
                                ],
                              ))
                            ],
                          ),
                        ),
                        Positioned.fill(
                          child: Column(
                            children: [
                              Expanded(flex: 95, child: Container()),
                              Container(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    Utils.navTo(
                                        context, "/mineagenttocashpage/0");
                                  },
                                  child: Container(
                                    width: ScreenUtil().setWidth(240),
                                    height: ScreenUtil().setWidth(31),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                4.w),
                                        color: StyleTheme.blue52Color),
                                    child: Text(Utils.txt('ljtx'),
                                        style: StyleTheme.font_white_255_15),
                                  ),
                                ),
                              ),
                              Expanded(flex: 25, child: Container()),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(20)),
                    Container(
                      height: ScreenUtil().setWidth(165),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // border: Border.all(
                        //     color: StyleTheme.gray235Color, width: 1.w),
                        borderRadius: BorderRadius.all(Radius.circular(5.w)),
                      ),
                      child: GridView.count(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        childAspectRatio: 90 / 65.0,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        children: dataTitleList.asMap().keys.map((index) {
                          dynamic element = dataTitleList[index];
                          return Container(
                            alignment: Alignment.center,
                            // color: Colors.orange,
                            // height: ScreenUtil().setWidth(36),
                            child: UnconstrainedBox(
                                child: Column(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${dataTitleValueList[index]}',
                                    style: StyleTheme.font_black_7716_14),
                                SizedBox(
                                  height: ScreenUtil().setWidth(5),
                                ),
                                Text(Utils.txt(element),
                                    style: StyleTheme.font_gray_153_12)
                              ],
                            )),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 40.w),
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          // padding: EdgeInsets.symmetric(
                          //     vertical: ScreenUtil().setWidth(15)),
                          child: Text(Utils.txt('ztztj'),
                              style: StyleTheme.font_black_7716_06_16),
                        ),
                        Wrap(
                          children: statisticsList.asMap().keys.map((index) {
                            String name = statisticsList[index];
                            return Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setWidth(10)),
                                child: Row(
                                  children: [
                                    Text(Utils.txt(name),
                                        style: StyleTheme.font_gray_153_12),
                                    Expanded(child: Container()),
                                    Text(
                                        '${_data[statisticsValueList[index]] ?? ''}',
                                        style: StyleTheme.font_gray_153_12),
                                    SizedBox(width: 40.w),
                                  ],
                                ));
                          }).toList(),
                        )
                      ],
                    )
                  ],
                ),
              );
  }
}
