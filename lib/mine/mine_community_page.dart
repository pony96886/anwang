import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/nvideourl_minxin.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineCommunityPage extends BaseWidget {
  MineCommunityPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineCommunityPageState();
  }
}

class _MineCommunityPageState extends BaseWidgetState<MineCommunityPage>
    with NVideoURLMinxin {
  bool isHud = true;
  UserModel? user;

  void getData() {
    reqUserInfo(context).then((value) {
      if (value?.status == 1) {
        isHud = false;
        setState(() {});
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            finish();
          });
        });
      }
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    user = Provider.of<BaseStore>(context, listen: false).user;
    setAppTitle(
        titleW: Text(Utils.txt('wdshequ'), style: StyleTheme.nav_title_font));
    getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return isHud
        ? LoadStatus.showLoading(mounted)
        : NestedScrollView(
            headerSliverBuilder: (cx, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                    child: Column(
                  children: [
                    SizedBox(height: 20.w),
                    Container(
                      height: 70.w,
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      margin:
                          EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      decoration: BoxDecoration(
                          color: StyleTheme.whiteColor,
                          boxShadow: const [
                            // BoxShadow(
                            //   color: Color.fromRGBO(0, 0, 0, 0.15),
                            //   offset: Offset(0, 0),
                            //   blurRadius: 6,
                            //   spreadRadius: 0,
                            // )
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.w))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(Utils.txt('qbye'),
                                    style: StyleTheme.font_gray_153_12),
                                SizedBox(height: 5.w),
                                Text("${user?.income_money ?? 0}",
                                    style:
                                        StyleTheme.font_black_7716_06_18_semi),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            height: 20.w,
                            width: 1.w,
                            color: StyleTheme.gray230Color,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(Utils.txt('dyuezsy'),
                                    style: StyleTheme.font_gray_153_12),
                                SizedBox(height: 5.w),
                                Text('${user?.income_total ?? 0}',
                                    style:
                                        StyleTheme.font_black_7716_06_18_semi),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.w),
                    Container(
                      height: 30.w,
                      padding:
                          EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Utils.navTo(context, "/mineearnlistpage");
                            },
                            child: Container(
                              width: 100.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: StyleTheme.blue52Color,
                                      width: 1.w),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.w))),
                              child: Text(
                                Utils.txt('symx'),
                                style: StyleTheme.font_blue_52_12,
                              ),
                            ),
                          ),
                          SizedBox(width: 40.w),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Utils.navTo(context, "/minetocashpage/1");
                            },
                            child: Container(
                              width: 100.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  gradient: StyleTheme.gradBlue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.w))),
                              child: Text(
                                Utils.txt('tx'),
                                style: StyleTheme.font_white_255_12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.w),
                  ],
                )),
              ];
            },
            body: GenCustomNav(
              isCenter: true,
              type: GenCustomNavType.none,
              titles: [
                Utils.txt('ysj'),
                Utils.txt('pdz'),
                Utils.txt('wtg'),
                Utils.txt('tgdhd'),
              ],
              pages: [
                CommunityChildPage(status: 1),
                CommunityChildPage(status: 0),
                CommunityChildPage(status: 2),
                CommunityChildPage(status: 3),
              ],
              selectStyle: StyleTheme.font_blue52_14,
              defaultStyle: StyleTheme.font_black_7716_14,
            ));
  }
}

class CommunityChildPage extends StatefulWidget {
  CommunityChildPage({Key? key, this.status = 0}) : super(key: key);
  final int status;

  @override
  State<CommunityChildPage> createState() => _CommunityChildPageState();
}

class _CommunityChildPageState extends State<CommunityChildPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  int page = 1;
  List<dynamic> posts = [];

  Future<bool> getData() {
    return reqPostStatusList(page: page, status: widget.status).then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List tp = List.from(value?.data ?? []);
      if (page == 1) {
        noMore = false;
        posts = tp;
      } else if (tp.isNotEmpty) {
        posts.addAll(tp);
      } else {
        noMore = true;
      }
      isHud = false;
      if (mounted) setState(() {});
      return noMore;
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
                        padding: EdgeInsets.zero,
                        itemCount: posts.length,
                        itemBuilder: (cx, index) {
                          dynamic e = posts[index];
                          return Utils.postModuleUI(context, e, isTime: true);
                        }),
                  );
  }
}
