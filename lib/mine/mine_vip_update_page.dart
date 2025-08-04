import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/nvideourl_minxin.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineVipUpdatePage extends BaseWidget {
  const MineVipUpdatePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineVipUpdatePageState();
  }
}

class _MineVipUpdatePageState extends BaseWidgetState<MineVipUpdatePage>
    with NVideoURLMinxin {
  int currentTab = 0;
  List<dynamic> products = [];
  List<dynamic> exps = [];
  dynamic selectP;
  dynamic currentUserP;
  bool netError = false;
  bool isHud = true;
  List rightsList = [];
  String product_vip_text = "";

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('hyzx'), style: StyleTheme.nav_title_font));
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  void getData() {
    userUpgradeVIPGoods().then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return;
      }
      if (value?.status == 1) {
        products = List.from(value?.data["goods"]);
        currentUserP = value?.data["payed"];
        if (products.isNotEmpty) {
          selectP = products.first;
          var firse = products[0];
          if (firse['right'] != null) {
            rightsList.addAll(firse['right']);
          }
        }
        isHud = false;
        setState(() {});
      } else {
        Utils.showText(value?.msg ?? '', call: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            finish();
          });
        });
      }
    });
  }

  //升级操作
  void _updateVip() {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    int money = user?.money ?? 0;
    int pay_coins = selectP['pay_coins'] ?? 0;

    bool isInsufficient = money < pay_coins;
    if (isInsufficient) {
      //金币不足提示用户
      Utils.showText('金币不足, 请充值！');
      return;
    }

    LoadStatus.showLoading(mounted);
    userVIPUpgrade(id: selectP['id']).then((value) {
      if (value?.status == 1) {
        //刷新用户数据
        reqUserInfo(context).then((_) {
          LoadStatus.closeLoading();
          Utils.showText(value?.msg ?? '', call: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              finish();
            });
          });
        });
      } else {
        LoadStatus.closeLoading();
        Utils.showText(value?.msg ?? '');
      }
    });
  }

  Widget equityItemWidget({
    String logo = "",
    String title = "",
    String text = "",
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 50.w,
          height: 50.w,
          child: ImageNetTool(url: logo),
        ),
        SizedBox(height: 2.w),
        SizedBox(
          height: 20.w,
          child: Text(
            title,
            style: StyleTheme.font_black_7716_14_medium,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 2.w),
        SizedBox(
          height: 40.w,
          child: Text(
            text,
            style: TextStyle(
              color: StyleTheme.blak7716_06_Color,
              fontSize: 11.sp,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  void onIndexChanged() {
    var firse = selectP;
    rightsList = firse['right'] ?? [];
    setState(() {});
  }

  @override
  Widget pageBody(BuildContext context) {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    String? tempTime = user?.expired_at.toString().split(' ')[0];
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : products.isEmpty
                ? LoadStatus.noData()
                : Stack(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: StyleTheme.margin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10.w),
                              Text(
                                Utils.txt('dqhy'),
                                style: StyleTheme.font_black_7716_16,
                              ),
                              SizedBox(height: 10.w),
                              Container(
                                height: 100.w,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: StyleTheme.whiteColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.w))),
                                padding: EdgeInsets.all(15.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentUserP['pname'],
                                              style: StyleTheme
                                                  .font_black_7716_18_blod,
                                            ),
                                            Text(
                                              '¥${currentUserP['promo_price_yuan']}',
                                              style: StyleTheme
                                                  .font_black_7716_15_medium,
                                            ),
                                            Text(
                                              '¥${currentUserP['price_yuan']}',
                                              style: TextStyle(
                                                  color: StyleTheme
                                                      .blak7716_04_Color,
                                                  fontSize: 12.sp,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  decorationColor: StyleTheme
                                                      .blak7716_04_Color),
                                            ),
                                          ]),
                                    ),
                                    LocalPNG(
                                        name: 'ai_mine_invite',
                                        width: 50.w,
                                        height: 50.w)
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.w),
                                  Text(
                                    Utils.txt('ksjz'),
                                    style: StyleTheme.font_black_7716_16,
                                  ),
                                  SizedBox(height: 13.w),
                                  SizedBox(
                                    height: 138.w,
                                    child: ListView(
                                      padding: EdgeInsets.zero,
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      children: products
                                          .map((e) => GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  selectP = e;
                                                  onIndexChanged();
                                                },
                                                child: Row(children: [
                                                  vipItemWidget(
                                                    product: e,
                                                    selP: selectP,
                                                  ),
                                                  SizedBox(width: 10.w),
                                                ]),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  SizedBox(height: 20.w),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LocalPNG(
                                          name: 'ai_vip_tequan',
                                          width: 16.w,
                                          height: 16.w),
                                      SizedBox(width: 5.w),
                                      Text(
                                        Utils.txt('hytq'),
                                        style:
                                            StyleTheme.font_black_7716_16_blod,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.w),
                                  GridView(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: StyleTheme.margin),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4, //横轴三个子widget
                                      childAspectRatio:
                                          25 / 40, //宽高比为1时，子widget
                                      crossAxisSpacing: 10.w,
                                      mainAxisSpacing: 10.w,
                                    ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: rightsList
                                        .asMap()
                                        .keys
                                        .map((e) => Container(
                                              // color: Colors.red,
                                              child: equityItemWidget(
                                                  logo: rightsList[e]['img'],
                                                  text: rightsList[e]['desc'],
                                                  title: rightsList[e]['name']),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                        Container(
                          width: double.infinity,
                          decoration:
                              BoxDecoration(color: StyleTheme.whiteColor),
                          child: Column(
                            children: [
                              SizedBox(height: 10.w),
                              GestureDetector(
                                onTap: () {
                                  //金币VIP升级
                                  _updateVip();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: StyleTheme.gradBlue,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.w))),
                                  width: ScreenUtil().screenWidth -
                                      StyleTheme.margin * 2,
                                  height: 40.w,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Center(
                                          child: RichText(
                                              text: TextSpan(
                                            text: Utils.txt('ljsj') +
                                                " (补金币${selectP["pay_coins"].toString().split(".").first})",
                                            style: StyleTheme.font_white_255_15,
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.w),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Utils.navTo(context, "/mineservicepage");
                                },
                                child: Text.rich(TextSpan(
                                    text: Utils.txt('zflx'),
                                    style: StyleTheme.font_black_7716_04_13,
                                    children: [
                                      TextSpan(
                                          text: Utils.txt('zuxkf'),
                                          style: StyleTheme.font_blue_30_13)
                                    ])),
                              ),
                              SizedBox(height: 20.w)
                            ],
                          ),
                        )
                      ],
                    ),
                  ]);
  }

  Widget vipItemWidget({Map? product, Map? selP}) {
    if (product == null || selP == null) {
      return Container();
    }
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 8.w),
            Container(
              decoration: BoxDecoration(
                  color: product == selP
                      ? const Color.fromRGBO(87, 111, 145, 1)
                      : StyleTheme.blue52Color.withOpacity(0.1),
                  border: Border.all(
                      color: product == selP
                          ? StyleTheme.yellowLineColor
                          : StyleTheme.blue52Color.withOpacity(0.3),
                      width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(7.w))),
              width: 114.w,
              height: 128.w,
              padding: EdgeInsets.symmetric(vertical: 10.w),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 5.w),
                    Text(
                      product["pname"],
                      style: product == selP
                          ? StyleTheme.font_yellowLine_255_16
                          : StyleTheme.font_black_7716_16,
                    ),
                    // SizedBox(height: ScreenUtil().setWidth(14)),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        "¥",
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: product == selP
                                ? StyleTheme.yellowLineColor
                                : StyleTheme.blue52Color,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        product["promo_price_yuan"].split(".").first,
                        style: TextStyle(
                            fontSize: 30.sp,
                            color: product == selP
                                ? StyleTheme.yellowLineColor
                                : StyleTheme.blue52Color,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
                    // SizedBox(height: ScreenUtil().setWidth(9)),
                    Text(
                      "¥" + product["price_yuan"].split(".").first,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: product == selP
                              ? StyleTheme.white04Color
                              : StyleTheme.blak7716_07_Color,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: product == selP
                              ? const Color.fromRGBO(170, 170, 170, 1)
                              : const Color.fromRGBO(86, 93, 109, 1)),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        product["give_tip"] != null && product["give_tip"].length > 0
            ? Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: product == selP
                        ? StyleTheme.yellowLineColor
                        : StyleTheme.blue52Color,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.w),
                        bottomRight: Radius.circular(10.w)),
                  ),
                  child: Center(
                    child: Text(
                      "${product["give_tip"] ?? "未知"}",
                      style: TextStyle(
                        color: product == selP
                            ? const Color.fromRGBO(112, 70, 32, 1)
                            : StyleTheme.whiteColor,
                        fontSize: 10.sp,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
