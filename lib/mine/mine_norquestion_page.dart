import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineNorquestionPage extends BaseWidget {
  MineNorquestionPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineNorquestionPageState();
  }
}

class _MineNorquestionPageState extends BaseWidgetState<MineNorquestionPage> {
  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('chjwt'), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    ConfigModel? cf = Provider.of<BaseStore>(context, listen: false).conf;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          EdgeInsets.symmetric(horizontal: StyleTheme.margin, vertical: 10.w),
      child: cf?.help == null || cf?.help?.isEmpty == true
          ? LoadStatus.noData()
          : Column(
              children: cf?.help?.map((e) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.question ?? "",
                          style: StyleTheme.font_black_7716_16_blod,
                          maxLines: 2,
                        ),
                        SizedBox(height: 10.w),
                        Utils.getContentSpan(e.answer ?? "",
                            isCopy: true,
                            style: StyleTheme.font_black_7716_07_14),
                        SizedBox(height: 30.w),
                      ],
                    );
                  }).toList() ??
                  [],
            ),
    );
  }
}
