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
            onPressed: () {},
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
