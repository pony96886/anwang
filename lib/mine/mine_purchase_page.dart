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

enum MediaType { pic, video, strip, aiMagic, aiPainting }

class MinePurchasePage extends BaseWidget {
  MinePurchasePage({Key? key, this.index = 0}) : super(key: key);
  final int index;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MinePurchasePageState();
  }
}

class _MinePurchasePageState extends BaseWidgetState<MinePurchasePage> {
  final GlobalKey<GenCustomNavState> key = GlobalKey<GenCustomNavState>();

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    Future.delayed(const Duration(milliseconds: 100), () {
      key.currentState?.openTabIndex(widget.index);
    });
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
              // lineColor: const Color.fromRGBO(241, 241, 241, 0.5),
              // type: GenCustomNavType.dotline,
              titles: [
                Utils.txt('aihh'),
                Utils.txt('aimf'),
                Utils.txt('tphl'),
                Utils.txt('sphl'),
                Utils.txt('aity'),
              ],
              pages: [
                PurchaseStatusPage(type: MediaType.aiPainting),
                PurchaseStatusPage(type: MediaType.aiMagic),
                PurchaseStatusPage(type: MediaType.pic),
                PurchaseStatusPage(type: MediaType.video),
                PurchaseStatusPage(type: MediaType.strip),
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

class PurchaseStatusPage extends StatefulWidget {
  PurchaseStatusPage({Key? key, required this.type}) : super(key: key);
  final MediaType type;

  @override
  State<PurchaseStatusPage> createState() => _PurchaseStatusPageState();
}

class _PurchaseStatusPageState extends State<PurchaseStatusPage> {
  @override
  Widget build(BuildContext context) {
    return GenCustomNav(
      type: GenCustomNavType.none,
      titles: widget.type == MediaType.video
          ? [
              Utils.txt('ysj'),
              Utils.txt('pdz'),
              Utils.txt('shzt'),
              Utils.txt('xxhdz'),
              Utils.txt('qbtw'),
            ]
          : [
              Utils.txt('ysj'),
              Utils.txt('pdz'),
              Utils.txt('shzt'),
              Utils.txt('qbtw'),
            ],
      pages: widget.type == MediaType.video
          ? [
              PurchaseChildPage(type: widget.type, status: 2),
              PurchaseChildPage(type: widget.type, status: 0),
              PurchaseChildPage(type: widget.type, status: 1),
              PurchaseChildPage(type: widget.type, status: 4),
              PurchaseChildPage(type: widget.type, status: 3),
            ]
          : [
              PurchaseChildPage(type: widget.type, status: 2),
              PurchaseChildPage(type: widget.type, status: 0),
              PurchaseChildPage(type: widget.type, status: 1),
              PurchaseChildPage(type: widget.type, status: 3),
            ],
      selectStyle: StyleTheme.font_blue52_14,
      defaultStyle: StyleTheme.font_black_7716_14,
    );
  }
}

class PurchaseChildPage extends StatefulWidget {
  PurchaseChildPage({
    Key? key,
    required this.type,
    required this.status,
  }) : super(key: key);
  final MediaType type;
  final int status;

  @override
  State<PurchaseChildPage> createState() => _PurchaseChildPageState();
}

class _PurchaseChildPageState extends State<PurchaseChildPage> {
  int page = 1;
  bool isMore = false;
  bool netError = false;
  bool isHud = true;
  bool isEdit = false;
  List array = [];
  List<int> delids = [];

  Future<bool> getData() async {
    ResponseModel<dynamic>? value;
    switch (widget.type) {
      case MediaType.pic:
        value = await reqMyFaces(page: page, status: widget.status);
        break;
      case MediaType.video:
        value = await reqMyVideos(page: page, status: widget.status);
        break;
      case MediaType.strip:
        value = await reqMyStrip(page: page, status: widget.status);
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

  void delData() async {
    if (delids.isEmpty) return;
    Utils.startGif(tip: Utils.txt("sancu"));
    ResponseModel<dynamic>? value;
    switch (widget.type) {
      case MediaType.pic:
        value = await reqDelMyFaces(ids: delids.join(","));
        break;
      case MediaType.video:
        value = await reqDelMyVideos(ids: delids.join(","));
        break;
      case MediaType.strip:
        value = await reqDelMyStrip(ids: delids.join(","));
        break;
      default:
    }
    Utils.closeGif();
    if (value?.status == 1) {
      array.removeWhere((el) => delids.contains(el["id"]));
      delids = [];
      isEdit = false;
      if (mounted) setState(() {});
    } else {
      Utils.showText(value?.msg ?? "");
    }
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
            : Stack(
                children: [
                  Column(
                    children: [
                      (widget.status == 2 || widget.status == 3) &&
                              array.isNotEmpty
                          ? Container(
                              height: 30.w,
                              margin: EdgeInsets.only(bottom: 5.w),
                              decoration: BoxDecoration(
                                color: StyleTheme.whiteColor,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: StyleTheme.margin),
                              alignment: Alignment.centerLeft,
                              child: Text(Utils.txt("qsrwzbt"),
                                  style: StyleTheme.font_red_255_12),
                            )
                          : Container(),
                      Expanded(
                        child: PullRefresh(
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: StyleTheme.margin),
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
                                      type: widget.type == MediaType.video
                                          ? 1
                                          : 0,
                                      isEdit: isEdit,
                                      isSelect: delids.contains(e["id"]),
                                      isLongPress:
                                          e["status"] == 2 || e["status"] == 3,
                                      //成功或失败才允许删除操作
                                      okfun: (x, f) {
                                        if (f) {
                                          //增加选中
                                          if (delids.contains(e['id'])) {
                                            delids.remove(e['id']);
                                          } else {
                                            delids.add(e['id']);
                                          }
                                          if (mounted) setState(() {});
                                          return;
                                        }
                                        //换头处理
                                        if (x == 2 &&
                                            widget.type == MediaType.pic) {
                                          Map picMap = {
                                            'resources': [e["face_thumb"]],
                                            'index': 0
                                          };
                                          String url = EncDecrypt.encry(
                                              jsonEncode(picMap));
                                          Utils.navTo(
                                              context, '/previewviewpage/$url');
                                          return;
                                        }
                                        //换脸处理
                                        if (x == 2 &&
                                            widget.type == MediaType.video) {
                                          Utils.navTo(context,
                                              "/unplayerpage/${Uri.encodeComponent(e["thumb"] ?? "")}/${Uri.encodeComponent(e["face_m3u8"] ?? "")}");
                                          return;
                                        }
                                        //去衣处理
                                        if (x == 2 &&
                                            widget.type == MediaType.strip) {
                                          Map picMap = {
                                            'resources': [e["strip_thumb"]],
                                            'index': 0
                                          };
                                          String url = EncDecrypt.encry(
                                              jsonEncode(picMap));
                                          Utils.navTo(
                                              context, '/previewviewpage/$url');
                                          return;
                                        }
                                      },
                                      editfun: () {
                                        isEdit = !isEdit;
                                        if (mounted) setState(() {});
                                      },
                                    );
                                  }),
                        ),
                      )
                    ],
                  ),
                  isEdit
                      ? Positioned(
                          right: 15.w,
                          bottom: 50.w,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              delData();
                            },
                            child: Container(
                              height: 30.w,
                              padding: EdgeInsets.symmetric(
                                  horizontal: StyleTheme.margin),
                              decoration: BoxDecoration(
                                  gradient: StyleTheme.gradBlue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.w))),
                              alignment: Alignment.center,
                              child: Text(
                                Utils.txt("yxzlt")
                                    .replaceAll("00", delids.length.toString()),
                                style: StyleTheme.font_white_255_12,
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              );
  }
}
