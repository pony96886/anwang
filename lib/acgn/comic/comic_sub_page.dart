import 'package:deepseek/acgn/comic/comic_subchild_page.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ComicSubPage extends StatefulWidget {
  ComicSubPage({required this.linkModel, this.isDiscover = false});

  final LinkModel linkModel;
  final bool isDiscover;

  @override
  State<ComicSubPage> createState() => _ComicSubPageState();
}

class _ComicSubPageState extends State<ComicSubPage> {
  List<dynamic> banners = [];
  List<dynamic> navis = [];
  List<dynamic> tips = [];

  late LinkModel _linkModel;

  bool _isShowList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _linkModel = widget.linkModel;
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil().screenWidth - StyleTheme.margin * 2;
    List sortNavis =
        Provider.of<BaseStore>(context, listen: false).conf?.comic_sort_nav ??
            [];

    if (widget.isDiscover) {
      sortNavis = Provider.of<BaseStore>(context, listen: false)
              .conf
              ?.mv_discover_sort_nav ??
          [];
    }
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
                navis.isEmpty
                    ? Container()
                    : Utils.homeNaviBarModuleUI(context, navis)
              ],
            ),
          ),
        ];
      },
      body: GenCustomNav(
        labelPadding: 15.w,
        titles: sortNavis.map((e) => (e["title"] ?? "") as String).toList(),
        pages: sortNavis.asMap().keys.map((index) {
          return ComicSubChildPage(
            linkModel: _linkModel,
            fun: index != 0
                ? null
                : (bannerList, naviList, tipList) {
                    banners = bannerList;
                    navis = naviList;
                    tips = tipList;
                    if (mounted) setState(() {});
                  },
            param: sortNavis[index],
          );
        }).toList(),
        type: GenCustomNavType.none,
        isCenter: true,
        selectStyle: StyleTheme.font_blue52_14,
        defaultStyle: StyleTheme.font_black_7716_14,
      ),
    );
  }
}
