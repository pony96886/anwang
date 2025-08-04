import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/home/home_more_video_list_page.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeMoreVideoPage extends BaseWidget {
  const HomeMoreVideoPage({Key? key, this.data}) : super(key: key);

  final dynamic data;

  @override
  State<HomeMoreVideoPage> cState() => _HomeMoreVideoPageState();
}

class _HomeMoreVideoPageState extends BaseWidgetState<HomeMoreVideoPage> {
  List banners = [];

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW:
            Text(widget.data['name'] ?? '', style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    double width = ScreenUtil().screenWidth - StyleTheme.margin * 2;
    return Column(
      children: [
        Container(
            padding: EdgeInsets.only(
                right: StyleTheme.margin,
                left: StyleTheme.margin,
                bottom: 10.w),
            child: GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: banners)),
        Expanded(
          child: GenCustomNav(
            titles: [
              Utils.txt('zx'),
              Utils.txt('zr'),
            ],
            pages: [
              HomeMoreVideoListPage(
                type: 'new',
                id: widget.data['link_url'],
                bannerFunc: (bannerList) {
                  banners = bannerList;
                  setState(() {});
                },
              ),
              HomeMoreVideoListPage(
                type: 'hot',
                id: widget.data['link_url'],
              )
            ],
            type: GenCustomNavType.none,
            selectStyle: StyleTheme.font_blue52_14,
            defaultStyle: StyleTheme.font_black_7716_14,
          ),
        ),
      ],
    );
  }
}
