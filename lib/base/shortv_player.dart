// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/nvideourl_minxin.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/vlog/vlog_hot_page.dart';
import 'package:deepseek/voice/voice_player_manager.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:universal_html/html.dart' as html;

class ShortVPlayer extends StatefulWidget {
  ShortVPlayer({
    Key? key,
    this.info,
    this.keepBottomBlank = false,
  }) : super(key: key);

  final Map<String, dynamic>? info;
  final bool keepBottomBlank; // 底部要不要留白
  @override
  State<ShortVPlayer> createState() => _ShortVPlayerState();
}

class _ShortVPlayerState extends State<ShortVPlayer> with NVideoURLMinxin {
  FlickManager? flickManager;
  bool opened = true;
  bool isPreview = false;
  bool isDone = false;
  bool isLocal = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initURL();
  }

  initURL() async {
    if (widget.info == null) return;
    isLocal = widget.info?["isLocal"] == 1 ? true : false;
    String source_240 = widget.info?['source_240'] ?? '';
    String preview_url = widget.info?['preview_url'] ?? '';
    VideoPlayerController? cr;
    if (source_240.isNotEmpty) {
      isPreview = false;
      cr = await initController(source240: source_240, isLocal: isLocal);
    } else {
      isPreview = true;
      cr = await initController(source240: preview_url, isLocal: isLocal);
    }
    if (cr == null) return;
    flickManager = FlickManager(
        videoPlayerController: cr,
        autoPlay: !kIsWeb,
        onVideoEnd: () {
          isDone = true;
          setState(() {});
        });
    if (mounted) setState(() {});

    if (VoicePlayerManager.instance.audioController != null) {
      VoicePlayerManager.instance.audioController?.pause();
      VoicePlayerManager.instance.isPlay.value = false;
      VoicePlayerManager.instance.removeFloatPayer();
      VoicePlayerManager.instance.disposes();
    }
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return flickManager == null
        ? Container()
        : VisibilityDetector(
            key: ObjectKey(flickManager),
            onVisibilityChanged: (visibility) {
              if (visibility.visibleFraction == 0 && mounted) {
                flickManager?.flickControlManager?.autoPause();
              } else if (visibility.visibleFraction == 1) {
                flickManager?.flickControlManager?.autoResume();
              }
            },
            child: FlickVideoPlayer(
              flickManager: flickManager!,
              flickVideoWithControls: FlickVideoWithControls(
                videoFit: BoxFit.contain,
                playerErrorFallback: Container(),
                playerLoadingFallback: Stack(
                  children: [
                    Positioned.fill(
                      child: ImageNetTool(
                          url: Utils.getPICURL(widget.info),
                          fit: BoxFit.contain),
                    ),
                    Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.grey[400],
                          valueColor: AlwaysStoppedAnimation(
                            StyleTheme.blue52Color,
                          ),
                          strokeWidth: 1.5,
                        ),
                      ),
                    )
                  ],
                ),
                controls: SinkPortraitWidget(
                  flickManager: flickManager!,
                  isBack: true,
                  isDone: isDone,
                  info: widget.info,
                  isPreview: isPreview,
                  skiPreview: () {
                    showAlertVp();
                  },
                  likeAct: () {
                    likeVideoRes();
                  },
                  collectAct: () {
                    collectVideoRes();
                  },
                  commentAct: () {
                    showMoreVideoComment(
                        context: context, data: widget.info?['id']);
                  },
                  followAct: () {
                    followUserRes();
                  },
                  enterUserCenterAct: () {
                    if (widget.info?["member"] != null) {
                      Utils.navTo(context,
                          '/mineotherusercenter/${widget.info?["member"]["aff"]}');
                    }
                  },
                  keepBottomBlank: widget.keepBottomBlank,
                ),
              ),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                playerErrorFallback: Container(),
                videoFit: BoxFit.contain,
                controls: SinkPortraitWidget(
                  flickManager: flickManager!,
                  info: widget.info,
                ),
              ),
            ),
          );
  }

  showMoreVideoComment({required BuildContext context, dynamic data}) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (ctx, setBottomSheetState) {
            return ShortVideoCommontPage(
                id: data,
                onClose: () {
                  Navigator.pop(ctx);
                  // setBottomSheetState() {}
                });
          });
        });
  }

  void showAlertVp({bool goby = false}) {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    if (user == null) return;
    int money = user.money ?? 0;
    int needmoney = widget.info?['coins'] ?? 0;
    bool isInsufficient = money < needmoney;
    if (goby && !isInsufficient) {
      byVideoRes(money - needmoney); //直接购买
      return;
    }
    if (widget.info?['isfree'] == 2) {
      Utils.showDialog(
          cancelTxt: Utils.txt('quxao'),
          confirmTxt: isInsufficient ? Utils.txt('qwcz') : Utils.txt('gmgk'),
          setContent: () {
            return Column(
              children: [
                Text(Utils.txt('gmspkwz'),
                    style: StyleTheme.font_gray_153_13, maxLines: 3),
                SizedBox(height: 15.w),
                Text("$needmoney" + Utils.txt('jinb'),
                    style: StyleTheme.font_yellow_255_13,
                    textAlign: TextAlign.center),
                SizedBox(height: 15.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(Utils.txt('ktvpzk') + "：$money",
                        style: StyleTheme.font_gray_153_13),
                  ],
                ),
              ],
            );
          },
          confirm: () {
            if (isInsufficient) {
              Utils.navTo(context, "/minegoldcenterpage");
            } else {
              byVideoRes(money - needmoney); //直接购买
            }
          });
    } else {
      Utils.showDialog(
          cancelTxt: Utils.txt('quxao'),
          confirmTxt: Utils.txt('czvip'),
          setContent: () {
            return Text(Utils.txt('gmvkwz'),
                style: StyleTheme.font_gray_153_13);
          },
          confirm: () {
            Utils.navTo(context, "/minevippage");
          });
    }
  }

  void byVideoRes(int money) {
    Utils.startGif(tip: Utils.txt("gmzz"));
    reqBuyVlog(id: widget.info?['id'] ?? 0, money: money, context: context)
        .then((value) {
      //关闭加载动画
      Utils.closeGif();
      if (value?.status == 1) {
        widget.info?['source_240'] = value?.data["url"] ?? '';
        initURL();
      } else {
        Utils.showText(value?.msg ?? '');
      }
    });
  }

  likeVideoRes() {
    reqUserLike(id: widget.info?['id'] ?? 0, type: 11).then((value) {
      if (value?.status == 1) {
        // initURL();
        widget.info?['is_like'] = value?.data['is_like'];

        int count = widget.info?['count_like'];
        count = widget.info?['is_like'] == 1 ? count + 1 : count - 1;
        widget.info?['count_like'] = max(count, 0);
        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? '');
      }
    });
  }

  collectVideoRes() {
    reqUserFavorite(id: widget.info?['id'] ?? 0, type: 11).then((value) {
      if (value?.status == 1) {
        // initURL();
        widget.info?['is_favorite'] = value?.data['is_favorite'];

        int count = widget.info?['favorites'];
        count = widget.info?['is_favorite'] == 1 ? count + 1 : count - 1;
        widget.info?['favorites'] = max(count, 0);
        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? '');
      }
    });
  }

  followUserRes() {
    reqFollowUser(aff: '${widget.info?['member']?['aff']}').then((value) {
      if (value?.status == 1) {
        // initURL();
        widget.info?['member']?['is_follow'] =
            widget.info?['member']?['is_follow'] == 1 ? 0 : 1;

        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? '');
      }
    });
  }
}

