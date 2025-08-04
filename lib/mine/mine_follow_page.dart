import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineFollowPage extends BaseWidget {
  MineFollowPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineFollowPageState();
  }
}

class _MineFollowPageState extends BaseWidgetState<MineFollowPage> {
  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt("wdgz"), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return GenCustomNav(
      type: GenCustomNavType.none,
      titles: [
        Utils.txt('yonghu'),
        Utils.txt('banku'),
      ],
      pages: [FollowChildUserPage(), FollowChildPostPage()],
      selectStyle: StyleTheme.font_blue52_14,
      defaultStyle: StyleTheme.font_black_7716_14,
    );
  }
}

class FollowChildUserPage extends StatefulWidget {
  FollowChildUserPage({Key? key}) : super(key: key);

  @override
  State<FollowChildUserPage> createState() => _FollowChildUserPageState();
}

class _FollowChildUserPageState extends State<FollowChildUserPage> {
  int page = 1;
  bool isMore = false;
  bool netError = false;
  bool isHud = true;
  bool isEdit = false;
  List array = [];

  Future<bool> getData() {
   return reqFollowUserList(page: page).then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List tp = List.from(value?.data["list"] ?? []);
      if (page == 1) {
        isMore = false;
        array = tp;
      } else if (tp.isNotEmpty) {
        array.addAll(tp);
      } else {
        isMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return isMore;
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
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : array.isEmpty
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
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        itemCount: array.length,
                        itemBuilder: (cx, index) {
                          dynamic e = array[index];
                          return followWidget(e);
                        }),
                  );
  }

  //item
  Widget followWidget(dynamic e) {
    return Column(children: [
      SizedBox(height: 10.w),
      SizedBox(
        height: 40.w,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Utils.navTo(context, '/mineotherusercenter/${e["aff"]}');
          },
          child: Row(
            children: [
              SizedBox(
                height: 40.w,
                width: 40.w,
                child: ImageNetTool(
                    url: e["thumb"] ?? '',
                    radius: BorderRadius.all(Radius.circular(20.w))),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(e["nickname"] ?? '',
                        style: StyleTheme.font_black_7716_14),
                    Utils.memberVip(
                      e["vip_str"] ?? '',
                      h: 14,
                      fontsize: 7,
                      margin: 5,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  reqFollowUser(aff: e["aff"].toString()).then((value) {
                    if (value?.status == 1) {
                      array.remove(e);
                      if (mounted) setState(() {});
                    } else {
                      Utils.showText(value?.msg ?? "");
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  height: 30.w,
                  decoration: BoxDecoration(
                      color: e["is_follow"] == 1
                          ? StyleTheme.blue52Color
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(15.w)),
                      border: Border.all(
                          color: e["is_follow"] == 1
                              ? Colors.transparent
                              : StyleTheme.blue52Color,
                          width: 0.5.w)),
                  child: Center(
                    child: Text(
                      e["is_follow"] == 1
                          ? Utils.txt("qxgz")
                          : "+ ${Utils.txt("guanz")}",
                      style: e["is_follow"] == 1
                          ? StyleTheme.font_white_255_11
                          : StyleTheme.font_blue_52_11,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      SizedBox(height: 9.5.w),
      Container(height: 0.5.w, color: StyleTheme.devideLineColor),
    ]);
  }
}

class FollowChildPostPage extends StatefulWidget {
  FollowChildPostPage({Key? key}) : super(key: key);

  @override
  State<FollowChildPostPage> createState() => _FollowChildPostPageState();
}

class _FollowChildPostPageState extends State<FollowChildPostPage> {
  int page = 1;
  bool isMore = false;
  bool netError = false;
  bool isHud = true;
  bool isEdit = false;
  List array = [];

  Future<bool> getData() {
    return reqFollowTopicList(page: page).then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List tp = List.from(value?.data ?? []);
      if (page == 1) {
        isMore = false;
        array = tp;
      } else if (tp.isNotEmpty) {
        array.addAll(tp);
      } else {
        isMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return isMore;
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
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : array.isEmpty
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
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        itemCount: array.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, //横轴三个子widget
                          childAspectRatio: 1.1, //宽高比为1时，子widget
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 10.w,
                        ),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var e = array[index];
                          return topicWidget(e);
                        }),
                  );
  }

  //item
  Widget topicWidget(dynamic e) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Utils.navTo(context, "/communitytagdetail/${e["id"]}");
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(e['thumb']), // 网络图片URL
                      fit: BoxFit.cover, // 图片的填充方式
                    ),
                    color: StyleTheme.whiteColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.w))),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(Radius.circular(5.w))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.w),
                      Center(
                        child: Text(
                          e["name"] ?? "",
                          style: StyleTheme.font_white_255_14,
                        ),
                      ),
                      SizedBox(height: 5.w),
                      Center(
                          child: Text(
                              "${e["post_num"] ?? "0"}${Utils.txt("tiez")}",
                              style: StyleTheme.font_white_255_12)),
                      SizedBox(height: 10.w),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.w),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            //话题关注/取消关注
            reqFollowTopic(topic_id: e["id"].toString()).then((value) {
              if (value?.status == 1) {
                array.remove(e);
                if (mounted) setState(() {});
              } else {
                Utils.showText(value?.msg ?? '');
              }
            });
          },
          child: Container(
            height: 26.w,
            decoration: BoxDecoration(
                color: e["is_follow"] == 1
                    ? StyleTheme.blue52Color
                    : Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(13.w)),
                border: Border.all(
                  color: e["is_follow"] == 1
                      ? Colors.transparent
                      : StyleTheme.blue52Color,
                  width: 0.5.w,
                )),
            child: Center(
              child: Text(
                e["is_follow"] == 1
                    ? Utils.txt("qxgz")
                    : "+ ${Utils.txt("guanz")}",
                style: e["is_follow"] == 1
                    ? StyleTheme.font_white_255_12
                    : StyleTheme.font_blue_52_12,
              ),
            ),
          ),
        )
      ],
    );
  }
}
