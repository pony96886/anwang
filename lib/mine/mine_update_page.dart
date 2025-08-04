import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineUpdatePage extends BaseWidget {
  const MineUpdatePage({Key? key, this.type = "nickname", this.title = ""})
      : super(key: key);
  final String? type; //修改昵称：nickname 填写邀请码：invite 兑换码：code
  final String? title;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineUpdatePageState();
  }
}

class _MineUpdatePageState extends BaseWidgetState<MineUpdatePage> {
  //文本框
  TextEditingController controller = TextEditingController();

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(
            widget.type == "nickname"
                ? Utils.txt('xgnichen')
                : widget.title ?? "",
            style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  void dealPostData() {
    if (controller.text.isEmpty) {
      Utils.showText(Utils.txt('qtxnrong'));
      return;
    }
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    Utils.startGif(tip: Utils.txt('jzz'));

    //修改昵称
    if (widget.type == "nickname") {
      reqUpdateUserInfo(nickname: controller.text).then((value) {
        Utils.closeGif();
        if (value?.status == 1 && user != null) {
          user.nickname = controller.text;
          Provider.of<BaseStore>(context, listen: false).setUser(user);
          // 修改昵称没有弹出成功 因为返回的msg是空的 所以直接弹出一个 成功 然后直接返回
          Utils.showText(Utils.txt('cg'));
          context.pop();
          return;
        }
        if (value?.msg?.isNotEmpty == true) {
          Utils.showText(value?.msg ?? "");
        }
      });
    }
    //填写邀请码
    if (widget.type == "invite") {
      reqInvitation(affCode: controller.text).then((value) {
        Utils.closeGif();
        if (value?.msg?.isNotEmpty == true) {
          Utils.showText(value?.msg ?? "");
        }
      });
    }
    //填写兑换码
    if (widget.type == "code") {
      reqOnExchange(cdk: controller.text).then((value) {
        Utils.closeGif();
        if (value?.msg?.isNotEmpty == true) {
          Utils.showText(value?.msg ?? "");
        }
      });
    }
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Utils.unFocusNode(context);
      },
      child: Column(
        children: [
          SizedBox(height: 20.w),
          Container(
            height: 50.w,
            margin: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
                color: StyleTheme.whiteColor,
                borderRadius: BorderRadius.all(Radius.circular(3.w))),
            alignment: Alignment.center,
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter(
                    RegExp("[a-zA-Z]|[0-9]|[\u4e00-\u9fa5]"),
                    allow: true),
                LengthLimitingTextInputFormatter(10)
              ],
              obscureText: false,
              keyboardType: TextInputType.text,
              autofocus: false,
              onChanged: (e) {},
              onSubmitted: (e) {},
              controller: controller,
              style: StyleTheme.font_black_7716_14,
              textInputAction: TextInputAction.done,
              cursorColor: StyleTheme.blue52Color,
              decoration: InputDecoration(
                hintText:
                    "${widget.type == 'nickname' ? Utils.txt("qsr") : Utils.txt('q')}${widget.title ?? ""}",
                hintStyle: StyleTheme.font_black_7716_04_14,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0)),
              ),
            ),
          ),
          SizedBox(height: 50.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dealPostData();
              },
              child: Container(
                height: 40.w,
                decoration: BoxDecoration(
                  color: StyleTheme.blue52Color,
                  borderRadius: BorderRadius.all(Radius.circular(4.w)),
                ),
                child: Center(
                  child: Text(
                    Utils.txt('quren'),
                    style: StyleTheme.font_white_255_14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
