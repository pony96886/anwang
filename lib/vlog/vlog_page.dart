import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/vlog/vlog_find_page.dart';
import 'package:deepseek/vlog/vlog_focus_list.dart';
import 'package:deepseek/vlog/vlog_hot_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/utils.dart';

class VlogPage extends BaseWidget {
  const VlogPage({Key? key, this.isShow = true}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _VlogPageState();
  }
}

class _VlogPageState extends BaseWidgetState<VlogPage> {
  bool isHud = true;
  bool netError = false;
  List banners = [];
  List categories = [];
  List<String> titles = [];
  List pageIDs = [];
  List<Widget> pages = [];
  int _initialIndex = 0;

  final GlobalKey<GenCustomNavState> _globalKey =
      GlobalKey<GenCustomNavState>();

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement initState
    if (widget.isShow && isHud) {
      getData();
    }
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    Utils.setStatusBar(isLight: false);
  }

  @override
  void didPushNext() {
    if (_initialIndex == 1) {
      Utils.setStatusBar(isLight: false);
    }
  }

  @override
  void didPopNext() {
    if (_initialIndex == 1) {
      Utils.setStatusBar(isLight: true);
    }
  }

  @override
  void didUpdateWidget(covariant VlogPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      getData();
    }
  }

  void getData() {
    isHud = false;
    var vlogNav =
        Provider.of<BaseStore>(context, listen: false).conf?.featured_nav ?? [];

    titles = vlogNav.map((e) => e["title"] as String).toList();
    // pageIDs = categories.map((e) => e["id"]).toList();

//     [
//     'title' => '关注',
//     'type'  => 4,
// ],
// [
//     'title' => '直播',
//     'type'  => 1,
// ],
// [
//     'title' => '短视频',
//     'type'  => 2,
// ],
// [
//     'title' => '发现',
//     'type'  => 3
// ]
    pages = vlogNav.asMap().keys.map((e) {
      // if (vlogNav[e]['default'] == 1) {
      //   _initialIndex = e;
      // }

      if (vlogNav[e]['type'] == 2) {
        _initialIndex = e;
      }
      return vlogNav[e]['type'] == 4
          ? Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(AppGlobal.context!).padding.top),
              child: VlogFocusList(),
            )
          : vlogNav[e]['type'] == 2
              ? VlogHotPage(
                  apiUrl:
                      '/api/vlog/list_recommend', // vlogNav[e]['api_url'] ?? '',
                )
              : vlogNav[e]['type'] == 3
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(AppGlobal.context!).padding.top),
                      child: VlogFindPage(linkModel: vlogNav[e]),
                    )
                  : Center(
                      child: Text(
                      vlogNav[e]['title'],
                      style: StyleTheme.font_blue52_14,
                    ));
    }).toList();
  }

  @override
  Widget pageBody(BuildContext context) {
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : Stack(
                children: [
                  Column(
                    children: [
                      // SizedBox(height: MediaQuery.of(context).padding.top),
                      Expanded(
                        child: GenCustomNav(
                          key: _globalKey,
                          selectStyle: StyleTheme.font_blue52_20_medium,
                          defaultStyle: _initialIndex == 1
                              ? StyleTheme.font_white_255_20
                              : StyleTheme.font_black_7716_20,
                          isCenter: true,
                          isStack: true,
                          initialIndex: _initialIndex,
                          titles: titles,
                          pages: pages,
                          inedxFunc: (index) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                // 在这里安全地更新状态
                                _initialIndex = index;
                                _globalKey.currentState?.defaultStyle =
                                    _initialIndex == 1
                                        ? StyleTheme.font_white_255_20
                                        : StyleTheme.font_black_7716_20;
                                if (_initialIndex == 1) {
                                  Utils.setStatusBar(isLight: true);
                                } else {
                                  Utils.setStatusBar(isLight: false);
                                }
                              });
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        height: StyleTheme.navHegiht,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: 40.w,
                                height: 40.w,
                                child: LocalPNG(
                                  name: _initialIndex == 1
                                      ? "ai_nav_back"
                                      : "ai_nav_back_w",
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
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Utils.navTo(context, "/homesearchpage");
                              },
                              child: LocalPNG(
                                  name: _initialIndex == 1
                                      ? 'ai_nav_search_w'
                                      : 'ai_nav_search',
                                  width: 24.w,
                                  height: 24.w),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
  }
}
