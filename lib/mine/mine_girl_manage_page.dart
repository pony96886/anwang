import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineGirlManagePage extends BaseWidget {
  MineGirlManagePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineGirlManagePageState();
  }
}

class _MineGirlManagePageState extends BaseWidgetState<MineGirlManagePage> {
  List dataList = [];
  bool isHud = true;

  Future<bool> getJoinData() {
    return reqContactList().then((value) {
      if (value?.status == 1) {
        dataList = value?.data?["office_contact"]["data"];
      } else {
        Utils.showText(value?.msg ?? "");
      }
      isHud = false;
      setState(() {});
      return false;
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate

    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    setAppTitle(
      titleW: Text(Utils.txt('ypgl'), style: StyleTheme.nav_title_font),
      rightW: user?.agent != 1
          ? null
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Utils.navTo(context, '/homedatepublishpage');
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: StyleTheme.gradBlue,
                  borderRadius: BorderRadius.all(Radius.circular(14.w)),
                ),
                height: 28.w,
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Center(
                  child: Text(
                    Utils.txt("fb"),
                    style: StyleTheme.font_white_255_14,
                  ),
                ),
              ),
            ),
    );

    if (user?.agent != 1) {
      getJoinData();
    }
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  Widget _joinWidget() {
    return isHud
        ? LoadStatus.showLoading(mounted)
        : dataList.isNotEmpty
            ? PullRefresh(
                onRefresh: () {
                  return getJoinData();
                },
                child: ListView(
                    padding: EdgeInsets.all(StyleTheme.margin),
                    // itemCount: dataList.length,
                    children: dataList.asMap().keys.map((index) {
                      dynamic e = dataList[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15.w),
                          Text(
                            Utils.txt('gfrz'),
                            style: StyleTheme.font_black_7716_16_blod,
                          ),
                          SizedBox(height: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 24.w),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.w),
                                color: StyleTheme.whiteColor,
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                      color: StyleTheme.whiteColor,
                                      offset: const Offset(0, 0),
                                      blurStyle: BlurStyle.normal,
                                      spreadRadius: 1.w,
                                      blurRadius: 1.w),
                                ]),
                            child: Column(
                              children: List.from(e['list'])
                                  .map((x) => GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          Utils.openURL(x['url']);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.w),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                // height: 49.w,
                                                child: Row(
                                                  children: [
                                                    LocalPNG(
                                                      name: x['type'] ==
                                                              'Telegram'
                                                          ? 'ai_mine_tg'
                                                          : 'ai_mine_potato',
                                                      width: 49.w,
                                                      height: 49.w,
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    Expanded(
                                                        child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${x['name']}',
                                                          style: StyleTheme
                                                              .font_black_7716_14_medium,
                                                        ),
                                                        SizedBox(height: 4.w),
                                                        Text(
                                                          '${x['decs']}',
                                                          style: StyleTheme
                                                              .font_black_7716_06_12,
                                                          maxLines: 2,
                                                        ),
                                                      ],
                                                    )),
                                                    SizedBox(width: 10.w),
                                                    Container(
                                                      width: 70.w,
                                                      height: 25.w,
                                                      decoration: BoxDecoration(
                                                        color: StyleTheme
                                                            .blue52Color,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12.5.w)),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          Utils.txt('ljjr'),
                                                          style: StyleTheme
                                                              .font_white_255_12,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              // SizedBox(
                                              //   height: 10.w,
                                              // )
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          SizedBox(height: 10.w),
                          // RichText(
                          //   text: TextSpan(
                          //     text: Utils.txt('rzsm') * 9,
                          //     style: StyleTheme.font_black_7716_06_12,
                          //   ),
                          // ),
                          // Text(
                          //   Utils.txt('rzsm') * 99,
                          //   style: StyleTheme.font_black_7716_06_12,
                          //   maxLines: 99,
                          // )
                        ],
                      );
                    }).toList()))
            : LoadStatus.noData();
  }

  Widget _listWidget() {
    return MyGirlListPage();
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody

    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;

    return user?.agent != 1 ? _joinWidget() : _listWidget();
  }
}

class MyGirlListPage extends StatefulWidget {
  const MyGirlListPage({super.key});

  @override
  State<MyGirlListPage> createState() => _MyGirlListPageState();
}

class _MyGirlListPageState extends State<MyGirlListPage> {
  List<dynamic> navs = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

// 1-等待 2-拒绝 3=处理中 4=已完成
    navs = [
      {'title': Utils.txt('dsh'), 'status': 1},
      {'title': Utils.txt('yfb'), 'status': 4},
      {'title': Utils.txt('wtg'), 'status': 2},
      {'title': Utils.txt('clz'), 'status': 3},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GenCustomNav(
      labelPadding: 20.w,
      isEquallyDivide: true,
      titles: navs.map((e) => "${e["title"]}").toList(),
      pages: navs.asMap().keys.map((e) {
        return MyGirlChildPage(
          status: navs[e]["status"],
        );
      }).toList(),
      type: GenCustomNavType.line,
      // titleBottomLineWidth: 17.w,
      // selectStyle: StyleTheme.font_white_255_16_semi,
      // defaultStyle: StyleTheme.font_white_255_06_14,
    );
  }
}

class MyGirlChildPage extends StatefulWidget {
  MyGirlChildPage({
    Key? key,
    this.status = 1,
  }) : super(key: key);
  final int status;

  @override
  State<MyGirlChildPage> createState() => _MyGirlChildPageState();
}

class _MyGirlChildPageState extends State<MyGirlChildPage> {
  int page = 1;
  bool noMore = false;
  bool netError = false;
  bool isHud = true;
  List<dynamic> array = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<bool> getData() {
   return reqGirlManageList(status: widget.status, page: page).then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return false;
      }
      List st = List.from(value?.data ?? []);
      if (page == 1) {
        noMore = false;
        array = st;
      } else if (st.isNotEmpty) {
        array.addAll(st);
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
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 15.w,
                        childAspectRatio: 165 / (213 + 68),
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: array.length,
                      itemBuilder: (context, index) {
                        dynamic e = array[index];
                        return Utils.dateModuleUI(context, e,
                            disalbleTap: widget.status != 4 ? true : false);
                      },
                    ),
                  );
  }
}
