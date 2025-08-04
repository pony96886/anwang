import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/vlog/vlog_find_sub_page.dart';
import 'package:deepseek/vlog/vlog_hot_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VlogSecondPage extends BaseWidget {
  VlogSecondPage({Key? key, this.data}) : super(key: key);
  dynamic data;

  @override
  State<VlogSecondPage> cState() => _VlogSecondPageState();
}

class _VlogSecondPageState extends BaseWidgetState<VlogSecondPage> {
  @override
  void onCreate() {
    // TODO: implement onCreate
    Utils.setStatusBar(isLight: true);
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    Utils.setStatusBar(isLight: false);
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  Widget pageBody(BuildContext context) {
    return Stack(
      children: [
        VlogHotPage(
          userGlobalData: true,
          keepBottomBlank: true,
        ),
        Positioned.fill(
          child: Column(
            children: [
              Container(
                height: StyleTheme.topHeight,
              ),
              SizedBox(
                height: StyleTheme.navHegiht,
                child: Stack(
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.1),
                                    offset: Offset(0, 0),
                                    spreadRadius: 5,
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: LocalPNG(
                                name: "ai_nav_back",
                                width: 18,
                                height: 18,
                                fit: BoxFit.fill,
                              ),
                            ),
                            onTap: () {
                              finish();
                            },
                          ),
                          SizedBox(width: 20.w, height: 20.w),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
