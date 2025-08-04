import 'dart:typed_data';

import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//有bytes直接读取 否则网络图片加载
class ImageNetTool extends StatelessWidget {
  const ImageNetTool({
    Key? key,
    this.url = "",
    this.bytes,
    this.fit = BoxFit.cover,
    this.scale = 1.0,
    this.backColor = const Color.fromRGBO(244, 244, 244, 1),
    this.radius = const BorderRadius.all(Radius.circular(3)),
  }) : super(key: key);

  final String url;
  final BoxFit fit;
  final double scale;
  final BorderRadius radius;
  final Uint8List? bytes;
  final Color? backColor;

  Widget placeholder({int type = 1}) => RepaintBoundary(
        child: type == 1
            ? Container(
                color: backColor,
                alignment: Alignment.center,
                child: LocalPNG(
                  name: "ai_app_placeholder",
                  width: 40.w,
                  height: 30.w,
                  fit: BoxFit.fill,
                ),
              )
            : Container(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenWidth / 2,
                alignment: Alignment.center,
                child: SizedBox(
                  height: 20.w,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    color: StyleTheme.gray95Color,
                    strokeWidth: 2.w,
                  ),
                ),
              ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: bytes != null
          ? Image.memory(
              bytes!,
              scale: scale,
              fit: fit,
              width: fit == BoxFit.cover ? double.infinity : null,
              height: fit == BoxFit.cover ? double.infinity : null,
              frameBuilder: (context, child, frame, bool wasSynchronous) {
                if (wasSynchronous || frame != null) return child;
                return placeholder(type: fit == BoxFit.cover ? 1 : 2);
              },
              errorBuilder: (context, error, stackTrace) {
                return placeholder(type: fit == BoxFit.cover ? 1 : 2);
              },
            )
          : url.isEmpty
              ? placeholder(type: fit == BoxFit.cover ? 1 : 2)
              : Image.network(
                  url,
                  scale: scale,
                  fit: fit,
                  width: fit == BoxFit.cover ? double.infinity : null,
                  height: fit == BoxFit.cover ? double.infinity : null,
                  frameBuilder: (context, child, frame, bool wasSynchronous) {
                    if (wasSynchronous || frame != null) return child;
                    return placeholder(type: fit == BoxFit.cover ? 1 : 2);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return placeholder(type: fit == BoxFit.cover ? 1 : 2);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return placeholder(type: fit == BoxFit.cover ? 1 : 2);
                  },
                ),
    );
  }
}
