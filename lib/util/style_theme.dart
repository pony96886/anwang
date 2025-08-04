// ignore_for_file: non_constant_identifier_names

import 'package:deepseek/util/app_global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StyleTheme {
  //距离
  static double get margin => 13.w;

  /*导航条高度*/
  static double get navHegiht => 44.w;

  static double get topHeight =>
      kIsWeb ? 5.w : MediaQuery.of(AppGlobal.context!).padding.top;
  static bool ipx =
      kIsWeb && (ScreenUtil().screenHeight / ScreenUtil().screenWidth >= 1.26);
  static double bottom = ipx ? 15.w : 0;

  /*底部导航条高度*/
  static double get botHegiht => 55.w;

  static double get pxBotHegiht => ipx ? (botHegiht + bottom) : botHegiht;

  //颜色
  static Color bgColor = const Color.fromRGBO(242, 244, 247, 1);
  static Color blackColor = const Color.fromRGBO(0, 0, 0, 1);

  static Color devideLineColor = const Color.fromRGBO(7, 7, 16, 0.1);

  static Color black019Color = const Color.fromRGBO(0, 0, 19, 1);
  static Color black31Color = const Color.fromRGBO(31, 31, 31, 1);
  static Color black45Color = const Color.fromRGBO(45, 48, 65, 1);

  static Color blak7716Color = const Color.fromRGBO(7, 7, 16, 1);
  static Color blak7716_06_Color = const Color.fromRGBO(7, 7, 16, 0.6);
  static Color blak7716_07_Color = const Color.fromRGBO(7, 7, 16, 0.7);
  static Color blak7716_08_Color = const Color.fromRGBO(7, 7, 16, 0.8);
  static Color blak7716_04_Color = const Color.fromRGBO(7, 7, 16, 0.4);
  static Color blak7716_05_Color = const Color.fromRGBO(7, 7, 16, 0.5);

  static Color gray77Color = const Color.fromRGBO(77, 77, 77, 1);
  static Color gray92Color = const Color.fromRGBO(92, 93, 100, 1);
  static Color gray102Color = const Color.fromRGBO(102, 102, 102, 1);
  static Color gray150Color = const Color.fromRGBO(150, 150, 150, 1);
  static Color gray195Color = const Color.fromRGBO(195, 195, 195, 1);
  static Color gray91Color = const Color.fromRGBO(242, 244, 247, 1);
  static Color gray230Color = const Color.fromRGBO(230, 228, 228, 1);
  static Color gray235Color = const Color.fromRGBO(235, 235, 235, 1);
  static Color gray244Color = const Color.fromRGBO(244, 244, 247, 1);
  static Color yellowColor = const Color.fromRGBO(255, 191, 0, 1);

  static Color yellowLineColor = const Color.fromRGBO(242, 205, 151, 1);

  static Color blue52Color = const Color.fromRGBO(52, 136, 255, 1);

  static Color blue25Color = const Color.fromRGBO(25, 103, 210, 1);
  static Color red253Color = const Color.fromRGBO(253, 19, 64, 1);
  static Color red255Color = const Color.fromRGBO(255, 109, 116, 1);
  static Color gray95Color = const Color.fromRGBO(95, 95, 95, 1);
  static Color gray128Color = const Color.fromRGBO(128, 128, 128, 1);
  static Color gray172Color = const Color.fromRGBO(172, 171, 176, 1);
  static Color gray198Color = const Color.fromRGBO(198, 198, 198, 1);
  static Color whiteColor = const Color.fromRGBO(255, 255, 255, 1);
  static Color white04Color = const Color.fromRGBO(255, 255, 255, 0.4);
  static Color white06Color = const Color.fromRGBO(255, 255, 255, 0.6);
  static Color white08Color = const Color.fromRGBO(255, 255, 255, 0.8);

  static LinearGradient gradBlue = const LinearGradient(
    colors: [
      Color.fromRGBO(52, 136, 255, 1),
      Color.fromRGBO(52, 136, 255, 1),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient gradOrange = const LinearGradient(
    colors: [
      Color.fromRGBO(246, 113, 31, 1),
      Color.fromRGBO(248, 166, 7, 1),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  //字体
  static TextStyle nav_title_font =
      font(size: 18, weight: FontWeight.w600, color: blak7716Color);

  static TextStyle font_gray_95_12 =
      StyleTheme.font(size: 12, weight: FontWeight.normal, color: gray95Color);

  static TextStyle font_gray_95_14 =
      StyleTheme.font(size: 14, weight: FontWeight.normal, color: gray95Color);

  static TextStyle font_black_019_14 = StyleTheme.font(
      size: 14, weight: FontWeight.normal, color: black019Color);

  static TextStyle font_black_31_12 =
      StyleTheme.font(size: 12, weight: FontWeight.normal, color: black31Color);

  static TextStyle font_black_31_11 =
      StyleTheme.font(size: 11, weight: FontWeight.normal, color: black31Color);

  static TextStyle font_black_31_14 =
      StyleTheme.font(size: 14, weight: FontWeight.normal, color: black31Color);

  static TextStyle font_gray_77_12 =
      StyleTheme.font(size: 12, weight: FontWeight.normal, color: gray77Color);

  static TextStyle font_blue_52_11 =
      StyleTheme.font(size: 11, weight: FontWeight.normal, color: blue52Color);

  static TextStyle font_blue_52_12 =
      StyleTheme.font(size: 12, weight: FontWeight.normal, color: blue52Color);

  static TextStyle font_blue_52_13 =
      StyleTheme.font(size: 13, weight: FontWeight.normal, color: blue52Color);

  static TextStyle font_blue_52_15 =
      StyleTheme.font(size: 15, weight: FontWeight.normal, color: blue52Color);

  static TextStyle font_yellow_255_13 =
      StyleTheme.font(size: 13, weight: FontWeight.normal, color: yellowColor);

  static TextStyle font_yellowLine_255_16 = StyleTheme.font(
      size: 16, weight: FontWeight.normal, color: yellowLineColor);

  static TextStyle font_blue52_14 =
      StyleTheme.font(size: 14, weight: FontWeight.normal, color: blue52Color);

  static TextStyle font_blue52_12 =
      StyleTheme.font(size: 12, weight: FontWeight.normal, color: blue52Color);

  static TextStyle font_blue52_13_medium =
      StyleTheme.font(size: 13, weight: FontWeight.w500, color: blue52Color);

  static TextStyle font_blue52_20_medium =
      StyleTheme.font(size: 20, weight: FontWeight.w500, color: blue52Color);

  static TextStyle font_blue52_15 =
      StyleTheme.font(size: 15, weight: FontWeight.normal, color: blue52Color);

  static TextStyle font_yellow_255_18 =
      StyleTheme.font(size: 18, weight: FontWeight.normal, color: yellowColor);

  static TextStyle font_yellow_255_14 =
      StyleTheme.font(size: 14, weight: FontWeight.normal, color: yellowColor);

  static TextStyle font_yellow_255_23_semi =
      StyleTheme.font(size: 23, weight: FontWeight.w600, color: blue52Color);

  static TextStyle font_yellow_255_25 =
      StyleTheme.font(size: 25, weight: FontWeight.normal, color: blue52Color);

  static TextStyle font_gray_102_11 =
      font(size: 11, weight: FontWeight.normal, color: gray102Color);

  static TextStyle font_gray_102_12 =
      font(size: 12, weight: FontWeight.normal, color: gray102Color);

  static TextStyle font_gray_102_14 =
      font(size: 14, weight: FontWeight.normal, color: gray102Color);

  static TextStyle font_gray_102_13 =
      font(size: 13, weight: FontWeight.normal, color: gray102Color);

  static TextStyle font_black_7716_04_12 =
      font(size: 12, weight: FontWeight.normal, color: blak7716_04_Color);

  static TextStyle font_black_7716_04_10 =
      font(size: 10, weight: FontWeight.normal, color: blak7716_04_Color);

  static TextStyle font_black_7716_05_11 =
      font(size: 10, weight: FontWeight.normal, color: blak7716_05_Color);

  static TextStyle font_black_7716_04_13 =
      font(size: 13, weight: FontWeight.normal, color: blak7716_04_Color);

  static TextStyle font_black_7716_04_14 =
      font(size: 14, weight: FontWeight.normal, color: blak7716_04_Color);

  static TextStyle font_black_7716_04_16 =
      font(size: 16, weight: FontWeight.normal, color: blak7716_04_Color);

  static TextStyle font_gray_150_13 =
      font(size: 13, weight: FontWeight.normal, color: gray150Color);

  static TextStyle font_gray_150_14_medium =
      font(size: 14, weight: FontWeight.w600, color: gray150Color);

  static TextStyle font_gray_150_15 =
      font(size: 15, weight: FontWeight.normal, color: gray150Color);

  static TextStyle font_gray_198_13 =
      StyleTheme.font(size: 13, weight: FontWeight.normal, color: gray198Color);

  static TextStyle font_black_7716_04_15 = StyleTheme.font(
      size: 15, weight: FontWeight.normal, color: blak7716_04_Color);

  static TextStyle font_black_7716_06_11 = StyleTheme.font(
      size: 11, weight: FontWeight.normal, color: blak7716_06_Color);

  static TextStyle font_black_7716_06_11_medium = StyleTheme.font(
      size: 11, weight: FontWeight.w600, color: blak7716_06_Color);

  static TextStyle font_black_7716_06_15 = StyleTheme.font(
      size: 15, weight: FontWeight.normal, color: blak7716_06_Color);

  static TextStyle font_black_7716_14_medium =
      StyleTheme.font(size: 14, weight: FontWeight.w500, color: blak7716Color);

  static TextStyle font_black_7716_16 = StyleTheme.font(
      size: 16, color: StyleTheme.blak7716Color, weight: FontWeight.normal);

  static TextStyle font_black_7716_16_blod = StyleTheme.font(
          size: 16, color: StyleTheme.blak7716Color, weight: FontWeight.w600)
      .toHeight(1);

  static TextStyle font_black_7716_16_medium = StyleTheme.font(
      size: 16, color: StyleTheme.blak7716Color, weight: FontWeight.w500);

  static TextStyle font_black_7716_20_medium = StyleTheme.font(
      size: 20, color: StyleTheme.blak7716Color, weight: FontWeight.w500);

  static TextStyle font_black_7716_06_12 =
      StyleTheme.font(size: 12, color: StyleTheme.blak7716_06_Color, height: 1);

  static TextStyle font_black_7716_06_14 =
      StyleTheme.font(size: 14, color: StyleTheme.blak7716_06_Color);

  static TextStyle font_black_7716_06_13 =
      StyleTheme.font(size: 13, color: StyleTheme.blak7716_06_Color);

  static TextStyle font_black_7716_07_13 =
      StyleTheme.font(size: 13, color: StyleTheme.blak7716_07_Color);

  static TextStyle font_black_7716_07_14 =
      StyleTheme.font(size: 14, color: StyleTheme.blak7716_07_Color);

  static TextStyle font_black_7716_07_12 =
      StyleTheme.font(size: 12, color: StyleTheme.blak7716_07_Color);

  static TextStyle font_black_7716_08_12 =
      StyleTheme.font(size: 12, color: StyleTheme.blak7716_08_Color);

  static TextStyle font_black_7716_12 =
      StyleTheme.font(size: 12, color: StyleTheme.blak7716Color);

  static TextStyle font_black_7716_14 = StyleTheme.font(
      size: 14, weight: FontWeight.normal, color: blak7716Color);

  static TextStyle font_black_7716_15 = StyleTheme.font(
      size: 14, weight: FontWeight.normal, color: blak7716Color);

  static TextStyle font_black_7716_13 = StyleTheme.font(
      size: 13, weight: FontWeight.normal, color: blak7716Color);

  static TextStyle font_black_7716_20 = StyleTheme.font(
      size: 20, weight: FontWeight.normal, color: blak7716Color);

  static TextStyle font_black_7716_17_medium =
      StyleTheme.font(size: 17, weight: FontWeight.w500, color: blak7716Color);

  static TextStyle font_black_7716_18 = StyleTheme.font(
      size: 18, weight: FontWeight.normal, color: blak7716Color);

  static TextStyle font_black_7716_18_blod =
      StyleTheme.font(size: 18, weight: FontWeight.bold, color: blak7716Color);

  static TextStyle font_black_7716_14_blod =
      StyleTheme.font(size: 14, weight: FontWeight.bold, color: blak7716Color);

  static TextStyle font_black_7716_15_medium =
      StyleTheme.font(size: 15, weight: FontWeight.w500, color: blak7716Color);

  static TextStyle font_black_7716_06_16 = StyleTheme.font(
      size: 16, weight: FontWeight.normal, color: blak7716_06_Color);

  static TextStyle font_black_7716_06_16_medium = StyleTheme.font(
      size: 16, weight: FontWeight.w600, color: blak7716_06_Color);

  static TextStyle font_blue52_16_medium =
      StyleTheme.font(size: 16, weight: FontWeight.w500, color: blue52Color);

  static TextStyle font_blue52_17_medium =
      StyleTheme.font(size: 17, weight: FontWeight.w500, color: blue52Color);

  static TextStyle font_black_7716_06_16_semi =
      font(size: 16, weight: FontWeight.w600, color: blak7716_06_Color);

  static TextStyle font_black_7716_06_18 = StyleTheme.font(
      size: 18, weight: FontWeight.normal, color: blak7716_06_Color);

  static TextStyle font_black_7716_06_18_semi =
      font(size: 18, weight: FontWeight.w600, color: blak7716_06_Color);

  static TextStyle font_white_255_04_14 =
      font(size: 14, weight: FontWeight.normal, color: white04Color);

  static TextStyle font_white_255_04_12 =
      font(size: 12, weight: FontWeight.normal, color: white04Color);

  static TextStyle font_white_255_06_14 =
      font(size: 14, weight: FontWeight.normal, color: white06Color);

  static TextStyle font_white_255_08_14 =
      font(size: 14, weight: FontWeight.normal, color: white08Color);

  static TextStyle font_white_255_15_semi =
      font(size: 15, weight: FontWeight.w600);

  static TextStyle font_white_255_16_semi =
      font(size: 16, weight: FontWeight.w600);

  static TextStyle font_white_255_9 = font(size: 9, weight: FontWeight.normal);

  static TextStyle font_white_255_10 =
      font(size: 10, weight: FontWeight.normal);

  static TextStyle font_white_255_11 =
      font(size: 11, weight: FontWeight.normal);

  static TextStyle font_white_255_12 =
      font(size: 12, weight: FontWeight.normal);

  static TextStyle font_white_255_13 =
      font(size: 13, weight: FontWeight.normal);

  static TextStyle font_white_255_14 =
      font(size: 14, weight: FontWeight.normal);

  static TextStyle font_white_255_14_medium =
      font(size: 14, weight: FontWeight.w600);

  static TextStyle font_white_255_15 =
      font(size: 15, weight: FontWeight.normal);

  static TextStyle font_white_255_20 =
      font(size: 20, weight: FontWeight.normal);

  static TextStyle font_white_255_15_medium =
      font(size: 15, weight: FontWeight.w500);

  static TextStyle font_white_255_16 =
      font(size: 16, weight: FontWeight.normal);

  static TextStyle font_white_255_17_medium =
      font(size: 17, weight: FontWeight.w600);

  static TextStyle font_white_255_19_medium =
      font(size: 19, weight: FontWeight.w600);

  static TextStyle font_black_31_16_semi =
      font(size: 16, weight: FontWeight.w600, color: black31Color);

  static TextStyle font_black_31_18 =
      font(size: 18, weight: FontWeight.normal, color: black31Color);

  static TextStyle font_black_31_20 =
      font(size: 20, weight: FontWeight.normal, color: black31Color);

  static TextStyle font_red_255_11 =
      font(size: 11, weight: FontWeight.normal, color: red255Color);

  static TextStyle font_red_255_12 =
      font(size: 12, weight: FontWeight.normal, color: red255Color);

  static TextStyle font_gray_128_12 =
      StyleTheme.font(size: 12, weight: FontWeight.normal, color: gray128Color);

  static TextStyle font_gray_153_11 = StyleTheme.font(
      size: 11, weight: FontWeight.normal, color: blak7716_07_Color);

  static TextStyle font_gray_153_12 = StyleTheme.font(
      size: 12, weight: FontWeight.normal, color: blak7716_07_Color);

  static TextStyle font_gray_153_13 = StyleTheme.font(
      size: 13, weight: FontWeight.normal, color: blak7716_07_Color);

  static TextStyle font_gray_153_16 = StyleTheme.font(
      size: 16, weight: FontWeight.normal, color: blak7716_07_Color);

  static TextStyle font_blue_30_12 =
      StyleTheme.font(size: 12, weight: FontWeight.normal, color: blue25Color);

  static TextStyle font_blue_30_13 =
      StyleTheme.font(size: 12, weight: FontWeight.normal, color: blue25Color);

  static TextStyle font_blue_30_14 =
      StyleTheme.font(size: 14, weight: FontWeight.normal, color: blue25Color);

  static TextStyle font(
      {int size = 16,
      Color color = Colors.white,
      FontWeight weight = FontWeight.normal,
      List<Shadow>? shadows,
      TextDecoration decoration = TextDecoration.none,
      FontStyle fontStyle = FontStyle.normal,
      double? height}) {
    return TextStyle(
      fontFamily: null,
      color: color,
      fontSize: size.sp,
      fontWeight: weight,
      overflow: TextOverflow.ellipsis,
      decoration: decoration,
      fontStyle: fontStyle,
      decorationStyle: TextDecorationStyle.dotted,
      shadows: shadows,
      height: height,
    );
  }
}

extension TextStyleExt on TextStyle {
  TextStyle toHeight(
    double? height,
  ) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationStyle: decorationStyle,
      shadows: shadows,
      height: height ?? 1,
    );
  }

  TextStyle toColor(
    Color? color,
  ) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationStyle: decorationStyle,
      shadows: shadows,
      height: height ?? 1,
    );
  }
}
