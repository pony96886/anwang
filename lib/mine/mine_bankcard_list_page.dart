import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MineBankcardListPage extends BaseWidget {
  cState() => _MineBankcardListPageState();
}

class _MineBankcardListPageState extends BaseWidgetState<MineBankcardListPage> {
  int page = 1;
  bool isAll = false;
  bool networkErr = false;
  bool isHud = true;
  late List _dataList;

  int _selectedIndex = -1;
  List<String> accountTypeList = //["sryh",
      ["srkh", "srxm"];

  List<TextEditingController> _textControllerList = [];
  // List<> accountTypeList = ["sryh", "srkh", "srxm"];

  @override
  void onCreate() async {
    setAppTitle(
      titleW: Text(Utils.txt('tx'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          showAddBankCardView();
        },
        child: Text(Utils.txt('tji'), style: StyleTheme.font_black_7716_14),
      ),
    );

    _textControllerList.add(TextEditingController());
    _textControllerList.add(TextEditingController());

    _getBankList();
  }

  @override
  void onDestroy() {}

  _getBankList() async {
    Map param = {"page": page, "limit": 10};
    try {
      ResponseModel<dynamic>? res = await cashBankCardList(param);
      isHud = false;
      if (res?.status != 1) {
        networkErr = true;
        Utils.showText(res?.msg as String);
      } else {
        if (page == 1) {
          _dataList = res?.data['list'];
        } else {
          _dataList.addAll(res?.data['list']);
        }

        if (res?.data['list'].length < 10) {
          isAll = true;
        }
      }
    } catch (e) {
      networkErr = true;
    }

    setState(() {});
  }

  _addBankCard(BuildContext ctx) async {
    String bankNumber = _textControllerList[0].text;
    String userName = _textControllerList[1].text;

    if (bankNumber.length > 0 && userName.length > 0) {
      Utils.startGif();

      Map param = {'card': bankNumber, 'name': userName};

      try {
        ResponseModel<dynamic>? res = await cashAddBankCard(param);
        Utils.log(res?.data);

        if (res?.status != 1) {
          Utils.showText(res?.msg as String);
          ctx.pop();
        } else {
          _getBankList();
          ctx.pop();
        }

        _textControllerList[0].clear();
        _textControllerList[1].clear();

        Utils.closeGif();
      } catch (e) {
        Utils.closeGif();
      }
      // ctx.pop();
    } else {
      Utils.closeGif();

      Utils.showText(Utils.txt('qsrxx'));
    }
  }

  _bankcardDeleteIndex(int index) async {
    dynamic card = _dataList[index];

    Utils.startGif(tip: '');
    Map param = {'id': card['id']};

    try {
      ResponseModel<dynamic>? res = await cashDeleteBankCard(param);
      print(res?.data);
      if (res?.status != 1) {
        Utils.showText(res?.msg as String);
      } else {
        _selectedIndex = -1;
        _getBankList();
      }
      Utils.closeGif();
    } catch (e) {
      Utils.closeGif();
    }
  }

  _askDeleteIndex(int index) {
    Utils.showDialog(
        confirm: () {
          _bankcardDeleteIndex(index);
        },
        cancelTxt: Utils.txt('quxao'),
        setContent: () {
          return Text(Utils.txt("qrsctxzh"),
              style: StyleTheme.font_black_7716_14);
        });
  }

