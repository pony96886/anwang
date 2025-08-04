import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

enum MediaType {
  mv,
  vlog,
  aiGirlFriend,
  post,
  voice,
  cartoon,
  comic,
  game,
  novel,
  // girl,
  stripChat,
}

extension MediaTypeExtension on MediaType {
  String get name {
    switch (this) {
      case MediaType.mv:
        return Utils.txt('csp');
      case MediaType.vlog:
        return Utils.txt('dsp');
      case MediaType.aiGirlFriend:
        return Utils.txt('aigf');
      case MediaType.post:
        return Utils.txt('tiez');
      case MediaType.voice:
        return Utils.txt('as');
      case MediaType.cartoon:
        return Utils.txt('dm');
      case MediaType.comic:
        return Utils.txt('mh');
      case MediaType.game:
        return Utils.txt('sy');
      case MediaType.novel:
        return Utils.txt('xs');
      // case MediaType.girl:
      //   return Utils.txt('yp');
      case MediaType.stripChat:
        return Utils.txt('lliao');
      default:
        return '';
    }
  }

  String get value {
    switch (this) {
      case MediaType.mv:
        return 'mv';
      case MediaType.vlog:
        return 'vlog';
      case MediaType.aiGirlFriend:
        return 'aigirlfriend';
      case MediaType.post:
        return 'community';
      case MediaType.voice:
        return 'voice';
      case MediaType.cartoon:
        return 'cartoon';
      case MediaType.comic:
        return 'comic';
      case MediaType.game:
        return 'game';
      case MediaType.novel:
        return 'novel';
      // case MediaType.girl:
      //   return 'girl';
      case MediaType.stripChat:
        return 'chat';
      default:
        return '';
    }
  }
}

class HomeSearchPage extends BaseWidget {
  const HomeSearchPage({Key? key, this.searchStr, this.index})
      : super(key: key);

  final String? searchStr;
  final String? index;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _HomeSearchPageState();
  }
}

class _HomeSearchPageState extends BaseWidgetState<HomeSearchPage> {
  bool isSearch = false;
  bool isStartSearch = false; //开始搜索标识
  bool isHud = true;
  List records = [];
  String recordKey = "search_record";
  String prevText = "";
  List hots = [];
  List banners = [];
  TextEditingController textController = TextEditingController();
  int initialIndex = 0;

  late bool useAppsList =
      Provider.of<BaseStore>(context, listen: false).conf?.adVersion == 1;

