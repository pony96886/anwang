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

class CartoonMorePage extends BaseWidget {
  CartoonMorePage({this.param});
  dynamic param;
  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _CartoonMorePageState();
  }
}

class _CartoonMorePageState extends BaseWidgetState<CartoonMorePage> {
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

    if (widget.param['title'] != null) {
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
                child: CartoonMorePageChild(
                  param: widget.param,
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
              //     child: CartoonMorePageChild(
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

class CartoonMorePageChild extends StatefulWidget {
  CartoonMorePageChild({this.param, this.bannerFunc});
  final dynamic param;
  final Function(dynamic)? bannerFunc;

  @override
  State<CartoonMorePageChild> createState() => _CartoonMorePageChildState();
}

class _CartoonMorePageChildState extends State<CartoonMorePageChild> {
  int page = 1;
  bool isHud = true;
  List<dynamic> values = [];
  dynamic value;
  bool noMore = false;
  bool netWorkErr = false;

  Future<bool> _getData() async {
    dynamic t = await reqMoreCartoons(sort: widget.param["value"], page: page);
    if (t.status != 1) {
      netWorkErr = true;

      Utils.showText(t.msg);
      setState(() {});
      return false;
    }
    if (page == 1) {
      noMore = false;
      values = List.from(t.data);

      // if (widget.titleFunc != null) {
      //   // widget.titleFunc(t.data["title"] ?? "loading");
      // }

      // if (widget.bannerFunc != null) {
      //   widget.bannerFunc?.call(t.data['banner']);
      // }
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

  _videoList() {
    double _w = (ScreenUtil().screenWidth -
            StyleTheme.margin * 2 -
            ScreenUtil().setWidth(4)) /
        2;
    return GridView.builder(
        cacheExtent: ScreenUtil().screenHeight * 5,
        padding: EdgeInsets.symmetric(
            horizontal: StyleTheme.margin, vertical: ScreenUtil().setWidth(10)),
        itemCount: values.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.w,
          crossAxisSpacing: 10.w,
          childAspectRatio: 171 / 122,
        ),
        itemBuilder: (context, index) {
          var e = values[index];
          return Utils.videoModuleUI2(context, e, isCartoon: true);
        });
  }

  Widget _getListWidget() {
    return _videoList();
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
