// ignore_for_file: must_be_immutable

import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//下标样式
enum GenCustomNavType {
  none,
  line,
  dotline,
  cover,
}

class GenCustomNav extends StatefulWidget {
  GenCustomNav({
    Key? key,
    required this.titles,
    required this.pages,
    this.defaultStyle,
    this.selectStyle,
    this.isCenter = false,
    this.isSearch = false,
    this.showListGridSwitch = false,
    this.initialShowList = false,
    this.listGridSwitchFunc,
    this.rightWidget,
    this.inedxFunc,
    this.labelPadding = 20,
    this.leftSideMargin = 0,
    this.type = GenCustomNavType.line,
    this.lineColor = Colors.transparent,
    this.initialIndex = 0,
    this.isEquallyDivide = false,
    this.whichUseFor = '',
    this.isStack = false,
  }) : super(key: key);

  Color lineColor;
  List<String> titles;
  List<Widget> pages;
  TextStyle? defaultStyle;
  TextStyle? selectStyle;
  bool isCenter;
  bool isSearch;
  bool showListGridSwitch;
  bool initialShowList;
  Function(bool isShowList)? listGridSwitchFunc;
  Widget? rightWidget;
  GenCustomNavType type;
  double labelPadding;
  double leftSideMargin;

  Function(int)? inedxFunc;
  int initialIndex = 0;
  bool isEquallyDivide; // 能不能平均分
  String whichUseFor; // 判断是不是用在Home跳转用的
  bool isStack; // 是colume上下分布 还是stack那样把标题重叠在上面

  @override
  State<GenCustomNav> createState() => GenCustomNavState();
}