//竖屏
// class SinkPortraitWidget extends StatefulWidget {
//   SinkPortraitWidget({
//     Key? key,
//     this.isBack = false,
//     this.isPreview = false,
//     this.isDone = false,
//     this.info,
//     this.skiPreview,
//     this.shareVp,
//     this.nowToVp,
//     this.nowByKb,
//     this.closeBarrage,
//   }) : super(key: key);
//   final bool isBack;
//   final bool isPreview;
//   final bool isDone;
//   final Map? info;
//   final Function? skiPreview; //跳过预览
//   final Function? shareVp; //分享得VIP
//   final Function? nowToVp; //立即开通
//   final Function? nowByKb; //钻石购买
//   final Function(bool)? closeBarrage;
//   State<SinkPortraitWidget> createState() => _SinkPortraitWidgetState();
// }

// class _SinkPortraitWidgetState extends State<SinkPortraitWidget> {
//   double _speed = 1.0;
//   Map<String, double> speedList = {
//     "2.0": 2.0,
//     "1.8": 1.8,
//     "1.5": 1.5,
//     "1.2": 1.2,
//     "1.0": 1.0,
//   };
//   bool _hideSpeedStu = true;
//   bool _openBarrage = true;

//   @override
//   void initState() {
//     super.initState();
//   }

