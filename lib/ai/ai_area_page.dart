import 'package:deepseek/ai/ai_girl_page.dart';
import 'package:deepseek/ai/ai_magic_page.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/face/face_pic_page.dart';
import 'package:deepseek/face/face_video_page.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/face/face_pic_child_page.dart';
import 'package:deepseek/strip/strip_page.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as ImgLib;

class AIAreaPage extends StatelessWidget {
  const AIAreaPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  Widget build(BuildContext context) {
    return _AIAreaPage(isShow: isShow);
  }
}

class _AIAreaPage extends BaseWidget {
  const _AIAreaPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __AIAreaPageState();
  }
}

class __AIAreaPageState extends BaseWidgetState<_AIAreaPage> {
  final ImagePicker _picker = ImagePicker();
  bool isHud = true;
  Function(int, String, int, int)? fun;
  List<dynamic> navs = [];

  int _currentIndex = 0;

  dynamic discrip;

  @override
  void didUpdateWidget(covariant _AIAreaPage oldWidget) {
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
      titleW: Text(Utils.txt('hl'), style: StyleTheme.nav_title_font),
      // rightW: GestureDetector(
      //   behavior: HitTestBehavior.translucent,
      //   onTap: () {
      //     Utils.navTo(context, "/minepurchasepage/0");
      //   },
      //   child: Text(Utils.txt('record'), style: StyleTheme.font_black_7716_14),
      // ),
    );
    navs = Provider.of<BaseStore>(context, listen: false).conf?.face_nav ?? [];

    discrip = UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == 'IndexNavJump') {
        int index = event.arg["index"];

        // selectIndex = index;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    discrip.cancel();
    super.dispose();
  }

  @override
  Widget pageBody(BuildContext context) {
    return isHud
        ? Container()
        : Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: StyleTheme.topHeight,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      GenCustomNav(
                        // isCenter: true,
                        type: GenCustomNavType.none,
                        leftSideMargin: 20.w,
                        whichUseFor: 'AI',
                        inedxFunc: (p0) {
                          _currentIndex = p0;
                        },
                        titles: [
                          Utils.txt('aihh'),
                          Utils.txt('aimf'),
                          Utils.txt('tphl'),
                          Utils.txt('sphl'),
                          Utils.txt('aity'),
                          Utils.txt('ainy'),
                        ],
                        pages: [
                          Container(),
                          Container(),
                          FacePicPage(
                            isShow: widget.isShow,
                          ),
                          FaceVideoPage(
                            isShow: widget.isShow,
                          ),
                          StripPage(
                            isShow: widget.isShow,
                          ),
                          AIGirlPage(
                            isShow: widget.isShow,
                          ),
                        ],
                        selectStyle: StyleTheme.font_blue52_17_medium,
                        defaultStyle: StyleTheme.font_black_7716_06_16,
                      ),
                      Container(
                        height: StyleTheme.navHegiht,
                        alignment: Alignment.centerRight,
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (_currentIndex >= 3) {
                              _currentIndex = 0;
                            }
                            Utils.navTo(
                                context, "/minepurchasepage/$_currentIndex");
                          },
                          child: Container(
                            width: 30.w,
                            height: 25.w,
                            alignment: Alignment.topCenter,
                            child: Text(Utils.txt('record'),
                                style: StyleTheme.font_black_7716_07_14),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
