// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';
import 'dart:io';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:universal_html/html.dart' as html;

// ignore: must_be_immutable
class PullRefresh extends StatefulWidget {
  PullRefresh({
    Key? key,
    this.child,
    this.onRefresh,
    this.onLoading,
  }) : super(key: key);
  Widget? child;
  Future<bool> Function()? onRefresh;
  Future<bool> Function()? onLoading;
  @override
  _PullRefreshState createState() => _PullRefreshState();
}

class _PullRefreshState extends State<PullRefresh> {
  RefreshController? _refreshController;
  bool isBottom = true;
  String txtTip = "";
  bool noMore = false;
  bool moreLoad = true;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController?.dispose();
  }

  void _onRefresh() async {
    if (widget.onRefresh == null) return;
    moreLoad = false;
    await widget.onRefresh?.call();
    _refreshController?.refreshCompleted(resetFooterState: true);
    noMore = false;
    Future.delayed(const Duration(seconds: 1), () {
      moreLoad = true;
    });
  }

  void _onLoading() async {
    if (widget.onLoading == null) return;
    moreLoad = false;
    noMore = await widget.onLoading?.call() ?? false;
    noMore
        ? _refreshController?.loadNoData()
        : _refreshController?.loadComplete();
    moreLoad = true;
  }

  bool isMobile() {
    //moblie web+device
    if (kIsWeb) {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      return userAgent.contains("mobile") ||
          userAgent.contains("android") ||
          userAgent.contains("iphone") ||
          userAgent.contains("ipad");
    } else {
      return Platform.isAndroid || Platform.isIOS;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (scrollNotification) {
        if (isMobile()) return false;
        if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
          // 到底部了，加载更多
            if (!noMore && moreLoad && _refreshController!.isLoading == false) {
              _refreshController?.requestLoading();
            }
        }
        return false;
      },
      child: SmartRefresher(
        enablePullDown: widget.onRefresh != null,
        enablePullUp: widget.onLoading != null,
        header: const GifOfHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            if (mode == LoadStatus.idle) {
              txtTip = Utils.txt('zlyd');
            } else if (mode == LoadStatus.loading) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.w),
                child: Center(
                  child: SizedBox(
                    height: 20.w,
                    width: 20.w,
                    child: CircularProgressIndicator(
                      color: StyleTheme.blue52Color,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            } else if (mode == LoadStatus.failed) {
              txtTip = Utils.txt('zzsb');
            } else if (mode == LoadStatus.canLoading) {
              txtTip = Utils.txt('ssjz');
            } else {
              txtTip = Utils.txt('wydx');
            }
            return SizedBox(
                height: 50.w,
                child: Center(
                    child: Text(txtTip, style: StyleTheme.font_gray_153_12)));
          },
        ),
        controller: _refreshController!,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: widget.child,
      ),
    );
  }
}

class GifOfHeader extends RefreshIndicator {
  const GifOfHeader() : super(height: 80, refreshStyle: RefreshStyle.Follow);
  @override
  State<StatefulWidget> createState() {
    return GifOfHeaderState();
  }
}

class GifOfHeaderState extends RefreshIndicatorState<GifOfHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (mode == RefreshStatus.refreshing) {}
    super.onModeChange(mode);
  }

  @override
  Future<void> endRefresh() {
    return Future.delayed(const Duration(microseconds: 500), () {});
  }

  @override
  void resetValue() {
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.w),
      child: Center(
        child: SizedBox(
          height: 20.w,
          width: 20.w,
          child: CircularProgressIndicator(
            color: StyleTheme.blue52Color,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
