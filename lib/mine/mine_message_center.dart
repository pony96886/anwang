import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineMessageCenterPage extends BaseWidget {
  const MineMessageCenterPage({Key? key}) : super(key: key);

  @override
  _MineMessageCenterPageState cState() => _MineMessageCenterPageState();
}

class _MineMessageCenterPageState extends BaseWidgetState<MineMessageCenterPage> {

  dynamic data = {};

  void getData() {
    reqSystemNotice(context).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didPopNext() {
    getData();
  }

  @override
  void onCreate() {
    setAppTitle(
        titleW: Text(Utils.txt("xxzx"), style: StyleTheme.nav_title_font));
    // getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return Consumer<BaseStore>(
      builder: (ctx, state, child) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Utils.navTo(context, "/minesystempage");
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(StyleTheme.margin),
                child: Row(
                  children: [
                    LocalPNG(name: 'app_mine_system_message', width: 50.w, height: 50.w),
                    SizedBox(width: 10.w),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(Utils.txt('xtxx'), style: StyleTheme.font_black_7716_15),
                            const Spacer(),
                            (state.notice?.systemNoticeCount ?? 0) > 0 ? Container(
                              decoration: BoxDecoration(
                                color: StyleTheme.blue52Color,
                                borderRadius: BorderRadius.circular(10.0.w),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.w),
                              child: Text('${state.notice?.systemNoticeCount}', style: StyleTheme.font_white_255_11),
                            ) : Container()
                          ],
                        ),
                        SizedBox(width: 5.w),
                        (state.notice?.systemNotice?.question.isEmpty ?? false) || (state.notice?.systemNotice == null) ?
                        Text(Utils.txt('zwxx'), style: StyleTheme.font_black_7716_06_13) :
                        Text(state.notice?.systemNotice?.question ?? '', style: StyleTheme.font_black_7716_06_13),
                      ],
                    ))
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Utils.navTo(context, "/mineservicepage");
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(StyleTheme.margin),
                child: Row(
                  children: [
                    LocalPNG(name: 'app_wd_zzkf', width: 50.w, height: 50.w),
                    SizedBox(width: 10.w),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(Utils.txt('gfkf'), style: StyleTheme.font_black_7716_15),
                            const Spacer(),
                            (state.notice?.feedCount ?? 0) > 0 ? Container(
                              decoration: BoxDecoration(
                                color: StyleTheme.blue52Color,
                                borderRadius: BorderRadius.circular(10.0.w),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.w),
                              child: Text('${state.notice?.feedCount}', style: StyleTheme.font_white_255_11),
                            ) : Container()
                          ],
                        ),
                        SizedBox(width: 5.w),
                        (state.notice?.feed?.question.isEmpty ?? false) || (state.notice?.feed == null) ?
                        Text(Utils.txt('zwxx'), style: StyleTheme.font_black_7716_06_13) :
                        Text(state.notice?.feed?.question ?? '', style: StyleTheme.font_black_7716_06_13),
                      ],
                    ))
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
