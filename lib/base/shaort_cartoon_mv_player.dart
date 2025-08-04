// ignore_for_file: non_constant_identifier_names

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/nvideourl_minxin.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:universal_html/html.dart' as html;

class ShorCartoonMvPlayer extends StatefulWidget {
  ShorCartoonMvPlayer({
    Key? key,
    this.info,
  }) : super(key: key);
  final Map<String, dynamic>? info;
  @override
  State<ShorCartoonMvPlayer> createState() => _ShorCartoonMvPlayerState();
}

class _ShorCartoonMvPlayerState extends State<ShorCartoonMvPlayer>
    with NVideoURLMinxin {
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
                controls: SinklandscapeWidget(
                  isBack: true,
                  isDone: isDone,
                  info: widget.info,
                  isPreview: isPreview,
                  shareVp: () {
                    Utils.navTo(context, "/minesharepage");
                  },
                  skiPreview: () {
                    showAlertVp();
                  },
                  nowToVp: () {
                    Utils.navTo(context, "/minevippage");
                  },
                  nowByKb: () {
                    showAlertVp(goby: true);
                  },
                  closeBarrage: (flag) {
                    opened = flag;
                    if (mounted) setState(() {});
                  },
                ),
              ),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                playerErrorFallback: Container(),
                videoFit: BoxFit.contain,
                controls: SinklandscapeWidget(
                  info: widget.info,
                  closeBarrage: (flag) {
                    opened = flag;
                    if (mounted) setState(() {});
                  },
                ),
              ),
            ),
          );
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
    if (widget.info?['type'] == 2) {
      Utils.showDialog(
          cancelTxt: Utils.txt('quxao'),
          confirmTxt: isInsufficient ? Utils.txt('qwcz') : Utils.txt('gmgk'),
          setContent: () {
            return Column(
              children: [
                Text(widget.info?['pay_tip'] ?? Utils.txt('gmspkwz'),
                    style: StyleTheme.font_gray_153_13, maxLines: 3),
                // Text(Utils.txt('gmspkwz'),
                //     style: StyleTheme.font_gray_153_13, maxLines: 3),
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
    reqBuyCartoon(id: widget.info?['id'] ?? 0, money: money, context: context)
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
}

//横屏
class SinklandscapeWidget extends StatefulWidget {
  SinklandscapeWidget({
    Key? key,
    this.isBack = false,
    this.isPreview = false,
    this.isDone = false,
    this.info,
    this.skiPreview,
    this.shareVp,
    this.nowToVp,
    this.nowByKb,
    this.closeBarrage,
  }) : super(key: key);
  final bool isBack;
  final bool isPreview;
  final bool isDone;
  final Map? info;
  final Function? skiPreview; //跳过预览
  final Function? shareVp; //分享得VIP
  final Function? nowToVp; //立即开通
  final Function? nowByKb; //钻石购买
  final Function(bool)? closeBarrage;
  State<SinklandscapeWidget> createState() => _SinklandscapeWidgetState();
}

class _SinklandscapeWidgetState extends State<SinklandscapeWidget> {
  double _speed = 1.0;
  Map<String, double> speedList = {
    "2.0": 2.0,
    "1.8": 1.8,
    "1.5": 1.5,
    "1.2": 1.2,
    "1.0": 1.0,
  };
  bool _hideSpeedStu = true;
  bool _openBarrage = true;

  @override
  void initState() {
    super.initState();
  }

  // build 倍数列表
  List<Widget> _buildSpeedListWidget() {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);
    List<Widget> columnChild = [];
    speedList.forEach((String mapKey, double speedVals) {
      columnChild.add(
        Ink(
          child: InkWell(
            onTap: () {
              if (_speed == speedVals) return;
              _speed = speedVals;
              _hideSpeedStu = true;
              flickVideoManager.videoPlayerController?.setPlaybackSpeed(_speed);
              setState(() {});
            },
            child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 30,
              child: Text(
                "$mapKey X",
                style: TextStyle(
                  color: _speed == speedVals
                      ? StyleTheme.blue52Color
                      : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
      columnChild.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Container(
            width: 50,
            height: 1,
            color: Colors.white54,
          ),
        ),
      );
    });
    columnChild.removeAt(columnChild.length - 1);
    return columnChild;
  }

  Widget _noConditionWidget(context) {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    FlickDisplayManager flickDisplayManager =
        Provider.of<FlickDisplayManager>(context);
    bool flag = (flickVideoManager.videoPlayerValue!.isBuffering &&
            flickVideoManager.videoPlayerValue!.isPlaying) ||
        !flickVideoManager.videoPlayerValue!.isInitialized;
    double rate = flickVideoManager.videoPlayerValue?.aspectRatio ?? 0.0;

    return LayoutBuilder(builder: (context, cons) {
      double top = cons.maxWidth > cons.maxHeight ? 0 : StyleTheme.topHeight;

      double sss = StyleTheme.topHeight;
      return Stack(
        children: [
          Positioned.fill(
            child: FlickShowControlsAction(
              child: FlickSlideVideoAction(
                child: Center(
                  child: flag
                      ? Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.grey[400],
                              valueColor: AlwaysStoppedAnimation(
                                  StyleTheme.blue52Color),
                              strokeWidth: 1.5,
                            ),
                          ),
                        )
                      : FlickAutoHideChild(
                          showIfVideoNotInitialized: false,
                          child: FlickPlayToggle(
                            replayChild: LocalPNG(
                              name: "ai_replay_n",
                              width: 40,
                              height: 40,
                            ),
                            playChild: LocalPNG(
                              name: "ai_play_n",
                              width: 40,
                              height: 40,
                            ),
                            pauseChild: LocalPNG(
                              name: "ai_pause_n",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          FlickAutoHideChild(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 55,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(0, 0, 0, 0.0),
                            Color.fromRGBO(0, 0, 0, 0.1),
                            Color.fromRGBO(0, 0, 0, 0.3),
                            Color.fromRGBO(0, 0, 0, 0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: StyleTheme.margin,
                  right: StyleTheme.margin,
                  bottom: 15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              FlickCurrentPosition(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              Text(
                                ' / ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              FlickTotalDuration(
                                color: Colors.white,
                                fontSize: 16,
                              )
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              widget.info?["isSpeed"] == 1
                                  ? FlickSetPlayBack(
                                      speed: _speed,
                                      setPlayBack: () {
                                        _hideSpeedStu = !_hideSpeedStu;
                                        setState(() {});
                                      },
                                      playBackChild: Text(
                                        "${_speed == 1.0 ? '1.0' : _speed == 2.0 ? '2.0' : _speed} X",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    )
                                  : Container(),
                              rate > 1 || kIsWeb && !widget.isPreview
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: FlickFullScreenToggle(
                                        enterFullScreenChild: const Icon(
                                            Icons.fullscreen,
                                            size: 25,
                                            color: Colors.white),
                                        exitFullScreenChild: const Icon(
                                            Icons.fullscreen_exit,
                                            size: 25,
                                            color: Colors.white),
                                        toggleFullscreen: () {
                                          if (kIsWeb) {
                                            html.VideoElement video = html
                                                    .document
                                                    .querySelector('video')
                                                as html.VideoElement;
                                            video.muted = false;
                                            video.volume = 1;
                                            video.setAttribute(
                                                'playsinline', 'true');
                                            video.setAttribute(
                                                'autoplay', 'true');
                                            if (html.document
                                                    .fullscreenElement ==
                                                null) {
                                              video.enterFullscreen();
                                            } else {
                                              html.document.exitFullscreen();
                                            }
                                          } else {
                                            controlManager.toggleFullscreen();
                                          }
                                        },
                                      ),
                                    )
                                  : Container()
                            ],
                          )
                        ],
                      ),
                      !flickVideoManager.videoPlayerValue!.isInitialized ||
                              flickDisplayManager.showPlayerControls
                          ? FlickVideoProgressBar(
                              flickProgressBarSettings:
                                  FlickProgressBarSettings(
                                padding: const EdgeInsets.only(top: 10),
                                height: 3,
                                handleRadius: 6,
                                curveRadius: 4,
                                backgroundColor: Colors.white24,
                                bufferedColor:
                                StyleTheme.blue52Color.withOpacity(0.38),
                                playedColor: StyleTheme.blue52Color,
                                handleColor: StyleTheme.blue52Color,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                widget.isPreview
                    ? Positioned(
                        right: 0,
                        bottom: 30,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            widget.skiPreview?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: widget.info?['type'] == 2
                                  ? StyleTheme.gradOrange
                                  : StyleTheme.gradBlue,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                            ),
                            child: Center(
                              child: Text.rich(
                                TextSpan(
                                    text: widget.info?['type'] == 2
                                        ? "${widget.info?['coins'] ?? 0}${Utils.txt("kbtgyl")}"
                                        : Utils.txt("ktvptgyl"),
                                    style: StyleTheme.font_white_255_12),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                // 倍数选择
                Positioned(
                  right: controlManager.isFullscreen == false
                      ? (rate > 1 ? 39 : 3)
                      : (rate > 1 ? 50 : 3),
                  bottom: 55,
                  child: !_hideSpeedStu
                      ? FlickAutoHideChild(
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                children: _buildSpeedListWidget(),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
          Positioned(
            top: top,
            left: 2,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      offset: Offset(0, 0),
                      spreadRadius: 5,
                      blurRadius: 5,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: LocalPNG(
                  name: "ai_nav_back",
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
              ),
              onTap: () {
                if (widget.isBack) {
                  AppGlobal.appRouter?.pop();
                } else {
                  controlManager.toggleFullscreen();
                }
              },
            ),
          )
        ],
      );
    });
  }

  Widget _conditionWidget(BuildContext context) {
    Widget dgt = Container();
    var vflag = false;
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    if (user == null) return dgt;
    if (user.vip_level! < 1 && widget.info?['type'] == 1) {
      //需要VIP
      dgt = Text(Utils.txt('kvbw'),
          style: StyleTheme.font_white_255_14, maxLines: 2);
      vflag = false;
    } else if (widget.info?['type'] == 2) {
      dgt = DefaultTextStyle(
        style: StyleTheme.font_white_255_14,
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: "${widget.info?['coins'] ?? 0}",
                style: StyleTheme.font_yellow_255_14),
            TextSpan(text: Utils.txt('jbjsw') + "，"),
            TextSpan(text: Utils.txt('ktvpzk') + "${user.money}")
          ]),
        ),
      );
      vflag = true;
    }
    return Container(
      color: Colors.black87,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 22,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          offset: Offset(0, 0),
                          blurRadius: 11)
                    ],
                  ),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: LocalPNG(
                      name: "ai_nav_back",
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                    onTap: () {
                      AppGlobal.appRouter?.pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 50,
            right: 50,
          ),
          child: Column(
            children: [
              Text(Utils.txt("skjs"), style: StyleTheme.font_white_255_14),
              const SizedBox(height: 10),
              dgt,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (vflag) {
                    widget.nowByKb?.call();
                  } else {
                    widget.nowToVp?.call();
                  }
                },
                child: Container(
                  height: 32,
                  width: 110,
                  decoration: BoxDecoration(
                    gradient: StyleTheme.gradBlue,
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                  ),
                  child: Center(
                    child: Text(vflag ? Utils.txt("gmgk") : Utils.txt("ljkv"),
                        style: StyleTheme.font_white_255_12),
                  ),
                ),
              ),
              const SizedBox(width: 37),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  widget.shareVp?.call();
                },
                child: Container(
                  height: 32,
                  width: 110,
                  decoration: BoxDecoration(
                    gradient: StyleTheme.gradBlue,
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                  ),
                  child: Center(
                    child: Text(Utils.txt("yqfxdvp"),
                        style: StyleTheme.font_white_255_12),
                  ),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isDone && widget.isPreview
        ? _conditionWidget(context)
        : _noConditionWidget(context);
  }
}
