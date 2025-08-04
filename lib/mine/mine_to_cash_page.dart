import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:deepseek/mine/mine_bankcard_list_page.dart';
import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';

class MineAgentToCashPage extends BaseWidget {
  MineAgentToCashPage({this.isbance = "0"}) : super();
  String isbance;
  cState() => _MineAgentToCashPageState();
}

class _MineAgentToCashPageState extends BaseWidgetState<MineAgentToCashPage> {
  bool networkErr = false;
  bool isHud = true;
  bool _isBalance = false;

  ///提现成功
  bool _applySuccessed = false;
  dynamic _applySuccessedTip;

  dynamic _currentBankcard;
  late String _rule; // 规则
  dynamic _proxy_money; //扣币余额
  double _proxy_rate = 0; // 代理提现 手续费
  int _sumAllResultMoney = 0; // 计算后所有需要扣除的money
  int _sumResultMoney = 0; // 提现到账money
  String inputAmount = "";
  var discrip;

  @override
  void onCreate() {
    _isBalance = widget.isbance == "1";
    setAppTitle(
        titleW: Text(_isBalance ? Utils.txt('sytx') : Utils.txt('dltx'),
            style: StyleTheme.nav_title_font));
    _getWithDrawRule();
    _getBankList();

    discrip = UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == 'cash_choose_bankcard') {
        _currentBankcard = event.arg["item"];
        Utils.log(event);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void onDestroy() {
    discrip.cancel();
  }

  _getWithDrawRule() async {
    try {
      ResponseModel<dynamic>? res = await cashWithdrawRule({});
      if (res?.status != 1) {
        Utils.showText(res?.msg as String);
        isHud = false;
        networkErr = true;
      } else {
        if (_isBalance) {
          _rule = res?.data['rule_coins_text'] ?? res?.data['rule_text'];
        } else {
          _rule = res?.data['rule_proxy_text'] ?? res?.data['rule_text'];
        }
        _proxy_money =
            _isBalance ? res?.data['income_money'] : res?.data['proxy_money'];
        _proxy_rate =
            _isBalance ? res?.data['income_rate'] : res?.data['proxy_rate'];
        isHud = false;
        networkErr = false;
      }
      if (mounted) setState(() {});
    } catch (e) {
      isHud = false;
      networkErr = true;
      if (mounted) setState(() {});
    }
  }

  _getBankList() async {
    Map param = {"page": 1, "limit": 10};
    try {
      ResponseModel<dynamic>? res = await cashBankCardList(param);
      if (res?.status != 1) {
        Utils.showText(res?.msg as String);
      } else {
        List _bankList = res?.data['list'];
        for (var item in _bankList) {
          if (item['is_default'] == 1) {
            _setBankCard(item);
            break;
          }
        }
      }
    } catch (e) {}

    setState(() {});
  }

  _withdrawAct() async {
    dynamic card = _currentBankcard;
    BotToast.showLoading();
    //  "withdraw_from": 1, // 提现类型 1 全民代理，2收益
    Map param = {
      'card_id': card['id'],
      'amount': inputAmount,
      'withdraw_from': _isBalance ? 2 : 1
    };

    try {
      ResponseModel<dynamic>? res;
      res = await cashApplyWithdraw(param);
      if (res?.status != 1) {
        Utils.showText(res?.msg as String);
      } else {
        // Utils.showText(res?.msg as String);
        _applySuccessedTip = res?.msg as String;
        _applySuccessed = true;
        // _getBankList();
        setState(() {});
      }
      BotToast.closeAllLoading();
    } catch (e) {
      BotToast.closeAllLoading();
    }
  }

  _askWithdraw() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (inputAmount.isEmpty) {
      Utils.showText(Utils.txt("srje"));
      return;
    }
    if (_currentBankcard == null) {
      Utils.showText(Utils.txt("xzc"));
      return;
    }

    Utils.showDialog(
        cancelTxt: Utils.txt('quxao'),
        confirm: () {
          _withdrawAct();
        },
        setContent: () {
          return Text(
            Utils.txt('sftxd') +
                '\n' +
                '${_currentBankcard['bank']}' +
                ' ' +
                subStringFour('${_currentBankcard['card']}'),
            style: StyleTheme.font_black_7716_14,
            maxLines: 3,
            textAlign: TextAlign.center,
          );
        });
  }

