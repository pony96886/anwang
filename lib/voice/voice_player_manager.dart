import 'dart:math';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/download_voice_utils.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/download_utils.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/voice/widgets/draggable_button.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

///创建单例持有播放器，方便全局监听播放器及对播放器操作，初始化方法：VoicePlayerManager.instance

class VoicePlayerManager {
  VideoPlayerController? audioController; //播放器控制器
  dynamic data; // 当前播放数据
  BuildContext? context; //initVideoPlayer方法中必须传过来
  bool isLocal = false;

  //播放音频是悬浮按钮层
  OverlayEntry? overlayEntry;

  // 私有构造函数，防止外部直接创建实例
  VoicePlayerManager._privateConstructor();

  //是否循环
  ValueNotifier<bool> isCircuit = ValueNotifier(true);

  //播放器是否初始化
  ValueNotifier<bool> isInit = ValueNotifier(false);

  //是否播放状态
  ValueNotifier<bool> isPlay = ValueNotifier(false);

  //进度
  ValueNotifier<Duration> progress =
      ValueNotifier<Duration>(const Duration(seconds: 0));

  //进度条缓冲区
  Duration buffered = const Duration(seconds: 0);
  Duration total = const Duration(seconds: 0);
  bool isErr = false;
  int currentId = -99;
  BuildContext? topContext; //获取顶层context，否则界面跳转后会被遮挡，在BottomNaviBar组件中传过来

  List<dynamic> voices = []; //播放列表数据

  Timer? _timer; //定时结束
  int? minutes; //定时几分钟

  Timer? _secondTimer; //秒数 定时器
  int remainSeconds = 0; // 倒计时 剩余秒数

  bool needCoinsTip = true; //金币充足情况下，购买时否需要弹窗提示用户需要多少金币购买

  // 唯一实例
  static final VoicePlayerManager _instance =
      VoicePlayerManager._privateConstructor();

  // 获取唯一实例的公共静态方法
  static VoicePlayerManager get instance => _instance;

  void disposes() {
    currentId = -99;
    audioController?.removeListener(addListenerAudio);
    audioController?.dispose();
    isInit.value = false;
    isPlay.value = false;
    progress.value = const Duration(seconds: 0);
    buffered = const Duration(seconds: 0);
    total = const Duration(seconds: 0);
  }

