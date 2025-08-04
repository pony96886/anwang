import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NovelRecPage extends StatefulWidget {
  const NovelRecPage({super.key, this.linkModel, this.isShow = false});
  final bool isShow;

  final LinkModel? linkModel;

  @override
  State<NovelRecPage> createState() => _NovelRecPageState();
}

class _NovelRecPageState extends State<NovelRecPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  int page = 1;
  late LinkModel _linkModel;
  List array = [];

  List<dynamic> banners = [];
  List<dynamic> navis = [];
  List<dynamic> tips = [];

  @override
  void initState() {
    // TODO: implement initState

    _linkModel = widget.linkModel ?? LinkModel();
    super.initState();
    if (widget.isShow) {
      getData();
    }
  }

  @override
  void didUpdateWidget(covariant NovelRecPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      getData();
    }
  }

  Future<bool> getData() async {
    dynamic res = await reqNovelRec(id: _linkModel.id ?? 0, page: page);

    if (res?.status != 1) {
      netError = true;
      isHud = false;
      if (mounted) setState(() {});
      return false;
    }

    List tp = List.from(res?.data?['novels'] ?? []);
    if (page == 1) {
      banners = List.from(res?.data?['banner'] ?? res?.data?['banners'] ?? []);
      tips = List.from(res?.data?['tips'] ?? []);
      navis = List.from(res?.data?['nav'] ?? []);

      noMore = false;
      array = tp;
    } else if (tp.isNotEmpty) {
      array.addAll(tp);
    } else {
      noMore = true;
    }
    isHud = false;
    if (mounted) setState(() {});
    return noMore;
  }

  Widget constructWidget(BuildContext context, dynamic e) {
    if (e['url'] != null) {
      return Utils.adListUI(context, e);
    }

    List array = e['items'] ?? [];
    return Column(
      children: [
        Container(
          // height: 100.w,
          margin: EdgeInsets.only(bottom: StyleTheme.margin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                e['title'] ?? "",
                style: StyleTheme.font_black_7716_16_blod,
              ),
              SizedBox(width: 5.w),
              Text(
                e['sub_title'] ?? "",
                style: StyleTheme.font(
                    size: 12, weight: FontWeight.normal, height: 1),
              ),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    Utils.navTo(context, '/novelmorepage', extra: {
                      "title": e['title'],
                      "id": e['id'],
                      "value": e['value'],
                    });
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      Text(Utils.txt('ckgd'),
                          style: StyleTheme.font_black_7716_04_14),
                      LocalPNG(
                        name: 'ai_common_right_arrow_138',
                        width: 12.w,
                        height: 12.w,
                      )
                    ],
                  )),
            ],
          ),
        ),
        array.isEmpty
            ? const SizedBox()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: array.length,
                itemBuilder: (context, index) {
                  dynamic e = array[index];
                  return Utils.novelListModuleUI(context, e);
                },
              ),
        // SizedBox(height: 10.w),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil().screenWidth - StyleTheme.margin * 2;
    return isHud
        ? LoadStatus.showLoading(mounted)
        : netError
            ? LoadStatus.netError(onTap: () {
                netError = false;
                getData();
              })
            : array.isEmpty
                ? LoadStatus.noData()
                : NestedScrollView(
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
                    body: PullRefresh(
                      onRefresh: () {
                        page = 1;
                        return getData();
                      },
                      onLoading: () {
                        page++;
                        return getData();
                      },
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        // shrinkWrap: true,
                        // physics: NeverScrollableScrollPhysics(),
                        itemCount: array.length,
                        itemBuilder: (context, index) {
                          dynamic e = array[index];
                          return constructWidget(context, e);
                        },
                      ),
                    ),
                  );
  }
}
