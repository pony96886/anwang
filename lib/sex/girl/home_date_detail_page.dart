import 'dart:convert' as convert;

import 'package:card_swiper/card_swiper.dart';

import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
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
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeDateDetailPage extends BaseWidget {
  HomeDateDetailPage({Key? key, this.id = "0"}) : super(key: key);
  final String id;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeDateDetailPageState();
  }
}

class _HomeDateDetailPageState extends BaseWidgetState<HomeDateDetailPage> {
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

  void getData() {
    reqGirlDetail(id: widget.id).then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return;
      }
      if (value?.status == 1) {
        data = value?.data['girl'];
        _medias = List.from(data['medias']);
        _tip = value?.data['tip'];
        // tags = List.from(data["detail"]["tags"]);
        // categories = List.from(data["detail"]["category"]);
        isHud = false;
        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 100), () {
              finish();
            });
          }
        });
      }
    });
  }

//点赞
  void postLikeData() {
    reqUserLike(type: 21, id: int.parse(widget.id)).then((value) {
      if (value?.status == 1) {
        data["is_like"] = data["is_like"] == 0 ? 1 : 0;
        int likeCt = data['like_fct'];
        likeCt += data["is_like"] == 1 ? 1 : -1;
        if (likeCt < 0) {
          likeCt = 0;
        }
        data['like_fct'] = likeCt;
        setState(() {});
      } else {
        Utils.showText(value?.msg ?? "");
      }
    });
  }

  //收藏
  void postCollectData() {
    reqUserFavorite(type: 21, id: int.parse(widget.id)).then((value) {
      if (value?.status == 1) {
        data["is_favorite"] = data["is_favorite"] == 0 ? 1 : 0;
        int favoriteCt = data['favorite_fct'];
        favoriteCt += data["is_favorite"] == 1 ? 1 : -1;
        if (favoriteCt < 0) {
          favoriteCt = 0;
        }
        data['favorite_fct'] = favoriteCt;
        setState(() {});
      } else {
        Utils.showText(value?.msg ?? "");
      }
    });
  }

  //购买
  void buyGirl() {
    Utils.showAlertBuy(context, data,
        coinTip: '${data['coins']}' + Utils.txt('jbjs'),
        vipTip: Utils.txt('vmfjs'),
        cancelQuit: false,
        buyFunc: reqGirlBuy, doneFunc: (resData) {
      data['contact'] = resData['contact'];
      if (mounted) setState(() {});
    });
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return Stack(
      children: [
        netError
            ? LoadStatus.netError(onTap: () {
                netError = false;
                getData();
              })
            : isHud
                ? LoadStatus.showLoading(mounted)
                : SingleChildScrollView(
                    // padding:
                    //     EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 320.w,
                          child: Stack(
                            children: [
                              Swiper(
                                itemCount: _medias.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (_medias[index]['media_type'] != 1) {
                                        return;
                                      }

                                      List pics = [];
                                      for (var element in _medias) {
                                        if (element['media_type'] == 1) {
                                          pics.add(
                                            Utils.getPICURL(element),
                                            // {'media_url': element['media_url']},
                                          );
                                        }
                                      }

                                      Map pPicMap = Map.from(picMap);
                                      pPicMap['resources'] = pics;

                                      int jumpIndex = 0;
                                      for (var i = 0; i < pics.length; i++) {
                                        if (pics[i] ==
                                            Utils.getPICURL(_medias[index])) {
                                          jumpIndex = i;
                                          break;
                                        }
                                      }
                                      pPicMap['index'] = jumpIndex;
                                      String picurl = EncDecrypt.encry(
                                          convert.jsonEncode(pPicMap));
                                      Utils.navTo(
                                          context, '/previewviewpage/$picurl');
                                    },
                                    child: ImageNetTool(
                                      url: Utils.getPICURL(_medias[index]),
                                    ),
                                  );
                                },
                                onIndexChanged: (index) {
                                  _selectedIndex = index;
                                  setState(() {});
                                },
                              ),
                              Positioned(
                                right: 10.w,
                                bottom: 10.w,
                                child: Container(
                                  width: 55.w,
                                  height: 25.w,
                                  decoration: BoxDecoration(
                                      color: StyleTheme.blackColor
                                          .withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(12.5.w)),
                                  child: Center(
                                    child: Text(
                                      "${_selectedIndex + 1} / ${_medias.length}",
                                      style: StyleTheme.font_white_255_16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: StyleTheme.margin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 16.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '¥${data['price']}',
                                      style: StyleTheme.font_yellow_255_23_semi,
                                    ),
                                    Row(
                                      children: [
                                        // LocalPNG(
                                        //   name: 'hls_chat_share',
                                        //   width: 25.w,
                                        //   height: 25.w,
                                        // ),
                                        // SizedBox(
                                        //   width: 5.w,
                                        // ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: postLikeData,
                                          child: Row(
                                            children: [
                                              LocalPNG(
                                                name: data["is_like"] == 1
                                                    ? 'ai_chat_like_on'
                                                    : 'ai_chat_like_off',
                                                width: 20.w,
                                                height: 20.w,
                                              ),
                                              SizedBox(
                                                width: 4.w,
                                              ),
                                              Text(
                                                Utils.renderFixedNumber(
                                                    data['like_fct']),
                                                style: StyleTheme
                                                    .font_black_7716_04_13,
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: postCollectData,
                                          child: Row(
                                            children: [
                                              LocalPNG(
                                                name: data["is_favorite"] == 1
                                                    ? 'ai_chat_favorite_on'
                                                    : 'ai_chat_favorite_off',
                                                width: 20.w,
                                                height: 20.w,
                                              ),
                                              SizedBox(
                                                width: 2.w,
                                              ),
                                              Text(
                                                Utils.renderFixedNumber(
                                                    data['favorite_fct']),
                                                style: StyleTheme
                                                    .font_black_7716_04_13,
                                              )
                                            ],
                                          ),
                                        ),

                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            Utils.navTo(
                                                context, '/minesharepage');
                                          },
                                          child: Row(
                                            children: [
                                              LocalPNG(
                                                name: 'ai_girl_share',
                                                width: 24.w,
                                                height: 24.w,
                                              ),
                                              SizedBox(
                                                width: 2.w,
                                              ),
                                              Text(
                                                Utils.txt('fenx'),
                                                style: StyleTheme
                                                    .font_black_7716_04_13,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.w,
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    data['title'],
                                    style: StyleTheme.font_black_7716_18_blod,
                                    maxLines: 99,
                                  ),
                                  // SizedBox(
                                  //   width: 10.w,
                                  // ),
                                  // Container(
                                  //   // width: 55.w,
                                  //   height: 26.w,
                                  //   padding:
                                  //       EdgeInsets.symmetric(horizontal: 5.w),
                                  //   decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.all(
                                  //           Radius.circular(13.w)),
                                  //       border: Border.all(
                                  //           color: StyleTheme.blue52Color,
                                  //           width: 0.5.w)),
                                  //   child: Row(
                                  //     children: [
                                  //       LocalPNG(
                                  //         name: 'hls_chat_official_tip',
                                  //         width: 15.w,
                                  //         height: 15.w,
                                  //       ),
                                  //       SizedBox(
                                  //         width: 6.w,
                                  //       ),
                                  //       Text(
                                  //         Utils.txt("gfts"),
                                  //         style: StyleTheme.font_blue_52_11,
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                              SizedBox(
                                height: 10.w,
                              ),
                              Text(
                                _tip,
                                maxLines: 1000,
                                style: StyleTheme.font_blue_52_13,
                              ),

                              //                               "tdzl": "她的资料",
                              // "grzl": "个人资料",
                              // "xfqk": "消费情况",
                              // "fwxm": "服务项目",
                              // "jiesao": "介绍",
                              // "lxfs": "联系方式",
                              // "lxfsys": "联系方式：已隐藏，需要a金币解锁",

                              SizedBox(
                                height: 10.w,
                              ),
                              Text(
                                Utils.txt('ziliao') +
                                    ": " +
                                    '${data["age"]}' +
                                    Utils.txt('sold') +
                                    ' ' +
                                    '${data["height"]}' +
                                    Utils.txt('c') +
                                    ' ' +
                                    '${data["cup"]}' +
                                    Utils.txt('bzcup'),
                                style: StyleTheme.font_black_7716_14,
                              ),
                              SizedBox(
                                height: 10.w,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Utils.txt('xangmu') + ": ",
                                    style: StyleTheme.font_black_7716_14,
                                    maxLines: 999,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${data['service']}',
                                      style: StyleTheme.font_black_7716_14,
                                      maxLines: 999,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.w,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Utils.txt('jiesao') + ": ",
                                    style: StyleTheme.font_black_7716_14,
                                    maxLines: 999,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${data['intro']}',
                                      style: StyleTheme.font_black_7716_14,
                                      maxLines: 999,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.w,
                              ),
                              _sourceArea(),
                            ],
                          ),
                        ),
                        SizedBox(height: 50.w),
                      ],
                    ),
                  ),
        Utils.createNav(
            navColor: Colors.transparent,
            left: GestureDetector(
              child: Container(
                alignment: Alignment.centerLeft,
                width: 40.w,
                height: 40.w,
                child: LocalPNG(
                  name: 'ai_nav_back',
                  width: 17.w,
                  height: 17.w,
                  fit: BoxFit.contain,
                ),
              ),
              behavior: HitTestBehavior.translucent,
              onTap: () {
                finish();
              },
            )),
        // Column(
        //   children: [
        //     SizedBox(
        //       height: StyleTheme.topHeight,
        //     ),
        //   ],
        // )
      ],
    );
  }

  Widget _sourceArea() {
    String contact = data['contact'] ?? '';

    return Column(
      children: [
        Builder(
          builder: (
            context,
          ) {
            if (contact.isEmpty) {
              return Column(
                children: [
                  DottedBorder(
                    color: StyleTheme.blue52Color,
                    padding: EdgeInsets.zero,
                    strokeWidth: 1.w,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(5.w),
                    child: Container(
                      color: StyleTheme.blue52Color.withOpacity(0.3),
                      height: 64.w,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // MyImage.asset(
                          //   MyImagePaths.appGameWarning,
                          //   width: 15.w,
                          // ),
                          Text(
                            data['type'] == 1 // 0： 免费 1:VIP 2:金币
                                ? Utils.txt('lxfsysvip')
                                : Utils.txt('lxfsys')
                                    .replaceAll('a', '${data['coins']}'),
                            style: StyleTheme.font_blue_52_12,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 13.w),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: buyGirl,
                    child: Container(
                      height: 50.w,
                      // margin:
                      //     EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      decoration: data['type'] == 1
                          ? BoxDecoration(
                              color: StyleTheme.blue52Color,
                              borderRadius: BorderRadius.circular(25.w))
                          : BoxDecoration(
                              // color: StyleTheme.blue52Color,
                              gradient: StyleTheme.gradBlue,
                              borderRadius: BorderRadius.circular(25.w)),
                      child: Center(
                        child: Text(
                          data['type'] == 1 // 0： 免费 1:VIP 2:金币
                              ? Utils.txt('vmfjs')
                              : '${data['coins']}' + Utils.txt('jbjs'),
                          style: data['type'] == 1
                              ? StyleTheme.font_white_255_15_semi
                              : StyleTheme.font_white_255_15_semi,
                        ),
                      ),
                    ),
                  )
                ],
              );
            }

            return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // uploadData();
                  Utils.copyToClipboard('${data['contact']}', showToast: true, tip: Utils.txt('yfz'));
                },
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: Utils.txt('lxfs') + ": " + '${data['contact']}',
                    style: StyleTheme.font_blue_52_13,
                  ),
                  TextSpan(
                    text: '（${Utils.txt('djfz')}）',
                    style: StyleTheme.font_blue_52_13,
                  ),
                ])));
          },
        ),
      ],
    );
  }
}
