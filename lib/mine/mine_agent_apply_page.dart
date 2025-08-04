import 'package:deepseek/model/bconf_model.dart';
import 'package:flutter/material.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineAgentApplyPage extends BaseWidget {
  const MineAgentApplyPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineAgentApplyPageState();
  }
}

class _MineAgentApplyPageState extends BaseWidgetState<MineAgentApplyPage> {
  TextEditingController? _controller;

  @override
  void onCreate() {
    // TODO: implement initState
    _controller = TextEditingController();
    // setAppTitle(title: Utils.txt('sqdl'));
    // setAppTitle(
    // bgColor: const Color.fromRGBO(21, 22, 23, 1),
    // );
  }

  @override
  Widget appbar() {
    return Container();
  }

  _applyAgent() async {
    String contack = _controller?.text ?? '';
    Utils.startGif();
    applyProxyWithContact(contack).then((value) {
      if (value?.status == 1) {
        Utils.showText(value?.msg ?? '', call: () {
          reqUserInfo(context).then((value) => context.pop());
        });
      } else {
        Utils.showText(value?.msg ?? '', call: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            context.pop();
          });
        });
      }
    });
  }

  _askApplyAgent() {
    String contack = _controller?.text ?? '';
    if (contack.isEmpty) {
      Utils.showText(Utils.txt('qsrnr'));
      return;
    }
    Utils.showDialog(
        confirm: _applyAgent,
        cancelTxt: Utils.txt('quxao'),
        confirmTxt: Utils.txt('quren'),
        setContent: () {
          return Text(Utils.txt("sqdlm"), style: StyleTheme.font_black_7716_14);
        });
  }

  @override
  Widget pageBody(BuildContext context) {
    BconfModel? cf =
        Provider.of<BaseStore>(context, listen: false).conf?.config;
    double width = ScreenUtil().screenWidth - StyleTheme.margin * 2;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Utils.unFocusNode(context);
            },
            child: Column(
              children: [
                SizedBox(height: 10.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.w),
                  child: LocalPNG(
                    name: 'ai_dlsq_bg',
                    width: width,
                    height: width * 160 / 367.5,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 20.w),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: Utils.txt('yy'),
                      style: StyleTheme.font_black_7716_14,
                    ),
                    TextSpan(
                      text: "${cf?.proxy_join_num ?? 0}",
                      style: StyleTheme.font_blue52_14,
                    ),
                    TextSpan(
                      text: Utils.txt('r'),
                      style: StyleTheme.font_black_7716_14,
                    ),
                    TextSpan(
                      text: Utils.txt('sqcw'),
                      style: StyleTheme.font_black_7716_14,
                    ),
                  ])),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: StyleTheme.whiteColor,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 38.w),
                        height: 40.w,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: StyleTheme.blue52Color, width: 1),
                            borderRadius: BorderRadius.circular(5.w)),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          style: StyleTheme.font_black_7716_14,
                          cursorColor: StyleTheme.blue52Color,
                          decoration: InputDecoration(
                            hintText: Utils.txt('txlx'),
                            hintStyle: StyleTheme.font_black_7716_06_14,
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.w),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: _askApplyAgent,
                          child: Container(
                            alignment: Alignment.center,
                            width: 264.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              gradient: StyleTheme.gradBlue,
                              borderRadius: BorderRadius.circular(19.w),
                            ),
                            child: Text(Utils.txt('tjao'),
                                style: StyleTheme.font_white_255_14),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.w),
                    ],
                  ),
                ),
              ],
            )));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
