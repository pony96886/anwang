import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pageviewmixin.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:provider/provider.dart';

class GameTagPage extends BaseWidget {
  GameTagPage({this.tag = ""});
  String tag;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _GameTagPageState();
  }
}

class _GameTagPageState extends BaseWidgetState<GameTagPage> {
  late PageController _pageController;
  int _selectIndex = 0;
  bool _isOnTab = false;

  List sortNavis = [];
  // List<String> titles = [Utils.txt("zxpx"), Utils.txt("rdpx")];
  Widget? bannerWidget;

  void _onTabPageChange(index, {bool isOnTab = false}) {
    _selectIndex = index;
    if (!isOnTab) {
      setState(() {});
    } else {
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 200), curve: Curves.linear);
      //等待滑动解锁
      Future.delayed(Duration(milliseconds: 200), () {
        _isOnTab = false;
        setState(() {});
      });
    }
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    _pageController = PageController();

    sortNavis = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.game_tag_sort_nav ??
        [];

    setAppTitle(titleW: Text(widget.tag, style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    _pageController.dispose();
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return Column(
      children: [
        bannerWidget != null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                child: bannerWidget,
              )
            : Container(),
        Expanded(
            child: GenCustomNav(
                titles: sortNavis.map((e) => e['title'].toString()).toList(),
                pages: sortNavis
                    .asMap()
                    .keys
                    .map((e) => GameTagPageChild(
                          tag: widget.tag,
                          bannerFunc: (p0) {
                            if (p0 != null && p0.length > 0) {
                              if (bannerWidget == null) {
                                bannerWidget = GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: p0);
                                setState(() {});
                              }
                            }
                          },
                        ))
                    .toList())

            // PageView(
            //   onPageChanged: (index) {
            //     if (!_isOnTab) _onTabPageChange(index, isOnTab: false);
            //   },
            //   controller: _pageController,
            //   children: [
            //     PageViewMixin(
            //       child: GameTagPageChild(
            //         tag: widget.tag,
            //         bannerFunc: (p0) {
            //           if (p0 != null && p0.length > 0) {
            //             if (bannerWidget == null) {
            //               bannerWidget = GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: p0);
            //               setState(() {});
            //             }
            //           }
            //         },
            //       ),
            //     ),
            //     // PageViewMixin(
            //     //     child: GameTagPageChild(
            //     //   type: "hot",
            //     //   param: widget.param,
            //     //   contentType: widget.contentType,
            //     // )),
            //   ],
            // ),
            )
      ],
    );
  }
}

class GameTagPageChild extends StatefulWidget {
  GameTagPageChild({this.bannerFunc, this.tag = ""});
  String tag;
  final Function(dynamic)? bannerFunc;

  @override
  State<GameTagPageChild> createState() => _GameTagPageChildState();
}

class _GameTagPageChildState extends State<GameTagPageChild> {
  int page = 1;
  bool isHud = true;
  List<dynamic> values = [];
  dynamic value;
  bool noMore = false;
  bool netWorkErr = false;

  Future<bool> _getData() async {
    dynamic t = await reqGameTag(tag: widget.tag, page: page);
    if (t.status != 1) {
      netWorkErr = true;

      Utils.showText(t.msg);
      setState(() {});
      return false;
    }
    if (page == 1) {
      noMore = false;
      values = List.from(t.data);
    } else if (List.from(t.data).length > 0) {
      values.addAll(List.from(t.data));
    } else {
      noMore = true;
    }
    isHud = false;
    setState(() {});
    return noMore;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  _gameList() {
    return Utils.gameListView(context, values);
  }

  Widget _getListWidget() {
    return _gameList();
  }

  @override
  Widget build(BuildContext context) {
    return netWorkErr
        ? LoadStatus.netError(onTap: _getData)
        : isHud == true
            ? LoadStatus.showLoading(mounted)
            : (values.length == 0
                ? LoadStatus.noData()
                : PullRefresh(
                    onRefresh: () {
                      page = 1;
                      noMore = false;
                      return _getData();
                    },
                    onLoading: () {
                      page++;
                      return _getData();
                    },
                    child: _getListWidget(),
                  ));
  }
}
