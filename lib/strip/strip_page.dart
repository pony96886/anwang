import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ImgLib;
import 'package:provider/provider.dart';

class StripPage extends StatelessWidget {
  const StripPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  Widget build(BuildContext context) {
    return _StripPage(isShow: isShow);
  }
}

class _StripPage extends BaseWidget {
  const _StripPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __StripPageState();
  }
}

class __StripPageState extends BaseWidgetState<_StripPage> {
  bool isHud = true;
  String imgURL = "";
  int kW = 0;
  int kH = 0;

  final ImagePicker _picker = ImagePicker();

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
    Utils.closeGif();
    Utils.log(data);
    if (data['code'] == 1) {
      var image = ImgLib.decodeImage(await file?.readAsBytes() ?? []);
      imgURL = data['msg'].toString();
      kW = image?.width ?? 100;
      kH = image?.height ?? 100;
      if (mounted) setState(() {});
    } else {
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  void uploadData(int coins, int remainValue) {
    if (imgURL.isEmpty) {
      Utils.showText(Utils.txt("qscsptp"));
      return;
    }
    Utils.startGif(tip: Utils.txt("scz"));
    reqStripAI(context,
            thumb: imgURL,
            width: kW,
            height: kH,
            coins: coins,
            remainValue: remainValue)
        .then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        imgURL = "";
        kW = 0;
        kH = 0;
        if (mounted) setState(() {});
      }
      Utils.showText(value?.msg ?? "", time: 2);
    });
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement initState
    // setAppTitle(
    //   titleW: Text(Utils.txt('aity'), style: StyleTheme.nav_title_font),
    //   rightW: GestureDetector(
    //     behavior: HitTestBehavior.translucent,
    //     onTap: () {
    //       Utils.navTo(context, "/minepurchasepage/2");
    //     },
    //     child: Text(Utils.txt('record'), style: StyleTheme.font_black_7716_14),
    //   ),
    // );

    if (widget.isShow && isHud) {
      isHud = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant _StripPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      isHud = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget pageBody(BuildContext context) {
    int money = Provider.of<BaseStore>(context, listen: false).user?.money ?? 0;
    int coins = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.strip_coins ??
        0;

    int remainValue =
        Provider.of<BaseStore>(context, listen: false).user?.strip_value ?? 0;
    String btnTxt = remainValue > 0
        ? Utils.txt('ljscsyac').replaceAll('aa', '$remainValue')
        : Utils.txt('ddjs')
            .replaceAll("00", coins.toString())
            .replaceAll("##", money.toString());

    return isHud
        ? Container()
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.w),
                    child: DottedBorder(
                      // dashPattern: const [3, 1],
                      strokeWidth: 2.w,
                      padding: EdgeInsets.all(2.w),
                      borderPadding: EdgeInsets.zero,
                      color: StyleTheme.blak7716_07_Color,
                      child: Container(
                        width: double.infinity,
                        height: 150.w,
                        decoration: BoxDecoration(color: StyleTheme.whiteColor),
                        child: imgURL.isEmpty
                            ? GestureDetector(
                                onTap: () {
                                  imagePickerAssets();
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo,
                                        size: 40.w,
                                        color: StyleTheme.blue52Color),
                                    SizedBox(height: 5.w),
                                    Text(Utils.txt("qxzbkbp"),
                                        style: StyleTheme
                                            .font_black_7716_06_11_medium)
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  Center(
                                      child: ImageNetTool(
                                          url: AppGlobal.imgBaseUrl + imgURL,
                                          fit: BoxFit.contain)),
                                  Positioned(
                                    right: 5.w,
                                    top: 5.w,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        imgURL = "";
                                        kW = 0;
                                        kH = 0;
                                        if (mounted) setState(() {});
                                      },
                                      child: LocalPNG(
                                          name: "ai_post_delete",
                                          width: 15.w,
                                          height: 15.w),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.w),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // bool pass = Provider.of<BaseStore>(context, listen: false)
                    //         .user?.pass == 1;
                    // if (pass) {
                    //   //有通卡直接直达，啥都不用判断
                    //   uploadData(money, remainValue);
                    //   return;
                    // }

                    if (money - coins < 0 && remainValue <= 0) {
                      Utils.navTo(context, "/minegoldcenterpage");
                      return;
                    }
                    if (remainValue <= 0) {
                      money = money - coins;
                    }

                    if (remainValue > 0) {
                      remainValue = remainValue - 1;
                    }
                    uploadData(money, remainValue);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: StyleTheme.gradBlue,
                        borderRadius: BorderRadius.all(Radius.circular(5.w))),
                    margin: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                    height: 40.w,
                    alignment: Alignment.center,
                    child: Text(btnTxt, style: StyleTheme.font_white_255_15),
                  ),
                ),
                SizedBox(height: 15.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  child: Text(
                    Utils.txt("djzsmdesc"),
                    style: StyleTheme.font_black_7716_07_12,
                    maxLines: 10,
                  ),
                ),
                SizedBox(height: 20.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  child: Text(
                    Utils.txt("txlxfs"),
                    style: StyleTheme.font_black_7716_14_medium,
                  ),
                ),
                SizedBox(height: 10.w),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 173 / 228,
                  children: ["ai_strip_before", "ai_strip_after"]
                      .map((e) => LocalPNG(name: e))
                      .toList(),
                ),
                SizedBox(height: 20.w),
              ],
            ),
          );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
