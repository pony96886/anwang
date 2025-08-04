import 'dart:convert';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as imgLib;

class HomeNakedChatPublishPage extends BaseWidget {
  HomeNakedChatPublishPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeNakedChatPublishPageState();
  }
}

class _HomeNakedChatPublishPageState
    extends BaseWidgetState<HomeNakedChatPublishPage> {
  bool isHud = true;
  bool netError = false;
  final ImagePicker picker = ImagePicker();

  int picLimit = 6;
  List<Map> upList = [];

  List _seletedCates = [];
  Map cate = {};
  String girlName = '';
  String girlAge = '';
  String girlHeight = '';
  String girlWeight = '';
  String girlCup = '';
  String girlPrice = '';
  String girlTime = '';
  String girlOption = '';
  String girlIntro = '';
  String girlContact = '';

  showCategory(BuildContext ctx) {
    List cates =
        Provider.of<BaseStore>(context, listen: false).conf?.chat_select_nav ??
            [];

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: ctx,
        builder: (context) {
          List seletedCates = List.from(_seletedCates);
          return StatefulBuilder(builder: (context, sss) {
            return Container(
              color: StyleTheme.bgColor,
              padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
              // height: 200.w,\
              constraints: BoxConstraints(minHeight: 100.w, maxHeight: 300.w),
              child: Column(
                children: [
                  SizedBox(
                    height: 40.w,
                    child: Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Icon(
                            Icons.close,
                            size: 25.w,
                            color: StyleTheme.blak7716Color,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  Wrap(
                      runSpacing: 5.w,
                      spacing: 5.w,
                      children: cates
                          .map((e) => GestureDetector(
                                onTap: () {
                                  if (seletedCates.contains(e)) {
                                    seletedCates.remove(e);
                                  } else {
                                    seletedCates.add(e);
                                  }
                                  sss(() {});
                                },
                                child: Builder(builder: (context) {
                                  bool isSelected = false;
                                  for (var element in seletedCates) {
                                    if (element == e) {
                                      isSelected = true;
                                      break;
                                    }
                                  }
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 5.w),
                                    decoration: BoxDecoration(
                                        color: isSelected
                                            ? StyleTheme.blue52Color
                                            : StyleTheme.whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(5.w)),
                                    child: Text(
                                      '${e['name']}',
                                      style: isSelected
                                          ? StyleTheme.font_white_255_14
                                          : StyleTheme.font_black_7716_14,
                                    ),
                                  );
                                }),
                              ))
                          .toList()),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _seletedCates = seletedCates;
                      _seletedCates.sort((a, b) => int.parse(a['id'].toString())
                          .compareTo(int.parse(b['id'].toString())));
                      setState(() {});
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: StyleTheme.margin, vertical: 10.w),
                      height: 50.w,
                      decoration: BoxDecoration(
                          // color: StyleTheme.blue52Color,
                          gradient: StyleTheme.gradBlue,
                          borderRadius: BorderRadius.circular(25.w)),
                      child: Center(
                        child: Builder(builder: (context) {
                          return Text(
                            Utils.txt('quren'),
                            style: StyleTheme.font_white_255_15,
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(
                      // height: StyleTheme.bottom + 20.w,
                      )
                ],
              ),
            );
          });
        });
  }

  Future<void> imagePickerAssets() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.pngLimitSize(file);
      if (flag) return;
      uploadPNG(file);
    }
  }

  void uploadPNG(XFile file) async {
    Utils.startGif(tip: Utils.txt('scz'));
    var res;
    if (kIsWeb) {
      res = await NetworkHttp.xfileHtmlUploadImage(
          file: file, position: 'upload');
    } else {
      res = await NetworkHttp.xfileUploadImage(file: file, position: 'upload');
    }
    // var data = jsonDecode(res);
    var data = Map.from(res);
    BotToast.closeAllLoading();
    if (data['code'] == 1) {
      String url = data['msg'].toString();
      var image = imgLib.decodeImage(await file.readAsBytes());

      String imgBaseUrl = AppGlobal.imgBaseUrl.toString();
      String lastString = imgBaseUrl.substring(imgBaseUrl.length - 1);
      String firstString = url.substring(0, 1);
      if (lastString == '/' || firstString == '/') {
        imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);
      }
      upList.add({
        "media_url": url,
        "url": imgBaseUrl + url,
        "thumb_width": image?.width ?? 100,
        "thumb_height": image?.height ?? 100,
      });
      if (mounted) setState(() {});
    } else {
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  void uploadData() {
    if (_seletedCates.isEmpty ||
        girlName.isEmpty ||
        girlAge.isEmpty ||
        girlHeight.isEmpty ||
        girlWeight.isEmpty ||
        girlCup.isEmpty ||
        girlPrice.isEmpty ||
        girlTime.isEmpty ||
        girlOption.isEmpty ||
        girlIntro.isEmpty ||
        girlContact.isEmpty) {
      Utils.showText(Utils.txt("qs"));
      return;
    }

    if (upList.isEmpty) {
      Utils.showText(Utils.txt("qsctp"));
      return;
    }

    List media = [];
    for (var element in upList) {
      media.add({
        'cover': element['media_url'],
        "uri": element['media_url'],
        "width": element['thumb_width'],
        "height": element['thumb_height'],
        "type": "img",
      });
    }

    String cateString = _seletedCates.map((e) => e['id']).join(',');

    Utils.startGif();
    reqNakedChatCreat(
      cateId: cateString,
      name: girlName,
      price: girlPrice,
      age: girlAge,
      height: girlHeight,
      weight: girlWeight,
      cup: girlCup,
      option: girlOption,
      time: girlTime,
      contact: girlContact,
      intro: girlIntro,
      medias: json.encode(media),
      // context,
    ).then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        Utils.showDialog(
          confirmTxt: Utils.txt('quren'),
          setContent: () {
            return Text(
              value?.msg ?? '',
              style: StyleTheme.font_gray_153_13,
              maxLines: 10,
            );
          },
          confirm: () {
            finish();
          },
        );
      } else {
        Utils.showDialog(
          confirmTxt: Utils.txt('quren'),
          setContent: () {
            return Text(
              value?.msg ?? '',
              style: StyleTheme.font_gray_153_13,
              maxLines: 10,
            );
          },
          confirm: () {
            // finish();
          },
        );
      }
    });
  }

  @override
  void onCreate() {
    setAppTitle(
        titleW: Text(Utils.txt('fbll'), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return Scaffold(
      body: Container(
        color: StyleTheme.bgColor,
        padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Utils.unFocusNode(context);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '*',
                      style: StyleTheme.font(
                          size: 15,
                          weight: FontWeight.w500,
                          color: StyleTheme.blue52Color,
                          height: 2),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      Utils.txt('pnch') + ':',
                      style: StyleTheme.font_black_7716_16,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.w,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: StyleTheme.whiteColor,
                      borderRadius: BorderRadius.circular(4.w)),
                  child: TextField(
                    onChanged: (value) {
                      girlName = value;
                    },
                    style: StyleTheme.font_black_7716_14,
                    cursorColor: StyleTheme.blue52Color,
                    textInputAction: TextInputAction.done,
                    decoration: Utils.customInputStyle(
                        horizontal: 15.w,
                        hit: Utils.txt('qsrnh') + Utils.txt('pnch')),
                  ),
                ),
                SizedBox(
                  height: 10.w,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '*',
                      style: StyleTheme.font(
                          size: 15,
                          weight: FontWeight.w500,
                          color: StyleTheme.blue52Color,
                          height: 2),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      Utils.txt('tdzl') + ':',
                      style: StyleTheme.font_black_7716_16,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.w,
                ),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('lx') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          // Utils.showDialog()
                          showCategory(context);
                        },
                        child: Container(
                            height: 48.w,
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            decoration: BoxDecoration(
                                color: StyleTheme.whiteColor,
                                borderRadius: BorderRadius.circular(4.w)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Builder(builder: (context) {
                                  String text = Utils.txt('qxzyx');

                                  if (_seletedCates.isNotEmpty) {
                                    // text = _seletedCates
                                    //     .map((e) => e['id'])
                                    //     .join(',');

                                    text = _seletedCates
                                        .map((e) => e['name'])
                                        .join(',');
                                  }
                                  return Text(
                                    text,
                                    style: _seletedCates.isEmpty
                                        ? StyleTheme.font_black_7716_04_14
                                        : StyleTheme.font_black_7716_14,
                                  );
                                }),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.w,
                ),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('nl') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: TextField(
                          onChanged: (value) {
                            girlAge = value;
                          },
                          style: StyleTheme.font_black_7716_14,
                          cursorColor: StyleTheme.blue52Color,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp("[0-9]"),
                                allow: true),
                            LengthLimitingTextInputFormatter(4),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: Utils.customInputStyle(
                            horizontal: 15.w,
                            hit: Utils.txt('qsrnh') + Utils.txt('nl'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('sg') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: TextField(
                            onChanged: (value) {
                              girlHeight = value;
                            },
                            style: StyleTheme.font_black_7716_14,
                            cursorColor: StyleTheme.blue52Color,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp("[0-9]"),
                                  allow: true),
                              LengthLimitingTextInputFormatter(4),
                            ],
                            keyboardType: TextInputType.number,
                            decoration: Utils.customInputStyle(
                                horizontal: 15.w,
                                hit: Utils.txt('qsrnh') +
                                    Utils.txt('sg') +
                                    ' cm')),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('tz') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: TextField(
                          onChanged: (value) {
                            girlWeight = value;
                          },
                          style: StyleTheme.font_black_7716_14,
                          cursorColor: StyleTheme.blue52Color,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp("[0-9]"),
                                allow: true),
                            LengthLimitingTextInputFormatter(4),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: Utils.customInputStyle(
                              horizontal: 15.w,
                              hit:
                                  Utils.txt('qsrnh') + Utils.txt('tz') + ' kg'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('bzcup') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: TextField(
                          onChanged: (value) {
                            girlCup = value;
                          },
                          style: StyleTheme.font_black_7716_14,
                          cursorColor: StyleTheme.blue52Color,
                          textInputAction: TextInputAction.done,
                          decoration: Utils.customInputStyle(
                              horizontal: 15.w,
                              hit: Utils.txt('qsrnh') + Utils.txt('bzcup')),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('fybz') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: TextField(
                          onChanged: (value) {
                            girlPrice = value;
                          },
                          style: StyleTheme.font_black_7716_14,
                          cursorColor: StyleTheme.blue52Color,
                          textInputAction: TextInputAction.done,
                          decoration: Utils.customInputStyle(
                              horizontal: 15.w, hit: Utils.txt('qsrfybz')),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('fwsj') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(4.w)),
                        child: TextField(
                          onChanged: (value) {
                            girlTime = value;
                          },
                          style: StyleTheme.font_black_7716_14,
                          cursorColor: StyleTheme.blue52Color,
                          textInputAction: TextInputAction.done,
                          decoration: Utils.customInputStyle(
                              horizontal: 15.w, hit: Utils.txt('qsrfwsj')),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('fwxm') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 150.w,
                        child: Container(
                          decoration: BoxDecoration(
                              color: StyleTheme.whiteColor,
                              borderRadius: BorderRadius.circular(4.w)),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 10,
                            autofocus: false,
                            onChanged: (value) {
                              girlOption = value;
                            },
                            style: StyleTheme.font_black_7716_14,
                            cursorColor: StyleTheme.blue52Color,
                            textInputAction: TextInputAction.done,
                            decoration: Utils.customInputStyle(
                              horizontal: 15.w,
                              hit: Utils.txt('qsrfwxm'),
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.w,
                      child: Center(
                        child: Text(
                          Utils.txt('fwjs') + ':',
                          style: StyleTheme.font_black_7716_16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 150.w,
                        child: Container(
                          decoration: BoxDecoration(
                              color: StyleTheme.whiteColor,
                              borderRadius: BorderRadius.circular(4.w)),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 10,
                            autofocus: false,
                            onChanged: (value) {
                              girlIntro = value;
                            },
                            style: StyleTheme.font_black_7716_14,
                            cursorColor: StyleTheme.blue52Color,
                            textInputAction: TextInputAction.done,
                            decoration: Utils.customInputStyle(
                              horizontal: 15.w,
                              hit: Utils.txt('qsrfwjs'),
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '*',
                      style: StyleTheme.font(
                          size: 15,
                          weight: FontWeight.w500,
                          color: StyleTheme.blue52Color,
                          height: 2),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      Utils.txt('lxfs') + ':',
                      style: StyleTheme.font_black_7716_16,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.w,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: StyleTheme.whiteColor,
                      borderRadius: BorderRadius.circular(4.w)),
                  child: TextField(
                    onChanged: (value) {
                      girlContact = value;
                    },
                    style: StyleTheme.font_black_7716_14,
                    cursorColor: StyleTheme.blue52Color,
                    textInputAction: TextInputAction.done,
                    decoration: Utils.customInputStyle(
                        horizontal: 15.w, hit: Utils.txt('qsrlxfs')),
                  ),
                ),
                SizedBox(
                  height: 10.w,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '*',
                      style: StyleTheme.font(
                          size: 15,
                          weight: FontWeight.w500,
                          color: StyleTheme.blue52Color,
                          height: 2),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      Utils.txt('scfm') + ':',
                      style: StyleTheme.font_black_7716_16,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.w,
                ),
                GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10.w,
                  crossAxisSpacing: 10.w,
                  children: upList.map((e) {
                    Widget w = Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 9.w, right: 9.w),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                            child: ImageNetTool(
                              fit: BoxFit.contain,
                              url: e["url"] ?? '',
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              upList.remove(e);
                              if (mounted) setState(() {});
                            },
                            child: LocalPNG(
                              name: "app_post_delete",
                              width: 18.w,
                              height: 18.w,
                            ),
                          ),
                        )
                      ],
                    );
                    return w;
                  }).toList()
                    ..add(
                      upList.length == picLimit
                          ? Container()
                          : GestureDetector(
                              onTap: imagePickerAssets,
                              child: Stack(children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: StyleTheme.whiteColor,
                                      borderRadius: BorderRadius.circular(7.w)),
                                ),
                                Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          LocalPNG(
                                              name: "ai_post_image_add",
                                              width: 30.w,
                                              height: 30.w),
                                          SizedBox(height: 5.w),
                                          Text(Utils.txt('djsctp'),
                                              style: StyleTheme
                                                  .font_black_7716_04_12)
                                        ]))
                              ]),
                            ),
                    ),
                ),
                SizedBox(
                  height: 10.w,
                ),
                Row(
                  children: [
                    Text(
                      Utils.txt('zuscazpbcgbm')
                          .replaceAll('a', '$picLimit')
                          .replaceAll('b', '2'),
                      style: StyleTheme.font(
                          size: 14, color: StyleTheme.blak7716_04_Color),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.w,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    uploadData();
                  },
                  child: Container(
                    height: 50.w,
                    decoration: BoxDecoration(
                        color: StyleTheme.blue52Color,
                        borderRadius: BorderRadius.circular(25.w)),
                    child: Center(
                      child: Text(
                        Utils.txt('ljfb'),
                        style: StyleTheme.font_white_255_15,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100.w,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
