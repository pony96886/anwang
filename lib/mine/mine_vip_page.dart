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

class MineVipPage extends BaseWidget {
  MineVipPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineVipPageState();
  }
}

class _MineVipPageState extends BaseWidgetState<MineVipPage>
    with NVideoURLMinxin {
  int currentTab = 0;
  List<dynamic> products = [];
  List<dynamic> exps = [];
  dynamic selectP;
  bool netError = false;
  bool isHud = true;
  List rightsList = [];
  String product_vip_text = "";

  void getData() {
    reqProductOfVIP().then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return;
      }
      if (value?.status == 1) {
        products = List.from(value?.data["product"]);
        product_vip_text = value?.data["product_vip_text"];
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
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: StyleTheme.margin),
                                //
                                constraints: BoxConstraints(
                                  minHeight: 86.w,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      clipBehavior: Clip.hardEdge,
                                      borderRadius:
                                          BorderRadius.circular(33.5.w),
                                      child: Container(
                                        height: 67.w,
                                        width: 67.w,
                                        decoration: BoxDecoration(
                                          gradient: StyleTheme.gradBlue,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 63.w,
                                            height: 63.w,
                                            child: ImageNetTool(
                                              url: user?.thumb ?? '',
                                              radius: BorderRadius.all(
                                                  Radius.circular(31.5.w)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 13.w),
                                    Expanded(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(user?.nickname ?? '',
                                                style: StyleTheme
                                                    .font_black_7716_16_blod),
                                            SizedBox(width: 5.w),
                                          ],
                                        ),
                                        SizedBox(height: 10.w),
                                        Row(
                                          children: [
                                            Text(
                                                (user?.vip_level ?? 0) < 1
                                                    ? Utils.txt('ktvpxs')
                                                    : Utils.txt('vkxdq')
                                                        .replaceAll("000",
                                                            user?.vip_str ?? "")
                                                        .replaceAll(
                                                            "##",
                                                            DateUtil.formatDateStr(
                                                                user?.expired_at ??
                                                                    "0000-00-00",
                                                                format:
                                                                    "yyyy/MM/dd")),
                                                style: StyleTheme
                                                    .font_black_7716_04_12)
                                          ],
                                        ),
                                      ],
                                    ))
                                  ],
                                ),
                              ),

                              // "cspsyxz": "长视频剩余00次下载",
                              // "dspsyxz": "短视频剩余00次下载",
                              // "dmsyxz": "动漫剩余00次下载",
                              // "asyxz": "ASMR剩余00次下载",
                              (user?.vip_level ?? 0) < 1
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: StyleTheme.margin),
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Utils.txt('cspsyxz').replaceAll(
                                                "00",
                                                "${user?.video_long_down_value ?? 0}"),
                                            style: StyleTheme.font_gray_153_12,
                                          ),
                                          Text(
                                            Utils.txt('dmsyxz').replaceAll("00",
                                                "${user?.cartoon_down_value ?? 0}"),
                                            style: StyleTheme.font_gray_153_12,
                                          ),
                                          Text(
                                            Utils.txt('asyxz').replaceAll("00",
                                                "${user?.voice_down_value ?? 0}"),
                                            style: StyleTheme.font_gray_153_12,
                                          ),

                                          // "tphlsy0c": "图片换脸剩余00次",
                                          // "sphlsy0c": "视频换脸剩余00次",
                                          // "aitysy0c": "AI脱衣剩余00次",
                                          // "ainvcjsy0c": "AI女友创建剩余00次",
                                          // "ainvltsy0c": "AI女友聊天剩余00次",

                                          Text(
                                            Utils.txt('tphlsy0c').replaceAll(
                                                "00",
                                                "${user?.img_face_value ?? 0}"),
                                            style: StyleTheme.font_gray_153_12,
                                          ),
                                          Text(
                                            Utils.txt('sphlsy0c').replaceAll(
                                                "00",
                                                "${user?.video_face_value ?? 0}"),
                                            style: StyleTheme.font_gray_153_12,
                                          ),
                                          Text(
                                            Utils.txt('aitysy0c').replaceAll(
                                                "00",
                                                "${user?.strip_value ?? 0}"),
                                            style: StyleTheme.font_gray_153_12,
                                          ),
                                          // Text(
                                          //   Utils.txt('ainvcjsy0c').replaceAll(
                                          //       "00",
                                          //       "${user?.ai_girlfriend_create_value ?? 0}"),
                                          //   style: StyleTheme.font_gray_153_12,
                                          // ),
                                          Text(
                                            Utils.txt('ainvltsy0c').replaceAll(
                                                "00",
                                                "${user?.ai_girlfriend_chat_value ?? 0}"),
                                            style: StyleTheme.font_gray_153_12,
                                          ),
                                        ]
                                            .map((e) => Container(
                                                margin: EdgeInsets.only(
                                                    right: StyleTheme.margin),
                                                child: e))
                                            .toList(),
                                      ),
                                    ),
                              Column(
                                children: [
                                  SizedBox(height: 20.w),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: StyleTheme.margin),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          Utils.txt('kthycw'),
                                          style: StyleTheme
                                              .font_black_7716_16_blod,
                                        ),
                                        // Text(
                                        //   Utils.txt("khykp"),
                                        //   style: StyleTheme.font_black_7716_16_blod,
                                        // ),
                                        // Text(
                                        //   Utils.txt("zmzxs"),
                                        //   style: StyleTheme.font_black_7716_16_blod,
                                        // )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 13.w),
                                  SizedBox(
                                    height: 138.w,
                                    child: ListView(
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
                                                  SizedBox(width: 10.w),
                                                  vipItemWidget(
                                                    product: e,
                                                    selP: selectP,
                                                  ),
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
                                          25 / 37, //宽高比为1时，子widget
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

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
      titleW: Text(Utils.txt('hyzx'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        onTap: () {
          Utils.navTo(context, "/minevrecordpage/1");
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
                  // gradient: LinearGradient(
                  //   colors: product == selP
                  //       ? [
                  //           const Color.fromRGBO(250, 246, 237, 1),
                  //           const Color.fromRGBO(250, 246, 237, 1)
                  //         ]
                  //       : [
                  //           const Color.fromRGBO(245, 245, 245, 1),
                  //           const Color.fromRGBO(245, 245, 245, 1)
                  //         ],
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  // ),
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
