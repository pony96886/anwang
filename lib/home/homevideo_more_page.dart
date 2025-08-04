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

class HomeVideoMorePage extends BaseWidget {
  const HomeVideoMorePage({super.key, this.param});
  final dynamic param;
  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeVideoMorePageState();
  }
}

class _HomeVideoMorePageState extends BaseWidgetState<HomeVideoMorePage> {
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
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
      //等待滑动解锁
      Future.delayed(const Duration(milliseconds: 200), () {
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
                child: HomeVideoMorePageChild(
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
              //     child: HomeVideoMorePageChild(
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

class HomeVideoMorePageChild extends StatefulWidget {
  const HomeVideoMorePageChild({super.key, this.param, this.bannerFunc});
  final dynamic param;
  final Function(dynamic)? bannerFunc;

  @override
  State<HomeVideoMorePageChild> createState() => _HomeVideoMorePageChildState();
}

class _HomeVideoMorePageChildState extends State<HomeVideoMorePageChild> {
  int page = 1;
  bool isHud = true;
  List<dynamic> values = [];
  dynamic value;
  bool noMore = false;
  bool netWorkErr = false;

  Future<bool> _getData() async {
    dynamic t =
        await reqMoreVideos(cate_id: widget.param["id"], has_ad: 1, page: page);
    if (t.status != 1) {
      netWorkErr = true;

      Utils.showText(t.msg);
      setState(() {});
      return false;
    }
    if (page == 1) {
      noMore = false;
      values = t.data["list"];

      if (widget.bannerFunc != null) {
        widget.bannerFunc?.call(t.data['banner'] ?? t.data['banners'] ?? []);
      }
    } else if ((t.data["list"] as List<dynamic>).length > 0) {
      values.addAll((t.data["list"] as List<dynamic>));
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
          return Utils.videoModuleUI2(context, e);
        });
  }

  // _mvList() {
  //   double _w = (ScreenUtil().screenWidth -
  //           StyleTheme.margin * 2 -
  //           ScreenUtil().setWidth(20)) /
  //       3;
  //   return GridView.builder(
  //       cacheExtent: ScreenUtil().screenHeight * 5,
  //       padding: EdgeInsets.symmetric(
  //           horizontal: StyleTheme.margin, vertical: ScreenUtil().setWidth(10)),
  //       itemCount: values.length,
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 3,
  //         mainAxisSpacing: ScreenUtil().setWidth(12),
  //         crossAxisSpacing: ScreenUtil().setWidth(12),
  //         childAspectRatio: 110 / 175,
  //       ),
  //       itemBuilder: (context, index) {
  //         var t = values[index];
  //         return GestureDetector(
  //           onTap: () {
  //             context.push(Utils.getRealHash('smallvideodetail/${t["id"]}'));
  //           },
  //           child: Stack(
  //             children: [
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   SizedBox(
  //                     height: _w / 110 * 147,
  //                     child: PlatformAwareNetworkImage(
  //                         url: clipImageUrl(Utils.getThumb(t),
  //                             inputWidth: ScreenUtil().setWidth(110)),
  //                         borderRadius: BorderRadius.all(Radius.circular(5))),
  //                   ),
  //                   SizedBox(height: ScreenUtil().setWidth(3.5)),
  //                   Text(t["title"] ?? "loading",
  //                       style: GQStyle.white255_14, maxLines: 1),
  //                   // SizedBox(height: ScreenUtil().setWidth(3.5)),
  //                 ],
  //               ),
  //               Positioned(right: 0, top: 0, child: Utils.identiWget(t))
  //             ],
  //           ),
  //         );
  //       });
  // }

  // _comicsList() {
  //   return GridView.builder(
  //       cacheExtent: ScreenUtil().screenHeight * 5,
  //       padding: EdgeInsets.symmetric(
  //           horizontal: StyleTheme.margin, vertical: ScreenUtil().setWidth(10)),
  //       itemCount: values.length,
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 3,
  //         mainAxisSpacing: ScreenUtil().setWidth(4.5),
  //         crossAxisSpacing: ScreenUtil().setWidth(8),
  //         childAspectRatio: 111 / 202.5,
  //       ),
  //       itemBuilder: (context, index) {
  //         var e = values[index];
  //         e['content_type'] = widget.contentType;
  //         return AcgCard(data: e);
  //       });
  // }

  // _meiPNGList() {
  //   double _w = (ScreenUtil().screenWidth -
  //           StyleTheme.margin * 2 -
  //           ScreenUtil().setWidth(8)) /
  //       2;
  //   return GridView.builder(
  //       cacheExtent: ScreenUtil().screenHeight * 5,
  //       padding: EdgeInsets.symmetric(
  //           horizontal: StyleTheme.margin, vertical: ScreenUtil().setWidth(10)),
  //       itemCount: values.length,
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 2,
  //         mainAxisSpacing: ScreenUtil().setWidth(4.5),
  //         crossAxisSpacing: ScreenUtil().setWidth(10),
  //         childAspectRatio: 171 / 264.5,
  //       ),
  //       itemBuilder: (context, index) {
  //         var t = values[index];
  //         return PictureDoubleColumeCard(data: t);
  //       });
  // }

  Widget _getListWidget() {
    return _videoList();
    // switch (widget.contentType) {
    //   case 1:
    //     return _videoList();
    //     break;
    //   case 16:
    //     return _videoList();
    //     break;
    //   case 24:
    //     return _videoList();
    //     break;
    //   case 2:
    //     return _comicsList();
    //     break;
    //   case 3:
    //     return _mvList();
    //     break;
    //   case 6:
    //     return _meiPNGList();
    //     break;
    //   default:
    //     break;
    // }
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
