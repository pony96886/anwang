// ignore_for_file: no_logic_in_create_state

import 'dart:io';

import 'package:deepseek/util/approute_observer.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//基类
abstract class BaseWidget extends StatefulWidget {
  const BaseWidget({this.key}) : super(key: key);
  @override
  final Key? key;

  @override
  State<StatefulWidget> createState() => cState();

  State<StatefulWidget> cState();
}

abstract class BaseWidgetState<T extends BaseWidget> extends State<T>
    with RouteAware {
  String _backIcon = "ai_nav_back_w";
  Color _bgColor = StyleTheme.bgColor;
  Color _navColor = Colors.transparent;
  Color _lineColor = const Color.fromRGBO(36, 36, 37, 0);
  bool _navBack = false;
  BuildContext? _mContext;
  Widget? _rightW;
  Widget? _leftW;
  Widget? _appTitle;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // 这个跑起来要报错 先注释了
    ModalRoute<dynamic>? route = ModalRoute.of<dynamic>(context);
    if (route != null) {
      //路由订阅
      AppRouteObserver().routeObserver.subscribe(this, route);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onCreate();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build 统一布局基础页面
    _mContext = context;

    if (kIsWeb) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Stack(children: [
          backGroundView(),
          Column(
            children: [appbar(), Expanded(child: pageBody(context))],
          )
        ]),
      );
    } else if (Platform.isAndroid) {
      return Scaffold(
        primary: false,
        appBar: PreferredSize(child: Container(), preferredSize: Size.zero),
        backgroundColor: _bgColor,
        body: SafeArea(
            child: Stack(children: [
          backGroundView(),
          Column(
            children: [appbar(), Expanded(child: pageBody(context))],
          ),
        ])),
      );
    } else {
      return Scaffold(
        body: Stack(children: [
          backGroundView(),
          Column(
            children: [appbar(), Expanded(child: pageBody(context))],
          )
        ]),
        backgroundColor: _bgColor,
      );
    }
  }

  @override
  void dispose() {
    //取消路由订阅
    AppRouteObserver().routeObserver.unsubscribe(this);
    beforeDispose();
    onDestroy();
    super.dispose();
  }

  //页面初始化
  void onCreate();
  //页面布局
  Widget pageBody(BuildContext context);
  //页面销毁
  void onDestroy();
  //初始化之前的操作
  void beforeInit() {}
  //销毁之前的操作
  void beforeDispose() {}
  /*
    销毁页面
   */
  void finish() {
    context.pop();
  }

  Widget backGroundView() {
    return Container();
  }

  /*
   *  公用的AppBar的title
   */
  void setAppTitle({
    String backIcon = "ai_nav_back_w",
    Color navColor = Colors.transparent,
    Color bgColor = const Color.fromRGBO(242, 244, 247, 1),
    Widget? rightW,
    Widget? leftW,
    Widget? titleW,
    Color lineColor = const Color.fromRGBO(36, 36, 37, 0.0),
  }) {
    _appTitle = titleW;
    _backIcon = backIcon;
    _rightW = rightW;
    _leftW = leftW;
    _navColor = navColor;
    _bgColor = bgColor;
    _lineColor = lineColor;
    if (mounted) setState(() {});
  }

  void setBgColor(Color color) {
    _bgColor = color;
    if (mounted) setState(() {});
  }

  /*
   * 继承该基类的公用的AppBar 
   * 1.有标题默认正常标题栏；
   * 2.无标题为空，可以根据自身组件写标题组件或则调用appbar重写标题
   */
  Widget appbar() {
    return Utils.createNav(
      navColor: _navColor,
      titleW: _appTitle,
      left: _navBack ? _leftWidget() : _leftW,
      right: _rightW,
      lineColor: _lineColor,
    );
  }

  //强调用户自定义的左组件
  Widget _leftWidget() {
    return _leftW ??
        GestureDetector(
          child: Container(
            alignment: Alignment.centerLeft,
            width: 40.w,
            height: 40.w,
            child: LocalPNG(
              name: _backIcon,
              width: 17.w,
              height: 17.w,
              fit: BoxFit.contain,
            ),
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () {
            finish();
          },
        );
  }

  // Called when the current route has been pushed.
  // 当前的页面被push显示到用户面前 viewWillAppear.
  @override
  void didPush() {
    if (Navigator.canPop(context)) {
      _navBack = true;
      setState(() {});
    }
  }

  /// Called when the current route has been popped off.
  /// 当前的页面被pop viewWillDisappear.
  @override
  void didPop() {}

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  /// 上面的页面被pop后当前页面被显示时 viewWillAppear.
  @override
  void didPopNext() {}

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  /// 从当前页面push到另一个页面 viewWillDisappear.
  @override
  void didPushNext() {}
}
