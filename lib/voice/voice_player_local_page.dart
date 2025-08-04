// ignore_for_file: prefer_if_null_operators

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/input_container.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/shelf_proxy.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/voice/voice_player_manager.dart';
import 'package:deepseek/voice/widgets/voice_player_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:convert';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/community/community_post_review.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:video_player/video_player.dart';

class VoicePlayerLocalPage extends BaseWidget {
  VoicePlayerLocalPage({Key? key, this.data}) : super(key: key);
  dynamic data;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _VoicePlayerLocalPageState();
  }
}

class _VoicePlayerLocalPageState extends BaseWidgetState<VoicePlayerLocalPage>
    with TickerProviderStateMixin, RouteAware {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;

  late Animation<double> recordAnimation;
  late AnimationController recordController;

  //进度条缓冲区
  Duration buffered = const Duration(seconds: 0);
  Duration total = const Duration(seconds: 0);
  bool isErr = false;

  VideoPlayerController? audioController; //播放器控制器

  //播放器是否初始化
  ValueNotifier<bool> isInit = ValueNotifier(false);

  //是否播放状态
  ValueNotifier<bool> isPlay = ValueNotifier(false);

  //进度
  ValueNotifier<Duration> progress =
      ValueNotifier<Duration>(const Duration(seconds: 0));

  void getData() async {
    // dynamic res = await reqGameDetail(id: widget.id);
  }
  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate

    // 订阅播放完毕后自动切换音频后刷新界面
    // _subscription = eventBus.on<MyEvent>().listen((event) {
    //   debugPrint('Received event: ${event.message}');
    //   if (event.message == 'RefreshVoicePayerUI') {
    //     widget.data = VoicePlayerManager.instance.data;
    //     setState(() {});
    //   }
    // });

    //圆盘动画
    recordController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    recordAnimation = Tween<double>(begin: 0, end: 1).animate(recordController);

    //添加监听器来响应isPlay值的变化
    isPlay.addListener(_isPlayerListen);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initVideoPlayer(widget.data);
    });
  }

  Future<void> initVideoPlayer(dynamic model) async {
    LoadStatus.showLoading(mounted);

    String url = model['url'] ?? '';

    createStaticServer(url).then((value) {
      audioController = VideoPlayerController.network(value)
        ..setLooping(true)
        ..initialize().then((_) {
          isInit.value = true;
          total = audioController?.value.duration ?? const Duration(seconds: 0);
          audioController?.play();
          isPlay.value = true;

          LoadStatus.closeLoading();
          // MyToast.closeAllLoading();
          audioController?.addListener(addListenerAudio);
        }).onError((error, stackTrace) {
          LoadStatus.closeLoading();
          isErr = true;
          Utils.showText('初始化错误:$error');
        });
    });
  }

  addListenerAudio() {
    if (audioController == null || !audioController!.value.isInitialized) {
      return;
    }
    if (audioController!.value.buffered.isNotEmpty) {
      buffered = audioController!.value.buffered.last.end;
    }
    progress.value = audioController!.value.position;

    //有声播放完毕
    if (audioController!.value.position.inMilliseconds + 300 >=
        audioController!.value.duration.inMilliseconds) {
      // //播放完后自动从头播放
      // audioController!.seekTo(const Duration(milliseconds: 0));
      // audioController!.play();
      // isPlay.value = true;

      //播放完后自动从头暂停
      audioController!.seekTo(const Duration(milliseconds: 0));
      audioController!.pause();
      isPlay.value = false;
    }
  }

  _isPlayerListen() {
    if (mounted) {
      if (isPlay.value) {
        recordController.repeat();
      } else {
        recordController.stop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute<dynamic>? route = ModalRoute.of<dynamic>(context);
    if (route != null) {
      // //路由订阅
      // AppRouteObserver().routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    isPlay.removeListener(_isPlayerListen);
    audioController?.dispose();
    recordController.dispose();
    super.dispose();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy

    // isPlay.removeListener(_isPlayerListen);
    // audioController?.dispose();
    // recordController.dispose();
    // super.dispose();
  }

  //播放/暂停
  _togglePlay() {
    if (isPlay.value) {
      audioController?.pause();
      isPlay.value = false;
    } else {
      audioController?.play();
      isPlay.value = true;
    }
  }

  @override
  Widget pageBody(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: ImageNetTool(url: widget.data['big_cover'] ?? '')),
        Positioned.fill(
            child: Container(
          alignment: Alignment.center,
          // padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
          // child: ImageNetTool(url: widget.data['small_cover'] ?? ''),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.w, sigmaY: 12.w),
          ),
        )),
        Padding(
          padding: EdgeInsets.only(
              top: StyleTheme.topHeight + StyleTheme.navHegiht,
              left: 30.w,
              right: 30.w,
              bottom: 80.w),
          child: Column(
            children: [
              Expanded(
                child: Container(
                    padding: EdgeInsets.only(bottom: 60.w),
                    alignment: Alignment.center,
                    child: RotationTransition(
                        turns: recordAnimation,
                        child: SizedBox(
                          width: 345.w,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Positioned.fill(
                              //   child: Icon(Icons.circle,
                              //       size: 245.w, color: Colors.red),
                              // ),
                              // const MyImage.asset('appAsmrRecord,'
                              //     width: double.infinity),
                              Center(
                                child: LocalPNG(
                                    name: 'ai_voice_player_disk',
                                    width: 245.w,
                                    height: 245.w),
                              ),
                              Center(
                                  child: SizedBox(
                                width: 172.w,
                                height: 172.w,
                                child: ClipRRect(
                                    // clipBehavior: Clip.antiAliasWithSaveLayer,
                                    borderRadius: BorderRadius.circular(85.w),
                                    child: ImageNetTool(
                                        url: widget.data['small_cover'] ?? '')),
                              )),
                            ],
                          ),
                        ))),
              ),
              SizedBox(
                height: 44.w,
                child: ValueListenableBuilder(
                  valueListenable: progress,
                  builder: (context, Duration value, child) {
                    return ProgressBar(
                      timeLabelPadding: 5.w,
                      progress: value,
                      buffered: buffered,
                      total: total,
                      progressBarColor: Colors.white,
                      baseBarColor: Colors.white.withOpacity(0.24),
                      bufferedBarColor: Colors.white.withOpacity(0.24),
                      thumbColor: Colors.white,
                      barHeight: 3.0,
                      thumbRadius: 5.0,
                      timeLabelTextStyle: StyleTheme.font_white_255_14,
                      onSeek: (duration) {
                        if (isErr) {
                          Utils.showText('加载错误,请重试');
                          return;
                        }
                        if (!isInit.value) {
                          Utils.showText('正在等待音频加载完成');
                          return;
                        }
                        audioController?.seekTo(duration);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 25.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                      valueListenable: isPlay,
                      builder: (context, bool value, child) {
                        return _btnImgItem(
                            icon: value
                                ? 'ai_voice_player_pause'
                                : 'ai_voice_player_play',
                            width: 34.w,
                            height: 39.w,
                            onTap: () {
                              //播放/暂停
                              _togglePlay();
                            });
                      }),
                ],
              ),
            ],
          ),
        ),
        Utils.createNav(
          navColor: Colors.transparent,
          titleW: Text(widget.data['title'] ?? '',
              style: StyleTheme.font_white_255_16,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          left: GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              width: 40.w,
              height: 40.w,
              child: LocalPNG(
                name: "ai_nav_back_w",
                width: 17.w,
                height: 17.w,
                fit: BoxFit.contain,
              ),
            ),
            behavior: HitTestBehavior.translucent,
            onTap: () {
              finish();
            },
          ),
          right: GestureDetector(
            onTap: () {
              Utils.navTo(context, '/minesharepage');
            },
            child: Container(
              alignment: Alignment.centerRight,
              width: 40.w,
              height: 40.w,
              child: LocalPNG(
                name: "ai_voice_player_share",
                width: 17.w,
                height: 17.w,
                fit: BoxFit.contain,
              ),
            ),
            // lineColor: _lineColor,
          ),
        ),
      ],
    );
  }

  Widget _btnImgItem(
      {required String icon,
      required double width,
      required double height,
      Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: LocalPNG(name: icon, width: width, height: height),
    );
  }
}