//   // build 倍数列表
//   List<Widget> _buildSpeedListWidget() {
//     FlickVideoManager flickVideoManager =
//         Provider.of<FlickVideoManager>(context);
//     List<Widget> columnChild = [];
//     speedList.forEach((String mapKey, double speedVals) {
//       columnChild.add(
//         Ink(
//           child: InkWell(
//             onTap: () {
//               if (_speed == speedVals) return;
//               _speed = speedVals;
//               _hideSpeedStu = true;
//               flickVideoManager.videoPlayerController?.setPlaybackSpeed(_speed);
//               setState(() {});
//             },
//             child: Container(
//               alignment: Alignment.center,
//               width: 50,
//               height: 30,
//               child: Text(
//                 "$mapKey X",
//                 style: TextStyle(
//                   color: _speed == speedVals
//                       ? const StyleTheme.blue52Color
//                       : Colors.white,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//       columnChild.add(
//         Padding(
//           padding: const EdgeInsets.only(top: 5, bottom: 5),
//           child: Container(
//             width: 50,
//             height: 1,
//             color: Colors.white54,
//           ),
//         ),
//       );
//     });
//     columnChild.removeAt(columnChild.length - 1);
//     return columnChild;
//   }

//   Widget _noConditionWidget(context) {
//     FlickVideoManager flickVideoManager =
//         Provider.of<FlickVideoManager>(context);
//     FlickControlManager controlManager =
//         Provider.of<FlickControlManager>(context);
//     FlickDisplayManager flickDisplayManager =
//         Provider.of<FlickDisplayManager>(context);
//     bool flag = (flickVideoManager.videoPlayerValue!.isBuffering &&
//             flickVideoManager.videoPlayerValue!.isPlaying) ||
//         !flickVideoManager.videoPlayerValue!.isInitialized;
//     double rate = flickVideoManager.videoPlayerValue?.aspectRatio ?? 0.0;
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: FlickShowControlsAction(
//             child: FlickSeekVideoAction(
//               duration: const Duration(seconds: 60),
//               child: Center(
//                 child: flag
//                     ? Center(
//                         child: SizedBox(
//                           height: 40,
//                           width: 40,
//                           child: CircularProgressIndicator(
//                             backgroundColor: Colors.grey[400],
//                             valueColor:
//                                 const AlwaysStoppedAnimation(StyleTheme.blue52Color),
//                             strokeWidth: 1.5,
//                           ),
//                         ),
//                       )
//                     : FlickAutoHideChild(
//                         showIfVideoNotInitialized: false,
//                         child: FlickPlayToggle(
//                           replayChild: LocalPNG(
//                             name: "ai_replay_n",
//                             width: 40,
//                             height: 40,
//                           ),
//                           playChild: LocalPNG(
//                             name: "ai_play_n",
//                             width: 40,
//                             height: 40,
//                           ),
//                           pauseChild: LocalPNG(
//                             name: "ai_pause_n",
//                             width: 40,
//                             height: 40,
//                           ),
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ),
//         FlickAutoHideChild(
//           child: Stack(
//             children: [
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: IgnorePointer(
//                   child: Container(
//                     height: 55,
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Color.fromRGBO(0, 0, 0, 0.0),
//                           Color.fromRGBO(0, 0, 0, 0.1),
//                           Color.fromRGBO(0, 0, 0, 0.3),
//                           Color.fromRGBO(0, 0, 0, 0.9),
//                         ],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: StyleTheme.margin,
//                 right: StyleTheme.margin,
//                 bottom: 15,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 5),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: const [
//                             FlickCurrentPosition(
//                               color: Colors.white,
//                               fontSize: 16,
//                             ),
//                             Text(
//                               ' / ',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                             FlickTotalDuration(
//                               color: Colors.white,
//                               fontSize: 16,
//                             )
//                           ],
//                         ),
//                         const Spacer(),
//                         Row(
//                           children: [
//                             widget.info?["isSpeed"] == 1
//                                 ? FlickSetPlayBack(
//                                     speed: _speed,
//                                     setPlayBack: () {
//                                       _hideSpeedStu = !_hideSpeedStu;
//                                       setState(() {});
//                                     },
//                                     playBackChild: Text(
//                                       "${_speed == 1.0 ? '1.0' : _speed == 2.0 ? '2.0' : _speed} X",
//                                       style: const TextStyle(
//                                           color: Colors.white, fontSize: 16),
//                                     ),
//                                   )
//                                 : Container(),
//                             rate > 1 || kIsWeb && !widget.isPreview
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(left: 10),
//                                     child: FlickFullScreenToggle(
//                                       enterFullScreenChild: const Icon(
//                                           Icons.fullscreen,
//                                           size: 25,
//                                           color: Colors.white),
//                                       exitFullScreenChild: const Icon(
//                                           Icons.fullscreen_exit,
//                                           size: 25,
//                                           color: Colors.white),
//                                       toggleFullscreen: () {
//                                         if (kIsWeb) {
//                                           html.VideoElement video = html
//                                                   .document
//                                                   .querySelector('video')
//                                               as html.VideoElement;
//                                           video.muted = false;
//                                           video.volume = 1;
//                                           video.setAttribute(
//                                               'playsinline', 'true');
//                                           video.setAttribute(
//                                               'autoplay', 'true');
//                                           if (html.document.fullscreenElement ==
//                                               null) {
//                                             video.enterFullscreen();
//                                           } else {
//                                             html.document.exitFullscreen();
//                                           }
//                                         } else {
//                                           controlManager.toggleFullscreen();
//                                         }
//                                       },
//                                     ),
//                                   )
//                                 : Container()
//                           ],
//                         )
//                       ],
//                     ),
//                     !flickVideoManager.videoPlayerValue!.isInitialized ||
//                             flickDisplayManager.showPlayerControls
//                         ? FlickVideoProgressBar(
//                             flickProgressBarSettings: FlickProgressBarSettings(
//                               padding: const EdgeInsets.only(top: 10),
//                               height: 3,
//                               handleRadius: 6,
//                               curveRadius: 4,
//                               backgroundColor: Colors.white24,
//                               bufferedColor:
//                                   const StyleTheme.blue52Color.withOpacity(0.38),
//                               playedColor: const StyleTheme.blue52Color,
//                               handleColor: const StyleTheme.blue52Color,
//                             ),
//                           )
//                         : Container(),
//                   ],
//                 ),
//               ),
//               widget.isPreview
//                   ? Positioned(
//                       right: 0,
//                       bottom: 30,
//                       child: GestureDetector(
//                         behavior: HitTestBehavior.translucent,
//                         onTap: () {
//                           widget.skiPreview?.call();
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8),
//                           height: 30,
//                           decoration: BoxDecoration(
//                             gradient: StyleTheme.gradBlue,
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(15),
//                               bottomLeft: Radius.circular(15),
//                             ),
//                           ),
//                           child: Center(
//                             child: Text.rich(
//                               TextSpan(
//                                   text: widget.info?['isfree'] == 2
//                                       ? "${widget.info?['coins'] ?? 0}${Utils.txt("kbtgyl")}"
//                                       : Utils.txt("ktvptgyl"),
//                                   style: StyleTheme.font_white_255_12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                   : Container(),
//               // 倍数选择
//               Positioned(
//                 right: controlManager.isFullscreen == false
//                     ? (rate > 1 ? 39 : 3)
//                     : (rate > 1 ? 50 : 3),
//                 bottom: 55,
//                 child: !_hideSpeedStu
//                     ? FlickAutoHideChild(
//                         child: Container(
//                           child: Padding(
//                             padding: const EdgeInsets.all(5),
//                             child: Column(
//                               children: _buildSpeedListWidget(),
//                             ),
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black45,
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         ),
//                       )
//                     : Container(),
//               ),
//             ],
//           ),
//         ),
//         !widget.isBack
//             ? Container()
//             : Positioned(
//                 top: 0,
//                 left: 2,
//                 child: GestureDetector(
//                   behavior: HitTestBehavior.translucent,
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color.fromRGBO(0, 0, 0, 0.1),
//                           offset: Offset(0, 0),
//                           spreadRadius: 5,
//                           blurRadius: 5,
//                         )
//                       ],
//                     ),
//                     alignment: Alignment.center,
//                     child: LocalPNG(
//                       name: "ai_nav_back_w",
//                       width: 18,
//                       height: 18,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                   onTap: () {
//                     if (widget.isBack) {
//                       AppGlobal.appRouter?.pop();
//                     } else {
//                       controlManager.toggleFullscreen();
//                     }
//                   },
//                 ),
//               ),
//       ],
//     );
//   }

