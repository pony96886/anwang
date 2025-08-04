import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/vlog/vlog_find_sub_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class VlogFindPage extends StatefulWidget {
  VlogFindPage({required this.linkModel});

  final dynamic linkModel;

  @override
  State<VlogFindPage> createState() => _VlogFindPageState();
}

class _VlogFindPageState extends State<VlogFindPage> {
  List<dynamic> banners = [];
  List<dynamic> navis = [];

  late dynamic _linkModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _linkModel = widget.linkModel;
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil().screenWidth - StyleTheme.margin * 2;
    List sortNavis = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.vlog_discover_sort_nav ??
        [];
    return Container(
      margin: EdgeInsets.only(top: StyleTheme.navHegiht - 10.w),
      child: GenCustomNav(
        // isEquallyDivide: true,
        type: GenCustomNavType.cover,
        // coverColor: Colors.transparent,
        selectStyle: StyleTheme.font_white_255_13,
        defaultStyle: StyleTheme.font_black_7716_06_13,
        labelPadding: 0.w,
        titles: sortNavis.map((e) => (e["title"] ?? "") as String).toList(),
        pages: sortNavis.asMap().keys.map((index) {
          return VlogFindSubPage(
            // apiUrl: _linkModel['api_url'],
            fun: index != 0
                ? null
                : (bannerList, naviList) {
                    banners = bannerList;
                    navis = naviList;
                    if (mounted) setState(() {});
                  },
            param: {'type': sortNavis[index]['type']},
          );
        }).toList(),
      ),
    );
  }
}
