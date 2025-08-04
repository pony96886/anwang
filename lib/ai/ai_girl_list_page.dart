import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AIGirlListPage extends StatefulWidget {
  const AIGirlListPage({Key? key, this.isShow = false, this.nav})
      : super(key: key);
  final bool isShow;
  final dynamic nav;

  @override
  State<AIGirlListPage> createState() => _AIGirlListPageState();
}

class _AIGirlListPageState extends State<AIGirlListPage> {
  bool isHud = true;
  bool netError = false;
  List list = [];
  List tags = [];
  int page = 1;
  bool noMore = false;
  String selTagStr = 'all';

  Future<bool> getData() async {
    final res = await reqCharactorList(
        tag: selTagStr, sort: widget.nav['value'], page: page);
    if (res?.status != 1) {
      netError = true;
      setState(() {});
      return false;
    }
    List tp = List.from(res?.data);
    if (page == 1) {
      noMore = false;
      list = tp;
    } else if (tp.isNotEmpty) {
      list.addAll(tp);
    } else {
      noMore = true;
    }
    isHud = false;
    setState(() {});
    return noMore;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ConfigModel? conf = Provider.of<BaseStore>(context, listen: false).conf;
    tags = conf?.ai_girlfriend_tag ?? [];
    if (tags.isNotEmpty) {
      selTagStr = tags.first['value'];
    }

    if (widget.isShow) {
      getData();
    }
  }

  @override
  void didUpdateWidget(covariant AIGirlListPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (isHud && list.isEmpty) {
      getData();
    }
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
            : Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: StyleTheme.margin,
                        right: StyleTheme.margin,
                        bottom: 6.w),
                    height: 40.w,
                    child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 6.w),
                        scrollDirection: Axis.horizontal,
                        itemCount: tags.length,
                        itemBuilder: (context, iIndex) {
                          dynamic item = tags[iIndex];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              selTagStr = item['value'];
                              getData();
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10.w),
                              decoration: BoxDecoration(
                                  color: selTagStr == item['value']
                                      ? StyleTheme.blue52Color
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15.w)),
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Center(
                                child: FittedBox(
                                  child: Text(
                                    item['label'],
                                    style: selTagStr == item['value']
                                        ? StyleTheme.font_white_255_13
                                        : StyleTheme.font_black_7716_06_13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
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
                      child: list.isEmpty
                          ? LoadStatus.noData()
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: StyleTheme.margin),
                              itemBuilder: (context, index) {
                                return Utils.aiGirlModuleUI(
                                    context, list[index]);
                              },
                              itemCount: list.length,
                            ),
                    ),
                  ),
                ],
              );
  }
}
