import 'dart:async';
import 'package:deepseek/base/base_comment_review.dart';
import 'package:deepseek/base/input_container2.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/base/shortv_player.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:photo_view/photo_view_gallery.dart';

class VlogHotPage extends StatefulWidget {
  VlogHotPage({
    Key? key,
    this.apiUrl = '',
    this.param,
    this.noMore = false,
    this.userGlobalData = false,
    this.keepBottomBlank = false,
  }) : super(key: key);
  final String apiUrl;
  Map? param;
  final bool noMore;
  final bool userGlobalData; // 用不用 AppGlobal.shortVideosInfo
  final bool keepBottomBlank; // 底部要不要留白

  @override
  State<VlogHotPage> createState() => _VlogHotPageState();
}

class _VlogHotPageState extends State<VlogHotPage> {
  int page = 1;
  bool isHud = true;
  bool noMore = false;
  bool isAction = false;

  late StreamSubscription discrip;

  PageController? _pageController;
  String _apiUrl = '';
  dynamic _param = {};

  List<dynamic> array = [];
  //
  void getData() {
    if (noMore) return;

    Map param = Map.from(_param);
    param.addAll({"page": page});

    reqShortApiList(apiUrl: _apiUrl, param: param).then((value) {
      if (value?.status != 1) {
        isAction = false;
        return;
      }
      List<dynamic> tp = List.from(value?.data ?? []);
      if (page == 1) {
        array = tp;
      } else if (tp.isNotEmpty) {
        array.addAll(tp);
      } else {
        noMore = true;
      }
      isHud = false;
      isAction = false;
      if (mounted) setState(() {});
      // if (page == 1) {
      //   changeURL(0);
      // }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noMore = widget.noMore;

    if (widget.userGlobalData) {
      array = AppGlobal.shortVideosInfo['list'];
      page = AppGlobal.shortVideosInfo['page'];
      _apiUrl = AppGlobal.shortVideosInfo['api'] ?? '';
      _param = AppGlobal.shortVideosInfo['params'] ?? {};
      int initialIndex = AppGlobal.shortVideosInfo['index'];
      _pageController = PageController(initialPage: initialIndex);
      isHud = false;

      if (array.length - initialIndex < 4 && !isAction) {
        isAction = true;
        page++;
        getData();
      }
    } else {
      _apiUrl = widget.apiUrl;
      _param.addAll(widget.param ?? {});
      getData();
    }
    if (!kIsWeb) {
      discrip = UtilEventbus().on<EventbusClass>().listen((event) {
        if (event.arg["name"] == 'enter_vlog_page_event') {
          if (event.arg["type"] == "leave") {
            // PreloadUtils.removeCurrentTask();
          } else {
            if (mounted) setState(() {});
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isHud
        ? LoadStatus.showLoading(mounted)
        : array.isEmpty
            ? LoadStatus.noData()
            : PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                itemCount: array.length,
                scrollDirection: Axis.vertical,
                pageController: _pageController,
                onPageChanged: (index) async {
                  Utils.log("$index --- ${array.length}");
                  // changeURL(index);
                  if (array.length - index < 4 && !isAction) {
                    isAction = true;
                    page++;
                    getData();
                  }
                },
                builder: (cx, index) {
                  dynamic e = array[index];
                  reqVlogPlay(id: e['id']);
                  if (e['url'] != null) {
                    return PhotoViewGalleryPageOptions.customChild(
                        initialScale: 1.0,
                        minScale: 1.0,
                        maxScale: 1.0,
                        disableGestures: true,
                        child: Utils.adModuleInShortFlowUI(
                          context,
                          e,
                        ));
                  }

                  if (!kIsWeb) {
                    preloadShortV(array, index);
                  }

                  return PhotoViewGalleryPageOptions.customChild(
                    initialScale: 1.0,
                    minScale: 1.0,
                    maxScale: 1.0,
                    disableGestures: true,
                    child: ShortVPlayer(
                      info: e,
                      keepBottomBlank: widget.keepBottomBlank,
                    ),
                  );
                });
  }

  // 对列表中 当前视频 前1后2进行预加载
  Future<void> preloadShortV(List array, int index) async {
    if (array.length <= index) return;

    var preloadArray = [];
    // 取出前num个数据
    int numInFront = 1;
    for (int i = numInFront; i > 0; i--) {
      if (index - i >= 0) {
        preloadArray.insert(0, array[index - i]);
      }
    }
    // 取出后num个数据
    int numInBehind = 2;
    for (int i = numInBehind; i > 0; i--) {
      if (index + i < array.length) {
        preloadArray.insert(0, array[index + i]);
      }
    }

    // // 将当前播放的视频，插到第一个
    // preloadArray.insert(0, array[index]);
    // if (preloadArray.isNotEmpty) {
    //   await PreloadUtils.receivePreloadData(preloadArray);
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (!kIsWeb) {
      // PreloadUtils.removeCurrentTask();
      discrip.cancel();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }
}

class ShortVideoCommontPage extends StatefulWidget {
  ShortVideoCommontPage({Key? key, this.id = 0, this.onClose})
      : super(key: key);
  final int id;
  Function? onClose;

  @override
  State<ShortVideoCommontPage> createState() => ShortVideoCommontPageState();
}

class ShortVideoCommontPageState extends State<ShortVideoCommontPage> {
  int page = 1;
  bool noMore = false;
  bool networkErr = false;
  bool isHud = true;
  String last_ix = "";
  List<dynamic> comments = [];
  String tip = Utils.txt("wyddxf");
  String postid = "0";
  String commid = "0";
  bool isReplay = false;
  List<dynamic> _dataList = [];
  final FocusNode focusNode = FocusNode();
  final FocusNode xcfocusNode = FocusNode();

  thumbupVideoComment(int index) {}

  //发送评论
  void postComment(String text) async {
    if (text.isNotEmpty) {
      Utils.startGif(
        tip: Utils.txt('fbz'),
      );

      reqCreatComment(id: '${widget.id}', type: 'vlog', content: text)
          .then((value) {
        Utils.closeGif();
        Utils.showText(value?.msg ?? '');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(covariant ShortVideoCommontPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).viewInsets.bottom == 0) {
        focusNode.unfocus();
      } else {}
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> getData() {
    return reqCommentList(id: '${widget.id}', type: 'vlog', page: page).then((value) {
      if (value?.status != 1) {
        networkErr = true;
        if (mounted) setState(() {});
        return false;
      }
      // last_ix = value?.data["last_ix"] == null ? "" : value?.data["last_ix"];
      List st = List.from(value?.data ?? []);
      if (page == 1) {
        noMore = false;
        comments = st;
      } else if (st.isNotEmpty) {
        comments.addAll(st);
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
    return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 100),
        child: Container(
            height: ScreenUtil().screenHeight * 0.6,
            decoration: BoxDecoration(
              color: StyleTheme.bgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.w),
                topRight: Radius.circular(10.w),
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Utils.unFocusNode(context);
              },
              child: InputContainer2(
                focusNode: xcfocusNode,
                bg: StyleTheme.whiteColor,
                labelText: Utils.txt("wyddxf"),
                onEditingCompleteText: (value) {
                  _inputTxt(value);
                },
                child: networkErr
                    ? LoadStatus.netError(onTap: () {
                        networkErr = false;
                        getData();
                      })
                    : isHud
                        ? LoadStatus.showLoading(mounted)
                        : Column(
                            children: [
                              Container(
                                height: 60.w,
                                alignment: Alignment.center,
                                child: Text(Utils.txt('pl'),
                                    style:
                                        StyleTheme.font_black_7716_15_medium),
                              ),
                              Expanded(
                                child: PullRefresh(
                                  onLoading: () {
                                    page++;
                                    return getData();
                                  },
                                  child: comments.isEmpty
                                      ? LoadStatus.noData()
                                      : ListView.builder(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.w,
                                              horizontal: StyleTheme.margin),
                                          // physics:
                                          //     const NeverScrollableScrollPhysics(),
                                          itemCount: comments.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            // return Container();
                                            return BaseCommentReview(
                                              type: 'vlog',
                                              data: comments[index],
                                              resetCall: () {
                                                // resetXcfocusNode();
                                              },
                                            );
                                          }),
                                ),
                              ),
                            ],
                          ),
              ),
            )));
  }

  _inputTxt(String value) {
    if (true) {
      if (value.isEmpty) {
        Utils.showText(Utils.txt("qsrnr"));
        return;
      }

      postComment(value);
    }
  }
}
