import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class MyMarqueeTipsWidget extends StatelessWidget {
//   const MyMarqueeTipsWidget({required this.tips, this.onTap});
//   final List<dynamic> tips;
//   final Function(int index)? onTap;
//   @override
//   Widget build(BuildContext context) {
//     if (tips.isEmpty) return const SizedBox.shrink();

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
//       child: Row(
//         children: [
//           Icon(
//             Icons.icecream,
//             size: 20.w,
//             color: StyleTheme.blue52Color,
//           ),
//           // MyImage.asset(
//           //   MyImagePaths.appMarqueeIcon,
//           //   width: 20.w,
//           //   height: 20.w,
//           // ),
//           SizedBox(width: 5.w),
//           Expanded(
//             child: MarqueeWidget(
//               children: tips
//                   .asMap()
//                   .keys
//                   .map((index) => GestureDetector(
//                         behavior: HitTestBehavior.translucent,
//                         onTap: () {
//                           print('object');
//                           onTap?.call(index);
//                         },
//                         child: Container(
//                           height: 50.w,
//                           color: StyleTheme.blue52Color,
//                           child: Text(
//                             tips[index]['title'] ?? '',
//                             style: StyleTheme.font_white_255_14,
//                           ),
//                         ),
//                       ))
//                   .toList(),

//               // [
//               //   for (final tip in tips)
//               //     GestureDetector(
//               //       behavior: HitTestBehavior.opaque,
//               //       onTap: () {
//               //         onTap?.call(i)
//               //         // CommonUtils.openRoute(context, tip.toJson());
//               //       },
//               //       child: Text(
//               //         tip['title'] ?? '',
//               //         style: StyleTheme.font_white_255_14,
//               //       ),
//               //     ),
//               // ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MarqueeWidget extends StatefulWidget {
//   const MarqueeWidget({
//     // super.key,
//     this.pauseDuration = const Duration(milliseconds: 100),
//     this.scrollSpeed = 60.0,
//     required this.children,
//   });

//   final Duration pauseDuration;
//   final double scrollSpeed; //每秒滚动距离
//   final List<Widget> children;

//   @override
//   State<MarqueeWidget> createState() => _MarqueeWidgetState();
// }

// class _MarqueeWidgetState extends State<MarqueeWidget> {
//   final _controller = ScrollController();

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       Future.doWhile(_scroll);
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (_, constraints) {
//         final blankSpace = SizedBox(width: constraints.maxWidth, height: 0);
//         return ScrollConfiguration(
//           behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             controller: _controller,
//             physics: const NeverScrollableScrollPhysics(),
//             child: Row(children: [
//               blankSpace,
//               for (final child in widget.children) ...[
//                 child,
//                 blankSpace,
//               ],
//             ]),
//           ),
//         );
//       },
//     );
//   }

//   Future<bool> _scroll() async {
//     await Future.delayed(widget.pauseDuration);

//     if (!_controller.hasClients) return false;

//     _controller.jumpTo(0);
//     final maxScrollExtent = _controller.position.maxScrollExtent;
//     await _controller.animateTo(
//       maxScrollExtent,
//       duration: Duration(
//         seconds: (maxScrollExtent / widget.scrollSpeed).floor(),
//       ),
//       curve: Curves.linear,
//     );

//     return true;
//   }
// }

class SwiperTips extends StatefulWidget {
  const SwiperTips({
    required this.tips,
    this.radius = 0,
    this.aspectRatio = 325 / 20,
    this.onTap,
  });
  final List<dynamic> tips;
  final double radius;
  final double aspectRatio;
  final Function(int index)? onTap;
  @override
  State<SwiperTips> createState() => _SwiperTipsState();
}

class _SwiperTipsState extends State<SwiperTips> {
  final SwiperController _swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    final length = widget.tips.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      child: Row(
        children: [
          LocalPNG(
            name: 'ai_common_trumpet',
            width: 18.w,
            height: 14.w,
          ),
          SizedBox(width: 10.w),
          // Icon(
          //   Icons.icecream,
          //   size: 20.w,
          //   color: StyleTheme.blue52Color,
          // ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Swiper(
                  controller: _swiperController,
                  physics: const NeverScrollableScrollPhysics(), // 禁用手动滚动
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        widget.onTap?.call(index);
                      },
                      child: MarqueeWidget(
                        scrollSpeed: 60,
                        child: Text(
                          widget.tips[index]['title'] ?? '',
                          style: StyleTheme.font_black_7716_07_12,
                        ),
                        scrollComplete: () {
                          _swiperController.next();
                        },
                      ),
                    );
                  },
                  itemCount: length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarqueeWidget extends StatefulWidget {
  final Duration pauseDuration, forwardDuration;
  final double scrollSpeed; //滚动速度(时间单位是秒)。
  final Widget child; //子视图。
  final Function? scrollComplete; //滚动展示完后去上层切换下一个广告数据展示

  /// 注: 构造函数入参的默认值必须是常量。
  const MarqueeWidget({
    this.pauseDuration = const Duration(milliseconds: 100),
    this.forwardDuration = const Duration(milliseconds: 3000),
    this.scrollSpeed = 30.0,
    this.scrollComplete,
    required this.child,
  });

  @override
  State createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget>
    with SingleTickerProviderStateMixin {
  bool _validFlag = true;
  double _boxWidth = 0;
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    // debugPrint('Track_MarqueeView_dispose');
    _validFlag = false;
    _controller.removeListener(_onScroll); // 移除滚动监听器
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    scroll();
  }

  void _onScroll() {
    if (_controller.hasClients) {
      // 检查是否滚动到了末尾
      if (_controller.offset >= _controller.position.maxScrollExtent) {
        // 滚动到达末尾
        widget.scrollComplete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 使用LayoutBuilder获取组件的大小。
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _boxWidth = constraints.maxWidth;
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            // 禁止手动滑动。
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _boxWidth),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void scroll() async {
    while (_validFlag) {
      // debugPrint('Track_MarqueeView_scroll');
      await Future.delayed(widget.pauseDuration);
      if (_boxWidth <= 0) {
        continue;
      }
      _controller.jumpTo(0);
      await _controller.animateTo(_controller.position.maxScrollExtent,
          duration: Duration(
              seconds:
                  (_controller.position.maxScrollExtent / widget.scrollSpeed)
                      .floor()),
          curve: Curves.linear);
    }
  }
}