  List<MediaType> navs = [
    MediaType.mv,
    MediaType.vlog,
    MediaType.aiGirlFriend,
    MediaType.post,
    MediaType.voice,
    MediaType.cartoon,
    MediaType.comic,
    MediaType.game,
    MediaType.novel,
    // MediaType.girl,
    MediaType.stripChat,
  ];

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Column(
      children: [
        SizedBox(height: StyleTheme.topHeight),
        Container(
          height: StyleTheme.navHegiht,
          padding: EdgeInsets.only(left: StyleTheme.margin),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  finish();
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 27.w,
                  height: 40.w,
                  child: LocalPNG(
                    name: "ai_nav_back_w",
                    width: 17.w,
                    height: 17.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 36.w,
                  decoration: BoxDecoration(
                      color: StyleTheme.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(18.w))),
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: textController,
                          style: StyleTheme.font_black_7716_14,
                          textInputAction: TextInputAction.search,
                          cursorColor: StyleTheme.blue52Color,
                          enabled: !isHud,
                          //加载完才让输入
                          onSubmitted: (value) {
                            searchInfo();
                          },
                          onChanged: (value) {
                            if (value.isEmpty) {
                              isSearch = false;
                              prevText = "";
                              isStartSearch = false;
                            }
                            if (mounted) setState(() {});
                          },
                          decoration:
                              Utils.customInputStyle(hit: Utils.txt('srsgjz')),
                        ),
                      ),
                      if (textController.text.isEmpty) ...[
                        SizedBox(width: 10.w),
                        LocalPNG(
                            name: "ai_nav_search", width: 20.w, height: 20.w),
                      ],
                      Offstage(
                        offstage: textController.text.isEmpty,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            textController.clear();
                            isSearch = false;
                            prevText = "";
                            isStartSearch = false;
                            if (mounted) setState(() {});
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 3.w),
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: Icon(
                                Icons.cancel,
                                color: Colors.grey,
                                size: 20.w,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  searchInfo();
                },
                child: Container(
                  height: StyleTheme.navHegiht,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                  child: Text(
                    Utils.txt('sosuo'),
                    style: StyleTheme.font_black_7716_14,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  //搜索动作
  void searchInfo() {
    Utils.unFocusNode(context);
    Utils.log("${textController.text}---$prevText");
    if (textController.text.isEmpty) return;
    if (prevText == textController.text) return;
    isStartSearch = true; //开始搜索才刷新子页面数据，否则不刷新
    prevText = textController.text;
    if (!records.contains(textController.text)) {
      records.add(textController.text);
      AppGlobal.appBox?.put(recordKey, records);
    }
    isSearch = true;
    if (mounted) setState(() {});
    //延迟赋值
    Future.delayed(const Duration(milliseconds: 500), () {
      // isStartSearch = false;
    });
  }

  //热搜词+广告
  void getHotsData() {
    reqPopularSearch(limit: 20).then((value) {
      if (value?.status == 1) {
        hots = List.from(value?.data["top"]["mv"] ?? []);
        banners = List.from(value?.data["banner"] ?? []);
      }
      isHud = false;
      if (mounted) setState(() {});
    });
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    records = AppGlobal.appBox?.get(recordKey) ?? [];
    getHotsData();

    if (widget.searchStr?.isNotEmpty ?? false) {
      textController.text = widget.searchStr ?? '';
      initialIndex = int.parse(widget.index ?? '0');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchInfo();
      });
    }
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    textController.dispose();
  }

  //没有搜索页面
  Widget isNoSearchWidget() {
    return Container(
      padding: EdgeInsets.all(StyleTheme.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: Utils.txt('ssls'),
                    style: StyleTheme.font_black_7716_14_medium)
              ])),
              GestureDetector(
                onTap: () {
                  records.clear();
                  AppGlobal.appBox?.put(recordKey, records);
                  if (mounted) setState(() {});
                },
                child:
                    Text(Utils.txt('qcjl'), style: StyleTheme.font_gray_77_12),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(
              top: StyleTheme.margin,
              bottom: 20.w,
            ),
            child: records.isEmpty
                ? SizedBox(
                    height: 30.w,
                    child: Center(
                      child: Text(
                        Utils.txt('zwssjl'),
                        style: StyleTheme.font_gray_77_12,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 10.w,
                    runSpacing: 15.w,
                    children: records.map((e) {
                      return GestureDetector(
                        onTap: () {
                          textController.text = e;
                          searchInfo();
                        },
                        child: Container(
                          height: 30.w,
                          decoration: BoxDecoration(
                              color: StyleTheme.whiteColor,
                              borderRadius: BorderRadius.circular(15.w)),
                          padding: EdgeInsets.only(
                              left: StyleTheme.margin, right: 8.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                e,
                                style: StyleTheme.font_black_7716_07_13,
                              ),
                              Container(
                                color: StyleTheme.blak7716_06_Color,
                                height: 10.w,
                                width: 1.w,
                                margin: EdgeInsets.only(left: 10.w, right: 3.w),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  if (Utils.unFocusNode(context)) {
                                    records.remove(e);
                                    AppGlobal.appBox?.put(recordKey, records);
                                    if (mounted) setState(() {});
                                  }
                                },
                                child: SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: Center(
                                    child: Icon(Icons.close_outlined,
                                        size: 15.w,
                                        color: StyleTheme.blak7716_06_Color),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          banners.isEmpty
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(bottom: 20.w),
                  child: useAppsList
                      ? GeneralBannerAppsListWidget(
                          width: 1.sw - 26.w, data: banners)
                      : Utils.bannerSwiper(
                          width:
                              ScreenUtil().screenWidth - StyleTheme.margin * 2,
                          whRate: 2 / 7,
                          data: banners,
                          radius: 3,
                        ),
                ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: Utils.txt('rmtj'),
                style: StyleTheme.font_black_7716_14_medium)
          ])),
          SizedBox(height: 10.w),
          hots.isEmpty
              ? LoadStatus.noData()
              : Container(
                  padding: EdgeInsets.all(StyleTheme.margin),
                  decoration: BoxDecoration(
                      color: StyleTheme.whiteColor,

                      // gradient: const LinearGradient(
                      //   colors: [
                      //     StyleTheme.whiteColor,
                      //     Color.fromRGBO(241, 241, 241, 1),
                      //     Color.fromRGBO(255, 255, 255, 1)
                      //   ],
                      //   begin: Alignment.topCenter,
                      //   end: Alignment.bottomCenter,
                      // ),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.w),
                          topRight: Radius.circular(10.w))),
                  child: Column(
                    children: hots
                        .asMap()
                        .keys
                        .map((x) => Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    textController.text = hots[x]["work"];
                                    searchInfo();
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Container(
                                            margin: EdgeInsets.only(right: 8.w),
                                            height: 24.w,
                                            width: 24.w,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: const Color.fromRGBO(
                                                    52, 136, 255, 0.6),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12.w))),
                                            child: Text("${x + 1}",
                                                style: StyleTheme
                                                    .font_white_255_15),
                                          ),
                                        ),
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Container(
                                              height: 24.w,
                                              alignment: Alignment.center,
                                              child: Text(hots[x]["work"],
                                                  style: StyleTheme
                                                      .font_black_7716_15)),
                                        ),
                                        // TextSpan(
                                        //     text: hots[x]["name"],
                                        //     style:
                                        //         StyleTheme.font_black_31_14),
                                      ])),
                                      Text(
                                          "${hots[x]["num"]}${Utils.txt('redu')}",
                                          style: StyleTheme.font_blue52_15)
                                    ],
                                  ),
                                ),
                                SizedBox(height: 25.w)
                              ],
                            ))
                        .toList(),
                  ),
                )
        ],
      ),
    );
  }

  //搜索页面
  Widget isSearchWidget() {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight -
          StyleTheme.navHegiht -
          StyleTheme.topHeight,
      child: GenCustomNav(
        initialIndex: initialIndex,
        type: GenCustomNavType.none,
        titles: navs.map((e) => e.name).toList(),
        pages: navs
            .map(
              (e) => SearchChildPage(
                isStartSearch: isStartSearch,
                word: textController.text,
                type: e,
              ),
            )
            .toList(),
        selectStyle: StyleTheme.font_blue52_14,
        defaultStyle: StyleTheme.font_black_7716_14,
      ),
    );
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Utils.unFocusNode(context);
      },
      child: isHud
          ? LoadStatus.showLoading(mounted)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: isSearch ? isSearchWidget() : isNoSearchWidget(),
            ),
    );
  }
}

