import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeMoreVideoListPage extends StatefulWidget {
  const HomeMoreVideoListPage(
      {super.key, this.type = '', this.id = "", this.bannerFunc});
  final String type;
  final String id;
  final Function(dynamic)? bannerFunc;

  @override
  State<HomeMoreVideoListPage> createState() => _HomeMoreVideoListPageState();
}

class _HomeMoreVideoListPageState extends State<HomeMoreVideoListPage> {
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
    getData();
  }

  Future<bool> getData() {
    return reqListConstruct(id: widget.id, page: page, sort: widget.type)
        .then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List tp = List.from(value?.data["list"] ?? []);
      if (page == 1) {
        noMore = false;
        array = tp;
        widget.bannerFunc?.call(value?.data["banner"] ?? []);
      } else if (tp.isNotEmpty) {
        array.addAll(tp);
      } else {
        noMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return noMore;
    });
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
                      shrinkWrap: true,
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
