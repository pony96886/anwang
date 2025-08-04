import 'package:deepseek/base/input_container2.dart';
import 'package:common_utils/common_utils.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/input_container.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as ImgLib;
import 'package:image_picker/image_picker.dart';

class MineServicePage extends BaseWidget {
  MineServicePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineServicePageState();
  }
}

class _MineServicePageState extends BaseWidgetState<MineServicePage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  int page = 1;
  List chats = [];
  RegExp regExp = RegExp(
    r"(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?",
    multiLine: true,
  );
  ScrollController scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  void getData() {
    reqChatList(page: page).then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return;
      }
      List tp = List.from(value?.data);
      if (page == 1) {
        noMore = false;
        chats = tp;
      } else if (tp.isNotEmpty) {
        chats.addAll(tp);
      } else {
        noMore = true;
      }
      isHud = false;
      setState(() {});
      page++;
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
      titleW: Text(Utils.txt('zuxkf'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/minenorquestionpage");
        },
        child: Text(
          Utils.txt('chjwt'),
          style: StyleTheme.font_black_7716_14,
        ),
      ),
    );
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    scrollController.dispose();
  }

  //特殊字符处理
  Widget characterDeal(String msg) {
    var isPath = regExp.hasMatch(msg);
    var pathMsg = msg.replaceAll('http', '[deepseek]http');
    var pathList = pathMsg.split('[deepseek]');
    var textList = [];
    for (var i = 0; i < pathList.length; i++) {
      if (regExp.hasMatch(pathList[i])) {
        var newMsg = regExp.stringMatch(pathList[i]) == null
            ? pathList[i]
            : pathList[i].replaceAll(regExp.stringMatch(pathList[i]) ?? "",
                '[deepseek]${regExp.stringMatch(pathList[i])}[deepseek]');
        textList.addAll(newMsg.split('[deepseek]'));
      } else {
        textList.add(pathList[i]);
      }
    }
    return isPath
        ? Text.rich(TextSpan(
            children: textList
                .map((e) => TextSpan(
                      text: e,
                      style: TextStyle(
                        fontSize: 15.w,
                        color: regExp.hasMatch(e)
                            ? const Color.fromRGBO(25, 103, 210, 1)
                            : StyleTheme.blak7716Color,
                        decoration: regExp.hasMatch(e)
                            ? TextDecoration.underline
                            : null,
                        height: 1.7,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (regExp.hasMatch(e)) {
                            Utils.openURL(e);
                          }
                        },
                    ))
                .toList()))
        : Text(
            msg,
            style: TextStyle(
              fontSize: 15.w,
              color: StyleTheme.blak7716_06_Color,
              height: 1.7,
            ),
            softWrap: true,
          );
  }

  //用户对话
  userDialogue(dynamic data) {
    var actualw =
        ScreenUtil().screenWidth - StyleTheme.margin * 4 - 36.w - 10.w;
    var split =
        data["message"]?.toString().replaceAll("&amp;", "?").split("??");
    var url = split?.first ?? "";
    var whs = split?.last.split("_") ?? [];
    //默认值150
    var width = 150.0;
    var height = 150.0;
    if (whs.length > 1) {
      width = double.parse(whs.first);
      height = double.parse(whs.last);
      double scale = height / width;
      width = width > actualw ? actualw : width;
      height = width * scale;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.all(5.w),
            child: Text(
              data["createdAt"] ?? "",
              style: StyleTheme.font_black_7716_04_12,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.w),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                      color: StyleTheme.whiteColor,
                      // border: Border.all(
                      //     color: StyleTheme.yellow24718713Color.withAlpha(50),
                      //     width: 0.5.w),
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.all(StyleTheme.margin),
                  child: data["messageType"] == 1
                      ? characterDeal(data["message"])
                      : SizedBox(
                          width: width,
                          height: height,
                          child: ImageNetTool(url: url),
                        ),
                ),
              ),
              SizedBox(width: 10.w),
              LocalPNG(
                name: 'ai_mine_me',
                width: 36.w,
                height: 36.w,
              ),
            ],
          ),
        )
      ],
    );
  }

  //客服对话
  serviceDialogue(dynamic data) {
    var actualw =
        ScreenUtil().screenWidth - StyleTheme.margin * 4 - 36.w - 10.w;
    var split =
        data["message"]?.toString().replaceAll("&amp;", "?").split("??");
    var url = split?.first ?? "";
    var whs = split?.last.split("_") ?? [];
    //默认值150
    var width = 150.0;
    var height = 150.0;
    if (whs.length > 1) {
      width = double.parse(whs.first);
      height = double.parse(whs.last);
      double scale = height / width;
      width = width > actualw ? actualw : width;
      height = width * scale;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.all(5.w),
            child: Text(
              data["createdAt"] ?? "",
              style: StyleTheme.font_black_7716_04_12,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocalPNG(
                name: 'ai_mine_server',
                width: 36.w,
                height: 36.w,
              ),
              SizedBox(width: 10.w),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                      color: StyleTheme.whiteColor,
                      // border: Border.all(color: Colors.white, width: 0.5.w),
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.all(StyleTheme.margin),
                  child: data["messageType"] == 1
                      ? characterDeal(data["message"])
                      : SizedBox(
                          width: width.w,
                          height: height.w,
                          child: ImageNetTool(url: url),
                        ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> imagePickerAssets() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.pngLimitSize(file);
      if (flag) return;
      uploadFileImg(file);
    } else {
      // User canceled the picker
    }
  }

  void uploadFileImg(XFile? file) async {
    Utils.startGif(tip: Utils.txt('scz'));
    var data;
    if (kIsWeb) {
      data = await NetworkHttp.xfileHtmlUploadImage(
          file: file, position: 'upload');
    } else {
      data = await NetworkHttp.xfileUploadImage(file: file, position: 'upload');
    }
    Utils.log(data);
    if (data['code'] == 1) {
      var image = ImgLib.decodeImage(await file?.readAsBytes() ?? []);
      String url = data['msg'].toString() +
          "??${image?.width ?? 100}_${image?.height ?? 100}";
      reqSendContent(url, 2, 0).then((value) {
        Utils.closeGif();
        if (value?.status == 1) {
          Map msgResult = {
            "messageType": 2,
            "status": 1,
            "createdAt":
                DateUtil.formatDate(DateTime.now(), format: DateFormats.full),
            "message": AppGlobal.imgBaseUrl + url,
          };
          chats.insert(0, msgResult);
          setState(() {});
        } else {
          Utils.showText(Utils.txt('tpsbcs'));
        }
      });
    } else {
      Utils.closeGif();
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  //发送消息
  void sendContent(String text) async {
    if (text.isNotEmpty) {
      Utils.startGif(tip: Utils.txt('fasz'));
      reqSendContent(text, 1, 0).then((value) {
        Utils.closeGif();
        if (value?.status == 1) {
          Map msgResult = {
            "messageType": 1,
            "status": 1,
            "createdAt":
                DateUtil.formatDate(DateTime.now(), format: DateFormats.full),
            "message": text,
          };
          chats.insert(0, msgResult);
          setState(() {});
        } else {
          Utils.showText(Utils.txt('wlbjcs'));
        }
      });
    } else {
      Utils.showText(Utils.txt('qsrnr'));
    }
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : InputContainer2(
                bg: StyleTheme.whiteColor,
                onEditingCompleteText: ((value) {
                  sendContent(value.toString().trim());
                }),
                onSelectPicComplete: () {
                  imagePickerAssets();
                },
                labelText: Utils.txt('qsrxx'),
                child: chats.isEmpty
                    ? LoadStatus.noData()
                    : Column(
                        children: [
                          Container(
                            height: 30.w,
                            width: double.infinity,
                            decoration:
                                BoxDecoration(color: StyleTheme.whiteColor),
                            child: Center(
                              child: Text(Utils.txt("zxkfts"),
                                  textAlign: TextAlign.center,
                                  style: StyleTheme.font_blue52_12),
                            ),
                          ),
                          SizedBox(height: 10.w),
                          Expanded(
                            child: ListView.builder(
                                reverse: true,
                                shrinkWrap: true,
                                controller: scrollController,
                                padding: EdgeInsets.symmetric(
                                    horizontal: StyleTheme.margin),
                                itemCount: chats.length,
                                itemBuilder: (context, index) {
                                  dynamic e = chats[index];
                                  return e["status"] == 1
                                      ? userDialogue(e)
                                      : serviceDialogue(e);
                                }),
                          )
                        ],
                      ),
              );
  }
}
