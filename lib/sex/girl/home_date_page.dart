import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/marquee.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeDatePage extends BaseWidget {
  HomeDatePage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeDatePageState();
  }
}

class _HomeDatePageState extends BaseWidgetState<HomeDatePage> {
  bool isHud = true;
  bool netError = false;
  List<dynamic> banners = [];
  List<dynamic> tips = [];
  String noticeText = '';
  List<dynamic> navs = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List options = [];

  Map _filterMap = {};
  Map _filterTempMap = {};

  showFilterView() {
    _scaffoldKey.currentState?.openEndDrawer();
    // showModalBottomSheet(context: context, builder: builder)
  }

  Widget filterView() {
    return Container(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight,
      color: StyleTheme.bgColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
          child: Column(
            children: [
              SizedBox(
                height: StyleTheme.topHeight, // + StyleTheme.navHegiht,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    Map itemMap = options[index];
                    List items = List.from(itemMap['items'] ?? []);
                    return Column(
                      children: [
                        Container(
                          height: 27.w,
                          margin: EdgeInsets.symmetric(vertical: 10.w),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            options[index]['label'],
                            style: StyleTheme.font_black_7716_17_medium,
                          ),
                        ),
                        GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 80 / 30,
                                    mainAxisSpacing: 10.w,
                                    crossAxisSpacing: 8.w),
                            itemBuilder: (context, iIndex) {
                              dynamic item = items[iIndex];
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (_filterTempMap[itemMap['value']] ==
                                      item['value']) {
                                    _filterTempMap[itemMap['value']] = null;
                                  } else {
                                    _filterTempMap[itemMap['value']] =
                                        item['value'];
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: _filterTempMap[itemMap['value']] ==
                                              item['value']
                                          ? StyleTheme.blue52Color
                                          : StyleTheme.whiteColor,
                                      // border: Border.all(
                                      //   color: StyleTheme.blue52Color,
                                      //   width: 1,
                                      // ),
                                      borderRadius: BorderRadius.circular(4.w)),
                                  child: Center(
                                    child: FittedBox(
                                      child: Text(
                                        item['name'],
                                        style:
                                            _filterTempMap[itemMap['value']] ==
                                                    item['value']
                                                ? StyleTheme.font_white_255_14
                                                : StyleTheme
                                                    .font_black_7716_07_14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                      ],
                    );
                  }),
              SizedBox(
                height: 130.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      // _filterTempMap = {};
                      setState(() {});
                      _scaffoldKey.currentState?.closeEndDrawer();
                    },
                    child: Container(
                      width: 140.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                          color: StyleTheme.whiteColor,
                          borderRadius: BorderRadius.circular(20.w)),
                      alignment: Alignment.center,
                      child: Text(
                        Utils.txt('quxao'),
                        style: StyleTheme.font_black_7716_16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _filterMap = Map.from(_filterTempMap);
                      _filterMap.removeWhere((key, value) => value == null);
                      setState(() {});
                      _scaffoldKey.currentState?.closeEndDrawer();
                    },
                    child: Container(
                      width: 140.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                          color: StyleTheme.blue52Color,
                          borderRadius: BorderRadius.circular(20.w)),
                      alignment: Alignment.center,
                      child: Text(
                        Utils.txt('qd'),
                        style: StyleTheme.font_white_255_16,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 64.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getOptionData() {
    reqGirlOption().then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return;
      }
      options = List.from(value?.data ?? []);

      for (var element in options) {
        if (element['value'] == 'class') {
          AppGlobal.girlClassList = List.from(element['items']);
          break;
        }
      }

      isHud = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget appbar() {
    return Container();
  }

  @override
  void onCreate() {
    getOptionData();
    // setAppTitle(
    //     titleW: Text(Utils.txt('yp'), style: StyleTheme.nav_title_font));
    navs = Provider.of<BaseStore>(context, listen: false).conf?.girl_sort ?? [];
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return Scaffold(
      endDrawer: filterView(),
      key: _scaffoldKey,
      body: Column(
        children: [
          Expanded(
            child: netError
                ? LoadStatus.netError(onTap: () {
                    getOptionData();
                  })
                : isHud
                    ? LoadStatus.showLoading(mounted, text: Utils.txt('sjcshz'))
                    : Stack(
                        children: [
                          Container(
                            color: StyleTheme.bgColor,
                            child: NestedScrollView(
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) {
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
                                                margin: EdgeInsets.only(
                                                    bottom: 5.w),
                                                child: Utils.tipsWidget(
                                                    context, tips)),
                                        SizedBox(height: 5.w),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                              body: GenCustomNav(
                                labelPadding: 20.w,
                                titles:
                                    navs.map((e) => "${e["title"]}").toList(),
                                pages: navs.asMap().keys.map((e) {
                                  return HomeDateChildPage(
                                    // id: e['id'],
                                    sort: navs[e]["type"],
                                    filter: _filterMap,
                                    fun: e == 0
                                        ? (data) {
                                            banners = List.from(
                                                data['banner'] ??
                                                    data['banners'] ??
                                                    []);
                                            tips =
                                                List.from(data["tips"] ?? []);

                                            if (mounted) setState(() {});
                                          }
                                        : null,
                                  );
                                }).toList(),
                                type: GenCustomNavType.line,
                                // titleBottomLineWidth: 17.w,
                                // selectStyle: StyleTheme.font_white_255_16_semi,
                                // defaultStyle: StyleTheme.font_white_255_06_14,

                                rightWidget: SizedBox(
                                  // width: 100.w,
                                  // height: 40.w,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      showFilterView();
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          Utils.txt('sx'),
                                          style:
                                              StyleTheme.font_blue52_13_medium,
                                        ),
                                        SizedBox(
                                          width: 4.w,
                                        ),
                                        LocalPNG(
                                          name: 'ai_date_filter',
                                          width: 14.w,
                                          height: 15.w,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: StyleTheme.margin * 2,
                            bottom: StyleTheme.bottom + StyleTheme.margin * 2,
                            child: GestureDetector(
                              onTap: () {
                                Utils.navTo(context, '/homedatepublishpage');
                              },
                              child: // Icon(Icons.post_add)
                                  LocalPNG(
                                name: 'ai_sex_date_publish',
                                width: 40.w,
                                height: 40.w,
                              ),
                            ),
                          )
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class HomeDateChildPage extends StatefulWidget {
  HomeDateChildPage(
      {Key? key,
      this.id = 0,
      this.sort = "new",
      this.filter = const {},
      this.fun})
      : super(key: key);
  final int id;
  final String sort;

  final Map filter;
  final Function(dynamic banner)? fun;

  @override
  State<HomeDateChildPage> createState() => _HomeDateChildPageState();
}

class _HomeDateChildPageState extends State<HomeDateChildPage> {
  int page = 1;
  bool noMore = false;
  bool netError = false;
  bool isHud = true;
  List<dynamic> array = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(covariant HomeDateChildPage oldWidget) {
    // TODO: implement didUpdateWidget
    if (oldWidget.filter != widget.filter) {
      page = 1;
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<bool> getData() {
    return reqGirlIndexList(sort: widget.sort, options: widget.filter, page: page)
        .then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return false;
      }
      List st = List.from(value?.data["girls"] ?? []);
      if (page == 1) {
        noMore = false;
        array = st;
        widget.fun?.call(value?.data);
      } else if (st.isNotEmpty) {
        array.addAll(st);
      } else {
        noMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return noMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : array.isEmpty
                ? LoadStatus.noData()
                : PullRefresh(
                    onRefresh: () {
                      page = 1;
                      return getData();
                    },
                    onLoading: () {
                      page++;
                      return getData();
                    },
                    child: GridView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 15.w,
                        childAspectRatio: 165 / (213 + 68),
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: array.length,
                      itemBuilder: (context, index) {
                        dynamic e = array[index];
                        return Utils.dateModuleUI(context, e);
                      },
                    ),
                  );
  }
}
