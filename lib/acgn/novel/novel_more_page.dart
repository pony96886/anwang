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

class NovelMorePage extends BaseWidget {
  NovelMorePage({this.param, this.sort = ""});
  String sort;

  dynamic param;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _NovelMorePageState();
  }
}

class _NovelMorePageState extends BaseWidgetState<NovelMorePage> {
  late PageController _pageController;
  int _selectIndex = 0;
  bool _isOnTab = false;
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

    if (widget.param?['title'] != null) {
      setAppTitle(
          titleW:
              Text(widget.param['title'], style: StyleTheme.nav_title_font));
    }
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
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
        //   child: FljSliderBar(
        //     titles: titles,
        //     pageController: _pageController,
        //     selectStyle: GQStyle.white255_15,
        //     defaultStyle: GQStyle.gray191_15,
        //   ),
        // ),
        Expanded(
          child: PageView(
            onPageChanged: (index) {
              if (!_isOnTab) _onTabPageChange(index, isOnTab: false);
            },
            controller: _pageController,
            children: [
              PageViewMixin(
                child: NovelMorePageChild(
                  param: widget.param,
                  sort: widget.sort,
                  bannerFunc: (p0) {
                    if (p0 != null && p0.length > 0) {
                      if (bannerWidget == null) {
                        bannerWidget = GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: p0);
                        setState(() {});
                      }
                    }
                  },
                ),
              ),
              // PageViewMixin(
              //     child: NovelMorePageChild(
              //   type: "hot",
              //   param: widget.param,
              //   contentType: widget.contentType,
              // )),
            ],
          ),
        )
      ],
    );
  }
}

class NovelMorePageChild extends StatefulWidget {
  NovelMorePageChild({this.param, this.bannerFunc, this.sort = ""});
  String sort;
  final dynamic param;
  final Function(dynamic)? bannerFunc;

  @override
  State<NovelMorePageChild> createState() => _NovelMorePageChildState();
}

class _NovelMorePageChildState extends State<NovelMorePageChild> {
  int page = 1;
  bool isHud = true;
  List<dynamic> values = [];
  dynamic value;
  bool noMore = false;
  bool netWorkErr = false;

  Future<bool> _getData() async {
    dynamic t = await (widget.sort.isNotEmpty
        ? reqNovelsSort(sort: widget.sort, page: page)
        : reqMoreNovels(sort: widget.param["value"], page: page));
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

  _novelList() {
    return Utils.novelListView(context, values);
  }

  Widget _getListWidget() {
    return _novelList();
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
