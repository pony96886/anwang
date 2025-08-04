import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSubChildPage extends StatefulWidget {
  HomeSubChildPage(
      {required this.linkModel, this.index = 0, this.fun, this.param});

  final LinkModel linkModel;
  int index;
  final Function(List banners, List navis, List tips)? fun;
  Map? param;

  @override
  State<HomeSubChildPage> createState() => _HomeSubChildPageState();
}

class _HomeSubChildPageState extends State<HomeSubChildPage> {
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

    // param['type'] = null;

    dynamic res = await reqPureListByApiLink(apiLink: link, params: param);

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
                    child: GridView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      // shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 171 / (142 + 30),
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: array.length,
                      itemBuilder: (context, index) {
                        dynamic e = array[index];
                        return Utils.videoModuleUI(context, e);
                      },
                    ),
                  );
  }
}