class SearchChildPage extends StatefulWidget {
  SearchChildPage({
    Key? key,
    this.word = "",
    this.isStartSearch = false,
    this.type = MediaType.mv,
  }) : super(key: key);
  final String word;
  final bool isStartSearch;
  final MediaType type; //

  @override
  State<SearchChildPage> createState() => _SearchChildPageState();
}

class _SearchChildPageState extends State<SearchChildPage> {
  int page = 1;
  List _dataList = [];
  String last_ix = "";
  bool noMore = false;
  bool searchHud = true;

  //搜索数据
  Future<bool> searchData({bool isShow = false}) async {
    if (page == 1) {
      bool flag = widget.word.isNotEmpty && widget.isStartSearch;
      if (!flag) return false;
    }

    if (isShow) Utils.startGif(tip: Utils.txt('jzz'));

    ResponseModel<dynamic>? res;

    res = await reqSearchitems(
        word: widget.word,
        type: widget.type.value,
        extraParam: widget.type == MediaType.mv
            ? {
                "type": 1,
              }
            : null,
        page: page);

    // (widget.type == 0
    //         ? reqSearchVideos(word: widget.word, page: page)
    //         : reqSearchPosts(
    //             word: widget.word,
    //             page: page,
    //           ))
    //     .then((value) {
    if (isShow) Utils.closeGif();
    if (res?.status == 1) {
      List tmp = List.from(res?.data ?? []);
      if (page == 1) {
        noMore = false;
        _dataList = tmp;
      } else if (tmp.isNotEmpty) {
        _dataList.addAll(tmp);
      } else {
        noMore = true;
      }
      searchHud = false;
      if (mounted) setState(() {});
      return noMore;
    } else {
      Utils.showText(res?.msg ?? "");
      return false;
    }
  }

