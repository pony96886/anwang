import 'dart:ui';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/home/home_rec_page.dart';
import 'package:deepseek/home/home_sub_page.dart';
import 'package:deepseek/home/home_recchild_page.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, this.isShow = false, this.isAw = false})
      : super(key: key);
  final bool isShow;
  final bool isAw;

  @override
  Widget build(BuildContext context) {
    return _HomePage(
      isShow: isShow,
      isAw: isAw,
    );
  }
}

class _HomePage extends BaseWidget {
  const _HomePage({Key? key, this.isShow = false, this.isAw = false})
      : super(key: key);
  final bool isShow;
  final bool isAw;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __HomePageState();
  }
}

class __HomePageState extends BaseWidgetState<_HomePage> {
  bool isHud = true;
  bool netError = false;
  List banners = [];
  List categories = [];
  List<String> titles = [];
  List pageIDs = [];
  List<Widget> pages = [];
  var discrip;

  void getData() {
    int navid =
        Provider.of<BaseStore>(context, listen: false).conf?.config?.nav_id ??
            1;
    if (widget.isAw) {
      navid =
          Provider.of<BaseStore>(context, listen: false).conf?.config?.aw_id ??
              1;
    }

    List prependNavs = widget.isAw // 是否是aw
        ? []
        : Provider.of<BaseStore>(context, listen: false).conf?.nav_prepend ??
            [];
    reqTopNavConfig(id: navid).then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return;
      }
      categories = value?.data?.value ?? [];

      categories.insertAll(0, prependNavs);
      titles =
          categories.map((e) => (e["name"] ?? e["title"]) as String).toList();
      pageIDs = categories.map((e) => e["id"]).toList();
      pages = categories.asMap().keys.map((e) {
        LinkModel _link = LinkModel.fromJson(categories[e]);

        if (prependNavs.contains(categories[e])) {
          _link.api = categories[e]['type'] == 1
              ? '/api/index/index'
              : '/api/mv/discover2';

          _link.params = {
            'id': categories[e]['id'],
          };

          if (categories[e]['type'] == 1) {
            return HomeRecPage(
              linkModel: _link,
            );
          }
        }

        return HomeSubPage(
          linkModel: _link,
          isDiscover: categories[e]['type'] == 2,
        );
      }).toList();
      isHud = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement initState
    discrip = UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == 'IndexNavTapItem') {
        Map navi = event.arg["item"];
        if (navi['link_url'] != null) {
          int index = pageIDs.indexOf(navi['link_url']);
          UtilEventbus().fire(EventbusClass(
              {'name': 'IndexNavJump', 'index': index, 'label': 'home'}));
        }
        if (mounted) setState(() {});
      }
    });

    if (widget.isShow) {
      getData();
    }
  }

  @override
  void didUpdateWidget(covariant _HomePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      getData();
    }
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    bool shouldShowCover = false;

    shouldShowCover = widget.isAw; // && member.has_aw_privilege == false;

    List<String> vip_level_str = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.vip_level_str ??
        [];
    String vip_name_str = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.vip_name_str ??
        '';
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    int initialIndex = widget.isAw // 是否是aw
        ? 0
        : (Provider.of<BaseStore>(context, listen: false) // 是否有nav_prepend
                        .conf
                        ?.nav_prepend
                        ?.length ??
                    0) >
                0
            ? Provider.of<BaseStore>(context, listen: false)
                    .conf
                    ?.nav_prepend_default ??
                0
            : 0;

    // user?.vip_str = '王者卡';
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
                      widget.isAw
                          ? const SizedBox()
                          : SizedBox(height: StyleTheme.topHeight),
                      Expanded(
                        child: GenCustomNav(
                          isSearch: widget.isAw ? false : true,
                          initialIndex: initialIndex,
                          titles: titles,
                          pages: pages,
                        ),
                      )
                    ],
                  ),
                  // vip_level_str.isNotEmpty &&
                  //         vip_level_str.contains(user?.vip_str ?? '') ==
                  //             false &&
                  //         widget.isAw
                  user?.aw_privilege == 0 && widget.isAw
                      ? ClipRect(
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 12.w, sigmaY: 12.w),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Utils.navTo(context, "/minevippage");
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: vip_name_str.split("#").map((e) {
                                    if (e.contains("卡")) {
                                      return Text(e,
                                          style: StyleTheme.font_blue52_15
                                              .toHeight(1.5));
                                    } else if (e.contains("警告")) {
                                      return Text(e,
                                          style: TextStyle(
                                              color: StyleTheme.red253Color,
                                              fontSize: 15.sp,
                                              height: 2,
                                              fontWeight: FontWeight.w500));
                                    }
                                    return Text(e,
                                        style: StyleTheme.font_white_255_15
                                            .toHeight(1.5));
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              );
  }
}
