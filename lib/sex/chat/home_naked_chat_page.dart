import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/marquee.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeNakedChatPage extends BaseWidget {
  HomeNakedChatPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeNakedChatPageState();
  }
}

class _HomeNakedChatPageState extends BaseWidgetState<HomeNakedChatPage> {
  bool isHud = true;
  bool netError = false;
  List<dynamic> banners = [];
  List<dynamic> tips = [];
  List<dynamic> navs = [];

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    setAppTitle(
        titleW: Text(Utils.txt('lliao'), style: StyleTheme.nav_title_font));
    navs = Provider.of<BaseStore>(context, listen: false).conf?.chat_nav ?? [];
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: StyleTheme.bgColor,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 10.w),
                      Container(
                          padding: EdgeInsets.only(
                              right: StyleTheme.margin,
                              left: StyleTheme.margin,
                              bottom: 10.w),
                          child: GeneralBannerAppsListWidget(width: 1.sw - 26.w, data: banners)),
                      tips.isEmpty
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(bottom: 5.w),
                              child: Utils.tipsWidget(context, tips)),
                      SizedBox(height: 5.w),
                    ],
                  ),
                ),
              ];
            },
            body: GenCustomNav(
              labelPadding: 20.w,
              titles: navs.map((e) => "${e["name"]}").toList(),
              pages: navs.asMap().keys.map((e) {
                return HomeNakedChatChildPage(
                  id: navs[e]['id'] ?? 0,
                  type: navs[e]['type'] ?? 1,
                  sort: navs[e]['sort'] ?? '',
                  // sort: e["type"],
                  fun: e == 0
                      ? (data) {
                          banners = List.from(
                              data['banner'] ?? data['banners'] ?? []);
                          tips = List.from(data["tips"] ?? []);

                          if (mounted) setState(() {});
                        }
                      : null,
                );
              }).toList(),
              type: GenCustomNavType.line,
              // titleBottomLineWidth: 17.w,
              // selectStyle: StyleTheme.font_white_255_15_medium,
              // defaultStyle: StyleTheme.font_white_255_06_14,
            ),
          ),
        ),
        Positioned(
          right: StyleTheme.margin * 2,
          bottom: StyleTheme.bottom + StyleTheme.margin * 2,
          child: GestureDetector(
            onTap: () {
              Utils.navTo(context, '/homenakedchatpublishpage');
            },
            child: //Icon(Icons.post_add)
                LocalPNG(
              name: 'ai_sex_chat_publish',
              width: 40.w,
              height: 40.w,
            ),
          ),
        )
      ],
    );
  }
}

class HomeNakedChatChildPage extends StatefulWidget {
  HomeNakedChatChildPage(
      {Key? key, this.id = 0, this.type = 1, this.sort = '', this.fun})
      : super(key: key);
  final int id;
  final int type;
  final String sort;
  final Function(dynamic)? fun;

  @override
  State<HomeNakedChatChildPage> createState() => _HomeNakedChatChildPageState();
}

class _HomeNakedChatChildPageState extends State<HomeNakedChatChildPage> {
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
    return (widget.type == 2
            ? reqNakedChatSortList(sort: widget.sort, page: page)
            : reqNakedChatList(id: widget.id, page: page))
        .then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return false;
      }
      List st = List.from(value?.data["chats"] ?? []);
      if (page == 1) {
        noMore = false;
        array = st;
        widget.fun?.call(value?.data);
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
                        crossAxisSpacing: 6.w,
                        childAspectRatio: 172 / (230 + 31 + 13),
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: array.length,
                      itemBuilder: (context, index) {
                        dynamic e = array[index];
                        return Utils.nackedChatModuleUI(context, e);
                      },
                    ),
                  );
  }
}