//   Widget _conditionWidget(BuildContext context) {
//     Widget dgt = Container();
//     var vflag = false;
//     UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
//     if (user == null) return dgt;
//     if (user.vip_level! < 1 && widget.info?['isfree'] == 1) {
//       //需要VIP
//       dgt = Text(Utils.txt('kvbw'),
//           style: StyleTheme.font_white_255_14, maxLines: 2);
//       vflag = false;
//     } else if (widget.info?['isfree'] == 2) {
//       dgt = DefaultTextStyle(
//         style: StyleTheme.font_white_255_14,
//         child: Text.rich(
//           TextSpan(children: [
//             TextSpan(
//                 text: "${widget.info?['coins'] ?? 0}",
//                 style: StyleTheme.font_blue52_14),
//             TextSpan(text: Utils.txt('jbjsw') + "，"),
//             TextSpan(text: Utils.txt('ktvpzk') + "${user.money}")
//           ]),
//         ),
//       );
//       vflag = true;
//     }
//     return Container(
//       color: Colors.black87,
//       child: Column(children: [
//         !widget.isBack
//             ? Container()
//             : Padding(
//                 padding: EdgeInsets.all(8.w),
//                 child: Container(
//                   alignment: Alignment.centerLeft,
//                   height: 22,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 22,
//                         height: 22,
//                         decoration: const BoxDecoration(
//                           boxShadow: [
//                             BoxShadow(
//                                 color: Color.fromRGBO(0, 0, 0, 0.2),
//                                 offset: Offset(0, 0),
//                                 blurRadius: 11)
//                           ],
//                         ),
//                         alignment: Alignment.center,
//                         child: GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           child: LocalPNG(
//                             name: "ai_nav_back_w",
//                             width: 18,
//                             height: 18,
//                             fit: BoxFit.contain,
//                           ),
//                           onTap: () {
//                             AppGlobal.appRouter?.pop();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//         Padding(
//           padding: const EdgeInsets.only(
//             top: 20,
//             left: 50,
//             right: 50,
//           ),
//           child: Column(
//             children: [
//               Text(Utils.txt("skjs"), style: StyleTheme.font_white_255_14),
//               const SizedBox(height: 10),
//               dgt,
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(
//             top: 16,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: () {
//                   if (vflag) {
//                     widget.nowByKb?.call();
//                   } else {
//                     widget.nowToVp?.call();
//                   }
//                 },
//                 child: Container(
//                   height: 32,
//                   width: 110,
//                   decoration: BoxDecoration(
//                     gradient: StyleTheme.gradBlue,
//                     borderRadius: const BorderRadius.all(Radius.circular(3)),
//                   ),
//                   child: Center(
//                     child: Text(vflag ? Utils.txt("gmgk") : Utils.txt("ljkv"),
//                         style: StyleTheme.font_white_255_12),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 37),
//               GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: () {
//                   widget.shareVp?.call();
//                 },
//                 child: Container(
//                   height: 32,
//                   width: 110,
//                   decoration: BoxDecoration(
//                     gradient: StyleTheme.gradBlue,
//                     borderRadius: const BorderRadius.all(Radius.circular(3)),
//                   ),
//                   child: Center(
//                     child: Text(Utils.txt("yqfxdvp"),
//                         style: StyleTheme.font_white_255_12),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         )
//       ]),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.isDone && widget.isPreview
//         ? _conditionWidget(context)
//         : _noConditionWidget(context);
//   }
// }

class SinkPortraitWidget extends StatefulWidget {
  const SinkPortraitWidget({
    Key? key,
    this.flickManager,
    this.isBack = false,
    this.isPreview = false,
    this.isDone = false,
    this.info,
    this.skiPreview,
    this.likeAct,
    this.collectAct,
    this.commentAct,
    this.followAct,
    this.enterUserCenterAct,
    this.keepBottomBlank = false,
  }) : super(key: key);
  final FlickManager? flickManager;
  final bool isBack;
  final bool isPreview;
  final bool isDone;
  final Map? info;
  final Function? skiPreview; //跳过预览
  final Function? likeAct; //点赞
  final Function? collectAct; //收藏
  final Function? commentAct; //评论
  final Function? followAct; //关注
  final Function? enterUserCenterAct; //
  final bool keepBottomBlank;

  @override
  State<SinkPortraitWidget> createState() => _SinkPortraitWidgetState();
}

class _SinkPortraitWidgetState extends State<SinkPortraitWidget> {
  FlickManager? get flickManager => widget.flickManager;

  Duration _duration = const Duration();
  Duration _currentPos = const Duration();
  // 滑动后值
  Duration _dargPos = const Duration();
  double updatePrevDx = 0.0;
  int updatePosX = 0;

  bool _isTouch = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  _onHorizontalDragStart(DragStartDetails details) {
    _currentPos = flickManager?.flickVideoManager?.videoPlayerValue?.position ??
        const Duration(seconds: 0);
    _duration = flickManager?.flickVideoManager?.videoPlayerValue?.duration ??
        const Duration(seconds: 0);

    setState(() {
      updatePrevDx = details.globalPosition.dx;
      updatePosX = _currentPos.inMilliseconds;
    });
  }

  _onHorizontalDragUpdate(DragUpdateDetails details) {
    double curDragDx = details.globalPosition.dx;
    // 确定当前是前进或者后退
    int cdx = curDragDx.toInt();
    int pdx = updatePrevDx.toInt();
    bool isBefore = cdx > pdx;

    // 计算手指滑动的比例
    int newInterval = pdx - cdx;
    double playerW = ScreenUtil().scaleWidth;
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
    //
    setState(() {
      _isTouch = true;
      // 更新下上一次存的滑动位置
      updatePrevDx = curDragDx;
      // 更新时间
      updatePosX = dragRange.toInt();
      _dargPos = Duration(milliseconds: updatePosX.toInt());
    });
  }

  _onHorizontalDragEnd(DragEndDetails details) {
    flickManager?.flickControlManager?.seekTo(_dargPos);
    setState(() {
      _isTouch = false;
      _currentPos = _dargPos;
    });
  }

  Widget _buildDargProgressTime() {
    return _isTouch
        ? Container(
            height: 40,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                '${_duration2String(_dargPos)}  /  ${_duration2String(_duration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          )
        : Container();
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

  Widget _buildLinearProgress() {
    return _isTouch
        ? Container(
            height: 10.0.w,
            alignment: Alignment.bottomCenter,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: LinearProgressIndicator(
                minHeight: 10.0.w,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(StyleTheme.blue52Color),
                value: _dargPos.inMilliseconds / _duration.inMilliseconds,
              ),
            ),
          )
        : Container();
  }

  Widget _buildGestureDetector() {
    if (!flickManager!.flickVideoManager!.videoPlayerValue!.isInitialized) {
      return Container();
    }
    return Positioned(
      right: 0,
      left: 0,
      bottom: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SizedBox(
          height: 60.w,
          child: Column(
            children: <Widget>[
              _buildDargProgressTime(),
              const Spacer(),
              _buildLinearProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    return !_isTouch
        ? Utils.contentWidget(context, widget.info, showAlert: () {
            widget.skiPreview?.call();
          }, like: () {
            widget.likeAct?.call();
          }, collect: () {
            widget.collectAct?.call();
          }, comment: () {
            widget.commentAct?.call();
          }, follow: () {
            widget.followAct?.call();
          }, enterUserCenter: () {
            widget.enterUserCenterAct?.call();
          }, keepBottomBlank: widget.keepBottomBlank)
        : Container();
  }

  Widget _buildProgressWidget() {
    if (!(flickManager!.flickVideoManager?.videoPlayerValue?.isInitialized ??
        false)) {
      return Container();
    }

    Duration currentPos =
        flickManager?.flickVideoManager?.videoPlayerValue?.position ??
            const Duration(seconds: 0);
    Duration duration =
        flickManager?.flickVideoManager?.videoPlayerValue?.duration ??
            const Duration(seconds: 0);
    return Positioned(
      right: 0,
      left: 0,
      bottom: 0,
      child: kIsWeb
          ? Container(
              height: 2.0.w,
              alignment: Alignment.bottomCenter,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: LinearProgressIndicator(
                  minHeight: 2.0.w,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(StyleTheme.blue52Color),
                  value: currentPos.inMilliseconds / duration.inMilliseconds,
                ),
              ),
            )
          : FlickVideoProgressBar(
              flickProgressBarSettings: FlickProgressBarSettings(
                padding: const EdgeInsets.only(bottom: 0),
                height: 2,
                handleRadius: 0,
                curveRadius: 0,
                backgroundColor: Colors.white24,
                bufferedColor: Colors.transparent,
                playedColor: StyleTheme.blue52Color,
                handleColor: Colors.transparent,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);
    bool flag = (flickVideoManager.videoPlayerValue!.isBuffering &&
            flickVideoManager.videoPlayerValue!.isPlaying) ||
        !flickVideoManager.videoPlayerValue!.isInitialized;

    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);
    return Stack(
      children: [
        FlickShowControlsAction(
          child: Center(
            child: flag
                ? Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.grey[400],
                        valueColor:
                            AlwaysStoppedAnimation(StyleTheme.blue52Color),
                        strokeWidth: 1.5,
                      ),
                    ),
                  )
                : FlickAutoHideChild(
                    showIfVideoNotInitialized: false,
                    child: FlickPlayToggle(
                        replayChild: LocalPNG(
                          name: "ai_replay_n",
                          width: 50.w,
                          height: 50.w,
                        ),
                        playChild: LocalPNG(
                          name: "ai_play_n",
                          width: 50.w,
                          height: 50.w,
                        ),
                        // pauseChild: LocalPNG(
                        //   name: "ai_pause_n",
                        //   width: 40,
                        //   height: 40,
                        // ),
                        pauseChild: Container()),
                  ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              try {
                videoManager.isVideoEnded
                    ? controlManager.replay()
                    : controlManager.togglePlay();
              } catch (e) {
                Utils.log(e);
              }
            },
            child: Container(),
          ),
        ),
        _buildProgressWidget(),
        _buildContentWidget(),
        _buildGestureDetector(),
      ],
    );
  }
}
