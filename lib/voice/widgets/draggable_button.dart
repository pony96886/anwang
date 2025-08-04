import 'dart:async';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/voice/voice_player_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DraggableFloatingButton extends StatefulWidget {
  const DraggableFloatingButton({super.key});

  @override
  State<DraggableFloatingButton> createState() =>
      _DraggableFloatingButtonState();
}

class _DraggableFloatingButtonState extends State<DraggableFloatingButton> {
  double _x = ScreenUtil().screenWidth - 13.w - 60.w; // Initial X position
  double _y = ScreenUtil().screenHeight - 64.w - 60.w; // Initial Y position

  late StreamSubscription<MyEvent> _subscription;

  @override
  void initState() {
    super.initState();

    // 订阅播放完毕后自动切换音频后刷新界面
    _subscription = eventBus.on<MyEvent>().listen((event) {
      debugPrint('Received event: ${event.message}');
      if (event.message == 'RefreshVoicePayerUI') {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // 取消订阅
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: ScreenUtil().scaleWidth,
        maxHeight: ScreenUtil().scaleHeight,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: _x,
            top: _y,
            child: Listener(
              onPointerMove: (details) {
                setState(() {
                  _x = (_x + details.delta.dx).clamp(
                      0.0, ScreenUtil().screenWidth - 60.w);
                  _y = (_y + details.delta.dy).clamp(
                      0.0, ScreenUtil().screenHeight - 60.w);
                });
              },
              child: _buildButton(), // 内部点击事件仍然有效
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButton() {
    return GestureDetector(
      onTap: () {
        Utils.navTo(context, '/voiceplayerpage',
            extra: VoicePlayerManager.instance.data);
      },
      child: SizedBox(
        width: 60.w,
        height: 60.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            LocalPNG(name: 'ai_voice_player_disk', width: double.infinity),
            Positioned.fill(
                child: Center(
              child: SizedBox(
                width: 46.w,
                height: 46.w,
                child: ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: BorderRadius.circular(23.w),
                    child: SizedBox(
                      width: 46.w,
                      height: 46.w,
                      child: ImageNetTool(
                        url: VoicePlayerManager.instance.data?['small_cover'] ??
                            '',
                      ),
                    )),
              ),
            )),
            Positioned.fill(
                child: Center(
              child: SizedBox(
                width: 36.w,
                child: Text(
                  '播放中',
                  style: StyleTheme.font_white_255_11,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
