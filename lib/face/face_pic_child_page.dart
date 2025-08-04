import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ImgLib;
import 'package:provider/provider.dart';

class FacePicChildPage extends StatefulWidget {
  const FacePicChildPage({Key? key, this.id = 0}) : super(key: key);
  final int id;

  @override
  State<FacePicChildPage> createState() => _FacePicChildPageState();
}

class _FacePicChildPageState extends State<FacePicChildPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  int page = 1;
  List<dynamic> array = [];
  List<dynamic> banners = [];

  String type = "used";
  String sort = "desc";
  List<dynamic> navs = [];

  Function(String, int, int)? fun;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navs = Provider.of<BaseStore>(context, listen: false).conf?.face_sort ?? [];
    getData();
  }

  Future<bool> getData({bool isShow = false}) {
    if (isShow) Utils.startGif(tip: Utils.txt('jzz'));
   return reqGetPics(cate_id: widget.id, page: page, sort: sort, type: type)
        .then((value) {
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
    if (data['code'] == 1) {
      var image = ImgLib.decodeImage(await file?.readAsBytes() ?? []);
      String url = data['msg'].toString();
      int w = image?.width ?? 100;
      int h = image?.height ?? 100;
      fun?.call(url, w, h);
    } else {
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  void uploadData(dynamic e, String url, int w, int h) {
    if (url.isEmpty) {
      Utils.showText(Utils.txt("qscsptp"));
      return;
    }
    int money = Provider.of<BaseStore>(context, listen: false).user?.money ?? 0;
    int remainFaceValue =
        Provider.of<BaseStore>(context, listen: false).user?.img_face_value ??
            0;
    int coins = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.img_coins ??
        0;

    if (remainFaceValue > 0) {
      remainFaceValue = remainFaceValue - 1;
    } else {
      money = money - coins;
    }

    Utils.startGif(tip: Utils.txt("scz"));
    reqFaceAI(context,
            id: e["id"],
            thumb: url,
            width: w,
            height: h,
            coins: money,
            faceValue: remainFaceValue)
        .then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        Navigator.of(context).pop();
      }
      Utils.showText(value?.msg ?? "", time: 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
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
                              child: GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: banners)),
                        ),
                      ];
                    },
                    body: Column(
                      children: [
                        navs.isEmpty
                            ? Container()
                            : Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: StyleTheme.margin,
                                  vertical: 10.w,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: navs.map((e) {
                                    return Row(//
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 10.w),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            if (type == e["type"]) {
                                              sort = sort == "asc"
                                                  ? "desc"
                                                  : "asc";
                                            } else {
                                              type = e["type"];
                                              sort = "desc";
                                            }
                                            if (mounted) setState(() {});
                                            page = 1;
                                            getData(isShow: true);
                                          },
                                          child: Builder(builder: (cx) {
                                            String icon = "ai_sort_normal";
                                            if (e["type"] == type) {
                                              icon = sort == "asc"
                                                  ? "ai_sort_up"
                                                  : "ai_sort_down";
                                            }
                                            return Container(
                                              height: 20.w,
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(e["title"],
                                                      style: StyleTheme
                                                          .font_black_7716_06_15),
                                                  SizedBox(width: 1.w),
                                                  LocalPNG(
                                                    name: icon,
                                                    width: 9.w,
                                                    height: 11.w,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        )
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                        Expanded(
                          child: PullRefresh(
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
                                    horizontal: StyleTheme.margin,
                                    vertical: 5.w),
                                gridDelegate:
                                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                itemCount: array.length,
                                mainAxisSpacing: 10.w,
                                crossAxisSpacing: 10.w,
                                itemBuilder: (cx, index) {
                                  dynamic e = array[index];
                                  return Utils.materialModuleUI(
                                    context,
                                    e,
                                    imgfun: (f) {
                                      fun = f;
                                      imagePickerAssets();
                                    },
                                    okfun: (u, w, h) {
                                      uploadData(e, u, w, h);
                                    },
                                  );
                                }),
                          ),
                        )
                      ],
                    ));
  }
}
