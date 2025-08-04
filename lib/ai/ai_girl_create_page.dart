import 'dart:convert';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/user_model.dart';
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

class AIGirlCreatePage extends BaseWidget {
  AIGirlCreatePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _AIGirlCreatePageState();
  }
}

class _AIGirlCreatePageState extends BaseWidgetState<AIGirlCreatePage> {
  bool isHud = true;
  bool netError = false;

  String girlName = '';

  final inputFocusNode = FocusNode();

  List _items = [];

  getData() async {
    final res = await reqCharactorOptions();

    if (res?.status != 1) {
      netError = true;
      isHud = false;
      if (mounted) setState(() {});
      return;
    }

    List tp = List.from(res?.data ?? []);

    _items = tp;
    isHud = false;
    if (mounted) setState(() {});
  }

  _askCreateGirl() {
    if (girlName.isEmpty) {
      Utils.showText(Utils.txt('wndainycjygmz'));
      return;
    }
    for (var element in _items) {
      if (element['items'].every((item) => !(item['is_selected'] ?? false))) {
        Utils.showText('您还未选择${element['name']}');
        return;
      }
    }

    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    int characterValue = user?.ai_girlfriend_create_value ?? 0; //免费创建AI女友次数

    int money = user?.money ?? 0;
    int needmoney =
        Provider.of<BaseStore>(context, listen: false).conf?.character_coins ??
            0; //创建AI女友每次消耗金币数

    bool isInsufficient = money < needmoney;

// 有次数或者是VIP
    if (characterValue > 0) {
      _createGirl(count: characterValue - 1);
      return;
    }

    Utils.showDialog(
        cancelTxt: Utils.txt('quxao'),
        confirmTxt: isInsufficient ? Utils.txt('qwcz') : Utils.txt('gmgk'),
        setContent: () {
          return Column(
            children: [
              Text(Utils.txt('gmhckycnr'),
                  style: StyleTheme.font_gray_153_13, maxLines: 3),
              SizedBox(height: 15.w),
              Text("$needmoney" + Utils.txt('jinb'),
                  style: StyleTheme.font_yellow_255_13,
                  textAlign: TextAlign.center),
              SizedBox(height: 15.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Utils.txt('ktvpzk') + "：$money",
                      style: StyleTheme.font_gray_153_13),
                ],
              ),
            ],
          );
        },
        confirm: () {
          if (isInsufficient) {
            Utils.navTo(context, "/minegoldcenterpage");
          } else {
            _createGirl(money: money - needmoney); //直接购买
          }
        });
  }

  void _createGirl({int? money, count}) async {
    // UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    // final userCoins = user?.coins ?? 0; //用户剩余金币
    // int characterValue = user?.ai_girlfriend_chat_value ?? 0; //免费创建AI女友次数
    // int characterCoins =
    //     Provider.of<BaseStore>(context, listen: false).conf?.character_coins ??
    //         0; //创建AI女友每次消耗金币数
    // bool isSufficient = userCoins >= characterCoins; //金币是否足够

    Utils.startGif(tip: Utils.txt('nycjz'));

    final res = await reqCharactorCreate(
        name: girlName.trim(),
        figure: getSelectedItemsByProperty(_items, "figure"),
        race: getSelectedItemsByProperty(_items, "race"),
        age: getSelectedItemsByProperty(_items, "age"),
        eye_color: getSelectedItemsByProperty(_items, "eye_color"),
        hairstyle: getSelectedItemsByProperty(_items, "hairstyle"),
        hair_color: getSelectedItemsByProperty(_items, "hair_color"),
        body_shape: getSelectedItemsByProperty(_items, "body_shape"),
        breast_size: getSelectedItemsByProperty(_items, "breast_size"),
        hip_size: getSelectedItemsByProperty(_items, "hip_size"),
        personality: getSelectedItemsByProperty(_items, "personality"),
        hobby: getSelectedItemsByProperty(_items, "hobby"),
        relation: getSelectedItemsByProperty(_items, "relation"),
        clothes: getSelectedItemsByProperty(_items, "clothes"),
        money: money,
        count: count,
        context: context);

    Utils.closeGif();
    if (res?.status == 1) {
      Utils.showDialog(
        confirmTxt: Utils.txt('quren'),
        setContent: () {
          return Text(
            res?.data['desc'] ?? Utils.txt('nycjcg'),
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
            res?.msg ?? '',
            style: StyleTheme.font_gray_153_13,
            maxLines: 10,
          );
        },
        confirm: () {
          // finish();
        },
      );
    }
  }

  void selectItem(dynamic model, int itemId) {
    Utils.unFocusNode(context);
    for (var item in model['items']) {
      item['is_selected'] = (item['id'] == itemId); // 仅设置匹配 id 的 Item 为选中
    }

    setState(() {
      // model.selectItemById(itemId);
    });
  }

  String getSelectedItemsByProperty(List characters, String property) {
    List selectedTitles = characters
        .where((character) => character['property'] == property)
        .expand((character) => List.from(character['items']))
        .where((item) => item['is_selected'] ?? false)
        .map((item) => item['title'])
        .toList();

    return selectedTitles.join(',');
  }

  Widget _bottomCreatView() {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    // int characterValue =
    //     Provider.of<BaseStore>(context, listen: false).conf?.character_coins;

    final userCoins = user?.coins ?? 0; //用户剩余金币
    int characterValue = user?.ai_girlfriend_create_value ?? 0; //免费创建AI女友次数
    int characterCoins =
        Provider.of<BaseStore>(context, listen: false).conf?.character_coins ??
            0; //创建AI女友每次消耗金币数
    bool isSufficient = userCoins >= characterCoins; //金币是否足够

    String titleStr = '';
    if (characterValue > 0) {
      titleStr = '立即生成 (剩余$characterValue次)';
    } else {
      titleStr = '立即生成 ($characterCoins金币)';
    }

    return (user?.vip_level ?? 0) > 0
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _askCreateGirl,
                child: Container(
                  // padding:
                  //     EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
                  width: 320.w,
                  height: 40.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: StyleTheme.blue52Color,
                      borderRadius: BorderRadius.circular(20.w)),
                  child: Text(titleStr, style: StyleTheme.font_white_255_15),
                ),
              ),
            ],
          )
        : Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _askCreateGirl,
                  child: Container(
                    // padding: EdgeInsets.symmetric(
                    //   vertical: 15.w,
                    // ),
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        // color: StyleTheme.blue52Color,
                        gradient: StyleTheme.gradBlue,
                        borderRadius: BorderRadius.circular(20.w)),
                    child: Text(titleStr,
                        style: StyleTheme.font_white_255_14_medium),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // const VipCenterRoute().push(context);
                    Utils.navTo(context, '/minevippage');
                  },
                  child: Container(
                    // padding:
                    //     EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: StyleTheme.blue52Color,
                        borderRadius: BorderRadius.circular(20.w)),
                    child: Text(Utils.txt('ktvipmfsc'),
                        style: StyleTheme.font_white_255_15),
                  ),
                ),
              ),
            ],
          );
  }

  @override
  void onCreate() {
    setAppTitle(
        titleW: Text(Utils.txt('cjzjdainy'), style: StyleTheme.nav_title_font));

    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return isHud
        ? LoadStatus.showLoading(mounted)
        : netError
            ? LoadStatus.netError(onTap: () {
                netError = false;
                getData();
              })
            : Container(
                color: StyleTheme.bgColor,
                padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Utils.unFocusNode(context);
                  },
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            Utils.txt('srmz'),
                            style: StyleTheme.font_black_7716_04_15,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.w,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: StyleTheme.whiteColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4.w)),
                        child: TextField(
                          onChanged: (value) {
                            girlName = value;
                          },
                          style: StyleTheme.font_white_255_14,
                          cursorColor: StyleTheme.blue52Color,
                          textInputAction: TextInputAction.done,
                          decoration: Utils.customInputStyle(
                              horizontal: 15.w,
                              hit: Utils.txt('wndainycjygmz')),
                        ),
                      ),
                      SizedBox(
                        height: 10.w,
                      ),
                      for (var i = 0; i < _items.length; i++)
                        CommonSelectOption(
                          data: _items[i],
                          onTap: (item) {
                            selectItem(_items[i], item['id']);
                          },
                        ),
                      SizedBox(
                        height: 40.w,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.w),
                        child: Center(
                          child: Text(
                            Utils.txt('qrndainydwghxw'),
                            style: StyleTheme.font_white_255_15_semi,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 9.5.w,
                        runSpacing: 9.5.w,
                        children: List.generate(
                          _items
                              .where((item) => item['type'] == 1)
                              .toList()
                              .length,
                          (index) => ResultType(
                            key: Key(_items[index]['property']),
                            data: _items
                                .where((item) => item['type'] == 1)
                                .toList()[index],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.w),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.w,
                        children: List.generate(
                          _items
                              .where((item) => item['type'] == 0)
                              .toList()
                              .length,
                          (index) => ResultTypeText(
                            data: _items
                                .where((item) => item['type'] == 0)
                                .toList()[index],
                          ),
                        ),
                      ),
                      SizedBox(height: 40.w),
                      _bottomCreatView(),
                      SizedBox(
                        height: 50.w,
                      )
                    ],
                  ),
                ),
              );
  }
}

