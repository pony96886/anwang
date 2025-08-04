import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/community/community_usually.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatefulWidget {
  CommunityPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CommunityPageState();
  }
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  bool isHud = true;
  bool netError = false;
  List<dynamic> navs = [];

  List<Map> issues = [
    {"title": Utils.txt("tp"), "png": "ai_issue_pic"},
    {"title": Utils.txt("wenzhan"), "png": "ai_issue_video"},
    {"title": Utils.txt("twen"), "png": "ai_issue_ptxt"}
  ];

  void getData() {
    reqGetPostNav().then((value) {
      if (value?.status == 1) {
        navs = List.from(value?.data ?? []);
        BconfModel? cf =
            Provider.of<BaseStore>(context, listen: false).conf?.config;
        if (cf?.wdai_str?.isNotEmpty == true) {
          navs.add({'id': 100, 'title': cf?.wdai_str});
        }
        isHud = false;
      } else {
        netError = true;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CommunityPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      getData();
    }
  }

  //弹出发布选择
  Future<Widget?> showIssueAlert() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: StyleTheme.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.w),
                  topRight: Radius.circular(5.w),
                ),
              ),
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(20),
                        bottom: ScreenUtil().setWidth(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Text(
                          Utils.txt('xzfblx'),
                          style: StyleTheme.font_black_7716_16_blod,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.close,
                              color: StyleTheme.blak7716_06_Color, size: 20.w),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: issues
                        .map((e) => GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.of(context).pop();
                                if (e["png"] == "ai_issue_pic") {
                                  //图片
                                  Utils.navTo(context, "/communityissue/0");
                                } else if (e["png"] == "ai_issue_video") {
                                  //视频
                                  Utils.navTo(context, "/communityissue/1");
                                } else {
                                  //图文
                                  Utils.navTo(context, "/communityissue/2");
                                }
                              },
                              child: Column(
                                children: [
                                  LocalPNG(
                                    name: e["png"],
                                    width: 50.w,
                                    height: 52.7.w,
                                  ),
                                  Text(
                                    e["title"],
                                    style: StyleTheme.font_black_7716_15,
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 43.w)
                ],
              )),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          await showIssueAlert();
        },
        child: LocalPNG(
          name: 'ai_common_publish',
          width: 50.w,
          height: 50.w,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: StyleTheme.topHeight),
          Expanded(
              child: netError
                  ? LoadStatus.netError(onTap: () {
                      netError = false;
                      getData();
                    })
                  : isHud
                      ? LoadStatus.showLoading(mounted)
                      : GenCustomNav(
                          isSearch: true,
                          titles: navs
                              .map<String>((e) => e["title"] ?? "")
                              .toList(),
                          pages: navs.map<Widget>((e) {
                            if (e["id"] == 100) {
                              return CommunityUsally(
                                  id: e["id"], sort: e["type"] ?? '');
                            } else {
                              return CommunityChildPage(id: e["id"]);
                            }
                          }).toList(),
                        ))
        ],
      ),
    );
  }
}

class CommunityChildPage extends StatefulWidget {
  CommunityChildPage({Key? key, this.id = 0}) : super(key: key);
  final int id;

  @override
  State<CommunityChildPage> createState() => _CommunityChildPageState();
}

class _CommunityChildPageState extends State<CommunityChildPage> {
  List<dynamic> banners = [];
  List<dynamic> topics = [];
  List<dynamic> tps = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tps = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.forum_nav ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.only(
                        right: StyleTheme.margin,
                        left: StyleTheme.margin,
                        bottom: 10.w),
                    child: GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: banners)),
                topics.isEmpty
                    ? Container()
                    : GridView(
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, //横轴三个子widget
                          childAspectRatio: 110 / 50, //宽高比为1时，子widget
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 10.w,
                        ),
                        shrinkWrap: true,
                        children: topics
                            .map((e) => GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Utils.navTo(context,
                                        "/communitytagdetail/${e["id"]}");
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2.w),
                                    child: Stack(
                                      children: [
                                        // ImageNetTool(
                                        //   url: e["bg_thumb"] ?? "",
                                        //   radius: BorderRadius.all(
                                        //       Radius.circular(5.w)),
                                        // ),
                                        Container(color: StyleTheme.whiteColor),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                e["name"] ?? "",
                                                style: StyleTheme
                                                    .font_black_7716_07_13,
                                              ),
                                            ),
                                            // SizedBox(height: 2.w),
                                            Center(
                                                child: Text(
                                              "${e["post_num"] ?? "0"}${Utils.txt("tiez")}",
                                              style: StyleTheme
                                                  .font_black_7716_04_12,
                                            ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                SizedBox(height: 5.w),
              ],
            ),
          ),
        ];
      },
      body: GenCustomNav(
        labelPadding: 15,
        titles: tps.map((e) => "${e["title"]}").toList(),
        pages: tps.map((e) {
          return CommunityUsally(
            id: widget.id,
            sort: e["type"],
            fun: (data) {
              banners = List.from(data["banner"] ?? []);
              topics = List.from(data["topics"] ?? []);
              if (mounted) setState(() {});
            },
          );
        }).toList(),
        type: GenCustomNavType.none,
        selectStyle: StyleTheme.font_blue52_14,
        defaultStyle: StyleTheme.font_black_7716_14,
      ),
    );
  }
}
