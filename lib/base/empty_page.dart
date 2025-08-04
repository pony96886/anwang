import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyPage extends BaseWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _EmptyPageState();
  }
}

class _EmptyPageState extends BaseWidgetState<EmptyPage> {
  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('404ym'), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        context.pop();
      },
      child: Center(
        child: Text(
          '404 not found page, please click back',
          style: StyleTheme.font_black_31_16_semi,
        ),
      ),
    );
  }
}
