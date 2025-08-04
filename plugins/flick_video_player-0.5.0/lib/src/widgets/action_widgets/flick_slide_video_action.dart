import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class FlickSlideVideoAction extends StatefulWidget {
  const FlickSlideVideoAction({
    Key? key,
    this.child,
    this.textColor = Colors.white,
    this.fontSize = 24,
    this.closeGes = false,
  }) : super(key: key);

  final Widget? child;
  final Color textColor;
  final double fontSize;
  final bool closeGes;

  @override
  State<FlickSlideVideoAction> createState() => _FlickSlideVideoActionState();
}

class _FlickSlideVideoActionState extends State<FlickSlideVideoAction> {
  Duration _duration = const Duration();
  Duration _currentPos = const Duration();
  // 滑动后值
  Duration _dargPos = const Duration();
  double updatePrevDx = 0.0;
  double updatePrevDy = 0.0;
  int updatePosX = 0;
  bool isDargVerLeft = false;
  bool varTouchInitSuc = false;
  double updateDargVarVal = 0.0;

  bool _isTouch = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildDargProgressTime() {
    return _isTouch
        ? Container(
            height: 40,
            width: 200,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              color: Color.fromRGBO(0, 0, 0, 0.8),
            ),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              '${_duration2String(_dargPos)} / ${_duration2String(_duration)}',
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
              ),
            ),
          )
        : Container();
  }

  // build 显示垂直亮度，音量
  Widget _buildDargVolumeAndBrightness() {
    // 不显示
    if (!varTouchInitSuc) return Container();
    IconData iconData;
    // 判断当前值范围，显示的图标
    if (updateDargVarVal <= 0) {
      iconData = !isDargVerLeft ? Icons.volume_mute : Icons.brightness_low;
    } else if (updateDargVarVal < 0.5) {
      iconData = !isDargVerLeft ? Icons.volume_down : Icons.brightness_medium;
    } else {
      iconData = !isDargVerLeft ? Icons.volume_up : Icons.brightness_high;
    }
    // 显示，亮度 || 音量
    return Container(
      height: 40,
      width: 200,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
        color: Color.fromRGBO(0, 0, 0, 0.8),
      ),
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: <Widget>[
          Icon(
            iconData,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                value: updateDargVarVal,
                backgroundColor: Colors.white54,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _duration2String(Duration duration) {
    if (duration.inMilliseconds < 0) return "-: negtive";

    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    int inHours = duration.inHours;
    return inHours > 0
        ? "$inHours:$twoDigitMinutes:$twoDigitSeconds"
        : "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    void _onHorizontalDragStart(DragStartDetails details) {
      if (!videoManager.isVideoInitialized || widget.closeGes) {
        return;
      }

      _currentPos =
          videoManager.videoPlayerValue?.position ?? const Duration(seconds: 0);
      _duration =
          videoManager.videoPlayerValue?.duration ?? const Duration(seconds: 0);

      setState(() {
        updatePrevDx = details.globalPosition.dx;
        updatePosX = _currentPos.inMilliseconds;
      });
    }

    void _onHorizontalDragUpdate(DragUpdateDetails details) {
      if (!videoManager.isVideoInitialized || widget.closeGes) {
        return;
      }

      double curDragDx = details.globalPosition.dx;
      // 确定当前是前进或者后退
      int cdx = curDragDx.toInt();
      int pdx = updatePrevDx.toInt();
      bool isBefore = cdx > pdx;

      // 计算手指滑动的比例
      int newInterval = pdx - cdx;
      double playerW = MediaQuery.of(context).size.width;
      int curIntervalAbs = newInterval.abs();
      double movePropCheck = (curIntervalAbs / playerW) * 100;

      // 计算进度条的比例
      double durProgCheck = _duration.inMilliseconds.toDouble() / 100;
      int checkTransfrom = (movePropCheck * durProgCheck).toInt();
      int dragRange =
          isBefore ? updatePosX + checkTransfrom : updatePosX - checkTransfrom;

      // 是否溢出 最大
      int lastSecond = _duration.inMilliseconds;
      if (dragRange >= _duration.inMilliseconds) {
        dragRange = lastSecond;
      }
      // 是否溢出 最小
      if (dragRange <= 0) {
        dragRange = 0;
      }

      setState(() {
        _isTouch = true;
        // 更新下上一次存的滑动位置
        updatePrevDx = curDragDx;
        // 更新时间
        updatePosX = dragRange.toInt();
        _dargPos = Duration(milliseconds: updatePosX.toInt());
      });
    }

    void _onHorizontalDragEnd(DragEndDetails details) {
      if (!videoManager.isVideoInitialized || widget.closeGes) {
        return;
      }

      videoManager.videoPlayerController?.seekTo(_dargPos);
      setState(() {
        _isTouch = false;
        _currentPos = _dargPos;
      });
    }

    void _onVerticalDragStart(DragStartDetails detills) {
      if (kIsWeb) return;
      if (!videoManager.isVideoInitialized || widget.closeGes) {
        return;
      }

      double clientW = MediaQuery.of(context).size.width;
      double curTouchPosX = detills.globalPosition.dx;

      setState(() {
        // 更新位置
        updatePrevDy = detills.globalPosition.dy;
        // 是否左边
        isDargVerLeft = (curTouchPosX > (clientW / 2)) ? false : true;
      });
      // 大于 右边 音量 ， 小于 左边 亮度
      if (!isDargVerLeft) {
        // 音量
        FlutterVolumeController.getVolume().then((double? v) {
          varTouchInitSuc = true;
          setState(() {
            updateDargVarVal = v ?? 0;
          });
        });
      } else {
        // 亮度
        ScreenBrightness().current.then((double v) {
          varTouchInitSuc = true;
          setState(() {
            updateDargVarVal = v;
          });
        });
      }
    }

    void _onVerticalDragUpdate(DragUpdateDetails detills) {
      if (kIsWeb) return;
      if (!varTouchInitSuc) return null;
      double curDragDy = detills.globalPosition.dy;
      // 确定当前是前进或者后退
      int cdy = curDragDy.toInt();
      int pdy = updatePrevDy.toInt();
      bool isBefore = cdy < pdy;
      // + -, 不满足, 上下滑动合法滑动值，> 3
      if (isBefore && pdy - cdy < 3 || !isBefore && cdy - pdy < 3) return null;
      // 区间
      double dragRange =
          isBefore ? updateDargVarVal + 0.03 : updateDargVarVal - 0.03;
      // 是否溢出
      if (dragRange > 1) {
        dragRange = 1.0;
      }
      if (dragRange < 0) {
        dragRange = 0.0;
      }
      setState(() {
        updatePrevDy = curDragDy;
        varTouchInitSuc = true;
        updateDargVarVal = dragRange;
        // 音量
        if (!isDargVerLeft) {
          FlutterVolumeController.setVolume(dragRange);
        } else {
          ScreenBrightness().setScreenBrightness(dragRange);
        }
      });
    }

    void _onVerticalDragEnd(DragEndDetails detills) {
      if (kIsWeb) return;
      setState(() {
        varTouchInitSuc = false;
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Stack(
        children: <Widget>[
          Center(
            child: _buildDargProgressTime(),
          ),
          Center(
            child: _buildDargVolumeAndBrightness(),
          ),
          _isTouch ? Container() : widget.child ?? Container(),
        ],
      ),
    );
  }
}
