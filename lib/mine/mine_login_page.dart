import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineLoginPage extends BaseWidget {
  const MineLoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineLoginPageState();
  }
}

class _MineLoginPageState extends BaseWidgetState<MineLoginPage>
    with WidgetsBindingObserver {
  final userTxt = TextEditingController();
  final passwordTxt = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onCreate() {
    // TODO: implement onCreate
    WidgetsBinding.instance.addObserver(this);

    setAppTitle(lineColor: Colors.transparent);
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).viewInsets.bottom == 0) {
        scrollController.jumpTo(0);
      }
    });
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget backGroundView() {
    // TODO: implement backGroundView
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        child: Stack(
          children: [
            LocalPNG(name: "ai_mine_login_bg"),
            // Container(color: Colors.black12),
          ],
        ),
      ),
    );
  }

  //用户注册
  void userRegister() {
    Utils.unFocusNode(context);
    if (userTxt.text.isEmpty || userTxt.text.length < 6) {
      Utils.showText(Utils.txt('qsrzh'));
      return;
    }
    if (passwordTxt.text.isEmpty) {
      Utils.showText(Utils.txt('qsrmm'));
      return;
    }
    //全屏加载，禁止其他操作
    LoadStatus.showSLoading(text: Utils.txt('zzzc'));
    reqLoginByReg(
      username: userTxt.text,
      password: passwordTxt.text,
    ).then((res) {
      if (res?.status == 1) {
        AppGlobal.apiToken = res?.data ?? "";
        AppGlobal.appBox?.put("deepseek_token", AppGlobal.apiToken);
        showDialogBox();
      } else {
        Utils.showText(res?.msg ?? "");
      }
    }).whenComplete(() {
      LoadStatus.closeLoading();
    });
  }

  //用户登录
  void userLogin() {
    Utils.unFocusNode(context);
    if (userTxt.text.isEmpty || userTxt.text.length < 6) {
      Utils.showText(Utils.txt('qsrzh'));
      return;
    }
    if (passwordTxt.text.isEmpty) {
      Utils.showText(Utils.txt('qsrmm'));
      return;
    }
    LoadStatus.showSLoading(text: Utils.txt('zzdl'));
    reqLoginByAccount(username: userTxt.text, password: passwordTxt.text)
        .then((res) {
      if (res?.status == 1) {
        Utils.showText(Utils.txt('cgdl'));
        AppGlobal.apiToken = res?.data ?? "";
        AppGlobal.appBox?.put("deepseek_token", AppGlobal.apiToken);
        reqUserInfo(context).then((res) {
          context.pop();
          UtilEventbus().fire(EventbusClass({"name": "login"}));
        });
      } else {
        Utils.showText(res?.msg ?? "");
      }
    }).whenComplete(() {
      LoadStatus.closeLoading();
    });
  }

  //弹出对话框提示用户保存自己的账号和密码
  void showDialogBox() {
    Utils.showDialog(
      confirmTxt: Utils.txt('fzzhqbc'),
      setContent: () {
        return RichText(
            text: TextSpan(children: [
          TextSpan(
              text: Utils.txt('fzzhqbctx'), style: StyleTheme.font_gray_153_12),
          TextSpan(
              text: Utils.txt('fzzhqbcqw'),
              style: StyleTheme.font(size: 14, color: const Color(0xFFFF4500)))
        ]));
      },
      confirm: () {
        LoadStatus.showSLoading(text: Utils.txt('jzz'));
        reqUserInfo(context).then((res) {
          //复制信息
          Utils.copyToClipboard('回家地址：${res?.data?.share?.share_url} 帐号：${userTxt.text} 密码：${passwordTxt.text}');

          //退出当前页面
          Utils.showText(Utils.txt('zccgdl'), call: () {
            if (mounted) {
              Future.delayed(const Duration(milliseconds: 100), () {
                finish();
                UtilEventbus().fire(EventbusClass({"name": "login"}));
              });
            }
          });
        }).whenComplete(() {
          LoadStatus.closeLoading();
        });
      },
    );
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Utils.unFocusNode(context);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: StyleTheme.topHeight),
              Center(
                child: SizedBox(
                  height: 210.w,
                  // color: Colors.red,
                  child: Column(
                    children: [
                      SizedBox(height: 30.w),
                      LocalPNG(
                        name: "ai_mine_login_logo_w",
                        width: 131.w,
                        height: 131.w,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                height: 44.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(
                    //     color: StyleTheme.gray102Color, width: 0.5.w),
                    borderRadius: BorderRadius.all(Radius.circular(22.w))),
                alignment: Alignment.center,
                child: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter(RegExp("[a-zA-Z]|[0-9]"),
                        allow: true),
                    LengthLimitingTextInputFormatter(20),
                  ],
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  controller: userTxt,
                  style: StyleTheme.font(
                      size: 15, color: StyleTheme.blak7716Color),
                  textInputAction: TextInputAction.done,
                  cursorColor: StyleTheme.blue52Color,
                  decoration: InputDecoration(
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 29.w, // 限制最小宽度，增加左侧间距
                      minHeight: 24.w,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(right: 5.w),
                      child: LocalPNG(
                          name: 'ai_textfield_username',
                          width: 12.w,
                          height: 12.w),
                    ),
                    hintText: Utils.txt('qsrzh'),
                    hintStyle: StyleTheme.font_black_7716_06_15,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: Colors.transparent, width: 0.5.w)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: Colors.transparent, width: 0.5.w)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: Colors.transparent, width: 0.5.w)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: Colors.transparent, width: 0.5.w)),
                  ),
                ),
              ),
              SizedBox(height: 28.w),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                height: 44.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(
                    //     color: StyleTheme.gray102Color, width: 0.5.w),
                    borderRadius: BorderRadius.all(Radius.circular(22.w))),
                alignment: Alignment.center,
                child: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter(RegExp("[a-zA-Z]|[0-9]"),
                        allow: true),
                    LengthLimitingTextInputFormatter(20),
                  ],
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  controller: passwordTxt,
                  style: StyleTheme.font(
                      size: 15, color: StyleTheme.blak7716Color),
                  textInputAction: TextInputAction.done,
                  cursorColor: StyleTheme.blue52Color,
                  decoration: InputDecoration(
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 29.w, // 限制最小宽度，增加左侧间距
                      minHeight: 24.w,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(right: 5.w),
                      child: LocalPNG(
                          name: 'ai_textfield_password',
                          width: 12.w,
                          height: 12.w),
                    ),
                    hintText: Utils.txt('qsrmm'),
                    hintStyle: StyleTheme.font_black_7716_06_15,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: Colors.transparent, width: 0.5.w)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: Colors.transparent, width: 0.5.w)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: Colors.transparent, width: 0.5.w)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: Colors.transparent, width: 0.5.w)),
                  ),
                ),
              ),
              SizedBox(height: 28.w),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          userRegister();
                        },
                        child: Container(
                          height: 40.w,
                          decoration: BoxDecoration(
                              color: StyleTheme.whiteColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.w))),
                          alignment: Alignment.center,
                          child: Text(
                            Utils.txt('zuche'),
                            style: StyleTheme.font(
                              size: 16,
                              color: StyleTheme.blue52Color,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          userLogin();
                        },
                        child: Container(
                          height: 40.w,
                          decoration: BoxDecoration(
                              color: StyleTheme.blue52Color,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.w))),
                          alignment: Alignment.center,
                          child: Text(
                            Utils.txt('dneglu'),
                            style: StyleTheme.font(
                              size: 16,
                              color: StyleTheme.whiteColor,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60.w),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1.w,
                            color: StyleTheme.blue52Color.withOpacity(0.38),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(Utils.txt('wxts'),
                            style: StyleTheme.font_black_7716_16_blod,
                            textAlign: TextAlign.left),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Container(
                            height: 1.w,
                            color: StyleTheme.blue52Color.withOpacity(0.38),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.w),
                    Text(
                      "1.${Utils.txt('zhty')}\n2.${Utils.txt('zhte')}\n3.${Utils.txt('zhts')}",
                      textAlign: TextAlign.left,
                      style: StyleTheme.font(
                        size: 12,
                        color: StyleTheme.blak7716_06_Color,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
