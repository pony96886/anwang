import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/vlog/vlog_find_sub_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class VlogFindSubPage extends StatefulWidget {
  VlogFindSubPage({this.apiUrl = '', this.index = 0, this.fun, this.param});

  final String apiUrl;
  int index;
  final Function(List banners, List navis)? fun;
  Map? param;

  @override
  State<VlogFindSubPage> createState() => _VideoSubChildPageState();
}

class _VideoSubChildPageState extends State<VlogFindSubPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  int page = 1;
  List array = [];

  String _link = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future<bool>  getData() async {
    _link = widget.apiUrl;
    if (_link.isEmpty) {
      _link = '/api/vlog/list_discover';
    }

    Map param = {}; // _linkModel.params ?? {};
    param.addAll(widget.param ?? {});
    param['page'] = page;

    // param['sort'] = param['type'];
    // String type = widget.param?["type"] ?? "";
    // if (type.isNotEmpty) param["sort"] = type;

    // param['type'] = null;

    dynamic res = await reqShortApiList(apiUrl: _link, param: param);

    if (res?.status != 1) {
      netError = true;
      isHud = false;
      if (mounted) setState(() {});
      return false;
    }
    List tp = List.from(res?.data ?? []);
    if (page == 1) {
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
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 167 / (238 + 30),
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: array.length,
                      itemBuilder: (context, index) {
                        dynamic e = array[index];
                        return Utils.vlogModuleUI(context, e, onTapFunc: () {
                          AppGlobal.shortVideosInfo = {
                            'list': array,
                            'page': page,
                            'index': index,
                            'api': _link,
                            'params': widget.param
                          };

                          Utils.navTo(context, '/vlogsecondpage');
                        });
                      },
                    ),
                  );
  }
}
