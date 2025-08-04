import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GeneralBannerAppsListWidget extends StatefulWidget {
  const GeneralBannerAppsListWidget(
      {super.key,
      required this.width,
      this.whRate = 1.0,
      this.data,
      this.radius = 0,
      this.useMargin = false});

  final double width;
  final double whRate;
  final List<dynamic>? data;
  final double radius;
  final bool useMargin;

  @override
  State<GeneralBannerAppsListWidget> createState() =>
      _GeneralBannerAppsListWidgetState();
}

class _GeneralBannerAppsListWidgetState
    extends State<GeneralBannerAppsListWidget> {
  @override
  Widget build(BuildContext context) {
    bool useAppsList =
        Provider.of<BaseStore>(context, listen: false).conf?.adVersion == 1;
    return useAppsList
        ? Utils.appsListWidget(
            data: widget.data,
            whRate: widget.whRate,
            width: widget.width,
            radius: widget.radius,
            useMargin: widget.useMargin,
          )
        : CustomGirdBanner(
            data:
                (widget.data ?? []).map((e) => AdsModel.fromJson(e)).toList());
  }
}
