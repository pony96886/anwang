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
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/voice/voice_player_manager.dart';
import 'package:deepseek/voice/widgets/voice_player_sheet.dart';
import 'package:deepseek/voice/widgets/voice_player_time_sheet.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:convert';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/community/community_post_review.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class VoicePlayerPage extends BaseWidget {
  VoicePlayerPage({Key? key, this.data}) : super(key: key);
  dynamic data;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _VoicePlayerlPageState();
  }
}

class _VoicePlayerlPageState extends BaseWidgetState<VoicePlayerPage>
    with TickerProviderStateMixin, RouteAware {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;

  late Animation<double> recordAnimation;
  late AnimationController recordController;

  //点赞
  ValueNotifier<bool> isLike = ValueNotifier(false);

  //收藏
  ValueNotifier<bool> isFavorite = ValueNotifier(false);

  late StreamSubscription<MyEvent> _subscription;

  Timer? _secondTimer; //秒数 定时器

  void getData() async {}
  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    // 订阅播放完毕后自动切换音频后刷新界面
    _subscription = eventBus.on<MyEvent>().listen((event) {
      debugPrint('Received event: ${event.message}');
      if (event.message == 'RefreshVoicePayerUI') {
        widget.data = VoicePlayerManager.instance.data;
        setState(() {});
      }
    });

    //圆盘动画
    recordController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    recordAnimation = Tween<double>(begin: 0, end: 1).animate(recordController);

    if (widget.data != null) {
      isFavorite.value = (widget.data['is_favorite'] == 1);
      isLike.value = (widget.data['is_like'] == 1);

      if (VoicePlayerManager.instance.currentId == widget.data['id'] &&
          mounted) {
        //播放同一个ID音频数据时，直接播放即可
        VoicePlayerManager.instance.audioController?.play();
        //添加监听器来响应isPlay值的变化
        VoicePlayerManager.instance.isPlay.addListener(_isPlayerListen);
        VoicePlayerManager.instance.reportPlayVoice();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          recordController.repeat();
          VoicePlayerManager.instance.isPlay.value = true;

          if (VoicePlayerManager.instance.minutes != null) {
            VoicePlayerManager.instance.startTimer();
          }

          //如果数据是当前播放数据直接加入列表即可
          int index = VoicePlayerManager.instance.voices
              .indexWhere((model) => model['id'] == widget.data['id']);
          if (index == -1) {
            //防止重复添加
            VoicePlayerManager.instance.addVoiceList();
          }
        });
        return;
      }

      VoicePlayerManager.instance.initVideoPlayer(widget.data, context);
      //添加监听器来响应isPlay值的变化
      VoicePlayerManager.instance.isPlay.addListener(_isPlayerListen);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute<dynamic>? route = ModalRoute.of<dynamic>(context);
    if (route != null) {
      //路由订阅
      // AppRouteObserver().routeObserver.subscribe(this, route);
    }
  }

  _isPlayerListen() {
    if (mounted) {
      if (VoicePlayerManager.instance.isPlay.value) {
        recordController.repeat();
        if (VoicePlayerManager.instance.minutes != null) {
          VoicePlayerManager.instance.startTimer();
        }
      } else {
        recordController.stop();
      }
    }
  }

  /// 当前的页面被push显示到用户面前 viewWillAppear.
  @override
  void didPush() {
    Utils.setStatusBar(isLight: true);
    VoicePlayerManager.instance.removeFloatPayer();
  }

  /// 当前的页面被pop viewWillDisappear.
  @override
  void didPop() {
    if (VoicePlayerManager.instance.isPlay.value) {
      VoicePlayerManager.instance.showFloatPayer();
    } else {
      VoicePlayerManager.instance.disposes();
    }
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    // _subscription.cancel(); // 取消订阅
    // recordController.dispose();
    // isLike.dispose();
    // isFavorite.dispose();
    // VoicePlayerManager.instance.isPlay.removeListener(_isPlayerListen);
  }

  @override
  void dispose() {
    Utils.setStatusBar(isLight: false);
    _subscription.cancel(); // 取消订阅
    recordController.dispose();
    isLike.dispose();
    isFavorite.dispose();
    VoicePlayerManager.instance.isPlay.removeListener(_isPlayerListen);
    super.dispose();
  }

  //播放/暂停
  _togglePlay() {
    if (VoicePlayerManager.instance.isErr) {
      VoicePlayerManager.instance.initVideoPlayer(widget.data, context);
      return;
    }
    if (VoicePlayerManager.instance.isPlay.value) {
      VoicePlayerManager.instance.audioController?.pause();
      VoicePlayerManager.instance.isPlay.value = false;
    } else {
      VoicePlayerManager.instance.audioController?.play();
      VoicePlayerManager.instance.isPlay.value = true;
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
              kIsWeb
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder(
                            valueListenable: isLike,
                            builder: (context, bool value, child) {
                              return _btnItem(
                                  icon: value
                                      ? 'ai_voice_player_like_on'
                                      : 'ai_voice_player_like_off',
                                  name: Utils.txt('danzan'),
                                  onTap: () {
                                    //点赞
                                    likeVoice();
                                  });
                            }),
                        ValueListenableBuilder(
                            valueListenable: isFavorite,
                            builder: (context, bool value, child) {
                              return _btnItem(
                                  icon: value
                                      ? 'ai_voice_player_list_favorite_on'
                                      : 'ai_voice_player_list_favorite_off',
                                  name: Utils.txt('socang'),
                                  onTap: () {
                                    //收藏
                                    collectionVoice();
                                  });
                            }),
                        _btnItem(
                            icon: 'ai_voice_player_timer',
                            name: Utils.txt('ds'),
                            onTap: () {
                              //定时
                              showAudioPlayerTimeSheet();
                            }),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder(
                            valueListenable: isLike,
                            builder: (context, bool value, child) {
                              return _btnItem(
                                  icon: value
                                      ? 'ai_voice_player_like_on'
                                      : 'ai_voice_player_like_off',
                                  name: Utils.txt('danzan'),
                                  onTap: () {
                                    //点赞
                                    likeVoice();
                                  });
                            }),
                        ValueListenableBuilder(
                            valueListenable: isFavorite,
                            builder: (context, bool value, child) {
                              return _btnItem(
                                  icon: value
                                      ? 'ai_voice_player_list_favorite_on'
                                      : 'ai_voice_player_list_favorite_off',
                                  name: Utils.txt('socang'),
                                  onTap: () {
                                    //收藏
                                    collectionVoice();
                                  });
                            }),
                        kIsWeb
                            ? Container()
                            : _btnItem(
                                icon: 'ai_voice_player_download',
                                name: Utils.txt('xiazi'),
                                onTap: () {
                                  //下载
                                  VoicePlayerManager.instance.downVoice();
                                }),
                        _btnItem(
                            icon: 'ai_voice_player_timer',
                            name: Utils.txt('ds'),
                            onTap: () {
                              //定时
                              showAudioPlayerTimeSheet();
                            }),
                      ],
                    ),
              SizedBox(height: 20.w),
              SizedBox(
                height: 44.w,
                child: ValueListenableBuilder(
                  valueListenable: VoicePlayerManager.instance.progress,
                  builder: (context, Duration value, child) {
                    return ProgressBar(
                      timeLabelPadding: 5.w,
                      progress: value,
                      buffered: VoicePlayerManager.instance.buffered,
                      total: VoicePlayerManager.instance.total,
                      progressBarColor: Colors.white,
                      baseBarColor: Colors.white.withOpacity(0.24),
                      bufferedBarColor: Colors.white.withOpacity(0.24),
                      thumbColor: Colors.white,
                      barHeight: 3.0,
                      thumbRadius: 5.0,
                      timeLabelTextStyle: StyleTheme.font_white_255_14,
                      onSeek: (duration) {
                        if (VoicePlayerManager.instance.isErr) {
                          Utils.showText('加载错误,请重试');
                          return;
                        }
                        if (!VoicePlayerManager.instance.isInit.value) {
                          Utils.showText('正在等待音频加载完成');
                          return;
                        }
                        VoicePlayerManager.instance.audioController
                            ?.seekTo(duration);
                      },
                    );
                  },
                ),
              ),
              // SizedBox(height: 25.w),
              _countDownWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder(
                      valueListenable: VoicePlayerManager.instance.isCircuit,
                      builder: (context, bool value, child) {
                        return _btnImgItem(
                            icon: value
                                ? 'ai_voice_player_loop'
                                : 'ai_voice_player_random',
                            width: 25.w,
                            height: 20.w,
                            onTap: () {
                              //循环/随机播放
                              VoicePlayerManager.instance.isCircuit.value =
                                  !VoicePlayerManager.instance.isCircuit.value;
                            });
                      }),
                  _btnImgItem(
                      icon: 'ai_voice_player_previous',
                      width: 16.w,
                      height: 18.w,
                      onTap: () {
                        //上一首
                        VoicePlayerManager.instance.preVoice(isClicke: true);
                      }),
                  ValueListenableBuilder(
                      valueListenable: VoicePlayerManager.instance.isPlay,
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
                  _btnImgItem(
                      icon: 'ai_voice_player_next',
                      width: 16.w,
                      height: 18.w,
                      onTap: () {
                        //下一首
                        VoicePlayerManager.instance.nextVoice(isClicke: true);
                      }),
                  _btnImgItem(
                      icon: 'ai_voice_player_list',
                      width: 20.w,
                      height: 18.w,
                      onTap: () {
                        //播放列表
                        showAudioPlayerSheet();
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
                name: "ai_nav_back",
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
        // Positioned(
        //   top: StyleTheme.topHeight,
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
        //     child: Row(
        //       children: [],
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget _countDownWidget() {
    if (VoicePlayerManager.instance.minutes != null) {
      if (_secondTimer == null) {
        _secondTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {});
          }
        });
      }

      int remainSeconds = VoicePlayerManager.instance.remainSeconds;

      String minutNumString = (remainSeconds / 60).floor().toStringAsFixed(0);
      int secondNum = remainSeconds % 60;

      NumberFormat formatter = NumberFormat('00');
      String secondString = formatter.format(secondNum);

      return Container(
        height: 25.w,
        child: Text(
          Utils.txt('djs') + ' $minutNumString:$secondString',
          style: StyleTheme.font_black_7716_04_13,
        ),
      );
    }

    if (_secondTimer != null) {
      _secondTimer?.cancel();
      _secondTimer = null;
    }
    return Container(height: 25.w);
  }

  Widget _btnItem(
      {required String icon, required String name, Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(Icons.circle, size: 50.w, color: Colors.white),

          LocalPNG(name: icon, width: 27.w, height: 23.w),
          // MyImage.asset(
          //   icon,
          //   width: 27.w,
          //   height: 23.w,
          // ),
          SizedBox(height: 6.w),
          Text(
            name,
            style: StyleTheme.font_white_255_11,
          )
        ],
      ),
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

  //点赞
  Future<void> likeVoice() async {
    final res = await reqUserLike(id: widget.data['id'] ?? 0, type: 19);

    if (res?.status == 1) {
      widget.data?['is_like'] = res?.data['is_like'];
      isLike.value = (widget.data?['is_like'] == 1);
      VoicePlayerManager.instance.data?['is_like'] = widget.data?['is_like'];

      //更新播放列表中对应位置数据收藏状态
      var list = VoicePlayerManager.instance.voices;
      int index = list.indexWhere((model) => model['id'] == widget.data['id']);
      if (index != -1) {
        var model = list[index];
        model['is_like'] = widget.data?['is_like'];
      }
    } else if (res?.msg case final msg!) {
      Utils.showText(msg);
    }
  }

  //收藏
  Future<void> collectionVoice() async {
    final res = await reqUserFavorite(id: widget.data['id'] ?? 0, type: 19);

    if (res?.status == 1) {
      widget.data?['is_favorite'] = res?.data['is_favorite'];
      isFavorite.value = (widget.data?['is_favorite'] == 1);
      VoicePlayerManager.instance.data?['is_favorite'] =
          widget.data?['is_favorite'];

      //更新播放列表中对应位置数据收藏状态
      var list = VoicePlayerManager.instance.voices;
      int index = list.indexWhere((model) => model['id'] == widget.data['id']);
      if (index != -1) {
        var model = list[index];
        model['is_favorite'] = widget.data?['is_favorite'];
      }
    } else if (res?.msg case final msg!) {
      Utils.showText(msg);
    }
  }

  showAudioPlayerSheet() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          // return Container();
          return VoicePlayerSheet(complete: () {
            //播放列表切换播放成功后刷新界面
            widget.data = VoicePlayerManager.instance.data;
            isFavorite.value = (widget.data?['is_favorite'] == 1);
            setState(() {});
          });
        });
  }

  showAudioPlayerTimeSheet() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          // return Container();

          return const VoicePlayerTimeSheet();
        });
  }
}
