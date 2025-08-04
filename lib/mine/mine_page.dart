import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MinePage extends StatelessWidget {
  const MinePage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  Widget build(BuildContext context) {
    return _MinePage(isShow: isShow);
  }
}

class _MinePage extends BaseWidget {
  const _MinePage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __MinePageState();
  }
}

class __MinePageState extends BaseWidgetState<_MinePage> {
  List<Map> widgetList1 = [
    {
      "icon": "ai_mine_icon_order",
      "title": Utils.txt('wddd'),
      "route": "/mineorderpage",
    },
    {
      "icon": "ai_mine_icon_purchased",
      "title": Utils.txt('wdgm'),
      "route": "/minebuypage",
    },
    {
      "icon": "ai_mine_icon_community",
      "title": Utils.txt('wdshequ'),
      "route": "/minecommunitypage",
    },
    {
      "icon": "ai_mine_icon_favorite",
      "title": Utils.txt('wdsc'),
      "route": "/minecollectpage",
    },
  ];

  List<Map> widgetList2 = [
    {
      "icon": "ai_mine_icon_blogger_join",
      "title": Utils.txt('bzrz'),
      "route": "/minebloggerpage",
    },
    // {
    //   "icon": "ai_mine_icon_girl_manage",
    //   "title": Utils.txt('ypgl'),
    //   "route": "/minegirlmanagepage",
    // },
    {
      "icon": "ai_mine_icon_strip_chat_manage",
      "title": Utils.txt('llgl'),
      "route": "/minestripchatmanagepage",
    },
    {
      "icon": "ai_mine_icon_service",
      "title": Utils.txt('zuxkf'),
      "route": "/mineservicepage",
    },
  ];

  List<Map> widgetList3 = [
    {
      "icon": "ai_mine_icon_follows",
      "title": Utils.txt('wdgz'),
      "route": "/minefollowpage",
    },
    {
      "icon": "ai_mine_icon_download",
      "title": Utils.txt('xzhc'),
      "route": "/minedownpage",
    },
    {
      "icon": "ai_mine_icon_generate_records",
      "title": Utils.txt('scjl'),
      "route": "/minepurchasepage/0",
    },
    {
      "icon": "ai_mine_icon_recommend_elements",
      "title": Utils.txt('tj'),
      "route": "/minematepage",
    },
    {
      "icon": "ai_mine_icon_questions",
      "title": Utils.txt('chjwt'),
      "route": "/minenorquestionpage",
    },
    {
      "icon": "ai_mine_icon_groups",
      "title": Utils.txt('gfjlq'),
      "route": "/minegroupspage",
    },
    {
      "icon": "ai_mine_icon_invite_code",
      "title": Utils.txt('txyqm'),
      "route": "/mineupdatepage/invite/${Utils.txt('txyqm')}",
    },
    {
      "icon": "ai_mine_icon_redeem_code",
      "title": Utils.txt('txdhm'),
      "route": "/mineupdatepage/code/${Utils.txt('txdhm')}",
    },
  ];
  var discrip;
  bool isHud = true;

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  Future<bool> getData() {
    //刷新用户信息 + 消息
    return reqUserInfo(context).then((_) {
     return reqSystemNotice(context).then((_) {
        isHud = false;
        if (mounted) setState(() {});
        return false;
      });
    });
  }

