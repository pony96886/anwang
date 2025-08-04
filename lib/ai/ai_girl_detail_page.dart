import 'dart:convert' as convert;

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AIGirlDetailPage extends BaseWidget {
  AIGirlDetailPage({Key? key, this.id = "0"}) : super(key: key);
  final String id;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _AIGirlDetailPageState();
  }
}

class _AIGirlDetailPageState extends BaseWidgetState<AIGirlDetailPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;

  bool isReplay = false;
  String commid = "0";
  String tip = Utils.txt("wyddxf");
  int _selectedIndex = 0;

  int page = 1;
  String last_ix = "0";

  dynamic data;
  List _medias = [];
  String _tip = '';

  Map picMap = {};

  void getData() async {
    ResponseModel<dynamic>? res = await reqCharactorDetail(id: widget.id);
    if (res?.data == null) {
      netError = true;
      if (mounted) setState(() {});
      return;
    }
    if (res?.status == 1) {
      data = res?.data;
      // _medias = List.from([data['image_str']]);

      setAppTitle(titleW: Text(data['name'], style: StyleTheme.nav_title_font));

      // _tip = res?.data['tip'];
      // tags = List.from(data["detail"]["tags"]);
      // categories = List.from(data["detail"]["category"]);
      isHud = false;
      if (mounted) setState(() {});
    } else {
      Utils.showText(res?.msg ?? "", call: () {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            finish();
          });
        }
      });
    }
  }

  String _getBottomButtonTitle() {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    final userCoins = user?.money ?? 0; //用户剩余金币

    int characterValue = user?.ai_girlfriend_chat_value ?? 0; //免费AI女友聊天次数

    int characterCoins = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.ai_girlfriend_chat_coins ??
        0; //AI女友每次聊天消耗金币数

    bool isSufficient = userCoins >= characterCoins; //金币是否足够

    String title = Utils.txt('kslt');
    if (characterValue > 0) {
      title =
          '$title( ${Utils.txt('syac').replaceAll('a', '$characterValue')} )';
    } else {
      title = '$title(每次$characterCoins${Utils.txt('jinb')})';
    }
    return title;
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return Stack(
      children: [
        netError
            ? LoadStatus.netError(onTap: () {
                netError = false;
                getData();
              })
            : isHud
                ? LoadStatus.showLoading(mounted)
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                clipBehavior: Clip.antiAlias,
                                width: double.infinity,
                                height: 300.w,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: ImageNetTool(
                                  url: data['thumb'],
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: StyleTheme.margin),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 13.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data['name'],
                                              style: StyleTheme
                                                  .font_black_7716_18_blod,
                                              maxLines: 99,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5.w),
                                    Text(
                                      Utils.txt('rgznny'),
                                      style: StyleTheme.font_black_7716_07_13,
                                      maxLines: 99,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          Utils.txt('yxrzrl').replaceAll(
                                            'a',
                                            Utils.renderFixedNumber(
                                                int.parse('${data['aff_ct']}')),
                                          ),
                                          style:
                                              StyleTheme.font_black_7716_07_13,
                                          maxLines: 99,
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: SizedBox(
                                            height: 20.w,
                                            child: Stack(
                                              children: List.generate(
                                                  data['user_thumbs']!.length,
                                                  (index) => Positioned(
                                                        left: (10 * index).w,
                                                        bottom: 0,
                                                        child: Container(
                                                          width: 20.w,
                                                          height: 20.w,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  width: 1.w,
                                                                  color: StyleTheme
                                                                      .blue52Color),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.w)),
                                                          child: ImageNetTool(
                                                            url: data[
                                                                    'user_thumbs']
                                                                [index],
                                                            radius: BorderRadius
                                                                .circular(30.w),
                                                          ),
                                                        ),
                                                      )),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 15.w),
                                    Text(
                                      Utils.txt('jj'), //简介
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: StyleTheme.blak7716Color),
                                    ),
                                    SizedBox(height: 10.w),
                                    Text(
                                      data['desc'],
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                          color: StyleTheme.blak7716_07_Color),
                                    ),
                                    SizedBox(height: 20.w),
                                    Text(
                                      Utils.txt('jbzl'), //"基本资料",
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: StyleTheme.blak7716Color),
                                    ),
                                    SizedBox(height: 10.w),
                                    Text(
                                      data['intro'],
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                          color: StyleTheme.blak7716_07_Color),
                                    ),
                                    SizedBox(height: 60.w),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(StyleTheme.margin),
                        color: Colors.white,
                        child: GestureDetector(
                          onTap: () {
                            Utils.navTo(context,
                                '/aigirlchatpage/${data['id']}/${Uri.encodeComponent(data['name'])}/${Uri.encodeComponent(data['thumb'])}');
                          },
                          child: Container(
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: StyleTheme.blue52Color,
                              borderRadius: BorderRadius.circular(20.w),
                            ),
                            child: Center(
                              child: Text(_getBottomButtonTitle(), //开始聊天
                                  style: StyleTheme.font_white_255_15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ],
    );
  }
}

class BaseTitleText extends StatelessWidget {
  const BaseTitleText({super.key, required this.value, required this.keys});

  final String value;
  final String keys;

  @override
  Widget build(BuildContext context) {
    return keys.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            width: 0.12.sw,
            child: Text('${Utils.txt(value)}:',
                style: StyleTheme.font_gray_150_15),
          );
  }
}

class BaseTagText extends StatelessWidget {
  const BaseTagText({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return value.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            width: 0.3.sw,
            child: Text(value, style: StyleTheme.font_gray_150_15),
          );
  }
}
