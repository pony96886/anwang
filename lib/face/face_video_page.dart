import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/face/face_video_child_page.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FaceVideoPage extends StatelessWidget {
  const FaceVideoPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  Widget build(BuildContext context) {
    return _FaceVideoPage(isShow: isShow);
  }
}

class _FaceVideoPage extends BaseWidget {
  const _FaceVideoPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __FaceVideoPageState();
  }
}

class __FaceVideoPageState extends BaseWidgetState<_FaceVideoPage> {
  bool isHud = false;
  List<dynamic> navs = [];

  @override
  void onCreate() {
    // TODO: implement initState
    setAppTitle(
      titleW: Text(Utils.txt('sphl'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/minepurchasepage/1");
        },
        child: Text(Utils.txt('record'), style: StyleTheme.font_black_7716_14),
      ),
    );
    navs = Provider.of<BaseStore>(context, listen: false).conf?.video_nav ?? [];
  }

  @override
  void didUpdateWidget(covariant _FaceVideoPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      isHud = false;
      if (mounted) setState(() {});
    }
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
    return Scaffold(
      floatingActionButton: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/picmatepage/1");
        },
        child: LocalPNG(
          name: "ai_material_recm",
          height: 32.5.w,
          width: 115.5.w,
          fit: BoxFit.fill,
        ),
      ),
      body: isHud
          ? Container()
          : GenCustomNav(
              type: GenCustomNavType.line,
              titles: navs.map((e) => e["name"].toString()).toList(),
              pages: navs.map((e) => FaceVideoChildPage(id: e["id"])).toList()),
    );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