  _addBankcardWidet(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth - 100.w,
      height: 300.w,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DefaultTextStyle(
          style: StyleTheme.font_black_7716_14,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(Utils.txt('tjzh'),
                      style: StyleTheme.font_black_7716_14),
                ),
                SizedBox(height: 20.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(Utils.txt('zhlx')), Text(Utils.txt('yhk'))],
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(10),
                ),
                Column(
                  children: accountTypeList
                      .asMap()
                      .keys
                      .map(
                        (index) => SizedBox(
                          height: ScreenUtil().setWidth(50),
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: _textControllerList[index],
                            // textAlignVertical:
                            // TextAlignVertical.bottom,
                            style: StyleTheme.font_black_7716_14,
                            cursorColor: StyleTheme.blue52Color,
                            keyboardType: index == 0
                                ? TextInputType.number
                                : TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                              ),
                              hintText: Utils.txt(accountTypeList[index]),
                              hintStyle: StyleTheme.font_black_7716_14,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil().setWidth(5)),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(153, 153, 153, 1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil().setWidth(5)),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(153, 153, 153, 1)),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList()
                      .map((e) => Column(
                            children: [
                              e,
                              SizedBox(height: 20.w),
                            ],
                          ))
                      .toList(),
                ),
                SizedBox(height: 20.w),
                GestureDetector(
                  onTap: () {
                    _addBankCard(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40.w,
                    decoration: BoxDecoration(
                        gradient: StyleTheme.gradBlue,
                        borderRadius: BorderRadius.all(Radius.circular(5.w))),
                    child: Center(
                      child: Text(Utils.txt('quren'),
                          style: StyleTheme.font_white_255_14),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAddBankCardView() {
    showDialog(
        context: context,
        builder: (ss) {
          return AlertDialog(
              backgroundColor: StyleTheme.whiteColor,
              content: _addBankcardWidet(ss));
        });

    return;
  }

  @override
  pageBody(BuildContext context) {
    return networkErr
        ? LoadStatus.netError()
        : isHud
            ? LoadStatus.showLoading(mounted)
            : _dataList.length == 0
                ? Stack(
                    children: [
                      Positioned.fill(
                          child: LoadStatus.noData(text: Utils.txt('zwyhk'))),
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 20.w),
                        child: GestureDetector(
                          onTap: () {
                            showAddBankCardView();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenUtil().setWidth(324),
                            height: ScreenUtil().setWidth(40),
                            decoration: BoxDecoration(
                                gradient: StyleTheme.gradBlue,
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil().setWidth(5))),
                            child: Text(Utils.txt('tjxzh'),
                                style: StyleTheme.font_white_255_15),
                          ),
                        ),
                      )
                    ],
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                          child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: _dataList.asMap().keys.map((index) {
                            dynamic data = _dataList[index];
                            return Container(
                                padding: EdgeInsets.only(
                                  bottom: StyleTheme.margin,
                                ),
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      CustomSlidableAction(
                                        onPressed: (BuildContext context) {
                                          _askDeleteIndex(index);
                                        },
                                        flex: 1,
                                        backgroundColor: Colors.transparent,
                                        child: Icon(Icons.delete,
                                            size: 30.w,
                                            color: StyleTheme.blue52Color),
                                      ),
                                    ],
                                  ),
                                  child: MineBankCardWidget(
                                    data,
                                    selected: _selectedIndex == index,
                                    onTap: () {
                                      if (_selectedIndex != index) {
                                        _selectedIndex = index;
                                        setState(() {});
                                      }
                                    },
                                    index: index,
                                  ),
                                ));
                          }).toList(),
                        ),
                      )),
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 20.w),
                        child: Offstage(
                          child: GestureDetector(
                            onTap: () {
                              UtilEventbus().fire(EventbusClass({
                                "name": "cash_choose_bankcard",
                                'item': _dataList[_selectedIndex]
                              }));

                              context.pop();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: ScreenUtil().setWidth(328),
                              height: ScreenUtil().setWidth(44),
                              decoration: BoxDecoration(
                                  gradient: StyleTheme.gradBlue,
                                  borderRadius: BorderRadius.circular(5.w)),
                              child: Text(Utils.txt('quren'),
                                  style: StyleTheme.font_white_255_14),
                            ),
                          ),
                          offstage: _selectedIndex < 0,
                        ),
                      )
                    ],
                  );
  }
}

class MineBankCardWidget extends StatelessWidget {
  MineBankCardWidget(this.data,
      {this.selected = true, this.index = 0, required this.onTap});
  dynamic data;
  bool selected = false;
  int index;
  void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
            height: 110.w,
            width: double.infinity,
            child: Stack(children: [
              Positioned.fill(
                  child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(10)),
                ),
                width: double.infinity,
                height: double.infinity,
                child: LocalPNG(
                  name: ['ai_bcr_bg', 'ai_bcb_bg', 'ai_bco_bg'][index % 3],
                  fit: BoxFit.cover,
                ),
              )),
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  margin: EdgeInsets.only(
                    left: StyleTheme.margin,
                    top: StyleTheme.margin,
                    bottom: StyleTheme.margin,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          child: UnconstrainedBox(
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${data['bank']}',
                                    style: StyleTheme.font_white_255_14),
                                Text(
                                    '${data['card_type']}' +
                                        '|' +
                                        '${data['name']}',
                                    style: StyleTheme.font_white_255_14)
                              ],
                            )
                          ],
                        ),
                      )),
                      Positioned(
                          bottom: 0,
                          child: UnconstrainedBox(
                            child: Text(subStringFour('${data['card']}'),
                                style: StyleTheme.font_white_255_14),
                          )),
                      Positioned.fill(
                          right: 0,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ClipPath(
                              clipper: MyClipper(),
                              child: Container(
                                width: ScreenUtil().setWidth(41),
                                height: ScreenUtil().setWidth(57),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                            ScreenUtil().setWidth(5)),
                                        topRight: Radius.circular(
                                            ScreenUtil().setWidth(5))),
                                    color: selected
                                        ? Colors.white
                                        : Colors.white
                                            .withAlpha((255 * 0.6).toInt())),
                                child: Row(
                                  children: [
                                    SizedBox(width: 9.w),
                                    SizedBox.square(
                                        dimension: 20.w,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.w),
                                            color: selected
                                                ? StyleTheme.blue52Color
                                                : Colors.black.withAlpha(
                                                    (255 * 0.2).toInt()),
                                          ),
                                          child: selected
                                              ? Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 10.w,
                                                )
                                              : Container(),
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          ))
                    ],
                  ))
              // ))
              // ]
            ])));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // double roundFactor = size.width;
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(-size.width, size.height / 2.0, size.width, 0);
    // path.lineTo(0, size.height / 3.3);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

///把String分隔成4个字符一段的
String subStringFour(String text) {
  String str = '';
  int index = 1;
  for (var character in text.characters) {
    str += character;
    if (index % 4 == 0) {
      str += ' ';
    }
    index += 1;
  }
  return str;
}
