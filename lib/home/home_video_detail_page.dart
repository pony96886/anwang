// ignore_for_file: prefer_if_null_operators

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/input_container.dart';
import 'package:deepseek/base/input_container2.dart';
import 'package:deepseek/base/request_api.dart';
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

class HomeVideoDetailPage extends BaseWidget {
  const HomeVideoDetailPage({Key? key, this.id = '0'}) : super(key: key);
  final String id;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeVideoDetailPageState();
  }
}

class _HomeVideoDetailPageState extends BaseWidgetState<HomeVideoDetailPage> {
  bool isHud = true;
  dynamic videoInfo;
  List<dynamic> recdList = []; //推荐数据
  List<dynamic> banners = []; //广告数据

  void getData(String id) {
    reqVideoDetail(id: id).then((value) {
      if (value?.status == 1) {
        videoInfo = value?.data['detail'];
        banners = List.from(value?.data["banner"] ?? []);
        getRecList();
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

  void getRecList() {
    reqVideoDetailRecList(id: widget.id).then((value) {
      if (value?.status == 1) {
        recdList = List.from(value?.data ?? []);
      }
      isHud = false;
      if (mounted) setState(() {});
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
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    SizedBox(
                        width: ScreenUtil().screenWidth,
                        height: ScreenUtil().screenWidth / 16 * 9,
                        child: ShortvMvPlayer(info: videoInfo)),
                    Expanded(
                      child: Container(
                        color: StyleTheme.bgColor,
                        child: GenCustomNav(
                          type: GenCustomNavType.none,
                          titles: [
                            Utils.txt('janje'),
                            Utils.txt('pl') + "(${videoInfo['count_comment']})"
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
                                child:
                                    VideoCommentChildPage(id: videoInfo['id'])),
                          ],
                          defaultStyle: StyleTheme.font_black_7716_04_16,
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
  void onDestroy() {}

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
  const VideoIntroduceChildPage({
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
          style: StyleTheme.font_black_7716_15,
          maxLines: 2,
        ),
        SizedBox(height: 20.w),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${Utils.renderFixedNumber(widget.videoInfo["play_ct"] ?? 0)}${Utils.txt('cbf')}',
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
                title:
                    Utils.renderFixedNumber(widget.videoInfo["favorites"] ?? 0),
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
            ? Container(height: 20.w)
            : Container(
                padding: EdgeInsets.only(top: 10.w, bottom: 15.w),
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
                      Text(
                        Utils.txt('wntj'),
                        style: StyleTheme.font_black_7716_16_blod,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.w),
                  // Utils.videoModuleUI2(context, data)
                  GridView.count(
                    padding: EdgeInsets.only(bottom: 10.w),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 1,
                    mainAxisSpacing: 10.w,
                    crossAxisSpacing: 0,
                    childAspectRatio: 350 / 108,
                    children: widget.recdList.map((e) {
                      return GestureDetector(
                        onTap: () {
                          if (e["url"] == null) {
                            Utils.navTo(
                                context, "/homevideodetailpage/${e["id"]}",
                                replace: true);
                            return;
                          }
                          Utils.openRoute(context, e);
                        },
                        child: Container(
                          height: width / 2 / 16 * 9,
                          decoration: BoxDecoration(
                            color: StyleTheme.whiteColor,
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: width / 2,
                                height: double.infinity,
                                child: ImageNetTool(
                                  url: Utils.getPICURL(e),
                                  radius:
                                      BorderRadius.all(Radius.circular(3.w)),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10.w),
                                    Text(
                                      e["title"] ?? "",
                                      style: StyleTheme.font_black_7716_15,
                                      maxLines: 2,
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "${Utils.getHMTime(e["duration"] ?? 0)}",
                                            style: StyleTheme.font_gray_153_11),
                                        Text(
                                            "${Utils.renderFixedNumber(e["play_ct"] ?? 0)}${Utils.txt("cbf")}",
                                            style: StyleTheme.font_gray_153_11),
                                        // Spacer(),
                                      ],
                                    ),
                                    SizedBox(height: 10.w),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.w),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
    reqDownLoadNum(id: widget.videoInfo["id"]).then((value) {
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
    int type = widget.videoInfo["mv_type"] == 2 ? 11 : 1; //防止本身视频数据配置的是短视频，导致收藏类型错误
    reqUserFavorite(id: widget.videoInfo["id"], type: type).then((value) {
      if (value?.status == 1) {
        widget.videoInfo["is_favorite"] =
            widget.videoInfo["is_favorite"] == 0 ? 1 : 0;
        widget.videoInfo["is_favorite"] == 1
            ? widget.videoInfo["favorites"]++
            : widget.videoInfo["favorites"]--;
        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? "");
      }
    });
  }
}

//评论
class VideoCommentChildPage extends StatefulWidget {
  const VideoCommentChildPage({Key? key, this.id = 0}) : super(key: key);
  final int id;

  @override
  State<VideoCommentChildPage> createState() => _VideoCommentChildPageState();
}

class _VideoCommentChildPageState extends State<VideoCommentChildPage> {
  int page = 1;
  bool noMore = false;
  bool networkErr = false;
  bool isHud = true;
  String last_ix = "";
  List<dynamic> comentsList = [];
  FocusNode xcfocusNode = FocusNode();
  String tip = Utils.txt("wyddxf");
  String postid = "0";
  String commid = "0";
  bool isReplay = false;

  void resetXcfocusNode() {
    isReplay = false;
    tip = Utils.txt("wyddxf");
    xcfocusNode.unfocus();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future<bool> getData() {
    return reqMvComment(id: widget.id, last_ix: last_ix, page: page).then((value) {
      if (value?.data == null) {
        networkErr = true;
        if (mounted) setState(() {});
        return false;
      }
      last_ix = value?.data["last_ix"] == null ? "" : value?.data["last_ix"];
      List st = List.from(value?.data["list"] ?? []);
      if (page == 1) {
        noMore = false;
        comentsList = st;
      } else if (st.isNotEmpty) {
        comentsList.addAll(st);
      } else {
        noMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return noMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Utils.unFocusNode(context);
      },
      child: InputContainer2(
        focusNode: xcfocusNode,
        bg: StyleTheme.whiteColor,
        labelText: Utils.txt("wyddxf"),
        onEditingCompleteText: (value) {
          inputTxt(value);
        },
        child: networkErr
            ? LoadStatus.netError(onTap: () {
                networkErr = false;
                getData();
              })
            : isHud
                ? LoadStatus.showLoading(mounted)
                : PullRefresh(
                    onLoading: () {
                      page++;
                      return getData();
                    },
                    child: comentsList.isEmpty
                        ? LoadStatus.noData(w: 130)
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: StyleTheme.margin),
                            itemCount: comentsList.length,
                            itemBuilder: (context, index) {
                              return reviewWidget(comentsList[index]);
                            }),
                  ),
      ),
    );
  }

  void inputTxt(String value) {
    if (value.isEmpty) {
      Utils.showText(Utils.txt('qsrnr'));
      return;
    }
    Utils.startGif(tip: Utils.txt('jzz'));
    reqCreateMvComment(id: widget.id, content: value).then((value) {
      Utils.closeGif();
      Utils.showText(value?.msg ?? '');
    });
  }

  Widget reviewWidget(dynamic data) {
    double w = 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 15.w),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            height: 30.w,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {},
              child: ImageNetTool(
                url: data["member"]["thumb"] ?? "",
                radius: BorderRadius.all(Radius.circular(15.w)),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  data["member"]["nickname"] ?? "",
                  style: StyleTheme.font_black_7716_06_14,
                ),
                SizedBox(height: 2.w),
                Row(
                  children: [
                    Utils.memberVip(
                      data["member"]["vip_str"] ?? "",
                      h: 14,
                      fontsize: 8,
                      margin: 5,
                    ),
                    Text(
                      Utils.format(
                          DateTime.parse(data["created_at"].toString())),
                      style: StyleTheme.font_gray_153_12,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 13.w),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 40.w),
            child: Text(
              data["content"] != null
                  ? Utils.convertEmojiAndHtml(data["content"])
                  : "",
              style: StyleTheme.font_black_7716_06_14,
              textAlign: TextAlign.left,
              maxLines: 100,
            ),
          ),
        ],
      ),
      SizedBox(height: 15.w),
      Container(
        height: 0.5.w,
        color: StyleTheme.devideLineColor,
      )
    ]);
  }
}
