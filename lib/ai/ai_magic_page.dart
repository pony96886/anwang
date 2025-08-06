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

class AiMagicPage extends StatelessWidget {
  const AiMagicPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  Widget build(BuildContext context) {
    return _AiMagicPage(isShow: isShow);
  }
}

class _AiMagicPage extends BaseWidget {
  const _AiMagicPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __AiMagicPageState();
  }
}

class __AiMagicPageState extends BaseWidgetState<_AiMagicPage> {
  bool isHud = true;
  int page = 1;
  bool netError = false;
  bool noMore = false;
  List<dynamic> array = [];
  List<dynamic> banners = [];
  Function(int, String, int, int)? fun;
  List<dynamic> navs = [];

  @override
  void didUpdateWidget(covariant _AiMagicPage oldWidget) {
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
      titleW: Text(Utils.txt('aimf'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/minepurchasepage/0");
        },
        child: Text(Utils.txt('record'), style: StyleTheme.font_black_7716_14),
      ),
    );
    navs = Provider.of<BaseStore>(context, listen: false).conf?.face_nav ?? [];
    getData();
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

  Future<bool> getData({bool isShow = false}) {
    if (isShow) Utils.startGif(tip: Utils.txt('jzz'));
    return reqGetAiMagicListMaterial(page: page).then((value) {
      if (isShow) Utils.closeGif();
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List<dynamic> tps = List.from(value?.data["material"] ?? []);
      if (page == 1) {
        noMore = false;
        banners = List.from(value?.data["banner"] ?? []);
        array = tps;
      } else if (tps.isNotEmpty) {
        array.addAll(tps);
      } else {
        noMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return noMore;
    });
  }

  @override
  Widget pageBody(BuildContext context) {
    return isHud
        ? LoadStatus.showLoading(mounted)
        : netError
            ? LoadStatus.netError(onTap: () {
                netError = false;
                getData();
              })
            : array.isEmpty
                ? LoadStatus.noData()
                : NestedScrollView(
                    headerSliverBuilder: (cx, flag) {
                      return [
                        SliverToBoxAdapter(
                          child: Container(
                              padding: EdgeInsets.only(
                                  right: StyleTheme.margin,
                                  left: StyleTheme.margin,
                                  bottom: 5.w),
                              child: GeneralBannerAppsListWidget(
                                  width: 1.sw - 26.w, data: banners)),
                        ),
                      ];
                    },
                    body: PullRefresh(
                      onRefresh: () {
                        page = 1;
                        return getData();
                      },
                      onLoading: () {
                        page++;
                        return getData();
                      },
                      child: MasonryGridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: StyleTheme.margin, vertical: 5.w),
                          gridDelegate:
                              const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: array.length,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 10.w,
                          itemBuilder: (cx, index) {
                            dynamic e = array[index];
                            return InkWell(
                              onTap: () {
                                Utils.navTo(context, "/aimagicdetails",
                                    extra: e);
                              },
                              child: Container(
                                height: 250.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFF00000032).withOpacity(.2),
                                  borderRadius: BorderRadius.circular(6.w),
                                ),
                                child: Stack(
                                  children: [
                                    if (e["cover"] != "")
                                      ImageNetTool(
                                        url: e["cover"],
                                        radius: BorderRadius.all(
                                            Radius.circular(6.w)),
                                      ),
                                    Align(
                                      child: Text(
                                        e['title'],
                                        style: TextStyle(
                                          fontSize: 24.w,
                                          fontWeight: FontWeight.w600,
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
