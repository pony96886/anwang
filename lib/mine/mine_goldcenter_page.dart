import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/nvideourl_minxin.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineGoldCenterPage extends BaseWidget {
  MineGoldCenterPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineGoldCenterPageState();
  }
}

class _MineGoldCenterPageState extends BaseWidgetState<MineGoldCenterPage>
    with NVideoURLMinxin {
  bool isHud = true;
  bool netError = false;
  List products = [];
  dynamic selectP;
  String product_vip_text = "";

  Future<bool> getData() {
    return reqProductOfVipOrGold(type: 2).then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
      }
      if (value?.status == 1) {
        products = List.from(value?.data['product']);
        if (products.isNotEmpty) {
          selectP = products.first;
        }
        product_vip_text = value?.data["product_coins_text"];
        isHud = false;
        setState(() {});
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 100), () {
              finish();
            });
          }
        });
      }
      return false;
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
      titleW: Text(Utils.txt('jinbcz'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/minevrecordpage/2");
        },
        child: Text(
          Utils.txt('czjl'),
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
    UserModel? tp = Provider.of<BaseStore>(context).user;
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            setState(() {});
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : products.isEmpty
                ? LoadStatus.noData()
                : Column(
                    children: [
                      Expanded(
                          child: PullRefresh(
                        onRefresh: () {
                          return getData();
                        },
                        child: ListView(
                          padding: EdgeInsets.all(StyleTheme.margin),
                          children: [
                            Container(
                              width: ScreenUtil().screenWidth -
                                  StyleTheme.margin * 2,
                              height: (ScreenUtil().screenWidth -
                                      StyleTheme.margin * 2) /
                                  355 *
                                  107,
                              decoration: BoxDecoration(
                                  color: StyleTheme.blue52Color,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.w))),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: StyleTheme.margin),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Utils.txt('jinbye'),
                                              style:
                                                  StyleTheme.font_white_255_16,
                                            ),
                                            SizedBox(height: 5.w),
                                            Text(
                                              "${tp?.money ?? 0}",
                                              style: StyleTheme.font(
                                                  size: 30,
                                                  weight: FontWeight.w500,
                                                  color: StyleTheme.whiteColor),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            Utils.navTo(context,
                                                "/mineconsumptionpage");
                                          },
                                          child: Container(
                                            height: 25.w,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 13.w),
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  244, 244, 244, 1),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.w)),
                                            ),
                                            child: Center(
                                              child: Text(
                                                Utils.txt('xfmx'),
                                                style: StyleTheme.font(
                                                    size: 12,
                                                    color: const Color.fromRGBO(
                                                        70, 53, 22, 1)),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Utils.txt('qxzczje'),
                                    style: StyleTheme.font_black_7716_16_blod,
                                  ),
                                  SizedBox(height: 20.w),
                                  GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 13,
                                    crossAxisSpacing: 13,
                                    childAspectRatio: 94 / 114,
                                    scrollDirection: Axis.vertical,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: products
                                        .map((e) => GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () {
                                                selectP = e;
                                                setState(() {});
                                              },
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        height: ScreenUtil()
                                                            .setWidth(8),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color: e == selectP
                                                                ? const Color.fromRGBO(
                                                                    87, 111, 145, 1)
                                                                : StyleTheme
                                                                    .blue52Color
                                                                    .withOpacity(
                                                                        0.1),
                                                            border: Border.all(
                                                                color: e == selectP
                                                                    ? StyleTheme
                                                                        .yellowLineColor
                                                                    : StyleTheme
                                                                        .blue52Color
                                                                        .withOpacity(
                                                                            0.3),
                                                                width: 2.0),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(7.w))),
                                                        width: 114.w,
                                                        height: 120.w,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10.w),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SizedBox(
                                                                  height: 5.w),
                                                              Text(
                                                                e["pname"],
                                                                style: e ==
                                                                        selectP
                                                                    ? StyleTheme
                                                                        .font_yellowLine_255_16
                                                                    : StyleTheme
                                                                        .font_black_7716_16,
                                                              ),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      "¥",
                                                                      style: TextStyle(
                                                                          fontSize: 18
                                                                              .sp,
                                                                          color: e == selectP
                                                                              ? StyleTheme.yellowLineColor
                                                                              : StyleTheme.blue52Color,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      e["promo_price_yuan"]
                                                                          .split(
                                                                              ".")
                                                                          .first,
                                                                      style: TextStyle(
                                                                          fontSize: 30
                                                                              .sp,
                                                                          color: e == selectP
                                                                              ? StyleTheme.yellowLineColor
                                                                              : StyleTheme.blue52Color,
                                                                          fontWeight: FontWeight.bold),
                                                                    )
                                                                  ]),
                                                              Text(
                                                                "${Utils.txt('yuanj')}${e["price_yuan"].split(".").first}${Utils.txt('rmbd')}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15.sp,
                                                                    color: e == selectP
                                                                        ? StyleTheme
                                                                            .white04Color
                                                                        : StyleTheme
                                                                            .blak7716_04_Color,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    decorationColor: e ==
                                                                            selectP
                                                                        ? const Color
                                                                            .fromRGBO(
                                                                            170,
                                                                            170,
                                                                            170,
                                                                            1)
                                                                        : const Color
                                                                            .fromRGBO(
                                                                            86,
                                                                            93,
                                                                            109,
                                                                            1)),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  e["give_tip"] != null &&
                                                          e["give_tip"].length >
                                                              0
                                                      ? Positioned(
                                                          top: 0,
                                                          left: 0,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8.w),
                                                            height: 20.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: e ==
                                                                      selectP
                                                                  ? StyleTheme
                                                                      .yellowLineColor
                                                                  : StyleTheme
                                                                      .blue52Color,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10.w),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10.w)),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "${e["give_tip"] ?? "未知"}",
                                                                style:
                                                                    TextStyle(
                                                                  color: e ==
                                                                          selectP
                                                                      ? const Color
                                                                          .fromRGBO(
                                                                          112,
                                                                          70,
                                                                          32,
                                                                          1)
                                                                      : StyleTheme
                                                                          .whiteColor,
                                                                  fontSize:
                                                                      10.sp,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        decoration: BoxDecoration(color: StyleTheme.whiteColor
                            // gradient: LinearGradient(
                            //   colors: [
                            //     StyleTheme.gray235Color.withOpacity(0.9),
                            //     StyleTheme.gray235Color.withOpacity(0.1)
                            //   ],
                            //   begin: Alignment.centerLeft,
                            //   end: Alignment.centerRight,
                            // ),
                            ),
                        child: Column(
                          children: [
                            SizedBox(height: 10.w),
                            GestureDetector(
                              onTap: () {
                                showPayAlert(selectP, product_vip_text);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: StyleTheme.blue52Color,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.w))),
                                padding: EdgeInsets.symmetric(
                                    horizontal: StyleTheme.margin),
                                height: 40.w,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Center(
                                        child: RichText(
                                            text: TextSpan(
                                          text: Utils.txt('ljzf') +
                                              " ¥${selectP["promo_price_yuan"].split(".").first}",
                                          style: StyleTheme.font_white_255_15,
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setWidth(10)),
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
                                      style: StyleTheme.font_blue_30_13,
                                    )
                                  ])),
                            ),
                            SizedBox(height: 20.w)
                          ],
                        ),
                      )
                    ],
                  );
  }
}
