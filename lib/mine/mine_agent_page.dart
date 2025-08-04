import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/mine/mine_agent_apply_page.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineAgentPage extends BaseWidget {
  cState() => _MineAgentPageState();
}

class _MineAgentPageState extends BaseWidgetState {
  bool networkErr = false;
  bool isHud = true;
  dynamic _proxy_money; //余额
  dynamic _levelName; //等级名称

  dynamic _data;
  bool showApplyPage = false;

  @override
  void onCreate() {
    // TODO: implement onCreate
    UserModel? member = Provider.of<BaseStore>(context, listen: false).user;
    setAppTitle(
      titleW: Text(Utils.txt('dlzq'), style: StyleTheme.nav_title_font),
      rightW: member?.channel == 'self'
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Utils.navTo(context, "/mineagentprofitlistpage");
              },
              child:
                  Text(Utils.txt('symx'), style: StyleTheme.font_black_7716_14),
            )
          : Container(),
      lineColor: Colors.transparent,
    );
    _getAgentInfo();
  }

  // @override
  // Widget backGroundView() {
  //   // TODO: implement backGroundView
  //   return Container();
  // }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  _getAgentInfo() async {
    dynamic res = await getProxyDetail();
    if (res?.status != 1) {
      isHud = false;
      networkErr = true;
      setState(() {});
      return;
    }
    _data = res?.data;

    String ss = _data.runtimeType.toString();
    if (_data.runtimeType.toString() == 'List<dynamic>') {
      showApplyPage = true;
    } else {
      showApplyPage = false;
      _proxy_money = _data['proxy_money'];
      _levelName = _data['proxy_level_str'];
    }

    isHud = false;
    setState(() {});
  }

  @override
  Widget pageBody(BuildContext context) {
    UserModel? member = Provider.of<BaseStore>(context, listen: false).user;
    return networkErr
        ? LoadStatus.netError(onTap: _getAgentInfo)
        : isHud
            ? LoadStatus.showLoading(mounted)
            : showApplyPage
                ? const MineAgentApplyPage()
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: StyleTheme.margin,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().setWidth(65)),
                            child: Column(
                              children: [
                                _data == null
                                    ? Container()
                                    : Column(
                                        children: [
                                          SizedBox(
                                              height:
                                                  ScreenUtil().setWidth(11.5)),
                                          Container(
                                            height: 60.w,
                                            margin: EdgeInsets.all(
                                                ScreenUtil().setWidth(16.5)),
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: 60.w,
                                                    height: 60.w,
                                                    clipBehavior: Clip.hardEdge,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30.w)),
                                                        border: Border.all(
                                                            color: StyleTheme
                                                                .blue52Color,
                                                            width: 1)),
                                                    child: ImageNetTool(
                                                        url:
                                                            member?.thumb ?? "",
                                                        radius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30.w)))),
                                                SizedBox(width: 10.w),
                                                Expanded(
                                                    child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  member?.nickname ??
                                                                      "",
                                                                  style: StyleTheme
                                                                      .font_black_7716_17_medium),
                                                            ],
                                                          ),
                                                        ),
                                                        // Expanded(child: Container()),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  _levelName !=
                                                                          null
                                                                      ? '$_levelName'
                                                                      : Utils.txt(
                                                                          'yhysj'),
                                                                  style: StyleTheme
                                                                      .font_black_7716_07_12),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  Utils.txt(
                                                                      'ktxje'),
                                                                  style: StyleTheme
                                                                      .font_black_7716_15_medium),
                                                            ],
                                                          ),
                                                        ),
                                                        // Expanded(child: Container()),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  '$_proxy_money',
                                                                  style: StyleTheme.font(
                                                                      size: 17,
                                                                      color: StyleTheme
                                                                          .blue52Color,
                                                                      weight: FontWeight
                                                                          .w600,
                                                                      height:
                                                                          1)),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                SizedBox(height: 5.w),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Utils.navTo(
                                            context, "/mineagenttocashpage/0");
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: StyleTheme.blue52Color,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15.w),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        width: 120.w,
                                        height: 30.w,
                                        child: Text('立即提现',
                                            style: StyleTheme.font_white_255_15
                                                .toHeight(1.3)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Utils.navTo(context,
                                            "/mineagentpromotedatapage");
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: StyleTheme.blue52Color,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15.w),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        width: 120.w,
                                        height: 30.w,
                                        child: Text('推广数据',
                                            style: StyleTheme.font_white_255_15
                                                .toHeight(1.3)),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15.w),
                                GestureDetector(
                                  onTap: () {
                                    Utils.navTo(context, '/minesharepage');
                                  },
                                  child: LocalPNG(
                                    name: 'ai_agent_promotion_bar',
                                    width: 352.w,
                                    height: 123.w,
                                  ),
                                ),
                                SizedBox(height: 15.w),
                                GestureDetector(
                                    onTap: () {
                                      BconfModel? cf = Provider.of<BaseStore>(
                                              context,
                                              listen: false)
                                          .conf
                                          ?.config;
                                      Utils.openURL(cf?.official_group ?? "");
                                    },
                                    child: SizedBox(
                                        height: 1816.w,
                                        child: LocalPNG(
                                            name: 'ai_agent_bottom_bg'))),
                                SizedBox(height: 60.w),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20.w,
                          child: GestureDetector(
                            onTap: () {
                              if (member?.channel == 'self') {
                                Utils.navTo(context, "/minesharepage");
                              } else {
                                Utils.navTo(context, "/mineagentapplypage");
                              }
                            },
                            child: Center(
                              child: Container(
                                width: 264.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  gradient: StyleTheme.gradBlue,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.w),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                      (member?.channel == 'self')
                                          ? Utils.txt("ljtg")
                                          : Utils.txt("sqdl"),
                                      style: StyleTheme.font_white_255_15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
  }

  @override
  void didPush() {
    super.didPush();
    // Utils.setStatusBar(isLight: true);
  }

  @override
  void didPop() {
    // Utils.setStatusBar();
  }

  @override
  void didPopNext() {
    // Utils.setStatusBar(isLight: true);
  }

  @override
  void didPushNext() {
    // Utils.setStatusBar();
  }
}
