import 'dart:convert';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class XFileProgressToast extends StatefulWidget {
  const XFileProgressToast(
      {required this.file, required this.response, this.cancel})
      : super();
  final XFile? file;
  final Function(Map) response;
  final Function()? cancel;

  @override
  State<XFileProgressToast> createState() => _XFileProgressToastState();
}

class _XFileProgressToastState extends State<XFileProgressToast> {
  String progress = Utils.txt('scz');
  CancelToken cancelToken = CancelToken();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _upData();
  }

  _upData() async {
    if (kIsWeb) {
      var res = await NetworkHttp.xfileBytesUploadMp4(
        cancelToken: cancelToken,
        file: widget.file,
        position: 'upload',
        // progressCallback: (event) {
        //   Utils.log("---${event.loaded}--${event.total}");
        //   Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        //     var tmp = (event.loaded! / event.total! * 100).toInt();
        //     if (tmp % 1 == 0) {
        //       progress = "${Utils.txt('scz')} $tmp%";
        //       setState(() {});
        //     }
        //   });
        // },
        progressCallback: (count, total) {
          Utils.log("---$count--$total");
          var tmp = (count / total * 100).toInt();
          if (tmp % 1 == 0) {
            progress = "${Utils.txt('scz')} $tmp%";
            setState(() {});
          }
        },
      );
      widget.response(res == null ? {} : jsonDecode(res));
    } else {
      var res = await NetworkHttp.xfileUploadMp4(
        cancelToken: cancelToken,
        file: widget.file,
        position: 'upload',
        progressCallback: (count, total) {
          Utils.log("---$count--$total");
          var tmp = (count / total * 100).toInt();
          if (tmp % 1 == 0) {
            progress = "${Utils.txt('scz')} $tmp%";
            setState(() {});
          }
        },
      );
      widget.response(res == null ? {} : jsonDecode(res));
    }
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
              Text(progress, style: StyleTheme.font_blue_52_12)
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
                Text(Utils.txt('qxsc'), style: StyleTheme.font_black_31_12)
              ],
            ),
          ),
        )
      ],
    );
  }
}
