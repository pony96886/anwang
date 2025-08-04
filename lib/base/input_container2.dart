import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class InputContainer2 extends StatefulWidget {
  const InputContainer2({
    Key? key,
    this.child,
    this.onEditingCompleteText,
    this.onSelectPicComplete,
    this.onOutEventComplete,
    this.onCollectEventComplete,
    this.labelText,
    this.bg = Colors.white,
    this.focusNode,
    this.isCollect = false,
  }) : super(key: key);
  final bool isCollect;
  final Color bg;
  final Widget? child;
  final String? labelText;
  final ValueChanged? onEditingCompleteText;
  final Function? onSelectPicComplete;
  final Function? onOutEventComplete;
  final Function? onCollectEventComplete;
  final FocusNode? focusNode;

  @override
  State<InputContainer2> createState() => _InputContainer2State();
}

class _InputContainer2State extends State<InputContainer2> {
  final TextEditingController controller = TextEditingController();

  final List<Map<String, dynamic>> medias = [];

  String _string = '';

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                widget.onOutEventComplete?.call();
                Utils.unFocusNode(context);
              },
              child: widget.child ?? Container(),
            ),
          ),
          // Divider(
          //   height: 0.5.w,
          //   color: StyleTheme.whiteColor
          //       .withOpacity(0.6), // const Color.fromRGBO(216, 216, 216, 1),
          // ),
          Container(
            color: widget.bg,
            child: Column(
              children: [
                ListTile(
                  leading: widget.onSelectPicComplete == null
                      ? SizedBox(
                          height: 30.w,
                          width: 30.w,
                          child: ImageNetTool(
                            url: user?.thumb ?? "",
                            radius: BorderRadius.all(Radius.circular(15.w)),
                          ),
                        )
                      : GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Utils.unFocusNode(context);
                            widget.onSelectPicComplete?.call();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 2.w),
                            child: LocalPNG(
                                fit: BoxFit.fill,
                                name: "ai_mine_imgpicker",
                                width: 22.w,
                                height: 20.w),
                          ),
                        ),
                  title: TextField(
                    focusNode: widget.focusNode,
                    controller: controller,
                    style: StyleTheme.font_black_7716_14,
                    cursorColor: StyleTheme.blue52Color,
                    decoration: InputDecoration(
                      hintText: widget.labelText,
                      hintStyle: StyleTheme.font_black_7716_06_14,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: const OutlineInputBorder(
                        gapPadding: 0,
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 2,
                    onChanged: (value) {
                      _string = value;
                    },
                    onTap: () {
                      FocusScope.of(context).requestFocus(widget.focusNode);
                    },
                    onSubmitted: (_) {},
                  ),
                  trailing: widget.onCollectEventComplete == null
                      ? GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Utils.unFocusNode(context);
                            widget.onEditingCompleteText?.call(_string);
                            controller.text = "";
                            _string = '';
                          },
                          child: LocalPNG(
                            name: "ai_mine_send",
                            width: 30.w,
                            height: 30.w,
                          ),
                        )
                      : SizedBox(
                          width: 70.w,
                          height: 40.w,
                          child: Row(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Utils.unFocusNode(context);
                                  widget.onCollectEventComplete?.call();
                                },
                                child: LocalPNG(
                                  name: widget.isCollect
                                      ? "ai_collect_h"
                                      : "ai_collect_n",
                                  width: 26.w,
                                  height: 26.w,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Utils.unFocusNode(context);
                                  widget.onEditingCompleteText
                                      ?.call(controller.text);
                                  controller.text = "";
                                },
                                child: LocalPNG(
                                  name: "ai_mine_send",
                                  width: 30.w,
                                  height: 30.w,
                                ),
                              ),
                              SizedBox(width: 1.w),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
