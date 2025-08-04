import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//TA人中心
class MineOtherUserCenter extends BaseWidget {
  MineOtherUserCenter({Key? key, this.aff = "0"}) : super(key: key);
  final String aff;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineOtherUserCenterState();
  }
}

class _MineOtherUserCenterState extends BaseWidgetState<MineOtherUserCenter> {
  int page = 1;
  bool isHud = true;
  bool noMore = false;
  UserModel? user;
  List<dynamic> posts = [];

  @override
  Widget backGroundView() {
    // TODO: implement backGroundView
    return user == null
        ? Container()
        : SizedBox(
            width: ScreenUtil().screenWidth,
            height: ScreenUtil().screenWidth / 750 * 400,
            child: LocalPNG(name: "ai_others_top_bg"),
          );
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    // getData();
    setAppTitle(lineColor: Colors.transparent, backIcon: 'ai_nav_back_w');
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBodys
    return
        // isHud || user == null
        //     ? LoadStatus.showLoading(mounted)
        //     :
        NestedScrollView(
      headerSliverBuilder: (context, res) {
        return [
          SliverToBoxAdapter(
            child: user == null
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(
                      left: StyleTheme.margin,
                      right: StyleTheme.margin,
                      bottom: 15.w,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(33.5.w),
                          child: Container(
                            height: 67.w,
                            width: 67.w,
                            decoration:
                                BoxDecoration(gradient: StyleTheme.gradBlue),
                            child: Center(
                              child: ClipRRect(
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(31.5.w),
                                child: SizedBox(
                                  width: 63.w,
                                  height: 63.w,
                                  child: ImageNetTool(url: user?.thumb ?? ""),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user?.nickname ?? Utils.txt('kkyh'),
                                  style: StyleTheme.font_black_7716_16_blod),
                              user?.agent == 1
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 5.w),
                                      child: Row(
                                        children: [
                                          Text(Utils.txt('rzbz'),
                                              style: StyleTheme
                                                  .font_black_7716_07_12),
                                          SizedBox(width: 2.w),
                                          Icon(Icons.verified_sharp,
                                              size: 12.w,
                                              color: StyleTheme.blue52Color)
                                        ],
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ];
      },
      body: Container(
        decoration: BoxDecoration(
          color: StyleTheme.whiteColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.w), topRight: Radius.circular(10.w)),
        ),
        child: Column(
          children: [
            // SizedBox(height: 15.w),
            // Text(Utils.txt('allpst') + " (${user?.post_num})",
            //     style: StyleTheme.font_black_7716_06_18),
            SizedBox(height: 15.w),
            // Container(
            //     margin: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
            //     height: 0.5.w,
            //     color: StyleTheme.devideLineColor),
            Expanded(
                child: GenCustomNav(titles: [
              Utils.txt('allpst'),
              //  +(user == null ? '' : " (${user?.post_num})"),
              Utils.txt('dsp')
            ], pages: [
              OtherUserPostListPage(
                aff: widget.aff,
                func: (userModel) {
                  setState(() {
                    user = userModel;
                  });
                },
              ),
              OtherUserVlogListPage(
                aff: widget.aff,
              )
            ]))
          ],
        ),
      ),
    );
  }

  @override
  void didPush() {
    super.didPush();
    // Utils.setStatusBar(isLight: true);
  }

  @override
  void didPop() {
    // Utils.setStatusBar();
  }

  @override
  void didPopNext() {
    // Utils.setStatusBar(isLight: true);
  }

  @override
  void didPushNext() {
    // Utils.setStatusBar();
  }
}

class OtherUserPostListPage extends StatefulWidget {
  OtherUserPostListPage({Key? key, this.aff = "0", this.func})
      : super(key: key);
  final String aff;
  Function(UserModel? user)? func;

  @override
  State<OtherUserPostListPage> createState() => _OtherUserPostListPageState();
}

class _OtherUserPostListPageState extends State<OtherUserPostListPage> {
  int page = 1;
  bool isHud = true;
  bool noMore = false;
  UserModel? user;
  List<dynamic> posts = [];

  Future<bool> getData() async {
    return reqOthersCenterPost(aff: widget.aff, page: page).then((value) {
      if (value?.status == 1) {
        // setAppTitle(backIcon: "ai_nav_back_w", lineColor: Colors.transparent);
        List ps = List.from(value?.data["list"] ?? []);
        if (page == 1) {
          noMore = false;
          user = UserModel.fromJson(value?.data["info"] ?? {});
          widget.func?.call(user);
          posts = ps;
        } else if (ps.isNotEmpty) {
          posts.addAll(ps);
        } else {
          noMore = true;
        }
        isHud = false;
        if (mounted) setState(() {});
        return noMore;
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          // Future.delayed(const Duration(milliseconds: 100), () {
          //   finish();
          // });
        });
        return false;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return isHud
        ? LoadStatus.showLoading(mounted)
        : posts.isEmpty
            ? LoadStatus.noData()
            : PullRefresh(
                onRefresh: () {
                  page = 1;
                  return getData();
                },
                onLoading: () {
                  page++;
                  return getData();
                },
                child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 15.w),
                    itemCount: posts.length,
                    itemBuilder: (cx, index) {
                      dynamic e = posts[index];
                      return Utils.postModuleUI(context, e, isTime: true);
                    }),
              );
  }
}

class OtherUserVlogListPage extends StatefulWidget {
  OtherUserVlogListPage({Key? key, this.aff = "0"}) : super(key: key);
  final String aff;

  @override
  State<OtherUserVlogListPage> createState() => _OtherUserVlogListPageState();
}

class _OtherUserVlogListPageState extends State<OtherUserVlogListPage> {
  int page = 1;
  bool isHud = true;
  bool noMore = false;
  List<dynamic> _dataList = [];

  Future<bool> getData() async {
    return reqOthersVlog(aff: widget.aff, page: page).then((value) {
      if (value?.status == 1) {
        // setAppTitle(backIcon: "ai_nav_back_w", lineColor: Colors.transparent);
        List ps = List.from(value?.data ?? []);
        if (page == 1) {
          noMore = false;
          _dataList = ps;
        } else if (ps.isNotEmpty) {
          _dataList.addAll(ps);
        } else {
          noMore = true;
        }
        isHud = false;
        if (mounted) setState(() {});
        return noMore;
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          // Future.delayed(const Duration(milliseconds: 100), () {
          //   finish();
          // });
        });
        return false;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return isHud
        ? LoadStatus.showLoading(mounted)
        : _dataList.isEmpty
            ? LoadStatus.noData()
            : PullRefresh(
                onRefresh: () {
                  page = 1;
                  return getData();
                },
                onLoading: () {
                  page++;
                  return getData();
                },
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                  // shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.w,
                    crossAxisSpacing: 10.w,
                    childAspectRatio: 167 / (238 + 30),
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: _dataList.length,
                  itemBuilder: (context, index) {
                    dynamic e = _dataList[index];
                    return Utils.vlogModuleUI(context, e, onTapFunc: () {
                      AppGlobal.shortVideosInfo = {
                        'list': _dataList,
                        'page': page,
                        'index': index,
                        'api': '/api/vlog/list_peer',
                        'params': {'aff': widget.aff}
                      };

                      Utils.navTo(context, '/vlogsecondpage');
                    });
                  },
                ),
              );
  }
}
