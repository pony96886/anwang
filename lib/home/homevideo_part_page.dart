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

class HomeVideoPartPage extends BaseWidget {
  const HomeVideoPartPage({super.key, this.param});
  final dynamic param;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeVideoPartPageState();
  }
}

class _HomeVideoPartPageState extends BaseWidgetState<HomeVideoPartPage> {
  late PageController _pageController;
  int _selectIndex = 0;
  bool _isOnTab = false;

  List sortNavis = [];
  Widget? bannerWidget;

  @override
  void onCreate() {
    // TODO: implement onCreate
    _pageController = PageController();

    sortNavis = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.mv_second_sort_nav ??
        [];

    setAppTitle(
        titleW: Text(widget.param['title'], style: StyleTheme.nav_title_font));
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
                    .map((e) => HomeVideoPartPageChild(
                          id: widget.param['id'],
                          sort: sortNavis[e]['type'].toString(),
                          bannerFunc: (p0) {
                            if (p0 != null && p0.length > 0) {
                              if (bannerWidget == null) {
                                bannerWidget = GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: p0);
                                setState(() {});
                              }
                            }
                          },
                        ))
                    .toList()))
      ],
    );
  }
}

class HomeVideoPartPageChild extends StatefulWidget {
  const HomeVideoPartPageChild(
      {super.key, this.bannerFunc, this.id, this.sort = ''});
  final dynamic id;
  final String sort;
  final Function(dynamic)? bannerFunc;

  @override
  State<HomeVideoPartPageChild> createState() => _HomeVideoPartPageChildState();
}

class _HomeVideoPartPageChildState extends State<HomeVideoPartPageChild> {
  int page = 1;
  bool isHud = true;
  List<dynamic> values = [];
  dynamic value;
  bool noMore = false;
  bool netWorkErr = false;

  Future<bool> _getData() async {
    dynamic t =
        await reqPartVideos(id: widget.id, sort: widget.sort, page: page);
    if (t.status != 1) {
      netWorkErr = true;

      Utils.showText(t.msg);
      setState(() {});
      return false;
    }

    List tp = List.from(t.data['list']);
    if (page == 1) {
      noMore = false;
      values = tp;
    } else if (tp.isNotEmpty) {
      values.addAll(tp);
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