class GenCustomNavState extends State<GenCustomNav>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LinkPageController _pageController;
  int _selectIndex = 0;
  bool _isOnTab = false;
  late TextStyle defaultStyle;
  late TextStyle _selectStyle;

  late bool _isShowList;

  dynamic discrip;

  Widget _dealTabs() {
    // 如果平分 就不用padding
    widget.labelPadding = widget.isEquallyDivide ? 0 : widget.labelPadding;
    return Theme(
        data: ThemeData(
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent),
        child: LayoutBuilder(builder: (context, cons) {
          return TabBar(
            tabAlignment: TabAlignment.start,
            onTap: (index) {
              _isOnTab = true;
              _onTabPageChange(index, isOnTab: true);
            },
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            labelPadding: widget.isCenter
                ? EdgeInsets.symmetric(horizontal: widget.labelPadding.w / 2)
                : EdgeInsets.only(right: widget.labelPadding.w),
            isScrollable: true,
            physics: const BouncingScrollPhysics(),
            tabs: widget.titles
                .asMap()
                .keys
                .map((x) => Container(
                      alignment: Alignment.center,
                      width: widget.isEquallyDivide
                          ? cons.maxWidth / widget.titles.length
                          : null,
                      child: Tab(
                        child: widget.type == GenCustomNavType.cover
                            ? Container(
                                height: 30.w,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                decoration: BoxDecoration(
                                  color: _selectIndex == x
                                      ? StyleTheme.blue52Color
                                      : Colors
                                          .transparent, // StyleTheme.gray252Color,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.w)),
                                ),
                                child: Text(
                                  widget.titles[x],
                                  style: _selectIndex == x
                                      ? _selectStyle
                                      : defaultStyle,
                                ),
                              )
                            : widget.type == GenCustomNavType.dotline
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.titles[x],
                                        style: _selectIndex == x
                                            ? _selectStyle
                                            : defaultStyle,
                                      ),
                                      SizedBox(height: 1.w),
                                      _selectIndex == x
                                          ? LocalPNG(
                                              name: "ai_dot_n",
                                              width: 14.7.w,
                                              height: 6.w)
                                          : SizedBox(
                                              width: 14.7.w, height: 6.w),
                                    ],
                                  )
                                : widget.type == GenCustomNavType.line
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.titles[x],
                                            style: _selectIndex == x
                                                ? _selectStyle
                                                : defaultStyle,
                                          ),
                                          SizedBox(height: 2.w),
                                          SizedBox(
                                              width: 20.w,
                                              height: 3.w,
                                              child: _selectIndex == x
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            StyleTheme.gradBlue,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    1.5.w)),
                                                      ),
                                                    )
                                                  : Container())
                                        ],
                                      )
                                    : Text(
                                        widget.titles[x],
                                        style: _selectIndex == x
                                            ? _selectStyle
                                            : defaultStyle,
                                      ),
                      ),
                    ))
                .toList(),
            controller: _tabController,
          );
        }));
  }

  //开启对外接口
  void openTabIndex(int index) {
    _onTabPageChange(index);
  }

  void _onTabPageChange(index,
      {bool isOnTab = false, bool forceRereashTab = false}) {
    if (_selectIndex == index) {
      _isOnTab = false;
      return;
    }
    _selectIndex = index;
    if (!isOnTab) {
      _tabController.animateTo(_selectIndex);
      setState(() {});
      if (widget.inedxFunc != null) widget.inedxFunc!(_selectIndex);
    } else {
      _pageController.animateToPage(_selectIndex,
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
      if (forceRereashTab) {
        _tabController.animateTo(_selectIndex);
      }
      //等待滑动解锁
      Future.delayed(const Duration(milliseconds: 200), () {
        _isOnTab = false;
        setState(() {});
        widget.inedxFunc?.call(_selectIndex);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isShowList = widget.initialShowList;
    //设置默认字体
    if (widget.defaultStyle == null || widget.selectStyle == null) {
      defaultStyle = StyleTheme.font_black_7716_06_16;
      _selectStyle = StyleTheme.font_blue52_16_medium;
    } else {
      defaultStyle = widget.defaultStyle!;
      _selectStyle = widget.selectStyle!;
    }
    _tabController = TabController(
        length: widget.titles.length,
        vsync: this,
        initialIndex: widget.initialIndex);
    _pageController = LinkPageController(initialPage: widget.initialIndex)
      ..addListener(() {
        int dpage = _pageController.page!.round();
        if (dpage % 1 == 0) {
          if (!_isOnTab) _onTabPageChange(dpage, isOnTab: false);
        }
      });
    if (widget.initialIndex != 0) {
      _onTabPageChange(widget.initialIndex);
    }

    discrip = UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == 'AI_IndexNavJump' &&
          widget.whichUseFor == 'AI') {
        int index = event.arg["index"];
        _isOnTab = true;
        _onTabPageChange(index, isOnTab: _isOnTab, forceRereashTab: true);
      } else if (event.arg["name"] == 'Welfare_IndexNavJump' &&
          widget.whichUseFor == 'Welfare') {
        int index = event.arg["index"];
        _isOnTab = true;
        _onTabPageChange(index, isOnTab: _isOnTab, forceRereashTab: true);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.titles.isEmpty
        ? Container()
        : Builder(builder: (context) {
            Widget tabBarWidget = Column(
              children: [
                widget.isSearch
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: 5.w,
                          left: StyleTheme.margin,
                          right: StyleTheme.margin,
                        ),
                        child: Utils.searchWidget(context))
                    : Container(),
                Container(
                  height: StyleTheme.navHegiht,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          bottom: BorderSide(
                              width: 0.5.w, color: widget.lineColor))),
                  child: Row(
                    children: [
                      SizedBox(width: widget.leftSideMargin),
                      Expanded(
                        child: widget.isCenter
                            ? Container(
                                // color: Colors.red,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Center(child: _dealTabs())],
                                ),
                              )
                            : _dealTabs(),
                      ),
                      widget.showListGridSwitch
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isShowList = !_isShowList;
                                  widget.listGridSwitchFunc?.call(_isShowList);
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 10.w),
                                child: LocalPNG(
                                  name: _isShowList
                                      ? 'voice_list'
                                      : 'voice_girld',
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              ),
                            )
                          : widget.rightWidget ?? Container(),
                    ],
                  ),
                ),
              ],
            );

            Widget tabView = ExtendedTabBarView(
              children: widget.pages,
              controller: _tabController,
              pageController: _pageController,
              shouldIgnorePointerWhenScrolling: false,
              link: true,
            );

            if (widget.isStack == false) {
              return Column(
                children: [tabBarWidget, Expanded(child: tabView)],
              );
            } else {
              return Stack(
                children: [
                  tabView,
                  Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(AppGlobal.context!).padding.top,
                    child: Container(
                      height: StyleTheme.navHegiht,
                      child: Container(
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: widget.sidePadding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // widget.leftWidget ?? Container(),
                            Expanded(child: tabBarWidget),
                            // widget.rightWidget ?? Container(),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
          });
  }
}