class ResultType extends StatelessWidget {
  const ResultType({super.key, required this.data});

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    if (data['items'].isEmpty) {
      return const SizedBox.shrink();
    }
    List items = data['items'];
    dynamic selectItem =
        items.firstWhere((item) => item['is_selected'] ?? false,
            orElse: () => {
                  "id": 0,
                  "title": '未选择',
                  "property": '',
                  "image": '',
                  "sort": 0,
                  "created_at": '',
                  "updated_at": '',
                  "image_url": '',
                  "is_selected": false,
                });
    return SelectResultPicture(
      type: data['name'],
      asset: selectItem['image_url'],
      title: selectItem['title'],
    );
  }
}

class ResultTypeText extends StatelessWidget {
  const ResultTypeText({super.key, required this.data});

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    if (data['items'].isEmpty) {
      return const SizedBox.shrink();
    }
    List items = data['items'];
    dynamic selectItem =
        items.firstWhere((item) => item['is_selected'] ?? false,
            orElse: () => {
                  "id": 0,
                  "title": '未选择',
                  "property": '',
                  "image": '',
                  "sort": 0,
                  "created_at": '',
                  "updated_at": '',
                  "image_url": '',
                  "is_selected": false,
                });
    return TextSelectOption(
      label: data['name'],
      title: selectItem['title'],
    );
  }
}

