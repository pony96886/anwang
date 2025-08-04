import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/face/face_pic_child_page.dart';
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
import 'package:provider/provider.dart';
import 'package:image/image.dart' as ImgLib;

class FacePicPage extends StatelessWidget {
  const FacePicPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  Widget build(BuildContext context) {
    return _FacePicPage(isShow: isShow);
  }
}

class _FacePicPage extends BaseWidget {
  const _FacePicPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __FacePicPageState();
  }
}

class __FacePicPageState extends BaseWidgetState<_FacePicPage> {
  final ImagePicker _picker = ImagePicker();
  bool isHud = false;
  Function(int, String, int, int)? fun;
  List<dynamic> navs = [];

  @override
  void didUpdateWidget(covariant _FacePicPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      isHud = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void onCreate() {
    // TODO: implement initState
    setAppTitle(
      titleW: Text(Utils.txt('tphl'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/minepurchasepage/0");
        },
        child: Text(Utils.txt('record'), style: StyleTheme.font_black_7716_14),
      ),
    );
    navs = Provider.of<BaseStore>(context, listen: false).conf?.face_nav ?? [];
  }

  Future<void> imagePickerAssets(int type) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.pngLimitSize(file);
      if (flag) return;
      uploadFileImg(file, type);
    } else {
      // User canceled the picker
    }
  }

  void uploadFileImg(XFile? file, int type) async {
    Utils.startGif(tip: Utils.txt('scz'));
    var data;
    if (kIsWeb) {
      data = await NetworkHttp.xfileHtmlUploadImage(
          file: file, position: 'upload');
    } else {
      data = await NetworkHttp.xfileUploadImage(file: file, position: 'upload');
    }
    Utils.closeGif();
    if (data['code'] == 1) {
      var image = ImgLib.decodeImage(await file?.readAsBytes() ?? []);
      String url = data['msg'].toString();
      int w = image?.width ?? 100;
      int h = image?.height ?? 100;
      fun?.call(type, url, w, h);
    } else {
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  void uploadData({
    String img1 = "",
    int w1 = 0,
    int h1 = 0,
    String img2 = "",
    int w2 = 0,
    int h2 = 0,
    int coins = 0,
    int faceValue = 0,
  }) {
    if (img1.isEmpty) {
      Utils.showText(Utils.txt("sptp"));
      return;
    }
    if (img2.isEmpty) {
      Utils.showText(Utils.txt("qscsptp"));
      return;
    }
    Utils.startGif(tip: Utils.txt("scz"));
    reqFaceModuleAI(
      context,
      ground: img1,
      ground_w: w1,
      ground_h: h1,
      thumb: img2,
      thumb_w: w2,
      thumb_h: h2,
      coins: coins,
    ).then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        Navigator.of(context).pop();
      }
      Utils.showText(value?.msg ?? "", time: 2);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  Widget pageBody(BuildContext context) {
    return isHud
        ? Container()
        : Scaffold(
            floatingActionButton: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                showSheetAlert(
                  imgfun: (t, f) {
                    fun = f;
                    imagePickerAssets(t);
                  },
                  okfun: (s, c, faceValue) {
                    uploadData(
                        img1: s.first["url"],
                        w1: s.first["width"],
                        h1: s.first["height"],
                        img2: s.last["url"],
                        w2: s.last["width"],
                        h2: s.last["height"],
                        coins: c,
                        faceValue: faceValue);
                  },
                );
              },
              child: LocalPNG(
                name: "ai_material_custom",
                height: 32.5.w,
                width: 115.5.w,
                fit: BoxFit.fill,
              ),
            ),
            body: GenCustomNav(
                type: GenCustomNavType.line,
                titles: navs.map((e) => e["name"].toString()).toList(),
                pages: navs.map((e) => FacePicChildPage(id: e["id"])).toList()),
          );
  }

  void showSheetAlert({
    Function(int, Function(int, String, int, int))? imgfun,
    Function(List<Map>, int money, int faceValue)? okfun,
  }) {
    int coins = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.img_coins ??
        0;
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    int money = user?.money ?? 0;
    int remainFaceValue = user?.video_face_value ?? 0;
    String btnTxt = remainFaceValue > 0
        ? Utils.txt('ljscsyac').replaceAll('aa', '$remainFaceValue')
        : Utils.txt('ddjs')
            .replaceAll("00", coins.toString())
            .replaceAll("##", money.toString());
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          String modulURL = "";
          int moduleW = 0;
          int moduleH = 0;
          String picURL = "";
          int picW = 0;
          int picH = 0;
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
              decoration: BoxDecoration(
                color: StyleTheme.whiteColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.w),
                    topLeft: Radius.circular(5.w)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.w),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Utils.txt("srxtfm"),
                          style: StyleTheme.font_black_7716_14_medium,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.close,
                          size: 20.w,
                          color: StyleTheme.blak7716_07_Color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.w),
                    child: DottedBorder(
                      dashPattern: const [3, 1],
                      strokeWidth: 2.w,
                      padding: EdgeInsets.all(2.w),
                      borderPadding: EdgeInsets.zero,
                      color: StyleTheme.blak7716_07_Color,
                      child: Container(
                        width: double.infinity,
                        height: 100.w,
                        decoration: BoxDecoration(color: StyleTheme.whiteColor),
                        child: modulURL.isEmpty
                            ? GestureDetector(
                                onTap: () {
                                  imgfun?.call(0, (t, x, w, h) {
                                    if (t == 1) return;
                                    setBottomSheetState(() {
                                      modulURL = x;
                                      moduleW = w;
                                      moduleH = h;
                                    });
                                  });
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
                                          url: AppGlobal.imgBaseUrl + modulURL,
                                          fit: BoxFit.contain)),
                                  Positioned(
                                    right: 5.w,
                                    top: 5.w,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setBottomSheetState(() {
                                          modulURL = "";
                                          moduleW = 0;
                                          moduleH = 0;
                                        });
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
                  SizedBox(height: 20.w),
                  Text(
                    Utils.txt('sptpgzr'),
                    style: StyleTheme.font_black_7716_14_medium,
                  ),
                  SizedBox(height: 10.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.w),
                    child: DottedBorder(
                      dashPattern: const [3, 1],
                      strokeWidth: 2.w,
                      padding: EdgeInsets.all(2.w),
                      borderPadding: EdgeInsets.zero,
                      color: StyleTheme.blak7716_07_Color,
                      child: Container(
                        width: double.infinity,
                        height: 100.w,
                        decoration: BoxDecoration(color: StyleTheme.whiteColor),
                        child: picURL.isEmpty
                            ? GestureDetector(
                                onTap: () {
                                  imgfun?.call(1, (t, x, w, h) {
                                    if (t == 0) return;
                                    setBottomSheetState(() {
                                      picURL = x;
                                      picW = w;
                                      picH = h;
                                    });
                                  });
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
                                          url: AppGlobal.imgBaseUrl + picURL,
                                          fit: BoxFit.contain)),
                                  Positioned(
                                    right: 5.w,
                                    top: 5.w,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setBottomSheetState(() {
                                          picURL = "";
                                          picW = 0;
                                          picH = 0;
                                        });
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
                  SizedBox(height: 10.w),
                  Text(
                    Utils.txt("djzsmdesc"),
                    style: StyleTheme.font_black_7716_07_12,
                    maxLines: 10,
                  ),
                  SizedBox(height: 10.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          LocalPNG(
                              name: "ai_material_ok",
                              width: 50.w,
                              height: 50.w),
                          SizedBox(height: 2.w),
                          Text(Utils.txt("ljyy"),
                              style: StyleTheme.font_black_7716_07_12)
                        ],
                      ),
                      Column(
                        children: [
                          LocalPNG(
                              name: "ai_material_lter_face",
                              width: 50.w,
                              height: 50.w),
                          SizedBox(height: 2.w),
                          Text(Utils.txt("ryueg"),
                              style: StyleTheme.font_black_7716_07_12)
                        ],
                      ),
                      Column(
                        children: [
                          LocalPNG(
                              name: "ai_material_lter_eye",
                              width: 50.w,
                              height: 50.w),
                          SizedBox(height: 2.w),
                          Text(Utils.txt("tysj"),
                              style: StyleTheme.font_black_7716_07_12)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20.w),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      int mon = Provider.of<BaseStore>(context, listen: false)
                              .user
                              ?.money ??
                          0;
                      int faceValue =
                          Provider.of<BaseStore>(context, listen: false)
                                  .user
                                  ?.img_face_value ??
                              0;

                      if (mon - coins < 0 && faceValue <= 0) {
                        Navigator.of(context).pop();
                        Utils.navTo(context, "/minegoldcenterpage");
                        return;
                      }

                      if (faceValue > 0) {
                        // 有次数不扣金币
                        faceValue = faceValue - 1;
                      } else {
                        mon = mon - coins;
                      }
                      okfun?.call([
                        {
                          "url": modulURL,
                          "width": moduleW,
                          "height": moduleH,
                        },
                        {
                          "url": picURL,
                          "width": picW,
                          "height": picH,
                        }
                      ], mon, faceValue);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: StyleTheme.gradBlue,
                          borderRadius: BorderRadius.all(Radius.circular(5.w))),
                      padding:
                          EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      height: 40.w,
                      alignment: Alignment.center,
                      child: Text(btnTxt, style: StyleTheme.font_white_255_15),
                    ),
                  ),
                  SizedBox(height: 30.w),
                ],
              ),
            );
          });
        });
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