  @override
  void onCreate() {
    // TODO: implement initState
    discrip = UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == 'login') {
        if (mounted) setState(() {});
      } else if (event.arg["name"] == 'logout') {
        if (mounted) setState(() {});
      } else if (event.arg["name"] == 'unread') {
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MinePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      getData();
    }
  }

  //顶部设置
  Widget _topNavWidget() {
    return Column(
      children: [
        SizedBox(height: 10.w),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<BaseStore>(
              builder: (ctx, state, child) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Utils.navTo(context, "/minemessagecenter");
                },
                child: LocalPNG(
                  name: state.notice?.systemNoticeCount != 0 ||
                          state.notice?.feedCount != 0
                      ? 'ai_mine_msg_bell_on'
                      : 'ai_mine_msg_bell_off',
                  width: 25.w,
                  height: 25.w,
                ),
              ),
            ),
            SizedBox(width: 20.w),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Utils.navTo(context, "/minesetpage");
              },
              child: LocalPNG(
                name: 'ai_mine_setting',
                width: 25.w,
                height: 25.w,
              ),
            ),
            SizedBox(width: StyleTheme.margin),
          ],
        ),
      ],
    );
  }

  //头部数据
  Widget _headWidget() {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 20.w),
            Padding(
              padding: EdgeInsets.only(left: StyleTheme.margin),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Utils.navTo(context, "/minesetpage");
                },
                child: SizedBox(
                  height: 60.w,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: StyleTheme.blue52Color,
                              width: 1.w,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.w))),
                        height: 60.w,
                        width: 60.w,
                        child: SizedBox(
                          height: 59.w,
                          width: 59.w,
                          child: ImageNetTool(
                            url: user?.thumb ?? "",
                            radius: BorderRadius.all(
                              Radius.circular(29.5.w),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.nickname ?? "",
                                  style: StyleTheme.font_black_7716_16_blod
                                      .toHeight(1.3),
                                  maxLines: 1,
                                ),
                                SizedBox(width: 5.w),
                                Utils.memberVip(
                                  user?.vip_str ?? "",
                                  h: 14,
                                  fontsize: 8,
                                  margin: 5,
                                ),
                                user?.agent == 1
                                    ? Icon(Icons.verified_sharp,
                                        size: 15.w,
                                        color: StyleTheme.blue52Color)
                                    : Container(),
                              ],
                            ),
                            SizedBox(height: 5.w),
                            Row(
                              children: [
                                Text(
                                  "ID: ${user?.uid ?? "0"}",
                                  style: StyleTheme.font_black_7716_06_12,
                                ),
                                if (user?.vip_upgrade == 1) ...[
                                  SizedBox(width: 6.w),
                                  GestureDetector(
                                    onTap: () {
                                      Utils.navTo(context, "/vipupdatepage");
                                    },
                                    child: LocalPNG(
                                        name: 'app_uplevel_vip',
                                        width: 65,
                                        height: 22,
                                        fit: BoxFit.fitWidth),
                                  )
                                ]
                              ],
                            )
                          ],
                        ),
                      ),
                      user?.username?.isEmpty == true // || true
                          ? Row(
                              children: [
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Utils.navTo(context, "/mineloginpage");
                                    },
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: Center(
                                        child: Text(Utils.txt('ljdl'),
                                            style:
                                                StyleTheme.font_black_7716_12),
                                      ),
                                    )),
                                SizedBox(
                                  width: 3.w,
                                ),
                              ],
                            )
                          : Container(),
                      LocalPNG(
                        name: 'ai_mine_arrow',
                        width: 12.w,
                        height: 16.w,
                      ),
                      SizedBox(width: StyleTheme.margin)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.w),
          ],
        )
      ],
    );
  }

  Widget _vipWidget() {
    UserModel? tp = Provider.of<BaseStore>(context, listen: false).user;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, '/minevippage');
        },
        child: Container(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
            height: 66.w,
            child: Stack(
              children: [
                LocalPNG(
                  name: 'ai_mine_widget_vip',
                  height: 66.w,
                  fit: BoxFit.fill,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.w, right: 15.w),
                  child: Row(
                    children: [
                      LocalPNG(
                        name: 'ai_mine_widget_vip_left',
                        height: 41.w,
                        width: 51.w,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                Utils.txt('jindgg'),
                                style: StyleTheme.font_white_255_14,
                              ),
                            ],
                          ),
                          SizedBox(height: 1.w),
                          (tp?.vip_level ?? 0) < 1
                              ? Text(
                                  'VIP限时终身特惠活动进行中',
                                  style: StyleTheme.font_white_255_04_12,
                                )
                              : Text(
                                  Utils.txt('vkxdq')
                                      .replaceAll("000", tp?.vip_str ?? "")
                                      .replaceAll(
                                          "##",
                                          DateUtil.formatDateStr(
                                              tp?.expired_at ?? "0000-00-00",
                                              format: "yyyy/MM/dd")),
                                  style: StyleTheme.font_white_255_04_12)
                        ],
                      )),
                      SizedBox(width: 10.w),
                      (tp?.vip_level ?? 0) < 1
                          ? SizedBox(
                              width: 60.w,
                              height: 20.w,
                              child: LocalPNG(
                                name: 'ai_mine_widget_vip_right',
                                fit: BoxFit.fill,
                              ),
                            )
                          : Container()
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  //金币 邀请 代理
  Widget _individual3Widget() {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    return Container(
      height: 90.w,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Stack(
        children: [
          Positioned.fill(
            child: LocalPNG(
              name: 'ai_mine_individual_bg',
              // fit: BoxFit.fitWidth,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 5.w, right: 13.w, top: 30.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                card(
                    '/minegoldcenterpage',
                    'ai_mine_individual_camer',
                    Utils.txt('jinbcz'),
                    // Utils.txt('jinbye') + ' ${user?.money ?? 0}'
                    '${user?.money ?? 0.00}'),
                LocalPNG(
                  name: 'ai_mine_individual_line',
                  width: 2.w,
                  height: 50.w,
                  fit: BoxFit.fill,
                ),
                card('/minesharepage', 'ai_mine_individual_yaoqing',
                    Utils.txt('yqfx'), Utils.txt('yqfxdvp')),
                LocalPNG(
                  name: 'ai_mine_individual_line',
                  width: 2.w,
                  height: 50.w,
                  fit: BoxFit.fill,
                ),
                card('/mineagentpage', 'ai_mine_individual_tuiguan',
                    Utils.txt('tgzxj'), Utils.txt('zgfc')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget card(String path, String imageName, String title, String subTitle) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Utils.navTo(context, path);
      },
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              height: 60.w,
              // decoration: BoxDecoration(
              //     color: StyleTheme.blue52Color,
              //     borderRadius: BorderRadius.circular(5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LocalPNG(
                    name: imageName,
                    // fit: BoxFit.fill,
                    width: 26.w, height: 26.w,
                  ),
                  SizedBox(width: 5.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          textAlign: TextAlign.center,
                          style: StyleTheme.font(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              weight: FontWeight.w600,
                              size: 13)),
                      SizedBox(height: 2.w),
                      Text(subTitle,
                          style: StyleTheme.font(
                              color: StyleTheme.yellowColor,
                              weight: FontWeight.w500,
                              size: 11)),
                    ],
                  )
                ],
              )),
        ],
      ),
    );
  }

  //尾部数据
  Widget _itemsWidget(List list, {String title = ''}) {
    UserModel? tp = Provider.of<BaseStore>(context, listen: false).user;
    return Container(
      margin: EdgeInsets.only(
        top: StyleTheme.margin,
        left: StyleTheme.margin,
        right: StyleTheme.margin,
      ),
      padding: EdgeInsets.all(StyleTheme.margin),
      decoration: BoxDecoration(
          color: StyleTheme.whiteColor, borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          Container(
            // color: Colors.red,
            child: Row(
              children: [
                Text(title,
                    style: StyleTheme.font_black_7716_14_medium.toHeight(1)),
              ],
            ),
          ),
          Container(
            // color: Colors.red,
            height: 15.w,
          ),
          GridView.count(
            crossAxisCount: 4,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            mainAxisSpacing: 28.w,
            crossAxisSpacing: 0,
            childAspectRatio: 51 / 30,
            children: list
                .map((e) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Utils.navTo(context, e["route"]);
                      },
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                LocalPNG(
                                  name: e["icon"],
                                  width: 25.w,
                                  height: 25.w,
                                  fit: BoxFit.contain,
                                ),
                                Spacer(),
                                // SizedBox(
                                //   height: 9.w,
                                // ),
                                Text(
                                  e["title"],
                                  style:
                                      StyleTheme.font_black_7716_12.toHeight(1),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          e["icon"] == "ai_mine_reply"
                              ? tp?.unread_reply == 0
                                  ? Container()
                                  : Positioned(
                                      right: 10.w,
                                      top: 10.w,
                                      child: Container(
                                        width: 18.w,
                                        height: 18.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: StyleTheme.blue52Color,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(9.w))),
                                        child: Text(
                                            "${(tp?.unread_reply ?? 0) >= 99 ? '99+' : (tp?.unread_reply ?? 0)}",
                                            style: StyleTheme.font(size: 9)),
                                      ),
                                    )
                              : Container(),
                        ],
                      ),
                    ))
                .toList(),
          ),
          SizedBox(
            height: 2.w,
          )
        ],
      ),
    );
  }

  @override
  Widget pageBody(BuildContext context) {
    return isHud
        ? LoadStatus.showLoading(mounted)
        : Stack(
            children: [
              Container(
                color: StyleTheme.bgColor,
              ),
              // Positioned.fill(
              //   child: LocalPNG(
              //     name: "ai_mine_top_bg",
              //     // width: ScreenUtil().screenWidth,
              //     // height: ScreenUtil().screenWidth,
              //     //  /
              //     //     375 *
              //     //     (StyleTheme.topHeight + 44.w + 154.w),
              //     fit: BoxFit.fill,
              //   ),
              // ),
              Column(
                children: [
                  SizedBox(height: StyleTheme.topHeight),
                  _topNavWidget(),
                  Expanded(
                    child: PullRefresh(
                      onRefresh: () {
                         return getData();
                      },
                      child: SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _headWidget(),
                            SizedBox(
                              height: 135.w,
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: 45.w, child: _individual3Widget()),
                                  _vipWidget(),
                                ],
                              ),
                            ),
                            _itemsWidget(widgetList1, title: Utils.txt('cygn')),
                            _itemsWidget(widgetList2, title: Utils.txt('rzhz')),
                            _itemsWidget(widgetList3, title: Utils.txt('yhfw')),
                            SizedBox(height: 30.w),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    discrip.cancel();
  }

  @override
  void didPopNext() {
    reqSystemNotice(context).then((_) {
      if (mounted) setState(() {});
    });
  }
}
