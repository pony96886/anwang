import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/util/platform_utils_native.dart'
    if (dart.library.html) 'package:deepseek/util/platform_utils_web.dart'
    as ui;

//分片上传
class XfileMultipartToast extends StatefulWidget {
  const XfileMultipartToast(
      {super.key, required this.file, required this.response, this.cancel});
  final Object file;
  final Function(Map<String, dynamic>) response;
  final Function()? cancel;

  @override
  State<XfileMultipartToast> createState() => _XfileMultipartToastState();
}

class _XfileMultipartToastState extends State<XfileMultipartToast> {
  String progress = Utils.txt('scz');
  CancelToken cancelToken = CancelToken();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _uploadSliceData();
  }

  _uploadSliceData() async {
    var value = await ui.platformViewRegistry.r2fileSliceUploadMp4(
      context,
      widget.file,
      cancelToken: cancelToken,
      progressCallback: (count, total) {
        Utils.log("---$count--$total");
        var tmp = (count / total * 100).toInt();
        if (tmp % 1 == 0) {
          progress = "${Utils.txt('scz')} $tmp%";
          if (mounted) setState(() {});
        }
      },
    );
    widget.response(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          color: Colors.transparent,
          height: 110.w,
          width: 110.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30.w,
                width: 30.w,
                child: CircularProgressIndicator(
                  color: StyleTheme.blue52Color,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(height: 12.w),
              Text(progress, style: StyleTheme.font_blue52_12)
            ],
          ),
        ),
        SizedBox(height: 20.w),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            cancelToken.cancel();
            widget.cancel?.call();
          },
          child: Container(
            height: 30.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
                color: StyleTheme.gray244Color.withOpacity(0.8),
                borderRadius: BorderRadius.all(Radius.circular(3.w))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Utils.txt('qxsc'),
                    style: StyleTheme.font_black_7716_14_medium)
              ],
            ),
          ),
        )
      ],
    );
  }
}
