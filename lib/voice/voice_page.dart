import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/voice/voice_child_page.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/home/home_page.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:flutter/material.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class VoicePage extends BaseWidget {
  VoicePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _VoicePageState();
  }
}

class _VoicePageState extends BaseWidgetState<VoicePage> {
  List<dynamic> banners = [];
  List<dynamic> tips = [];

  List<dynamic> _voiceNav = [];
  List<dynamic> _voiceSortNav = [];

  bool _isShowList = false;

  int _voiceNavIndex = 0;

  @override
  void onCreate() {
    _voiceNav =
        Provider.of<BaseStore>(context, listen: false).conf?.voice_nav ?? [];

    _voiceSortNav =
        Provider.of<BaseStore>(context, listen: false).conf?.voice_sort_nav ??
            [];
    setAppTitle(
        titleW: Text(Utils.txt('as'), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  Widget _naviBarUI() {
    List values = _voiceNav;
    return Container(
        padding: EdgeInsets.only(
          left: StyleTheme.margin,
          right: StyleTheme.margin,
          bottom: 10.w,
        ),
        child: Column(
          children: [
            GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: values.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 80 / 30,
                    mainAxisSpacing: 10.w,
                    crossAxisSpacing: 10.w),
                itemBuilder: (context, index) {
                  dynamic e = values[index];
                  return GestureDetector(
                    onTap: () {
                      if (_voiceNavIndex == index) return;
                      setState(() {
                        _voiceNavIndex = index;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.w),
                      child: SizedBox(
                          height: 30.w,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                  child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: index == _voiceNavIndex
                                          ? StyleTheme.blue52Color
                                          : StyleTheme.whiteColor)),
                              Center(
                                child: Text(e["name"],
                                    style: index == _voiceNavIndex
                                        ? StyleTheme.font_white_255_13
                                        : StyleTheme.font_black_7716_07_13),
                              ),
                            ],
                          )),
                    ),
                  );
                }),
          ],
        ));
  }

  @override
  Widget pageBody(BuildContext context) {
    // return Container();
    double width = ScreenUtil().screenWidth - StyleTheme.margin * 2;

    return NestedScrollView(
      headerSliverBuilder: (cx, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.only(
                        right: StyleTheme.margin,
                        left: StyleTheme.margin,
                        bottom: 10.w),
                    child: GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: banners)),
                tips.isEmpty
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(bottom: 10.w),
                        child: Utils.tipsWidget(context, tips)),
                _voiceNav.isEmpty ? Container() : _naviBarUI()
              ],
            ),
          ),
        ];
      },
      body: GenCustomNav(
        labelPadding: 0,
        titles: _voiceSortNav.map((e) => (e["title"] ?? "") as String).toList(),
        type: GenCustomNavType.cover,
        showListGridSwitch: true,
        initialShowList: _isShowList,
        listGridSwitchFunc: (isShowList) {
          setState(() {
            _isShowList = isShowList;
          });
          // isShowList ? _listWidget() : _gridWidget();
        },
        pages: _voiceSortNav.asMap().keys.map((index) {
          // VoiceChildPage(linkModel: linkModel)
          return VoiceChildPage(
            listShape: _isShowList,
            fun: index != 0
                ? null
                : (bannerList, naviList, tipList) {
                    banners = bannerList;
                    tips = tipList;
                    if (mounted) setState(() {});
                  },
            param: {
              'id': _voiceNav[_voiceNavIndex]["id"],
              'type': _voiceSortNav[index]["type"],
            },
          );
        }).toList(),
        selectStyle: StyleTheme.font_white_255_13,
        defaultStyle: StyleTheme.font_black_7716_06_13,
      ),
    );
  }
}