  Widget _listView() {
    // mv,
    // vlog,
    // post,
    // voice,
    // cartoon,
    // comic,
    // novel,
    // girl,
    // stripChat,

    if (widget.type == MediaType.mv) {
      return _mvListView();
    } else if (widget.type == MediaType.vlog) {
      return _vlogListView();
    } else if (widget.type == MediaType.post) {
      return _postListView();
    } else if (widget.type == MediaType.voice) {
      return _voiceListView();
    } else if (widget.type == MediaType.cartoon) {
      return _cartoonListView();
    } else if (widget.type == MediaType.comic) {
      return _comicListView();
    } else if (widget.type == MediaType.novel) {
      return _novelListView();
    } else if (widget.type == MediaType.game) {
      return _gameListView();
      // } else if (widget.type == MediaType.girl) {
      //   return _girlListView();
    } else if (widget.type == MediaType.stripChat) {
      return _stripChatListView();
    } else if (widget.type == MediaType.aiGirlFriend) {
      return _aiGirlChatListView();
    }
    return Container();
  }

  Widget _aiGirlChatListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      itemBuilder: (context, index) {
        return Utils.aiGirlModuleUI(context, _dataList[index]);
      },
      itemCount: _dataList.length,
    );
  }

  Widget _mvListView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
        childAspectRatio: 171 / (142 + 30),
      ),
      scrollDirection: Axis.vertical,
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        dynamic e = _dataList[index];
        return Utils.videoModuleUI(context, e);
      },
    );
  }

  Widget _vlogListView() {
    return GridView.builder(
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
            'api': '/api/vlog/list_buy',
            'params': {}
          };

          Utils.navTo(context, '/vlogsecondpage');
        });
      },
    );
  }

  Widget _postListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin * 0),
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        dynamic item = _dataList[index];
        return Utils.postModuleUI(context, item);
      },
    );
  }

  Widget _voiceListView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
        childAspectRatio: 171 / 142,
      ),
      scrollDirection: Axis.vertical,
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        dynamic e = _dataList[index];
        return Utils.audioGridModuleUI(context, e);
      },
    );
  }

  Widget _cartoonListView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
        childAspectRatio: 171 / 122,
      ),
      scrollDirection: Axis.vertical,
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        dynamic e = _dataList[index];
        return Utils.videoModuleUI2(context, e, isCartoon: true);
      },
    );
  }

  Widget _comicListView() {
    return Utils.comicListView(context, _dataList);
  }

  Widget _novelListView() {
    return Utils.novelListView(context, _dataList);
  }

  Widget _gameListView() {
    return Utils.gameListView(context, _dataList);
  }

  Widget _girlListView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 15.w,
        childAspectRatio: 165 / (213 + 68),
      ),
      scrollDirection: Axis.vertical,
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        dynamic e = _dataList[index];
        return Utils.dateModuleUI(context, e);
      },
    );
  }

  Widget _stripChatListView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 6.w,
        childAspectRatio: 172 / (230 + 31 + 13),
      ),
      scrollDirection: Axis.vertical,
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        dynamic e = _dataList[index];
        return Utils.nackedChatModuleUI(context, e);
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchData(isShow: true);
  }

  // @override
  // void didUpdateWidget(covariant SearchChildPage oldWidget) {
  //   // TODO: implement didUpdateWidget

  //   if (_dataList.isEmpty && searchHud) {
  //     searchData(isShow: true);
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    return PullRefresh(
      onRefresh: () {
        page = 1;
        return searchData();
      },
      onLoading: () {
        page++;
        return searchData();
      },
      child: searchHud
          ? Container()
          : _dataList.isEmpty
              ? LoadStatus.noData()
              : _listView(),
    );
  }
}
