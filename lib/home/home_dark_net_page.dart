import 'package:deepseek/home/home_page.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:flutter/material.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeDarkNetPage extends BaseWidget {
  HomeDarkNetPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeDarkNetPageState();
  }
}

class _HomeDarkNetPageState extends BaseWidgetState<HomeDarkNetPage> {
  TextEditingController? _controller;

  @override
  void onCreate() {
    // TODO: implement initState
    _controller = TextEditingController();
    // setAppTitle(title: Utils.txt('sqdl'));

    setAppTitle(
        titleW: Text(Utils.txt('aw'), style: StyleTheme.nav_title_font));
  }

  @override
  Widget pageBody(BuildContext context) {
    // return Container();
    return HomePage(
      isAw: true,
      isShow: true,
    );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
