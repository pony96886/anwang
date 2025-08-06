import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/face/face_pic_child_page.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as ImgLib;

class AiMagicDetailsPage extends StatelessWidget {
  const AiMagicDetailsPage({Key? key, this.isShow = false, this.material})
      : super(key: key);
  final bool isShow;
  final dynamic material;

  @override
  Widget build(BuildContext context) {
    return _AiMagicDetailsPage(
      isShow: isShow,
      material: this.material,
    );
  }
}

class _AiMagicDetailsPage extends BaseWidget {
  const _AiMagicDetailsPage({Key? key, this.isShow = false, this.material})
      : super(key: key);
  final bool isShow;
  final dynamic material;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __AiMagicDetailsPageState();
  }
}

class __AiMagicDetailsPageState extends BaseWidgetState<_AiMagicDetailsPage> {
  final ImagePicker _picker = ImagePicker();
  Function(int, String, int, int)? fun;

  @override
  void didUpdateWidget(covariant _AiMagicDetailsPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void onCreate() {
    // TODO: implement initState
    setAppTitle(
      titleW: Text(widget.material['title'], style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/minepurchasepage/0");
        },
        child: Text(Utils.txt('gz'), style: StyleTheme.font_black_7716_14),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
    int remainMagicValue = user?.ai_magic_value ?? 0;
    String btnTxt = remainMagicValue > 0
        ? Utils.txt('ljscsyac').replaceAll('aa', '$remainMagicValue')
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
                color: Color(0xFF161622),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.w),
                    topLeft: Radius.circular(10.w)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.w),
                  Text(
                    Utils.txt("srhffm"),
                    style: TextStyle(
                        color: Color(0xffd8d8d8),
                        fontSize: 15.w,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 3.w),
                  Text(
                    Utils.txt("rlscsl"),
                    style: TextStyle(
                        color: Color(0xffd8d8d899).withOpacity(.6),
                        fontSize: 15.w),
                  ),
                  SizedBox(height: 25.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          LocalPNG(
                            name: "ai_magic_tip_1",
                            width: 79.w,
                            height: 105.3.w,
                          ),
                          SizedBox(
                            height: 5.8.w,
                          ),
                          Text(
                            Utils.txt("jsz"),
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.w),
                          ),
                          SizedBox(
                            height: 4.w,
                          ),
                          LocalPNG(
                            name: "ai_magic_tip_success",
                            width: 14.w,
                            height: 14.w,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          LocalPNG(
                            name: "ai_magic_tip_2",
                            width: 79.w,
                            height: 105.3.w,
                          ),
                          SizedBox(
                            height: 5.8.w,
                          ),
                          Text(
                            Utils.txt("ssyzd"),
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.w),
                          ),
                          SizedBox(
                            height: 4.w,
                          ),
                          LocalPNG(
                            name: "ai_magic_tip_error",
                            width: 14.w,
                            height: 14.w,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          LocalPNG(
                            name: "ai_magic_tip_3",
                            width: 79.w,
                            height: 105.3.w,
                          ),
                          SizedBox(
                            height: 5.8.w,
                          ),
                          Text(
                            Utils.txt("bszm"),
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.w),
                          ),
                          SizedBox(
                            height: 4.w,
                          ),
                          LocalPNG(
                            name: "ai_magic_tip_error",
                            width: 14.w,
                            height: 14.w,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          LocalPNG(
                            name: "ai_magic_tip_4",
                            width: 79.w,
                            height: 105.3.w,
                          ),
                          SizedBox(
                            height: 5.8.w,
                          ),
                          Text(
                            Utils.txt("gymh"),
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.w),
                          ),
                          SizedBox(
                            height: 4.w,
                          ),
                          LocalPNG(
                            name: "ai_magic_tip_error",
                            width: 14.w,
                            height: 14.w,
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 25.w),
                  SizedBox(
                    height: 45.w,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // int mon = Provider.of<BaseStore>(context, listen: false)
                        //         .user
                        //         ?.money ??
                        //     0;
                        // int magicValue =
                        //     Provider.of<BaseStore>(context, listen: false)
                        //             .user
                        //             ?.ai_magic_value ??
                        //         0;
                        //
                        // if (mon - coins < 0 && magicValue <= 0) {
                        //   Navigator.of(context).pop();
                        //   Utils.navTo(context, "/minegoldcenterpage");
                        //   return;
                        // }
                        //
                        // if (magicValue > 0) {
                        //   // 有次数不扣金币
                        //   magicValue = magicValue - 1;
                        // } else {
                        //   mon = mon - coins;
                        // }

                        fun = (t, x, w, h) {
                          if (t == 1) return;
                          Utils.startGif(tip: Utils.txt('tjz'));

                          reqGenerateVideo(widget.material['id'], x, w, h)
                              .then((val) {
                            Utils.closeGif();
                            if (val == null) {
                              Utils.showText("网络异常，请稍后再试");
                              return;
                            }
                            if (val!.status != 1) {
                              Utils.showText(val.msg!);
                            } else {
                              Utils.showText("提交成功");
                              Navigator.of(context).pop();
                            }
                          });
                        };
                        imagePickerAssets(0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF579bf1),
                              Color(0xFF3D54F5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(45.w),
                        ),
                        child: Text(
                          btnTxt,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.w),
                  Text(
                    Utils.txt("storage_tip"),
                    style: TextStyle(
                        color: Color(0xffffffff99).withOpacity(.6),
                        fontSize: 12.w),
                  ),
                  SizedBox(height: 16.w),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget pageBody(BuildContext context) {
    int coins = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.img_coins ??
        0;
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    int money = user?.money ?? 0;
    int remainMagicValue = user?.ai_magic_value ?? 0;
    String btnTxt = remainMagicValue > 0
        ? Utils.txt('ljscsyac').replaceAll('aa', '$remainMagicValue')
        : Utils.txt('ddjs')
            .replaceAll("00", coins.toString())
            .replaceAll("##", money.toString());

    return Scaffold(
      backgroundColor: Color(0xFF0b0a21),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(15.w),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Utils.navTo(context,
                      "/unplayerpage/${Uri.encodeComponent(widget.material["cover"])}/${Uri.encodeComponent(widget.material["video"])}");
                },
                child: Container(
                  height: 398.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageNetTool(
                        url: widget.material["cover"],
                        radius: BorderRadius.all(Radius.circular(14.w)),
                      ),
                      LocalPNG(
                        name: "ai_magic_play",
                        width: 85.5.w,
                        height: 85.5.w,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15.w,
              ),
              Text(
                Utils.txt('xzyzzp'),
                style: TextStyle(fontSize: 15.w, fontWeight: FontWeight.bold),
              ),
              Text(
                Utils.txt('zpdxbcg1m'),
                style: TextStyle(
                    fontSize: 15.w, color: Color(0xFFffffff99).withOpacity(.6)),
              ),
              SizedBox(
                height: 20.5.w,
              ),
              Row(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFffffff0c).withOpacity(.05),
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LocalPNG(
                          name: "ai_magic_upload",
                          width: 35.w,
                          height: 35.w,
                        ),
                        SizedBox(
                          height: 4.5.w,
                        ),
                        Text(
                          Utils.txt("djsc"),
                          style: TextStyle(
                              color: Color(0xFFffffffcc).withOpacity(.8),
                              fontSize: 12.w),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          )),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.w, horizontal: 15.w),
        child: SizedBox(
          height: 45.w,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              showSheetAlert();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF579bf1),
                    Color(0xFF3D54F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(45.w),
              ),
              child: Text(
                btnTxt,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
