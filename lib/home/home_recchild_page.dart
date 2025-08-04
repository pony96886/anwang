import 'dart:math';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeRecChildPage extends StatefulWidget {
  const HomeRecChildPage(
      {super.key,
      required this.linkModel,
      this.index = 0,
      this.fun,
      this.param});

  final LinkModel linkModel;
  final int index;
  final Function(List banners, List navis, List tips)? fun;
  final Map? param;

  @override
  State<HomeRecChildPage> createState() => _HomeRecChildPageState();
}

class _HomeRecChildPageState extends State<HomeRecChildPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  int page = 1;
  late LinkModel _linkModel;
  List array = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _linkModel = widget.linkModel;
    getData();
  }

  Future<bool> getData() async {
    String link = _linkModel.api ?? "";
    Map param = _linkModel.params ?? {};
    param['page'] = page;
    String type = widget.param?["type"] ?? "";
    if (type.isNotEmpty) param["sort"] = type;

    param['type'] = null;

    dynamic res = await reqConstructByApiLink(apiLink: link, params: param);

    if (res?.status != 1) {
      netError = true;
      isHud = false;
      if (mounted) setState(() {});
      return false;
    }
    List tp = List.from(res?.data?.list ?? []);
    if (page == 1) {
      noMore = false;
      array = tp;
      widget.fun?.call(List.from(res?.data?.banner ?? []),
          List.from(res?.data?.nav ?? []), List.from(res?.data?.tips ?? []));
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
    return isHud
        ? LoadStatus.showLoading(mounted)
        : netError
            ? LoadStatus.netError(onTap: () {
                netError = false;
                getData();
              })
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
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      // shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: array.length,
                      itemBuilder: (context, index) {
                        dynamic e = array[index];
                        return RecVideoContructCard(data: e);
                      },
                    ),
                  );
  }
}

class RecVideoContructCard extends StatefulWidget {
  const RecVideoContructCard({super.key, this.data});

  final dynamic data;

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
    dynamic t;
    if (data['type'] == 1) {
      t = await reqMoreVideos(cate_id: data['id'], page: page, limit: limit);
    } else {
      List sortNavis = Provider.of<BaseStore>(context, listen: false)
              .conf
              ?.mv_second_sort_nav ??
          [];

      t = await reqPartVideos(
          id: data['id'],
          sort: sortNavis.first['type'],
          page: page,
          limit: limit);
    }

    _isLoading = false;

    if (t.status != 1) {
      Utils.showText(t.msg);
      setState(() {});
      return;
    }

    List tp = List.from(t.data['list']);

    widget.data['items'] = tp;

    setState(() {});
  }

  _jumpToMore() {
    dynamic data = widget.data;

    if (data['type'] == 1) {
      Utils.navTo(context, '/homevideomorepage', extra: {
        "title": data['title'],
        "id": data['id'],
      });
    } else {
      Utils.navTo(context, '/homevideopartpage', extra: {
        "title": data['title'],
        "id": data['id'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic data = widget.data;
    if (data['url'] != null) {
      return Utils.adListViewModuleUI(context, data);
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
                style: StyleTheme.font_black_7716_06_12.toHeight(1),
              ),
              const Spacer(),
              GestureDetector(
                  onTap: _jumpToMore,
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Utils.txt('ckgd'),
                          style: StyleTheme.font_black_7716_04_12),
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
          physics: const NeverScrollableScrollPhysics(),
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
            return Utils.videoModuleUI2(context, e);
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
