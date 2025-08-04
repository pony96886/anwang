import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceChildPage extends StatefulWidget {
  VoiceChildPage({this.listShape = true, this.fun, this.param});

  bool listShape = false;
  final Function(List banners, List navis, List tips)? fun;
  Map? param;

  @override
  State<VoiceChildPage> createState() => _VoiceChildPageState();
}

class _VoiceChildPageState extends State<VoiceChildPage> {
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

  @override
  void didUpdateWidget(covariant VoiceChildPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.param?['id'] != widget.param?['id']) ||
        oldWidget.param?['type'] != widget.param?['type']) {
      page = 1;
      getData();
    }
  }

  Future<bool> getData() async {
    Map param = Map.from(widget.param ?? {});
    param['page'] = page;

    dynamic res =
        await reqVoiceIndex(id: param['id'], sort: param['type'], page: page);

    if (res?.status != 1) {
      netError = true;
      isHud = false;
      if (mounted) setState(() {});
      return false;
    }
    List tp = List.from(res?.data?['voices'] ?? []);
    if (page == 1) {
      noMore = false;
      array = tp;
      widget.fun?.call(
          List.from(res?.data?['banner'] ?? res?.data?['banners'] ?? []),
          List.from(res?.data?['nav'] ?? []),
          List.from(res?.data?['tips'] ?? []));
    } else if (tp.isNotEmpty) {
      array.addAll(tp);
    } else {
      noMore = true;
    }
    isHud = false;
    if (mounted) setState(() {});
    return noMore;
  }

  Widget _gridWidget() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
        childAspectRatio: 171 / 142,
      ),
      scrollDirection: Axis.vertical,
      itemCount: array.length,
      itemBuilder: (context, index) {
        dynamic e = array[index];
        return Utils.audioGridModuleUI(context, e);
      },
    );
  }

  Widget _listWidget() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: array.length,
      itemBuilder: (context, index) {
        dynamic e = array[index];
        return Utils.audioListModuleUI(context, e);
      },
    );
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
                    child: widget.listShape ? _listWidget() : _gridWidget(),
                  );
  }
}
