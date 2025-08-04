import 'dart:convert';

import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

enum MineMateType {
  pic,
  video,
}

class MineMatePage extends BaseWidget {
  MineMatePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineMatePageState();
  }
}

class _MineMatePageState extends BaseWidgetState<MineMatePage> {
  final GlobalKey<GenCustomNavState> key = GlobalKey<GenCustomNavState>();

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return Column(
      children: [
        SizedBox(height: StyleTheme.topHeight),
        Expanded(
            child: Stack(
          children: [
            GenCustomNav(
              key: key,
              // lineColor: StyleTheme
              //     .whiteColor, // const Color.fromRGBO(241, 241, 241, 0.5),
              // type: GenCustomNavType.dotline,
              titles: [
                Utils.txt('tphl'),
                Utils.txt('sphl'),
              ],
              pages: [
                MateStatusPage(type: MineMateType.pic),
                MateStatusPage(type: MineMateType.video),
              ],
              isCenter: true,
              selectStyle: StyleTheme.font_blue52_16_medium,
              defaultStyle: StyleTheme.font_black_7716_06_16,
            ),
            Positioned(
              top: 2.w,
              left: StyleTheme.margin,
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 40.w,
                  height: 40.w,
                  child: LocalPNG(
                    name: "ai_nav_back_w",
                    width: 17.w,
                    height: 17.w,
                    fit: BoxFit.contain,
                  ),
                ),
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  finish();
                },
              ),
            )
          ],
        ))
      ],
    );
  }
}

class MateStatusPage extends StatefulWidget {
  MateStatusPage({Key? key, required this.type}) : super(key: key);
  final MineMateType type;

  @override
  State<MateStatusPage> createState() => _MateStatusPageState();
}

class _MateStatusPageState extends State<MateStatusPage> {
  @override
  Widget build(BuildContext context) {
    return GenCustomNav(
      type: GenCustomNavType.none,
      titles: widget.type == MineMateType.video
          ? [
              Utils.txt('tcjg'),
              Utils.txt('qtyc'),
              Utils.txt('xxhdz'),
              Utils.txt('qtlc'),
            ]
          : [
              Utils.txt('tcjg'),
              Utils.txt('qtyc'),
              Utils.txt('qtlc'),
            ],
      pages: widget.type == MineMateType.video
          ? [
              MateChildPage(type: widget.type, status: 1),
              MateChildPage(type: widget.type, status: 0),
              MateChildPage(type: widget.type, status: 2),
              MateChildPage(type: widget.type, status: 3),
            ]
          : [
              MateChildPage(type: widget.type, status: 1),
              MateChildPage(type: widget.type, status: 0),
              MateChildPage(type: widget.type, status: 2),
            ],
      selectStyle: StyleTheme.font_blue52_14,
      defaultStyle: StyleTheme.font_black_7716_14,
    );
  }
}

class MateChildPage extends StatefulWidget {
  MateChildPage({
    Key? key,
    required this.type,
    required this.status,
  }) : super(key: key);
  final MineMateType type;
  final int status;

  @override
  State<MateChildPage> createState() => _MateChildPageState();
}

class _MateChildPageState extends State<MateChildPage> {
  int page = 1;
  bool isMore = false;
  bool netError = false;
  bool isHud = true;
  List array = [];

  Future<bool> getData() async {
    ResponseModel<dynamic>? value;
    switch (widget.type) {
      case MineMateType.pic:
        value = await reqRecPics(page: page, status: widget.status);
        break;
      case MineMateType.video:
        value = await reqRecVideos(page: page, status: widget.status);
        break;
      default:
    }
    if (value?.data == null) {
      netError = true;
      if (mounted) setState(() {});
      return false;
    }
    List tp = List.from(value?.data ?? []);
    if (page == 1) {
      isMore = false;
      array = tp;
    } else if (tp.isNotEmpty) {
      array.addAll(tp);
    } else {
      isMore = true;
    }
    isHud = false;
    if (mounted) setState(() {});
    return isMore;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
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
            : PullRefresh(
                onRefresh: () {
                  page = 1;
                  return getData();
                },
                onLoading: () {
                  page++;
                  return getData();
                },
                child: array.isEmpty
                    ? LoadStatus.noData()
                    : MasonryGridView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        gridDelegate:
                            const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: array.length,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                        itemBuilder: (cx, index) {
                          dynamic e = array[index];
                          return Utils.materialDealUI(
                            context,
                            e,
                            type: widget.type == MineMateType.video ? 1 : 0,
                            okfun: (x, f) {
                              //换头处理
                              if (x == 2 && widget.type == MineMateType.pic) {
                                Map picMap = {
                                  'resources': [e["thumb"]],
                                  'index': 0
                                };
                                String url =
                                    EncDecrypt.encry(jsonEncode(picMap));
                                Utils.navTo(context, '/previewviewpage/$url');
                                return;
                              }
                              //换脸处理
                              if (x == 1 && widget.type == MineMateType.video) {
                                Utils.navTo(context,
                                    "/unplayerpage/${Uri.encodeComponent(e["thumb"] ?? "")}/${Uri.encodeComponent(e["m3u8"] ?? "")}");
                                return;
                              }
                            },
                          );
                        }),
              );
  }
}
