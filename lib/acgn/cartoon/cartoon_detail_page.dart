// ignore_for_file: prefer_if_null_operators

import 'package:deepseek/base/base_comment_page.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/input_container.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/base/shaort_cartoon_mv_player.dart';
import 'package:deepseek/base/shortv_mv_player.dart';
import 'package:deepseek/util/download_utils.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/page_cache_mixin.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class CartoonDetailPage extends BaseWidget {
  CartoonDetailPage({Key? key, this.id = '0'}) : super(key: key);
  final String id;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _CartoonDetailPageState();
  }
}

class _CartoonDetailPageState extends BaseWidgetState<CartoonDetailPage> {
  bool isHud = true;
  dynamic videoInfo;
  List<dynamic> recdList = []; //推荐数据
  List<dynamic> banners = []; //广告数据

  void getData(String id) {
    reqCartoonDetail(id: id).then((value) {
      if (value?.status == 1) {
        videoInfo = value?.data['detail'];
        banners = List.from(value?.data["banner"] ?? []);

        recdList = List.from(value?.data['recommend'] ?? []);

        isHud = false;
        if (mounted) setState(() {});
      } else {
        Utils.showText(
          value?.msg ?? "",
          call: () {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) context.pop();
            });
          },
        );
      }
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
    getData(widget.id);
  }

  @override
  Widget pageBody(BuildContext context) {
    return Container(
      color: StyleTheme.bgColor, // isHud ? StyleTheme.bgColor : Colors.black,
      child: isHud
          ? LoadStatus.showLoading(mounted)
          : Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: StyleTheme.topHeight),
                    SizedBox(
                      width: ScreenUtil().screenWidth,
                      height: ScreenUtil().screenWidth / 16 * 9,
                      child: ShorCartoonMvPlayer(info: videoInfo),
                    ),
                    Expanded(
                      child: Container(
                        color: StyleTheme.bgColor,
                        child: GenCustomNav(
                          type: GenCustomNavType.none,
                          titles: [
                            Utils.txt('janje'),
                            Utils.txt('pl') + "(${videoInfo['comment_ct']})"
                          ],
                          pages: [
                            PageCacheMixin(
                              child: VideoIntroduceChildPage(
                                videoInfo: videoInfo,
                                banners: banners,
                                recdList: recdList,
                              ),
                            ),
                            PageCacheMixin(
                                child: BaseCommentPage(
                              id: '${videoInfo['id']}',
                              type: 'cartoon',
                            )
                                // VideoCommentChildPage(id: ),
                                ),
                          ],
                          defaultStyle: StyleTheme.font_gray_153_16,
                          selectStyle: StyleTheme.font_black_7716_16_medium,
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  right: 20.w,
                  bottom: 60.w,
                  child: GestureDetector(
                    onTap: () {
                      finish();
                    },
                    child: Container(
                      height: 40.w,
                      width: 40.w,
                      decoration: BoxDecoration(
                          gradient: StyleTheme.gradBlue,
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.w))),
                      child: Center(
                        child: Text(
                          Utils.txt("fh"),
                          style: StyleTheme.font_white_255_12,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  void didPush() {
    // Utils.setStatusBar(isLight: true, isLanch: false);
  }

  @override
  void didPop() {
    // Utils.setStatusBar(isLanch: false);
  }

  @override
  void didPopNext() {
    // Utils.setStatusBar(isLight: true, isLanch: false);
  }

  @override
  void didPushNext() {
    // Utils.setStatusBar(isLanch: false);
  }
}

//简介
class VideoIntroduceChildPage extends StatefulWidget {
  VideoIntroduceChildPage({
    Key? key,
    required this.videoInfo,
    required this.banners,
    required this.recdList,
  }) : super(key: key);
  final dynamic videoInfo;
  final List<dynamic> banners;
  final List<dynamic> recdList;

  @override
  State<VideoIntroduceChildPage> createState() =>
      _VideoIntroduceChildPageState();
}

class _VideoIntroduceChildPageState extends State<VideoIntroduceChildPage> {
  late bool useAppsList =
      Provider.of<BaseStore>(context, listen: false).conf?.adVersion == 1;

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil().screenWidth - StyleTheme.margin * 2;
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      children: [
        SizedBox(height: 5.w),
        Text(
          widget.videoInfo["title"] ?? "",
          style: StyleTheme.font_black_7716_14,
          maxLines: 2,
        ),
        SizedBox(height: 20.w),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${Utils.renderFixedNumber(widget.videoInfo["view_fct"] ?? 0)}${Utils.txt('cbf')}',
              style: StyleTheme.font_black_7716_04_13,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                collectMv();
              },
              child: btnWidget(
                iconName: widget.videoInfo["is_favorite"] == 1
                    ? "ai_video_favorite_on"
                    : "ai_video_favorite_off",
                title: Utils.renderFixedNumber(
                    widget.videoInfo["favorite_fct"] ?? 0),
                // style: widget.videoInfo["is_favorite"] == 1
                //     ? StyleTheme.font_blue52_14
                //     : StyleTheme.font_gray_95_14,
              ),
            ),
            SizedBox(width: 16.w),
            GestureDetector(
              onTap: () {
                Utils.navTo(context, "/minesharepage");
              },
              child: btnWidget(
                iconName: 'ai_video_share',
                title: Utils.txt('fenx'),
                // style: StyleTheme.font_gray_95_14,
              ),
            ),
            SizedBox(width: 16.w),
            GestureDetector(
              onTap: () {
                downLoadMV();
              },
              child: btnWidget(
                iconName: 'ai_video_download',
                title: Utils.txt('xiazi'),
                // style: StyleTheme.font_gray_95_14,
              ),
            )
          ],
        ),
        widget.banners.isEmpty
            ? Container(height: 10.w)
            : Container(
                padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
                child: useAppsList
                    ? GeneralBannerAppsListWidget(
                        width: 1.sw - 26.w, data: widget.banners)
                    : Utils.bannerSwiper(
                        width: width,
                        whRate: 2 / 7,
                        radius: 3,
                        data: widget.banners,
                      ),
              ),
        widget.recdList.isEmpty
            ? Center(child: LoadStatus.noData())
            : Column(
                children: [
                  Row(
                    children: [
                      Text(Utils.txt('wntj'),
                          style: StyleTheme.font_black_7716_16_blod),
                    ],
                  ),
                  SizedBox(height: 5.w),
                  GridView.builder(
                      cacheExtent: ScreenUtil().screenHeight * 5,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          // horizontal: StyleTheme.margin,
                          vertical: ScreenUtil().setWidth(10)),
                      itemCount: widget.recdList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 171 / 122,
                      ),
                      itemBuilder: (context, index) {
                        var e = widget.recdList[index];
                        return Utils.videoModuleUI2(context, e,
                            isCartoon: true);
                      }),
                  SizedBox(height: 20.w),
                ],
              ),
      ],
    );
  }

  //复用按钮组件
  Widget btnWidget(
      {String iconName = "", String title = "", TextStyle? style}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LocalPNG(
          name: iconName,
          width: 18.5.w,
          height: 18.5.w,
        ),
        SizedBox(width: 3.w),
        Text(
          title,
          style: style ?? StyleTheme.font_black_7716_04_13,
        )
      ],
    );
  }

  //下载视频
  void downLoadMV() async {
    if (kIsWeb) {
      Utils.showText(Utils.txt('tsadsy'));
      return;
    }
    Map taskInfo = {
      "id": widget.videoInfo["id"].toString(),
      "urlPath": "",
      "title": widget.videoInfo["title"],
      "cover_thumb": Utils.getPICURL(widget.videoInfo),
      "downloading": false,
      "isWaiting": true
    };
    Box box = await Hive.openBox('deepseek_video_box');
    List tasks = box.get('download_video_tasks') ?? [];
    int existTaskIndex = tasks.indexWhere((e) => e["id"] == taskInfo["id"]);
    if (tasks.isNotEmpty && existTaskIndex != -1) {
      Map info = tasks[existTaskIndex];
      if (info['progress'] == 1) {
        Utils.showText(Utils.txt("wjyxz"));
      } else {
        Utils.showText(Utils.txt("dqrwcz"));
      }
      return;
    }

    Utils.startGif(tip: Utils.txt('jzz'));
    reqCartoonDownLoadNum(id: widget.videoInfo["id"]).then((value) {
      Utils.closeGif();
      if (value?.status == 1) {
        taskInfo['urlPath'] = value?.data['downloadUrl'] ?? '';
        DownloadUtils.createDownloadTask(taskInfo);
      } else {
        Utils.showText(value?.msg ?? '');
      }
    });
  }

  void collectMv() {
    reqUserFavorite(id: widget.videoInfo["id"], type: 15).then((value) {
      if (value?.status == 1) {
        widget.videoInfo["is_favorite"] = value?.data["is_favorite"];
        widget.videoInfo["is_favorite"] == 1
            ? widget.videoInfo["favorite_fct"]++
            : widget.videoInfo["favorite_fct"]--;
        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? "");
      }
    });
  }
}
