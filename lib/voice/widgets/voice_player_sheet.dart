import 'dart:async';

import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/voice/voice_player_manager.dart';
import 'package:deepseek/voice/widgets/voice_player_sheet_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoicePlayerSheet extends StatefulWidget {
  const VoicePlayerSheet({super.key, this.complete});

  final Function? complete;

  @override
  State<VoicePlayerSheet> createState() => _VoicePlayerSheetState();
}

class _VoicePlayerSheetState extends State<VoicePlayerSheet> {
  double get bottomBarHeight => kIsWeb ? 17 : ScreenUtil().bottomBarHeight;

  late StreamSubscription<MyEvent> _subscription;

  @override
  void initState() {
    super.initState();

    _getData();

    // 订阅播放完毕后自动切换音频后刷新界面
    _subscription = eventBus.on<MyEvent>().listen((event) {
      debugPrint('Received event: ${event.message}');
      if (event.message == 'RefreshVoicePayerUI') {
        setState(() {});
        Navigator.pop(context);
      }
    });
  }

  Future<void> _getData() async {
    final res = await reqVoiceListQueue(page: 1, limit: 1000);
    if (res?.status == 1) {
      VoicePlayerManager.instance.voices = res?.data ?? []; //同步数据到单例中
    } else if (res?.msg case final msg?) {
      Utils.showText(msg);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _subscription.cancel(); // 取消订阅
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // //正在播放的数据放到第一位
    var list = VoicePlayerManager.instance.voices;
    // var playingData = VoicePlayerManager.instance.data;
    // int index = list.indexWhere((model) => model.id == playingData?.id);
    // if (index == -1) {
    //   MyToast.showText(text: '播放列表数据请求失败，请稍后再试！');
    // } else {
    //   list.removeAt(index);
    //   list.insert(0, playingData!);
    // }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
            top: 10.w,
            bottom: bottomBarHeight + 20.w,
            left: StyleTheme.margin,
            right: StyleTheme.margin),
        decoration: BoxDecoration(
            color: StyleTheme.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.w))),
        height: 500.w,
        child: Column(
          children: [
            SizedBox(
              height: 46.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   width: 42.w,
                  // ),
                  Text(Utils.txt('bflb'),
                      style: StyleTheme.font_black_7716_17_medium),
                  // GestureDetector(
                  //   onTap: () => Navigator.pop(context),
                  //   behavior: HitTestBehavior.translucent,
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(horizontal: 10.w),
                  //     height: double.infinity,
                  //     child: SizedBox(
                  //       width: 16.w,
                  //       height: 16.w,
                  //       child: LocalPNG(name: "ai_alert_close"),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
            SizedBox(height: 10.w),
            Divider(color: StyleTheme.devideLineColor, height: 0.5.w),
            Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) => VoicePlayerSheetCard(
                          data: list[index],
                          complete: () {
                            widget.complete?.call();
                          },
                          delete: () {
                            setState(() {});
                          },
                        )))
          ],
        ),
      ),
    );
  }
}
