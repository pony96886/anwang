import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/home/home_subchild_page.dart';
import 'package:deepseek/home/home_recchild_page.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeRecPage extends StatefulWidget {
  const HomeRecPage({super.key, required this.linkModel});

  final LinkModel linkModel;

  @override
  State<HomeRecPage> createState() => _HomeRecPageState();
}

class _HomeRecPageState extends State<HomeRecPage> {
  List<dynamic> banners = [];
  List<dynamic> navis = [];
  List<dynamic> tips = [];

  late LinkModel _linkModel;

  @override
  void initState() {
    super.initState();
    _linkModel = widget.linkModel;
  }

  @override
  Widget build(BuildContext context) {
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
                      : Utils.homeNaviModuleUI(context, navis),
                ],
              ),
            ),
          ];
        },
        body: HomeRecChildPage(
          linkModel: _linkModel,
          fun: (bannerList, naviList, tipList) {
            banners = bannerList;
            navis = naviList;
            tips = tipList;
            if (mounted) setState(() {});
          },
        ));
  }
}