class CommonSelectOption extends StatelessWidget {
  const CommonSelectOption({
    super.key,
    required this.data,
    required this.onTap,
  });

  final dynamic data;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 15.w, bottom: 5),
          child: Text(
            '选择${data['name']}',
            textAlign: TextAlign.left,
            style: StyleTheme.font_black_7716_04_15,
          ),
        ),
        data['type'] == 1
            ? SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
                  children: List.generate(
                      data['items'].length,
                      (index) => GestureDetector(
                            onTap: () {
                              onTap.call(data['items'][index]);
                            },
                            child: SelectOptionCard(
                              width:
                                  data['property'] == "figure" ? 170.w : 80.w,
                              height:
                                  data['property'] == "figure" ? 210.w : 90.w,
                              borderRadius: 5.w,
                              isSelect:
                                  data['items'][index]['is_selected'] ?? false,
                              asset: data['items'][index]['image_url'] ?? '',
                              title: data['items'][index]['title'],
                            ),
                          )),
                ),
              )
            : WrapOption(
                renderList: data['items'],
                onTap: (item) {
                  onTap.call(item);
                },
              )
      ],
    );
  }
}

class TextSelectOption extends StatelessWidget {
  const TextSelectOption({super.key, required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 25.w),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Text(
            title,
            style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: 5.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }
}

class SelectResultPicture extends StatelessWidget {
  const SelectResultPicture(
      {super.key,
      required this.asset,
      required this.type,
      required this.title});

  final String type;
  final String title;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 110.w,
          height: 60.w,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: ImageNetTool(
                  key: Key(asset),
                  url: asset,
                  radius: BorderRadius.circular(3.5.w),
                ),
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          // Colors.transparent,
                          // Colors.black,
                          // Colors.black,

                          Color.fromRGBO(0, 0, 0, 0.3),
                          Color.fromRGBO(0, 0, 0, 0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  )),
            ],
          ),
        ),
        SizedBox(height: 7.w),
        Text(
          type,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class WrapOption extends StatelessWidget {
  const WrapOption({
    super.key,
    required this.renderList,
    required this.onTap,
  });

  final List renderList;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9.5.w,
      runSpacing: 9.5.w,
      children: List.generate(
        renderList.length,
        (index) => GestureDetector(
          onTap: () {
            onTap.call(renderList[index]);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 25.w),
            // height: 35.w,
            decoration: BoxDecoration(
                color: (renderList[index]['is_selected'] ?? false)
                    ? StyleTheme.blue52Color
                    : Colors.white10,
                borderRadius: BorderRadius.circular(4.w)),
            child: Text(
              renderList[index]['title'],
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: renderList[index]['is_selected'] ?? false
                    ? StyleTheme.black019Color
                    : StyleTheme.gray172Color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15.w, bottom: 5),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: StyleTheme.font_white_255_16_semi,
      ),
    );
  }
}

class SelectOptionCard extends StatelessWidget {
  const SelectOptionCard({
    super.key,
    this.isSelect = false,
    required this.borderRadius,
    required this.width,
    required this.height,
    required this.asset,
    required this.title,
  });

  final double width;
  final double height;
  final double borderRadius;
  final bool isSelect;
  final String asset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius)),
              child: ImageNetTool(
                url: asset,
                radius: BorderRadius.circular(5.w),
              ),
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                ),
              )),
          Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius.w),
                    border: Border.all(
                      width: 2.w,
                      color: isSelect
                          ? StyleTheme.blue52Color
                          : Colors.transparent,
                    )),
              )),
          // Positioned.fill(
          //   child: Offstage(
          //     offstage: !isSelect,
          //     child: Container(
          //       decoration: BoxDecoration(
          //           border: Border.all(
          //               width: 2.w, color: StyleTheme.blue52Color)),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
