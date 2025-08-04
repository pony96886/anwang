import 'package:bot_toast/bot_toast.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadStatus {
  //全屏式loding
  static Function showSLoading({String? text}) {
    String tip = text ?? Utils.txt('jzz');
    return BotToast.showLoading(
        backgroundColor: Colors.black45,
        wrapToastAnimation: (AnimationController animation, fc, Widget child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: StyleTheme.blue52Color),
              SizedBox(height: 15.w),
              Text(tip,
                  style:
                      StyleTheme.font(size: 12, color: StyleTheme.blue52Color))
            ],
          );
        });
  }

  //列表loding
  static Widget showLoading(bool mounted, {String? text, int width = 100}) {
    String tip = text ?? Utils.txt('zzjzsh');
    if (mounted) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30.w,
              width: 30.w,
              child: CircularProgressIndicator(
                color: StyleTheme.blue52Color,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 15.w),
            Text(tip, style: StyleTheme.font_blue_52_12)
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  //关闭全屏式loading
  static void closeLoading() {
    return BotToast.closeAllLoading();
  }

  //无数据
  static Widget noData({String? text, double w = 218}) {
    String tip = text ?? Utils.txt('zwsj');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LocalPNG(name: "ai_nodata", width: w.w, height: w / 218 * 130),
          SizedBox(height: 10.w),
          Text(tip,
              style: StyleTheme.font(
                  size: 14, color: StyleTheme.blak7716_07_Color))
        ],
      ),
    );
  }

  //网络错误
  static Widget netError({String? text, Function? onTap}) {
    String tip = text ?? Utils.txt('zzsb');
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: 0.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalPNG(name: 'ai_no_network', width: 206.w, height: 110.7.w),
              SizedBox(height: 5.w),
              Text(tip,
                  style: StyleTheme.font(
                      size: 14, color: StyleTheme.blak7716_07_Color)),
            ],
          ),
        ),
      ),
    );
  }
}
