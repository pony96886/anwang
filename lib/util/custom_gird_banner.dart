import 'dart:async';
import 'dart:developer';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CustomGirdBanner extends StatefulWidget {
  const CustomGirdBanner({
    super.key,
    required this.data,
    this.radius = 5,
    this.imgWidth = 98,
    this.imgHeight = 125,
  });

  final List<AdsModel> data;
  final double radius;
  final double imgWidth;
  final double imgHeight;

  @override
  State<CustomGirdBanner> createState() => _CustomGirdBannerState();
}

class _CustomGirdBannerState extends State<CustomGirdBanner> {
  late final ScrollController _scrollController;
  Timer? _timer;
  int _currentIndex = 0;
  late int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _itemCount = widget.data.length;
    _scrollController = ScrollController();

    // 监听滑动事件
    _scrollController.addListener(() {
      final offset = _scrollController.position.pixels;
      final itemWidth = widget.imgWidth + 10.w; // 每个项的宽度加上间距
      final calculatedIndex = (offset / itemWidth).round();
      _currentIndex = calculatedIndex;

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        log("滑动到尽头！");
        // 在这里可以实现逻辑，比如跳回第一个广告
        _currentIndex = -1;
      } else if (_scrollController.position.pixels == 0.0) {
        log("滑动到0");
        _currentIndex = -1;
      }
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentIndex < _itemCount - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _scrollToIndex(_currentIndex);
    });
  }

  void _scrollToIndex(int index) {
    double scrollOffset = index * (widget.imgWidth + 10.w); // 每个项目的宽度加上间距

    // 限制滚动最大值，防止超出范围
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;

    // 如果滑动到最后一个广告时，限制最大滑动范围
    final double targetOffset =
        (scrollOffset > maxScrollExtent) ? maxScrollExtent : scrollOffset;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // 暂停定时器
  void _pauseTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
  }

  // 恢复定时器
  void _resumeTimer() {
    _pauseTimer();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pauseTimer();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.data.isEmpty
        ? Container()
        : NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction != ScrollDirection.idle) {
                // 用户开始滚动，暂停定时器
                _pauseTimer();
              } else {
                // 用户停止滚动，恢复定时器
                _resumeTimer();
              }
              return false;
            },
            child: VisibilityDetector(
              key: ObjectKey(widget.data),
              onVisibilityChanged: (visibility) async {
                if (visibility.visibleFraction == 0 && mounted) {
                  _pauseTimer();
                } else if (visibility.visibleFraction == 1 && mounted) {
                  _resumeTimer();
                }
              },
              child: Container(
                alignment: Alignment.centerLeft,
                // color: Colors.red,
                height: widget.imgHeight.w,
                child: GridView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: widget.imgHeight.w / widget.imgWidth.w,
                    mainAxisSpacing: 10.w,
                    crossAxisSpacing: 10.w,
                  ),
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: widget.data.length,
                  itemBuilder: (context, index) {
                    final data = widget.data[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Utils.openRoute(context, data.toJson());
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: widget.imgWidth.w,
                            height: widget.imgHeight.w,
                            child: ImageNetTool(
                                url: data.resource_url ?? '',
                                radius: BorderRadius.all(
                                    Radius.circular(widget.radius.w)),
                                fit: BoxFit.cover),
                          ),
                          // SizedBox(height: 5.w),
                          // Text(
                          //   data.name ?? '广告名称',
                          //   style: MyTheme.white13,
                          // ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
  }
}
