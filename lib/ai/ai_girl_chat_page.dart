import 'dart:convert' as convert;

import 'package:deepseek/ai/ai_chat_notifier.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AIGirlChatPage extends BaseWidget {
  AIGirlChatPage({
    Key? key,
    required this.id,
    required this.name,
    required this.avatar,
  });

  final int id;
  final String name;
  final String avatar;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _AIGirlChatPageState();
  }
}

class _AIGirlChatPageState extends BaseWidgetState<AIGirlChatPage>
    with WidgetsBindingObserver {
  bool isHud = true;
  bool netError = false;

  dynamic data;

  late final FocusNode _focusNode;
  final TextEditingController _controllerText = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List _messages = [];
  bool waiting = true;
  bool canSend = false;

  bool isKeyboardVisible = false;

  late final chatNotifier = context.read<AIChatNotifier>();

  double bottomInset = 0.0;

  @override
  void onCreate() {
    // TODO: implement onCreate

    setAppTitle(titleW: Text(widget.name, style: StyleTheme.nav_title_font));

    WidgetsBinding.instance.addObserver(this);

    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      _initChatList();
    });
  }

  Future<void> _initChatList() async {
    // final List<AIChatList> listCache =
    //     await chatNotifier.readChats(); //获取所有AI女友的聊天列表
    //
    // try {
    //   //筛选出id对应的女友消息，使用 firstWhere 找到第一个符合条件的元素
    //   AIChatList singleItem =
    //       listCache.firstWhere((item) => item.id == widget.id);
    //   _messages = List.from(singleItem.list ?? []);
    // } catch (e) {}

    //直接使用接口一次性请求所有历史聊天数据
    final res = await reqMineCharactorHistoryList(id: widget.id);
    if (res?.status != 1) {
      netError = true;
      setState(() {});
      return;
    }
    List tp = res?.data;
    tp = tp.reversed.toList(); //倒序

    for (var e in tp) {
      //同一时间格式，返回的格式是：2025-03-10T08:11:19.000000Z，转成：2025-03-10 08:11:19
      String timer = e['created_at'] ?? '';
      // timer = timer.substring(0, 19);
      // timer = timer.replaceAll('T', ' ');

      // 解析服务器时间
      DateTime utcTime = DateTime.parse(timer);
      // 转换为本地时间
      DateTime localTime = utcTime.toLocal();
      // 格式化输出
      String formattedTime = "${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')} "
          "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}";

      Message data = Message(
          greeting: e['content'],
          avatar: e['avatar'],
          nickname: e['sender_name'],
          timeStr: formattedTime,
          isDone: true,
          isUser: e['sender_type'] == 'user');
      _messages.add(data);
    }

    isHud = false;

    _scrollToBottom();
    setState(() {});
  }

  @override
  void didChangeMetrics() {
    // 检测键盘的显示状态
    bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0.0) {
      _scrollToBottom();
    }
  }

  @override
  void onDestroy() {
    // super.dispose();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _simulateAiResponse(String text) async {
    _focusNode.unfocus();

    final res = await reqCharactorChat(id: widget.id, text: text);
    if (res?.status == 0) {
      Utils.showText(res?.msg ?? '未知错误');
      waiting = true;
      setState(() {});
      _scrollToBottom();
      return;
    }
    if (res?.data == null) {
      Message msg = Message(
          greeting: '我还在学习中...，以尽量满足你的..需求',
          avatar: widget.avatar,
          nickname: widget.name,
          timeStr: Utils.getCurrentTimer());
      _messages.add(msg);
      waiting = true;

      await chatNotifier.updateChatIM(
          msg, widget.id, widget.name, widget.avatar);
    } else {
      Message msg = Message(
          greeting: res?.data,
          avatar: widget.avatar,
          nickname: widget.name,
          timeStr: Utils.getCurrentTimer());
      _messages.add(msg);
      waiting = true;

      await chatNotifier.updateChatIM(
          msg, widget.id, widget.name, widget.avatar);

      _refreshUserCoins();
    }

    setState(() {});
    _scrollToBottom();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        // FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  void updateMessageStatus(int index) {
    if (mounted) {
      setState(() {
        _messages[index].isDone = true;
      });
    }
  }

  //AI女友询问成功后刷新用户的免费AI聊天次数/金币余额
  Future<void> _refreshUserCoins() async {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    int characterCoins = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.ai_girlfriend_chat_coins ??
        0;

    if (user == null) return;

    final imValue = (user.ai_girlfriend_chat_value ?? 0) - 1;
    if (imValue >= 0) {
      //更新用户剩余次数
      Provider.of<BaseStore>(context, listen: false).setImChatValue(imValue);
    } else {
      //免费次数不够直接扣金币，刷新用户金币余额
      Provider.of<BaseStore>(context, listen: false)
          .setMoney((user.money ?? 0) - characterCoins); //更新用户的金币数量
    }
  }

  Future<void> _sendMessage() async {
    String userInput = _controllerText.text.trim();

    int maxStr = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.ai_girlfriend_chat_msg_ct ??
        100;

    if (userInput.length > maxStr) {
      _controllerText.text = _controllerText.text.substring(0, maxStr);
      userInput = _controllerText.text;
      Utils.showText('最多能输入$maxStr个字符');
      return;
    }

    if (waiting == false) {
      Utils.showText(Utils.txt('dfzzsk'));
      return;
    }
    if (userInput.isNotEmpty) {
      Message msg = Message(
          greeting: userInput,
          avatar: '',
          nickname: '',
          isUser: true,
          timeStr: Utils.getCurrentTimer());

      _messages.add(msg);
      canSend = false;
      waiting = false;

      await chatNotifier.updateChatIM(
          msg, widget.id, widget.name, widget.avatar);

      _controllerText.clear();
      // _scrollToBottom();
      // setState(() {});

      await _simulateAiResponse(userInput);
    } else {
      if (bottomInset <= 0.0) {
        FocusScope.of(context).unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(_focusNode);
        });
      }
      Utils.showText(Utils.txt('qsrnr'));
      return;
    }
  }

  void _onChangeInput(value) {
    if (_controllerText.text.isNotEmpty) {
      canSend = true;
    } else {
      canSend = false;
    }
    setState(() {
      canSend;
    });
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody

    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            _initChatList();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // _focusNode.unfocus();
                      },
                      child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return ChatBubble(
                              message: _messages[index],
                              animatedFinish: () {
                                _scrollToBottom();
                                updateMessageStatus(index);
                              },
                            );
                          }),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(StyleTheme.margin),
                    color: Colors.white,
                    child: Row(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            color: Colors.white10,
                            child: ImageNetTool(
                              url: user?.thumb ?? '',
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 13.w),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(18.w),
                            ),
                            child: TextField(
                              // enabled: waiting,
                              focusNode: _focusNode,
                              onChanged: _onChangeInput,
                              onSubmitted: (value) async {
                                await _sendMessage();
                              },
                              style: StyleTheme.font_black_7716_14,
                              controller: _controllerText,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                hintText: waiting
                                    ? Utils.txt('wyddxf')
                                    : Utils.txt('dfzzsk'),
                                hintStyle: StyleTheme.font_black_7716_04_14,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        InkWell(
                          onTap: () async {
                            await _sendMessage();
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 30.w,
                                height: 30.w,
                                child: LocalPNG(
                                  name:
                                      canSend ? 'ai_mine_send' : 'ai_mine_send',
                                  width: 30.w,
                                  height: 30.w,
                                ),
                              ),
                              // Text(Utils.txt('fs'), style: StyleTheme.font_white_255_11)
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final Function animatedFinish;

  const ChatBubble(
      {super.key, required this.message, required this.animatedFinish});

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    return SizedBox(
      child: message.isUser
          ? Padding(
              padding: EdgeInsets.only(
                left: StyleTheme.margin,
                right: StyleTheme.margin,
                bottom: StyleTheme.margin,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 40.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                  color: StyleTheme.blue52Color,
                                  borderRadius: BorderRadius.circular(5.w)),
                              child: Text(
                                message.greeting,
                                style: StyleTheme.font_white_255_14,
                                maxLines: 9999,
                              ),
                            ),
                            SizedBox(height: 3.w),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                message.timeStr,
                                style: StyleTheme.font_black_7716_04_10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ClipOval(
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          color: Colors.white10,
                          child: ImageNetTool(
                            url: user?.thumb ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.only(
                left: StyleTheme.margin,
                right: StyleTheme.margin,
                bottom: StyleTheme.margin,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      color: Colors.white10,
                      child: ImageNetTool(
                        url: message.avatar,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.nickname,
                          style: TextStyle(
                              color: StyleTheme.blak7716_07_Color,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 5.w),
                        Container(
                            constraints: BoxConstraints(minWidth: 100.w),
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.w)),
                            child: TypewriterText(
                              text: message.greeting,
                              render: message.isDone,
                              onFinish: () {
                                animatedFinish.call();
                              },
                            )),
                        SizedBox(height: 3.w),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message.timeStr,
                            style: StyleTheme.font_black_7716_04_10,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Function onFinish;
  final bool render;

  const TypewriterText(
      {super.key,
      required this.text,
      required this.onFinish,
      required this.render});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  final _typingDuration = const Duration(milliseconds: 30);
  final _deletingDuration = const Duration(milliseconds: 10);
  late String _displayedText;
  late String _incomingText;
  late String _outgoingText;

  @override
  void initState() {
    _incomingText = widget.text;
    _outgoingText = '';
    _displayedText = '';
    animateText();
    super.initState();
  }

  void animateText() async {
    if (widget.render) {
      _displayedText = widget.text;
      return;
    }
    final backwardLength = _outgoingText.length;
    if (backwardLength > 0) {
      for (var i = backwardLength; i >= 0; i--) {
        await Future.delayed(_deletingDuration);
        _displayedText = _outgoingText.substring(0, i);
        setState(() {});
      }
    }
    final forwardLength = _incomingText.length;
    if (forwardLength > 0) {
      for (var i = 0; i <= forwardLength; i++) {
        await Future.delayed(_typingDuration);
        _displayedText = _incomingText.substring(0, i);
        if (mounted) {
          setState(() {});
        }
        if (i % 15 == 0) {
          widget.onFinish.call();
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    if (oldWidget.text != widget.text) {
      _outgoingText = oldWidget.text;
      _incomingText = widget.text;
      animateText();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: TextStyle(
          color: StyleTheme.blak7716Color,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400),
    );
  }
}
