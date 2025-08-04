import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/community/community_usually.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NovelCategoriesPage extends BaseWidget {
  NovelCategoriesPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _NovelCategoriesPageState();
  }
}

class _NovelCategoriesPageState extends BaseWidgetState<NovelCategoriesPage> {
  int page = 1;
  bool noMore = false;
  bool netError = false;
  bool isHud = false;
  List<dynamic> banners = [];

  List<dynamic> array = [];

  List options = [];
  Map _filterTempMap = {
    "end": "all",
    "sort": "all",
    "theme_id": "all",
  };

  Future<bool> getData() {
    return reqNovelType(options: _filterTempMap, page: page).then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return false;
      }
      List st = List.from(value?.data ?? []);

      if (page == 1) {
        noMore = false;
        array = st;
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
  void onCreate() {
    // TODO: implement onCreate
    options =
        Provider.of<BaseStore>(context, listen: false).conf?.novel_type_nav ??
            [];
    setAppTitle(
        titleW: Text(Utils.txt('flbq'), style: StyleTheme.nav_title_font));
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : Container(
                margin: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                child: Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          Map itemMap = options[index];
                          List items = List.from(itemMap['items']);

                          return SizedBox(
                            height: 40.w,
                            child: Row(
                              children: [
                                Container(
                                  height: 27.w,
                                  margin: EdgeInsets.symmetric(vertical: 10.w),
                                  // alignment: Alignment.centerLeft,
                                  child: Text(
                                    itemMap['title'],
                                    style: StyleTheme.font_black_7716_16_blod
                                        .toHeight(1.2),
                                  ),
                                ),
                                SizedBox(
                                  width: 30.w,
                                ),
                                Expanded(
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: items.length,
                                        itemBuilder: (context, iIndex) {
                                          dynamic item = items[iIndex];
                                          return GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              if (_filterTempMap[
                                                      itemMap['value']] ==
                                                  item['value']) {
                                              } else {
                                                _filterTempMap[
                                                        itemMap['value']] =
                                                    item['value'];
                                                page = 1;
                                                getData();
                                              }
                                              setState(() {});
                                            },
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 30.w),
                                              // decoration: BoxDecoration(
                                              //     color: _filterTempMap[
                                              //                 itemMap['value']] ==
                                              //             item['value']
                                              //         ? StyleTheme.blue52Color
                                              //         : Colors.transparent,
                                              //     border: Border.all(
                                              //       color:
                                              //           StyleTheme.blue52Color,
                                              //       width: 1,
                                              //     ),
                                              //     borderRadius:
                                              //         BorderRadius.circular(2.w)),
                                              child: Center(
                                                child: FittedBox(
                                                  child: Text(
                                                    item['title'],
                                                    style: StyleTheme.font(
                                                        size: 16,
                                                        color: _filterTempMap[
                                                                    itemMap[
                                                                        'value']] ==
                                                                item['value']
                                                            ? StyleTheme
                                                                .blue52Color
                                                            : StyleTheme
                                                                .blak7716_07_Color),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }))
                              ],
                            ),
                          );
                        }),
                    Expanded(
                      child: array.isEmpty
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
                              child: Utils.novelListView(context, array,
                                  useHoriMargin: false),
                            ),
                    ),
                  ],
                ),
              );
  }
}
