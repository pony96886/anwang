import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineBloggerPage extends BaseWidget {
  MineBloggerPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineBloggerPageState();
  }
}

class _MineBloggerPageState extends BaseWidgetState<MineBloggerPage> {
  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('grsp'), style: StyleTheme.nav_title_font));
  }

  @override
  // Widget backGroundView() {
  // TODO: implement backGroundView
  // return LocalPNG(name: "ai_mine_blogger_bg");
  // }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    ConfigModel? cf = Provider.of<BaseStore>(context, listen: false).conf;
    return GestureDetector(
      onTap: () {
        Utils.openURL(cf?.config?.tg_up_auth ?? "");
      },
      child:
          // Stack(
          //   children: [
          Container(
        alignment: Alignment.topCenter,
        child: AspectRatio(
            aspectRatio: 375 / 693,
            child: LocalPNG(name: 'ai_mine_blogger_bg', fit: BoxFit.fitWidth)),
      ),
      //   Positioned(
      //       top: 401.w, left: (1.sw - 78.w) / 2,
      //       child: SizedBox(
      //           width: 78.w, height: 78.w,
      //           child: LocalPNG(name: 'telegram_logo')))
      // ],
      // ),
    );
    return Column(
      children: [
        const Spacer(),
        SizedBox(
          height: 280.w,
          width: 315.w,
          child: Stack(
            children: [
              LocalPNG(name: "ai_mine_blogger_box", fit: BoxFit.fitWidth),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Utils.openURL(cf?.config?.tg_up_auth ?? "");
                        },
                        child: Column(
                          children: [
                            LocalPNG(
                                name: "ai_mine_tg", width: 40.w, height: 40.w),
                            SizedBox(height: 10.w),
                            Text(Utils.txt('tjgfrzb'),
                                style: StyleTheme.font_gray_153_12),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.w),
                    Text(Utils.txt('rzsm'), style: StyleTheme.font_black_31_14),
                    Text(Utils.txt('rzsmdesc'),
                        style: StyleTheme.font_gray_102_13),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 53.w),
      ],
    );
  }
}
