import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeTaskPage extends BaseWidget {
  const HomeTaskPage({Key? key}) : super(key: key);

  @override
  _HomeTaskPageState cState() => _HomeTaskPageState();
}

class _HomeTaskPageState extends BaseWidgetState<HomeTaskPage> {
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
  Widget backGroundView() {
    // TODO: implement backGroundView
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(
          Utils.txt("dzfw"),
          style: StyleTheme.nav_title_font,
        ),
        bgColor: Colors.transparent);
    user = Provider.of<BaseStore>(context, listen: false).user;

    getData();
  }

  _jumpToExchagePage() {
    UtilEventbus()
        .fire(EventbusClass({"name": "Welfare_IndexNavJump", 'index': 1}));
  }

  Future<bool> getData() {
   return reqTaskList().then((value) {
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

  void _doSignAct() {
    Utils.startGif(tip: Utils.txt('qdz'));
    reqSignUp().then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        int sign_num = map['sign_num'] ?? 0;
        sign_num += 1;
        if (sign_num > 7) {
          sign_num = 7;
        }
        map['sign_num'] = sign_num;
        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) finish();
          });
        });
      }
    });
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  Widget _signitem({dynamic item, int signNum = 0, double itemWidth = 100}) {
    bool signed = item['sort'] <= signNum;
    return Container(
      width: itemWidth,
      height: itemWidth * 1.25,
      decoration: BoxDecoration(
          color: signed ? StyleTheme.blue52Color : StyleTheme.gray244Color,
          borderRadius: BorderRadius.circular(15.w)),
      padding: EdgeInsets.symmetric(vertical: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          signed
              ? Text(Utils.txt('yqd'), style: StyleTheme.font_white_255_12)
              : Text(item['title'], style: StyleTheme.font_black_7716_12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 33.w,
                  height: 33.w,
                  child: ImageNetTool(
                    url: item['icon'],
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
          Text(item['desc'],
              style: signed
                  ? StyleTheme.font_white_255_12
                  : StyleTheme.font_black_7716_04_12),
        ],
      ),
    );
  }

  Widget _signArea() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
          color: StyleTheme.whiteColor,
          borderRadius: BorderRadius.circular(5.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Utils.txt('qdlhl'), style: StyleTheme.font_black_7716_16_blod),
          SizedBox(height: 10.w),
          Text(Utils.txt('qdlhlsub'), style: StyleTheme.font_black_7716_06_12),
          SizedBox(height: 13.w),
          Column(
            children: [
              Wrap(
                spacing: 5.w,
                runSpacing: 5.w,
                children: List.from(map['sign_reward_list'])
                    .map((e) => _signitem(
                        item: e,
                        signNum: map['sign_num'],
                        itemWidth: (ScreenUtil().screenWidth -
                                StyleTheme.margin * 2 -
                                10.w * 2 -
                                7.w * 3) /
                            4))
                    .toList(),
              ),
              SizedBox(height: 5.w),
              Container(
                margin: EdgeInsets.only(top: StyleTheme.margin, bottom: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (map['sign_status'] == true) {
                            return;
                          }
                          _doSignAct();
                          // Utils.navTo(context, "/minevippage");
                        },
                        child: Container(
                          height: 40.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.w)),
                            // gradient: StyleTheme.gradBlue,
                            color: StyleTheme.blue52Color,
                          ),
                          child: Text(
                            map['sign_status']
                                ? Utils.txt('yqd')
                                : Utils.txt("ljqd"),
                            style: StyleTheme.font_white_255_15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: StyleTheme.margin,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _jumpToExchagePage();
                          // Utils.navTo(context, "/minevippage");
                        },
                        child: Container(
                          height: 40.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.w)),
                            // gradient: StyleTheme.gradBlue,
                            color: StyleTheme.blue52Color,
                          ),
                          child: Text(
                            Utils.txt("dhv"),
                            style: StyleTheme.font_white_255_15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
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
                                // SizedBox(height: 1.w),
                                Text(
                                    (user?.vip_level ?? 0) < 1
                                        ? Utils.txt('ktvpxs')
                                        : Utils.txt('vkxdq')
                                            .replaceAll(
                                                "000", user?.vip_str ?? "")
                                            .replaceAll(
                                                "##",
                                                DateUtil.formatDateStr(
                                                    user?.expired_at ??
                                                        "0000-00-00",
                                                    format: "yyyy/MM/dd")),
                                    style: StyleTheme.font_black_7716_07_13)
                              ],
                            )),
                          ],
                        ),
                      ),
                      SizedBox(height: StyleTheme.margin),
                      _signArea(),
                      SizedBox(height: 10.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: StyleTheme.margin, vertical: 10.w),
                        decoration: BoxDecoration(
                          color: StyleTheme.whiteColor,
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Utils.txt('dzfw'),
                                style: StyleTheme.font_black_7716_16_blod),
                            SizedBox(height: 10.w),
                            Text(Utils.txt('flrwsub'),
                                style: StyleTheme.font_black_7716_06_12),
                            SizedBox(height: 10.w),
                            SizedBox(
                              height: 44.w,
                              child: Row(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Utils.txt('yqi'),
                                        style: StyleTheme.font_black_7716_15
                                            .toHeight(1),
                                      ),
                                      Text(
                                        '${map['invited_num']}',
                                        style: StyleTheme.font_blue_52_15
                                            .toHeight(1),
                                      ),
                                      Text(
                                        Utils.txt('r'),
                                        style: StyleTheme.font_black_7716_15
                                            .toHeight(1),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 30.w),
                                  Row(
                                    children: [
                                      Text(
                                        Utils.txt('wdjf'),
                                        style: StyleTheme.font_black_7716_15
                                            .toHeight(1),
                                      ),
                                      Text(
                                        '${map['exp']}',
                                        style: StyleTheme.font_blue52_15
                                            .toHeight(1),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      //

                                      _jumpToExchagePage();
                                    },
                                    child: Container(
                                      width: 76.w,
                                      height: 28.w,
                                      decoration: BoxDecoration(
                                          color: StyleTheme.blue52Color,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14.w))),
                                      child: Center(
                                        child: Builder(builder: (context) {
                                          return Text(
                                            Utils.txt('dhv'),
                                            style: StyleTheme.font_white_255_12,
                                          );
                                        }),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                dynamic data =
                                    List.from(map['list'] ?? [])[index];
                                int taskType = data['task_type'] ?? 0;
                                int state = data['progress_status'] ??
                                    0; // 0 = 未开始，1 = 未完成 ，2 = 待领取奖励， 3 = 已经领取
                                if (state == 0) state = 1;
                                return Container(
                                  height: 72.w,
                                  // decoration: BoxDecoration(
                                  //   border: Border(
                                  //     bottom: BorderSide(
                                  //         color: Colors.white10,
                                  //         width: 0.5.w),
                                  //   ),
                                  // ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 40.w,
                                          height: 40.w,
                                          child: ImageNetTool(
                                              url: data['icon'] ?? '',
                                              radius: BorderRadius.all(
                                                  Radius.circular(20.w)))),
                                      SizedBox(width: 10.w),
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
                                                  .font_black_7716_14_medium,
                                            ),
                                            SizedBox(height: 2.w),
                                            Text(
                                              '${data['sub_title']}',
                                              style:
                                                  StyleTheme.font_gray_153_13,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      GestureDetector(
                                        onTap: () async {
                                          if (state == 2) {
                                            // 领取
                                            Map param = {'task_id': data['id']};
                                            Utils.startGif(
                                                tip: Utils.txt('jzz'));
                                            reqTaskAccept(param).then((value) {
                                              Utils.closeGif();
                                              if (value?.status == 1) {
                                                getData();
                                              } else {
                                                Utils.showText(
                                                    value?.msg ?? '');
                                              }
                                            });
                                          } else {
                                            //任务类型
                                            // 1 => 每日登陆
                                            // 2 => 评论/回复
                                            // 3 => 下载APP
                                            // 4 => 邀请用户1人
                                            // 5 => 邀请用户3人
                                            // 6 => 邀请用户10人
                                            // 7=> 邀请用户30人
                                            if (taskType == 3) {
                                              if (state != 2) {
                                                String url = data['app_url'];
                                                Utils.openURL(url);
                                              }
                                            } else if (taskType >= 4 &&
                                                taskType <= 7) {
                                              // text = state != 2 ? '去邀请' : '领取';
                                              Utils.navTo(
                                                  context, "/minesharepage");
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: 76.w,
                                          height: 28.w,
                                          decoration: BoxDecoration(
                                              color: state == 2
                                                  ? StyleTheme.blue52Color
                                                  : state == 3
                                                      ? StyleTheme
                                                          .blak7716_04_Color
                                                      : StyleTheme.blue52Color,
                                              // gradient: state == 2
                                              //     ? StyleTheme
                                              //         .gradBlue
                                              //     : state == 3
                                              //         ? StyleTheme
                                              //             .gradBlue
                                              //         : StyleTheme
                                              //             .gradBlue,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(14.w))),
                                          child: Center(
                                            child: Builder(builder: (context) {
                                              String text = '';
                                              text = state == 2
                                                  ? Utils.txt('lq')
                                                  : state == 1
                                                      ? Utils.txt('wwc')
                                                      : state == 3
                                                          ? Utils.txt('ylq')
                                                          : Utils.txt('wks');
                                              //任务类型
                                              // 1 => 每日登陆
                                              // 2 => 评论/回复
                                              // 3 => 下载APP
                                              // 4 => 邀请用户1人
                                              // 5 => 邀请用户3人
                                              // 6 => 邀请用户10人
                                              // 7=> 邀请用户30人
                                              if (taskType == 3) {
                                                text = state == 2
                                                    ? Utils.txt('lq')
                                                    : state == 3
                                                        ? Utils.txt('ylq')
                                                        : Utils.txt('ljxz');
                                              } else if (taskType >= 4 &&
                                                  taskType <= 7) {
                                                text = state == 2
                                                    ? Utils.txt('lq')
                                                    : state == 3
                                                        ? Utils.txt('ylq')
                                                        : Utils.txt('qyq');
                                              }
                                              return Text(
                                                text,
                                                style: state == 3
                                                    ? StyleTheme
                                                        .font_gray_128_12
                                                    : StyleTheme
                                                        .font_white_255_12,
                                              );
                                            }),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                              itemCount: List.from(map['list'] ?? []).length,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.w),
                    ],
                  ),
                ),
              );
  }
}