  _setBankCard(dynamic card) {
    _currentBankcard = card;
    setState(() {});
  }

  @override
  Widget appbar() {
    return !(networkErr == false && isHud == false)
        ? super.appbar()
        : Stack(children: [
            super.appbar(),
            Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  alignment: Alignment.centerRight,
                  height: StyleTheme.navHegiht,
                  child: GestureDetector(
                    onTap: () {
                      Utils.navTo(context, "/minecashrecordpage");
                    },
                    child: Text(Utils.txt('txjl'),
                        style: StyleTheme.font_black_7716_14),
                  ),
                ))
          ]);
  }

  @override
  pageBody(BuildContext context) {
    return networkErr
        ? LoadStatus.netError(onTap: _getWithDrawRule())
        : isHud
            ? LoadStatus.showLoading(mounted)
            : !_applySuccessed
                ? GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: ScreenUtil().setWidth(28)),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        children: [
                                          Text.rich(TextSpan(children: [
                                            TextSpan(
                                                text: Utils.txt('ye') + ': ',
                                                style: StyleTheme
                                                    .font_black_7716_14),
                                            TextSpan(
                                                text: '$_proxy_money',
                                                style: StyleTheme
                                                    .font_black_7716_14),
                                            TextSpan(
                                                text: Utils.txt("yu"),
                                                style: StyleTheme
                                                    .font_black_7716_14),
                                            // TextSpan(
                                            //     text:
                                            //         ' (${Utils.txt("hl")}：$_scale_tip)',
                                            //     style:
                                            //         StyleTheme.font_white_215_14),
                                          ])),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ScreenUtil().setHeight(15)),
                                  Text(Utils.txt("txye"),
                                      style: StyleTheme.font_black_7716_14),
                                  SizedBox(height: ScreenUtil().setWidth(10)),
                                  Container(
                                    height: 50.w,
                                    decoration: BoxDecoration(
                                      color: StyleTheme.whiteColor,
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: StyleTheme.margin),
                                    alignment: Alignment.center,
                                    child: TextField(
                                      onChanged: (value) {
                                        Utils.log("print --- $value");
                                        inputAmount =
                                            value.isEmpty ? "0" : value;
                                        _sumResultMoney =
                                            int.parse(inputAmount);
                                        _sumAllResultMoney = (_sumResultMoney /
                                                (1 - _proxy_rate))
                                            .ceil();
                                        if (mounted) setState(() {});
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(8),
                                      ],
                                      style: StyleTheme.font_black_7716_14,
                                      cursorColor: StyleTheme.blue52Color,
                                      decoration: InputDecoration(
                                        hintText: Utils.txt('srje'),
                                        hintStyle:
                                            StyleTheme.font_black_7716_14,
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: ScreenUtil().setWidth(11.5)),
                                  RichText(
                                      maxLines: 1,
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: Utils.txt('xhj') +
                                                Utils.txt('kc'),
                                            style:
                                                StyleTheme.font_black_7716_14),
                                        TextSpan(
                                            text: '$_sumAllResultMoney',
                                            style:
                                                StyleTheme.font_black_7716_14),
                                        // TextSpan(
                                        //     text: Utils.txt('bs'),
                                        //     style: StyleTheme.font_white_215_14
                                        const TextSpan(text: ' '),
                                        TextSpan(
                                            text: Utils.txt('dzhj') + ': ',
                                            style:
                                                StyleTheme.font_black_7716_14),
                                        TextSpan(
                                            text: '$_sumResultMoney',
                                            style:
                                                StyleTheme.font_black_7716_14),
                                        TextSpan(
                                            text: Utils.txt('yu'),
                                            style:
                                                StyleTheme.font_black_7716_14),
                                      ])),
                                  SizedBox(height: 25.w),
                                  GestureDetector(
                                    onTap: () {
                                      Utils.navTo(
                                          context, "/minebankcardlistpage");
                                    },
                                    child: Container(
                                      height: 50.w,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: StyleTheme.margin,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.w),
                                        color: StyleTheme.whiteColor,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _currentBankcard != null
                                              ? Text(
                                                  '${_currentBankcard['bank']}' +
                                                      ' ' +
                                                      subStringFour(
                                                          '${_currentBankcard['card']}'),
                                                  style: StyleTheme
                                                      .font_blue_30_14)
                                              : Text(Utils.txt('xztx'),
                                                  style: StyleTheme
                                                      .font_black_7716_14),
                                          Icon(
                                            Icons.keyboard_arrow_right_outlined,
                                            size: 30.w,
                                            color: const Color.fromRGBO(
                                                215, 215, 215, 1),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.w),
                                  Text(
                                    Utils.txt("txgz"),
                                    style: StyleTheme.font_black_7716_14,
                                  ),
                                  SizedBox(height: ScreenUtil().setHeight(5)),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      // Utils.txt('txgzd'),
                                      _rule,
                                      style: StyleTheme.font_gray_153_12,
                                      maxLines: 100,
                                      strutStyle: StrutStyle(
                                          forceStrutHeight: true,
                                          height: 1.w,
                                          leading: 0.9),
                                    ),
                                  ),
                                  SizedBox(height: 40.w),
                                  Container(
                                    margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewPadding
                                            .bottom),
                                    alignment: Alignment.bottomCenter,
                                    child: Offstage(
                                      child: GestureDetector(
                                        onTap: () {
                                          _askWithdraw();
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          width:
                                              ScreenUtil().screenWidth - 20.w,
                                          height: 44.w,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.w),
                                            gradient: StyleTheme.gradBlue,
                                          ),
                                          child: Text(Utils.txt('qrtx'),
                                              style:
                                                  StyleTheme.font_white_255_15),
                                        ),
                                      ),
                                      offstage: false,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(height: 105.w),
                    // SizedBox.square(
                    //   dimension: 150,
                    //   child: LocalPNG(name: 'ds_circle_post_success'),
                    // ),
                    // SizedBox(height: 40.w),
                    _applySuccessedTip != null
                        ? Container(
                            padding: EdgeInsets.only(
                                bottom: 20.w,
                                left: StyleTheme.margin,
                                right: StyleTheme.margin),
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              '$_applySuccessedTip',
                              textAlign: TextAlign.center,
                              style: StyleTheme.font_black_7716_14,
                              maxLines: 10,
                            ))
                        : Container(),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        finish();
                      },
                      child: Container(
                        width: 240.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.w),
                            gradient: StyleTheme.gradBlue),
                        child: Center(
                          child: Text(
                            Utils.txt('fh'),
                            style: StyleTheme.font_white_255_15,
                          ),
                        ),
                      ),
                    )
                  ]);
  }

  String calcFormula(String s) {
    s = "(" + s + ")";
    s = s.replaceAll(' ', '');
    RegExp r1 = RegExp(r"(()?)\(([^\)\(]*)\)");
    RegExp r2 = RegExp(r"([0-9\.]+)(\^)([0-9\.]+)");
    RegExp r3 = RegExp(r"([0-9\.]+)([\*\/\%])([0-9\.]+)");
    RegExp r4 = RegExp(r"([0-9\.]+)([\+\-])([0-9\.]+)");
    while (true) {
      var v1 = r1.firstMatch(s);
      if (v1 == null) {
        break;
      }
      var s1 = v1.group(3).toString();
      while (true) {
        var v2 = r2.firstMatch(s1);
        if (v2 == null) {
          v2 = r3.firstMatch(s1);
          if (v2 == null) {
            v2 = r4.firstMatch(s1);
            if (v2 == null) {
              break;
            }
          }
        }
        var opt = v2.group(2).toString().trim();
        var n1 = double.parse(v2.group(1).toString());
        var n2 = double.parse(v2.group(3).toString());
        var ret = "";
        if (opt == "+") {
          ret = (n1 + n2).toString();
        } else if (opt == "-") {
          ret = (n1 - n2).toString();
        } else if (opt == "*") {
          ret = (n1 * n2).toString();
        } else if (opt == "/") {
          ret = (n1 / n2).toString();
        } else if (opt == "%") {
          ret = (n1 % n2).toString();
        } else if (opt == "^") {
          ret = pow(n1, n2).toString();
        }
        s1 = s1.replaceAll(v2.group(0).toString(), ret);
      }
      s = s.replaceAll(v1.group(0).toString(), s1);
    }
    return s;
  }
}
