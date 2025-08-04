import 'dart:math';

import 'package:deepseek/base/base_store.dart';
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
import 'package:provider/provider.dart';

class CartoonRecPage extends StatefulWidget {
  CartoonRecPage({this.linkModel, this.isShow = false});
  final bool isShow;

  final LinkModel? linkModel;

  @override
  State<CartoonRecPage> createState() => _CartoonRecPageState();
}

class _CartoonRecPageState extends State<CartoonRecPage> {
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
  void didUpdateWidget(covariant CartoonRecPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      getData();
    }
  }

  Future<bool> getData() async {
    dynamic res = await reqCartoonRec(id: _linkModel.id ?? 0, page: page);

    if (res?.status != 1) {
      netError = true;
      isHud = false;
      if (mounted) setState(() {});
      return false;
    }

    List tp = List.from(res?.data?['cartoons'] ?? []);
    if (page == 1) {
      banners = List.from(res?.data?['banner'] ?? res?.data?['banners'] ?? []);
      tips = List.from(res?.data?['tips'] ?? []);

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
                              // navis.isEmpty
                              //     ? Container()
                              //     : Utils.homeNaviModuleUI(context, navis),
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
                          return RecVideoContructCard(data: e);
                          // return constructWidget(context, e);
                        },
                      ),
                    ),
                  );
  }
}

class RecVideoContructCard extends StatefulWidget {
  RecVideoContructCard({super.key, this.data});
  dynamic data;

  @override
  State<RecVideoContructCard> createState() => _RecVideoContructCardState();
}

class _RecVideoContructCardState extends State<RecVideoContructCard> {
  int page = 1;

  bool _isLoading = false;
  //换一换
  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
    });
    page++;
    final limit = max(6, List.from(widget.data['items']).length);

    dynamic data = widget.data;
    dynamic t =
        await reqMoreCartoons(sort: data["value"], page: page, limit: limit);

    _isLoading = false;

    if (t.status != 1) {
      Utils.showText(t.msg);
      setState(() {});
      return;
    }

    List tp = List.from(t.data);

    widget.data['items'] = tp;

    setState(() {});
  }

  _jumpToMore() {
    dynamic data = widget.data;
    Utils.navTo(context, '/cartoonmorepage', extra: {
      "title": data['title'],
      "id": data['id'],
      "value": data['value'],
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic data = widget.data;

    //判断是不是广告 是的话直接显示广告
    if (data['url'] != null) {
      return Utils.adListUI(context, data, imageRatio: 350 / 100);
    }
    List array = data['items'] ?? [];

    return Column(
      children: [
        Container(
          height: 30.w,
          margin: EdgeInsets.only(bottom: StyleTheme.margin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data['title'] ?? "",
                style: StyleTheme.font_black_7716_16_blod.toHeight(1),
              ),
              SizedBox(width: 5.w),
              Text(
                data['sub_title'] ?? "",
                style: StyleTheme.font(
                    size: 12, weight: FontWeight.normal, height: 1),
              ),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    Utils.navTo(context, '/cartoonmorepage', extra: {
                      "title": data['title'],
                      "id": data['id'],
                      "value": data['value'],
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
        GridView.builder(
          // padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.w,
            crossAxisSpacing: 10.w,
            childAspectRatio: 171 / 122,
          ),
          scrollDirection: Axis.vertical,
          itemCount: array.length,
          itemBuilder: (context, index) {
            dynamic e = array[index];
            return Utils.videoModuleUI2(context, e, isCartoon: true);
          },
        ),
        SizedBox(height: 6.w),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 30.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.w),
                    color: StyleTheme.whiteColor),
                child: _isLoading
                    ? Center(
                        child: SizedBox.square(
                          dimension: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: StyleTheme.blak7716_04_Color,
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        // color: Colors.deepOrange,
                        child: GestureDetector(
                          onTap: _getData,
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LocalPNG(
                                name: 'ai_video_card_reload',
                                width: 13.w,
                                height: 13.w,
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              Text(
                                Utils.txt('hyh'),
                                style: StyleTheme.font_black_7716_06_14,
                              )
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Container(
                height: 30.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.w),
                    color: StyleTheme.whiteColor),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  // color: Colors.deepOrange,
                  child: GestureDetector(
                    onTap: _jumpToMore,
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LocalPNG(
                          name: 'ai_video_card_more',
                          width: 13.w,
                          height: 13.w,
                        ),
                        SizedBox(
                          width: 6.w,
                        ),
                        Text(
                          Utils.txt('kgd'),
                          style: StyleTheme.font_black_7716_06_14,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.w),
      ],
    );
  }
}
