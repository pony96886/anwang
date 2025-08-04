import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/voice/voice_player_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoicePlayerTimeSheet extends StatefulWidget {
  const VoicePlayerTimeSheet({super.key});

  @override
  State<VoicePlayerTimeSheet> createState() => _VoicePlayerTimeSheetState();
}

class _VoicePlayerTimeSheetState extends State<VoicePlayerTimeSheet> {
  double get bottomBarHeight => kIsWeb ? 17 : ScreenUtil().bottomBarHeight;

  List<int> titles = [10, 20, 30, 40, 50, 60];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
            top: 10.w,
            bottom: bottomBarHeight + 20.w,
            left: StyleTheme.margin,
            right: StyleTheme.margin),
        decoration: BoxDecoration(
            color: StyleTheme.bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.w))),
        height: 46.w * titles.length + bottomBarHeight + 20.w + 70.w,
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
                  Text(Utils.txt('dsbf'),
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
            Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: titles.length,
                    itemBuilder: (context, index) =>
                        VoiceTimeSheetCard(minute: titles[index])))
          ],
        ),
      ),
    );
  }
}

class VoiceTimeSheetCard extends StatefulWidget {
  const VoiceTimeSheetCard(
      {super.key, required this.minute, this.isPlayAllAndDone = false});

  final int minute;
  final bool isPlayAllAndDone;

  @override
  State<VoiceTimeSheetCard> createState() => _VoiceTimeSheetCardState();
}

class _VoiceTimeSheetCardState extends State<VoiceTimeSheetCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (VoicePlayerManager.instance.minutes != null &&
            VoicePlayerManager.instance.minutes == widget.minute) {
          VoicePlayerManager.instance.resetTimer();
          Navigator.pop(context);

          return;
        }
        VoicePlayerManager.instance.minutes = widget.minute;
        VoicePlayerManager.instance.startCountDownTimer();
        Navigator.pop(context);
      },
      child: SizedBox(
        height: 46.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Divider(color: StyleTheme.devideLineColor, height: 0.5.w),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                          widget.isPlayAllAndDone
                              ? Utils.txt('bfwzt')
                              : '${widget.minute}${Utils.txt('minute')}',
                          style: StyleTheme.font_black_7716_15_medium)),
                  SizedBox(width: 10.w),
                  Visibility(
                    visible: (VoicePlayerManager.instance.minutes != null &&
                        VoicePlayerManager.instance.minutes == widget.minute),
                    child: SizedBox(
                      width: 19.w,
                      height: 18.w,
                      child: LocalPNG(name: "ai_voice_timer_list_check"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