  void showFloatPayer() {
    //不可播放时不显示
    if (data['voice']?.isEmpty ?? false) {
      return;
    }
    // 创建并插入悬浮按钮
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(topContext!);
      if (overlayEntry != null) {
        overlayEntry?.remove();
        overlayEntry = null;
      }
      overlayEntry = _createOverlayEntry();
      overlay.insert(overlayEntry!);
    });
  }

  void removeFloatPayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlayEntry?.remove();
      overlayEntry = null;
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(builder: (context) => const DraggableFloatingButton());
  }

  Future<void> initVideoPlayer(dynamic model, BuildContext buildContext) async {
    data = model;
    context = buildContext;

    getVoiceDataList(); //每次点击播放时一次性先拉去播放列表数据

    if (minutes != null) {
      startTimer();
    }

    //判断是否可以播放，弹窗提示
    if ((data['voice'] ?? '').isEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        VoicePlayerManager.instance.removeFloatPayer();
        disposes(); //暂停当前播放
        dialogPrompt(model); //传入数据，购买成功后改变voice字段数据
      });
      return;
    }

    if (currentId == data['id'] && audioController != null) {
      //如果播放的是同一个id的音频数据则不做任何实例化操作
      reportPlayVoice();
      return;
    }

    if (overlayEntry == null) {
      //如果不在播放器界面内部则不显示菊花
      LoadStatus.showSLoading();
    }

    // 释放旧的播放控制器（如果存在）
    if (audioController != null) {
      disposes(); //暂停当前播放
    }
    audioController = await initVideoPlayerService(data['voice'] ?? '')
      ..initialize().then((_) {
        isInit.value = true;
        total = audioController?.value.duration ?? const Duration(seconds: 0);
        // if (!kIsWeb) {
        audioController?.play();
        reportPlayVoice();
        isPlay.value = true;
        currentId = data['id'] ?? 0;
        // }
        addVoiceList(); //添加到播放列表
        audioController?.addListener(addListenerAudio);

        LoadStatus.closeLoading();
      }).onError((error, stackTrace) {
        LoadStatus.closeLoading();
        isErr = true;
        Utils.showText('初始化错误:$error');
        VoicePlayerManager.instance.removeFloatPayer();
      });
  }

  Future<VideoPlayerController> initVideoPlayerService(String purl) {
    return Future(() {
      return VideoPlayerController.network(purl);
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
    if (audioController!.value.position >= audioController!.value.duration) {
      nextVoice();
    }
  }

  //生成随机索引
  int _getRandomIndex() {
    final list = VoicePlayerManager.instance.voices;
    final random = Random();
    return random.nextInt(list.length);
  }

  //会员/金币购买弹窗
  void dialogPrompt(dynamic model) {
    UserModel? user = Provider.of<BaseStore>(context!, listen: false).user;
    if (user == null) return;

    if (data['type'] == 2) {
      //如果是金币音频则提示购买
      int money = user.money ?? 0;
      int needmoney = data['coins'] ?? 0;

      bool isInsufficient = money < needmoney;

      Utils.showDialog(
        cancelTxt: Utils.txt('quxao'),
        confirmTxt: isInsufficient ? Utils.txt('qwcz') : Utils.txt('gmgk'),
        backgroundReturn: () {
          AppGlobal.appRouter?.pop();
        },
        setContent: () {
          return Column(
            children: [
              Text(Utils.txt('gmhktwznr'),
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
            String currentLocation = AppGlobal.appRouter!.location;
            bool flag = false;
            if (currentLocation.contains('/voiceplayerpage')) {
              flag = true;
            }
            Utils.navTo(context!, "/minegoldcenterpage", replace: flag);
          } else {
            buyVoice(data, money - needmoney); //直接购买
          }
        },
        cancel: () {
          // context?.pop();

          AppGlobal.appRouter?.pop();
        },
      );
    }

    if (data['type'] == 1) {
      //如果是VIP音频则提示购买
      Utils.showDialog(
        cancelTxt: Utils.txt('quxao'),
        confirmTxt: Utils.txt('ljkt'),
        backgroundReturn: () {
          AppGlobal.appRouter?.pop();
        },
        setContent: () {
          return Column(
            children: [
              (data['pay_tip'] ?? '').isNotEmpty
                  ? data['pay_tip']
                  : Text(Utils.txt('gmvkwz'),
                      style: StyleTheme.font_gray_153_13, maxLines: 3),
            ],
          );
        },
        confirm: () {
          String currentLocation = AppGlobal.appRouter!.location;
          bool flag = false;
          if (currentLocation.contains('/voiceplayerpage')) {
            flag = true;
          }
          Utils.navTo(context!, '/minevippage', replace: flag);
        },
        cancel: () {
          // context?.pop();
          AppGlobal.appRouter?.pop();
        },
      );
    }

    // Member member = context!.read<UserNotifier>().member;
    // bool sufficient = member.money >= (data['coins'] ?? 0);
    // //如果用户开启了后续不再提醒，直接购买且余额充足，则直接购买
    // if (!needCoinsTip && sufficient && data['type'] == 2) {
    //   buyVoice(model);
    //   return;
    // } else if (!needCoinsTip && !sufficient && data['type'] == 2) {
    //   //如何余额不足则直接提示去充值操作
    //   showDialog(
    //     barrierDismissible: false,
    //     context: context!,
    //     builder: (ctx) => const Material(
    //       type: MaterialType.transparency,
    //       child: PopScope(
    //           canPop: false, //禁止弹窗通过滑动隐藏
    //           child: CoinsNotEnoughDialog()),
    //     ),
    //   );
    //   return;
    // }

    // showDialog(
    //   barrierDismissible: false,
    //   context: context!,
    //   builder: (ctx) => Material(
    //     type: MaterialType.transparency,
    //     child: PopScope(
    //         canPop: false, //禁止弹窗通过滑动隐藏
    //         child: CoinsDialog(data: model)),
    //   ),
    // );
  }

  Future<void> buyVoice(dynamic model, int money) async {
    LoadStatus.showSLoading(text: Utils.txt('gmdd'));

    final res = await reqVoiceBuy(context!, id: model['id'], money: money);

    LoadStatus.closeLoading();
    if (res?.status != 1) {
      Utils.showText(res?.msg ?? '');
      return;
    }

    model['voice'] = res?.data['voice'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoicePlayerManager insss = VoicePlayerManager.instance;
      VoicePlayerManager.instance.initVideoPlayer(model, context!);
      // VoicePlayerManager.instance.showFloatPayer();
      // if (context!.canPop()) {
      //   // context!.pop(); //隐藏弹窗
      // }
    });
  }

  //购买金币不足弹窗
  void coinsInsufficientDialog() {}

  //获取播放列表数据
  Future<void> getVoiceDataList() async {
    // final domain = topContext!.read<ASMRDomain>();
    final res = await reqVoiceListQueue(page: 1, limit: 10000);
    if (res?.status == 1) {
      voices = res?.data ?? [];
    } else if (res?.msg case final msg?) {
      Utils.showText(msg);
    }
  }

  //加入播放队列 --- 播放时默认直接加入到播放列表
  Future<void> addVoiceList() async {
    final res = await reqVoiceAddQueue(id: data['id'] ?? 0);
    // final domain = topContext!.read<ASMRDomain>();
    // final res = await domain.addVoiceQueue(id: data['id'] ?? 0);
    if (res?.status == 1) {
      getVoiceDataList();
    } else if (res?.msg case final msg?) {
      Utils.showText(msg);
    }
  }

  //下一首, isClicke: 用户主动在播放器界面操作的，播放列表为空或只有1条数据时需要提示用户
  void nextVoice({bool isClicke = false}) {
    //播放列表为空或者只有一个数据时循环播放即可
    if (voices.isEmpty) {
      if (isClicke) {
        Utils.showText(Utils.txt('noasmr')); //播放列表无音频数据
        return;
      }
      //播放完后自动从头播放
      audioController!.seekTo(const Duration(milliseconds: 0));
      audioController!.play();
      reportPlayVoice();
      isPlay.value = true;
      return;
    }

    if (voices.length == 1) {
      if (voices.first.id == data['id']) {
        if (isClicke) {
          Utils.showText(Utils.txt('oneasmr')); //当前只有一条音频数据
          return;
        }
        //播放完后自动从头播放
        audioController!.seekTo(const Duration(milliseconds: 0));
        audioController!.play();
        reportPlayVoice();
        isPlay.value = true;
        return;
      } else {
        VoicePlayerManager.instance.data = voices.first;
        initVideoPlayer(voices.first, context!);

        eventBus.fire(MyEvent('RefreshVoicePayerUI')); //发通知去播放界面/播放列表界面刷新数据
        return;
      }
    }

    if (isCircuit.value) {
      //循环播放

      int currentIndex =
          voices.indexWhere((model) => model['id'] == data['id']);
      if (currentIndex != -1) {
        //找到当前播放数据在列表中的位置
        if (currentIndex < voices.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0; // 循环到第一首
        }

        final currentData = voices[currentIndex];

        VoicePlayerManager.instance.data = currentData;
        initVideoPlayer(currentData, context!);
        eventBus.fire(MyEvent('RefreshVoicePayerUI')); //发通知去播放界面/播放列表界面刷新数据
      } else {
        if (voices.isNotEmpty) {
          //如果当前数据正好被删除了，找不到位置但是列表中还有数据则播放第一个
          VoicePlayerManager.instance.data = voices.first;
          initVideoPlayer(voices.first, context!);
          eventBus.fire(MyEvent('RefreshVoicePayerUI')); //发通知去播放界面/播放列表界面刷新数据
          return;
        }
        Utils.showText(Utils.txt('overend')); //当前音频播放结束，循环播放下一首错误
      }
    } else {
      //随机播放

      int currentIndex = _getRandomIndex();
      final currentData = voices[currentIndex];

      VoicePlayerManager.instance.data = currentData;
      initVideoPlayer(currentData, context!);
      eventBus.fire(MyEvent('RefreshVoicePayerUI')); //发通知去播放界面/播放列表界面刷新数据
    }
  }

  //上一首，isClicke: 用户主动在播放器界面操作的，播放列表为空或只有1条数据时需要提示用户
  void preVoice({bool isClicke = false}) {
    //播放列表为空或者只有一个数据时循环播放即可
    if (voices.isEmpty) {
      if (isClicke) {
        Utils.showText(Utils.txt('noasmr')); //播放列表无音频数据
        return;
      }
      //播放完后自动从头播放
      audioController!.seekTo(const Duration(milliseconds: 0));
      audioController!.play();
      reportPlayVoice();
      isPlay.value = true;
      return;
    }

    if (voices.length == 1) {
      if (voices.first.id == data['id']) {
        if (isClicke) {
          Utils.showText(Utils.txt('oneasmr')); //当前只有一条音频数据
          return;
        }

        //播放完后自动从头播放
        audioController!.seekTo(const Duration(milliseconds: 0));
        audioController!.play();
        reportPlayVoice();
        isPlay.value = true;
        return;
      } else {
        VoicePlayerManager.instance.data = voices.first;
        initVideoPlayer(voices.first, context!);
        eventBus.fire(MyEvent('RefreshVoicePayerUI')); //发通知去播放界面/播放列表界面刷新数据
        return;
      }
    }

    if (isCircuit.value) {
      //循环播放
      int currentIndex =
          voices.indexWhere((model) => model['id'] == data['id']);
      if (currentIndex != -1) {
        //找到当前播放数据在列表中的位置
        if (currentIndex > 0) {
          currentIndex--;
        } else {
          currentIndex = voices.length - 1; // 循环到最后一首
        }

        final currentData = voices[currentIndex];

        VoicePlayerManager.instance.data = currentData;
        initVideoPlayer(currentData, context!);
        eventBus.fire(MyEvent('RefreshVoicePayerUI')); //发通知去播放界面/播放列表界面刷新数据
      } else {
        if (voices.isNotEmpty) {
          //如果当前数据正好被删除了，找不到位置但是列表中还有数据则播放第一个
          VoicePlayerManager.instance.data = voices.first;
          initVideoPlayer(voices.first, context!);
          eventBus.fire(MyEvent('RefreshVoicePayerUI')); //发通知去播放界面/播放列表界面刷新数据
          return;
        }
        Utils.showText(Utils.txt('overend')); //当前音频播放结束，循环播放下一首错误
      }
    } else {
      //随机播放

      int currentIndex = _getRandomIndex();
      final currentData = voices[currentIndex];

      VoicePlayerManager.instance.data = currentData;
      initVideoPlayer(currentData, context!);
      eventBus.fire(MyEvent('RefreshVoicePayerUI')); //发通知去播放界面/播放列表界面刷新数据
    }
  }

  void startCountDownTimer() {
    disposeTimer();

    remainSeconds = (minutes ?? 0) * 60;

    startTimer();
  }

  void startTimer() {
    disposeTimer();

    // _timer = Timer(Duration(minutes: minutes ?? 0), () {
    //   if (isPlay.value) {
    //     //如果正在播放中则停止播放
    //     audioController?.pause();
    //     isPlay.value = false;
    //     removeFloatPayer();
    //     disposeTimer();
    //   }
    // });

    // remainSeconds = (minutes ?? 0) * 60;
    _secondTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainSeconds <= 0) {
        if (isPlay.value) {
          //如果正在播放中则停止播放
          audioController?.pause();
          isPlay.value = false;
          removeFloatPayer();
          disposeTimer();
        }
      }
      remainSeconds -= 1;
    });
  }

  void disposeTimer() {
    _timer?.cancel();
    _timer = null;

    _secondTimer?.cancel();
    _secondTimer = null;
  }

  void resetTimer() {
    minutes = null;
    disposeTimer();
  }

  //播放上报
  Future<void> reportPlayVoice() async {
    // final domain = topContext!.read<ASMRDomain>();
    // domain.reportVoicePlay(id: data['id'] ?? 0);

    reqVoicePlay(id: data['id'] ?? 0);
  }

  //语音下载
  Future<void> downVoice() async {
    final res = await reqVoiceDownload(id: data['id'] ?? 00);
    if (res?.status == 1) {
      final url = res?.data['url']; //获取下载地址

      downVoiceTaskOptional(url);
      // downVoiceTaskOptional(url);
    } else if (res?.msg case final msg?) {
      Utils.showText(msg);
    }

    // final domain = topContext!.read<ASMRDomain>();
    // final res = await domain.downloadVoice(id: data['id'] ?? 0);
    // if (res.isValid) {
    //   final url = res.data['url']; //获取下载地址
    //   downVoiceTaskOptional(url);
    // } else if (res.msg case final msg?) {
    //   Utils.showText(msg);
    // }
  }

  //下载任务操作
  Future<void> downVoiceTaskOptional(String url) async {
    if (kIsWeb) {
      Utils.showText(Utils.txt('tsadsy'));
      return;
    }

    // final cache = topContext!.read<CacheDomain>();
    // final downloadUtil = topContext!.read<DownloadUtil>();

    final taskInfo = {
      'id': '${data['id']}',
      'urlPath': url,
      'title': data['title'],
      'cover_thumb': data['small_cover'],
      'contentType': 2,
      'downloading': false,
      'isWaiting': true,

      //传入音频数据
      'small_cover': data['small_cover'],
      'big_cover': data['big_cover'],
      'view_fct': data['view_fct'],
      'favorite_fct': data['favorite_fct'],
      'is_favorite': data['is_favorite'],
      'play_fct': data['play_fct'],
      'type': data['type'],
      'coins': data['coins'],
      'duration': data['duration'],
      'voice': data['voice'],
      'payTip': data['payTip'],
      'created_at': data['created_at'],
    };

    Box box = await Hive.openBox('deepseek_voice_box');
    List tasks = box.get('download_voice_tasks') ?? [];
    int existTaskIndex = tasks.indexWhere((e) => e["id"] == taskInfo["id"]);
    if (tasks.isNotEmpty && existTaskIndex != -1) {
      Map info = tasks[existTaskIndex];
      if (info['progress'] == 1) {
        Utils.showText(Utils.txt("wjyxz"));
      } else {
        Utils.showText(Utils.txt("dqrwcz"));
      }
      return;
    }

    // final tasks = await cache.readDownloadVideoTasks();
    // final existTaskIndex = tasks.indexWhere((e) => e['id'] == taskInfo['id']);
    // if (tasks.isNotEmpty && existTaskIndex != -1) {
    //   final info = tasks[existTaskIndex];
    //   if (info['progress'] == 1) {
    //     Utils.showText(Utils.txt('voiceyxz')); //当前音频已下载，请去我的下载缓存查看吧
    //   } else {
    //     Utils.showText(Utils.txt('dqrwcz')); //当前任务已经存在,请勿重复操作！
    //   }
    //   return;
    // }

    DownloadVoiceUtils.createDownloadTask(taskInfo);

    // DownloadUtils.createDownloadTask(taskInfo);

    // downloadUtil.createDownloadTask(taskInfo: taskInfo);
  }
}
