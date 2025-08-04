import 'dart:async';

import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/voice/voice_player_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class VoicePlayerSheetCard extends StatefulWidget {
  const VoicePlayerSheetCard(
      {super.key, required this.data, required this.complete, this.delete});

  final dynamic data;

  final Function complete;

  final Function? delete;

  @override
  State<VoicePlayerSheetCard> createState() => _VoicePlayerSheetCardState();
}

class _VoicePlayerSheetCardState extends State<VoicePlayerSheetCard> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final currentData = VoicePlayerManager.instance.data;
    bool isPlaying = currentData?['id'] == widget.data['id'];

    return InkWell(
      onTap: () {
        if (!isPlaying) {
          VoicePlayerManager.instance.initVideoPlayer(widget.data, context);
          widget.complete.call();
        }
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.all(10.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Offstage(
            offstage: !isPlaying,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.w),
              child:
                  Text(Utils.txt('dqbf'), style: StyleTheme.font_black_7716_15),
            ),
          ),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(
                  dimension: 60.w,
                  child: ImageNetTool(
                    url: widget.data['small_cover'],
                  )),
              SizedBox(width: 10.w),
              Expanded(
                  child: Container(
                height: 50.w,
                // color: Colors.deepOrange,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(widget.data['title'] ?? '',
                          style: isPlaying
                              ? StyleTheme.font_blue52_15.toHeight(1)
                              : StyleTheme.font_white_255_15.toHeight(1),
                          maxLines: 1),
                      // Spacer(),
                      // SizedBox(height: 5.w),
                      Text("${Utils.getHMTime(widget.data["duration"] ?? 0)}",
                          style: StyleTheme.font_black_7716_04_13)
                    ]),
              )),
              SizedBox(width: 10.w),
              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    //更多操作按钮---下载/收藏/删除
                    playerOptional(widget.data);
                  },
                  child: Container(
                    key: _globalKey,
                    width: 30.w,
                    height: 30.w,
                    // color: Colors.deepOrange,
                    alignment: Alignment.center,
                    child: LocalPNG(
                      name: 'ai_voice_player_list_more',
                      width: 16.5.w,
                      height: 3.5.w,
                    ),
                  ))
            ],
          ),
          // Offstage(
          //   offstage: !isPlaying,
          //   child: Padding(
          //     padding: EdgeInsets.only(top: 17.w),
          //     child: Text('xys'.tr(context: context),
          //         style: MyTheme.white09_15_M),
          //   ),
          // ),
        ]),
      ),
    );
  }

  void playerOptional(dynamic data) {
    RelativeRect? widgetPosition;
    final RenderBox? renderBox =
        _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      widgetPosition = RelativeRect.fromLTRB(
          position.dx,
          position.dy + size.height + 10.w,
          position.dx + size.width,
          position.dy + size.height);
    }
    showMenu(
        context: context,
        color: StyleTheme.whiteColor, // 设置背景颜色
        position: widgetPosition!,
        items: [
          if (!kIsWeb)
            PopupMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LocalPNG(
                      name: 'ai_video_download', width: 18.w, height: 18.w),
                  SizedBox(width: 14.w),
                  Text(Utils.txt('xiazi'),
                      style: StyleTheme.font_black_7716_14),
                ],
              ),
              onTap: () {
                //下载
                downVoice();
              },
            ),
          PopupMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LocalPNG(
                    name: widget.data['is_favorite'] == 1
                        ? 'ai_voice_player_favorite_on'
                        : 'ai_voice_player_favorite_off',
                    width: 18.w,
                    height: 18.w),
                SizedBox(width: 14.w),
                Text(Utils.txt('socang'), style: StyleTheme.font_black_7716_14),
              ],
            ),
            onTap: () {
              //收藏
              collectionVoice();
            },
          ),
          PopupMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LocalPNG(
                    name: 'ai_voice_player_list_delete',
                    width: 18.w,
                    height: 18.w),
                SizedBox(width: 14.w),
                Text(Utils.txt('cdlzsx'), style: StyleTheme.font_black_7716_14),
              ],
            ),
            onTap: () {
              //从队列中删除
              deleteVoice();
            },
          ),
        ]);
  }

  Future<void> collectionVoice() async {
    final res = await reqUserFavorite(id: widget.data['id'] ?? 0, type: 19);
    if (res?.status == 1) {
      widget.data['is_favorite'] = res?.data['is_favorite'];

      if (widget.data['id'] == VoicePlayerManager.instance.data?['id']) {
        //如果收藏的当前播放着中音频则直接刷新上层界面
        VoicePlayerManager.instance.data?['is_favorite'] =
            widget.data['is_favorite'];
        widget.complete.call(); //收藏成功回调播放界面刷新显示
      }

      //更新VoicePlayerManager.instance.voices对应数据元收藏状态
      var list = VoicePlayerManager.instance.voices;
      int index = list.indexWhere((model) => model.id == widget.data['id)']);
      if (index == -1) {
        Utils.showText('音频不在列表中！');
      } else {
        dynamic model = list[index];
        model['is_favorite'] = widget.data['is_favorite'];
      }
    } else if (res?.msg case final msg?) {
      Utils.showText(msg);
    }
  }

  //从播放列表删除
  Future<void> deleteVoice() async {
    final res = await reqVoiceDeleteQueue(id: widget.data['id'] ?? 00);
    if (res?.status == 1) {
      VoicePlayerManager.instance.voices.remove(widget.data);
      widget.delete?.call();
    } else if (res?.msg case final msg?) {
      Utils.showText(msg);
    }
  }

  //语音下载
  Future<void> downVoice() async {
    final res = await reqVoiceDownload(id: widget.data['id'] ?? 00);
    if (res?.status == 1) {
      final url = res?.data['url']; //获取下载地址

      VoicePlayerManager.instance.downVoiceTaskOptional(url);
      // downVoiceTaskOptional(url);
    } else if (res?.msg case final msg?) {
      Utils.showText(msg);
    }
  }
}
