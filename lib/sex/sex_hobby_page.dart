import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/home/home_page.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/sex/chat/home_naked_chat_page.dart';
import 'package:deepseek/sex/girl/home_date_page.dart';
import 'package:flutter/material.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SexHobbyPage extends BaseWidget {
  SexHobbyPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _SexHobbyPageState();
  }
}

class _SexHobbyPageState extends BaseWidgetState<SexHobbyPage> {
  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {}

  @override
  Widget pageBody(BuildContext context) {
    // return Container();
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: StyleTheme.topHeight,
            ),
            Expanded(
              child: GenCustomNav(
                  isCenter: true,
                  type: GenCustomNavType.none,
                  titles: [
                    Utils.txt('lliao'),
                    // Utils.txt('yp'),
                  ],
                  selectStyle: StyleTheme.font_black_7716_20,
                  defaultStyle: StyleTheme.font_black_7716_20,
                  pages: [
                    HomeNakedChatPage(),
                    // HomeDatePage(),
                  ]),
            ),
          ],
        ),
        Positioned(
            child: Container(
          margin: EdgeInsets.only(top: StyleTheme.topHeight),
          padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
          height: StyleTheme.navHegiht,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 22.w,
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
            ],
          ),
        ))
      ],
    );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
