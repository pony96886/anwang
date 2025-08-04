import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/home/home_exchange_page.dart';
import 'package:deepseek/home/home_task_page.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeWelfarePage extends BaseWidget {
  HomeWelfarePage({Key? key}) : super(key: key);

  @override
  _HomeWelfarePageState cState() => _HomeWelfarePageState();
}

class _HomeWelfarePageState extends BaseWidgetState<HomeWelfarePage> {
  @override
  void onCreate() {
    // TODO: implement onCreate
    // setAppTitle(
    //     titleW: Text(Utils.txt("dzfw"), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  Widget backGroundView() {
    // TODO: implement backGroundView
    return LocalPNG(
      name: 'ai_welfare_sign_top_bg',
      height: 200.w,
    );
  }

  @override
  Widget pageBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: StyleTheme.topHeight),
        Expanded(
            child: Stack(
          children: [
            GenCustomNav(
              // key: key,
              // lineColor: const Color.fromRGBO(241, 241, 241, 0.5),
              // type: GenCustomNavType.dotline,

              whichUseFor: 'Welfare',
              titles: [
                Utils.txt('dzfw'),
                Utils.txt('jfdh'),
              ],
              pages: const [
                HomeTaskPage(),
                HomeExchangePage(),
              ],
              isCenter: true,
              selectStyle: StyleTheme.font_blue52_20_medium,
              defaultStyle: StyleTheme.font_black_7716_20,
            ),
            Positioned(
              top: 2.w,
              left: StyleTheme.margin,
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 40.w,
                  height: 40.w,
                  child: LocalPNG(
                    name: "ai_nav_back_w",
                    width: 17.w,
                    height: 17.w,
                    fit: BoxFit.contain,
                  ),
                ),
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  finish();
                },
              ),
            )
          ],
        ))
      ],
    );
  }
}
