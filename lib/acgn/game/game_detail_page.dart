// ignore_for_file: prefer_if_null_operators

import 'dart:math';

import 'package:deepseek/base/base_comment_review.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/input_container.dart';
import 'package:deepseek/base/input_container2.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:convert';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/community/community_post_review.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GameDetailPage extends BaseWidget {
  GameDetailPage({Key? key, this.id = "0"}) : super(key: key);
  final String id;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _GameDetailPageState();
  }
}

class _GameDetailPageState extends BaseWidgetState<GameDetailPage> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;

  bool isReplay = false;
  String commid = "0";
  String postid = "0";
  String tip = Utils.txt("wyddxf");
  FocusNode focusNode = FocusNode();

  List<dynamic> recdList = []; //推荐数据
  List<dynamic> banners = []; //广告数据

  dynamic nextData;
  dynamic prevData;

  int page = 1;

  dynamic data;
  List comments = [];
  Map picMap = {};

  late bool useAppsList =
      Provider.of<BaseStore>(context, listen: false).conf?.adVersion == 1;

  void resetXcfocusNode() {
    isReplay = false;
    tip = Utils.txt("wyddxf");
    focusNode.unfocus();
    if (mounted) setState(() {});
  }

  Future<bool> getData() async {
    dynamic res = await reqGameDetail(id: widget.id);
    if (res?.status != 1) {
      netError = true;
      isHud = false;
      if (mounted) setState(() {});
    }
    if (res?.status == 1) {
      data = res?.data['detail'];

      recdList = List.from(res?.data['recommend']); //推荐数据
      banners = List.from(res?.data['banner']); //广告数据

      nextData = res?.data['next'];
      prevData = res?.data['prev'];

      // setAppTitle(
      //     titleW: Text(data['title'], style: StyleTheme.nav_title_font));
      page = 1;
      getReviewData();

      isHud = false;
      if (mounted) setState(() {});
    } else {
      Utils.showText(res?.msg ?? "", call: () {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) finish();
        });
      });
    }
    return false;
  }

  //加载评论unlock
  Future<bool> getReviewData() async {
    dynamic res = await reqCommentList(id: widget.id, type: 'game', page: page);
    if (res?.data == null) {
      Utils.showText(res?.msg ?? "");
      return false;
    }
    List st = List.from(res?.data ?? []);
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
  }

  //购买帖子
  void _askBuyGame() async {
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    if (user == null) return;
    int money = user.money ?? 0;
    int needmoney = data['coins'] ?? 0;
    bool isInsufficient = money < needmoney;

    Utils.showDialog(
        cancelTxt: Utils.txt('quxao'),
        confirmTxt: isInsufficient ? Utils.txt('qwcz') : Utils.txt('gmgk'),
        setContent: () {
          return Column(
            children: [
              Text(Utils.txt('gmhckycnr'),
                  style: StyleTheme.font_gray_153_13, maxLines: 3),
              SizedBox(height: 15.w),
              Text("$needmoney" + Utils.txt('jinb'),
                  style: StyleTheme.font_yellow_255_13,
                  textAlign: TextAlign.center),
              SizedBox(height: 15.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Utils.txt('ktvpzk') + "：$money",
                      style: StyleTheme.font_gray_153_13),
                ],
              ),
            ],
          );
        },
        confirm: () {
          if (isInsufficient) {
            Utils.navTo(context, "/minegoldcenterpage");
          } else {
            _buyGame(money - needmoney); //直接购买
          }
        });
  }

  //购买帖子
  void _buyGame(int money) async {
    Utils.startGif(tip: Utils.txt("gmzz"));

    dynamic res = await reqGameBuy(context, id: data["id"], money: money);

    if (res?.status == 1) {
      data['download_urls'] = res.data["url"] ?? {};

      setState(() {});
    } else {
      Utils.showText(res?.msg ?? '');
    }

    //关闭加载动画
    Utils.closeGif();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate

    setAppTitle(
        titleW: Text(Utils.txt('sy'), style: StyleTheme.nav_title_font));
    getData();
  }

  @override
  void didUpdateWidget(covariant GameDetailPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).viewInsets.bottom == 0) {
        resetXcfocusNode();
      } else {}
    });
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  Widget _sourceArea() {
    List currentLinks = data['download_urls'];
    return Column(
      children: [
        Container(
          height: 42.w,
          child: Row(
            children: [
              Text(
                Utils.txt('yxxz'),
                style: StyleTheme.font_black_7716_16_blod,
              ),
            ],
          ),
        ),
        Builder(
          builder: (
            context,
          ) {
            if (currentLinks.isEmpty) {
              return Column(
                children: [
                  DottedBorder(
                    padding: EdgeInsets.zero,
                    color: StyleTheme.blue52Color,
                    strokeWidth: 1.w,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(8.w),
                    child: Container(
                      decoration: BoxDecoration(
                          color: StyleTheme.blue52Color.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(8.w))),
                      height: 69.w,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // MyImage.asset(
                          //   MyImagePaths.appGameWarning,
                          //   width: 15.w,
                          // ),
                          Icon(
                            Icons.warning,
                            size: 15.w,
                            color: StyleTheme.blue52Color,
                          ),
                          SizedBox(width: 5.w),
                          Text(Utils.txt('nrycjsck'),
                              style: TextStyle(
                                color: StyleTheme.blue52Color,
                                fontSize: 14.sp,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.w),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (data['type'] == 1) {
                        Utils.navTo(context, '/minevippage');
                      } else if (data['type'] == 2) {
                        _askBuyGame();
                      }
                      // const VipCenterRoute().push(context);
                    },
                    child: Container(
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          // gradient: MyTheme.jellyCyan_gradient_colors,
                          color: StyleTheme.blue52Color,
                          borderRadius: BorderRadius.all(Radius.circular(4.w))),
                      child: Text(data['pay_tip'] ?? Utils.txt('ktvkpyp'),
                          style: StyleTheme.font_white_255_16),
                    ),
                  ),
                ],
              );
            }

            bool showSecret = data['password'].toString().isNotEmpty;
            String secret = data['password'].toString();
            return DottedBorder(
              color: StyleTheme.blue52Color,
              strokeWidth: 1.w,
              padding: EdgeInsets.zero,
              radius: Radius.circular(8.w),
              borderType: BorderType.RRect,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: StyleTheme.margin, vertical: 20.w),
                // decoration: DottedDecoration(
                //     borderRadius: BorderRadius.all(Radius.circular(4.w)),
                //     shape: Shape.box,
                //     color: StyleTheme.white08Color,
                //     strokeWidth: 1.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: currentLinks.map((link) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Utils.copyToClipboard(link['archive_url'] ?? '', showToast: true, tip: Utils.txt('fzcgqxz'));
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: (ensureEndsWithColon(
                                            link['label'] ?? ''))
                                        .replaceAll(',', '\n'),
                                    style: TextStyle(
                                        color: StyleTheme.blak7716Color,
                                        fontSize: 14.sp)),
                                TextSpan(
                                    text: link['archive_url']
                                        ?.replaceAll(',', '\n'),
                                    style: TextStyle(
                                        color: StyleTheme.blak7716Color,
                                        fontSize: 14.sp)),
                                TextSpan(
                                    text: " [${Utils.txt('dwfz')}]",
                                    style: TextStyle(
                                        color: StyleTheme.blue52Color,
                                        fontSize: 14.sp)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10.w),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Utils.copyToClipboard(secret, showToast: true, tip: Utils.txt('fzcgqxz'));
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: Utils.txt('jymm'),
                                style: TextStyle(
                                    color: StyleTheme.blak7716Color,
                                    fontSize: 14.sp)),
                            TextSpan(
                                text: showSecret ? secret : Utils.txt('ptjc'),
                                style: TextStyle(
                                    color: StyleTheme.blak7716Color,
                                    fontSize: 14.sp)),
                            if (showSecret)
                              TextSpan(
                                  text: " [${Utils.txt('dwfz')}]",
                                  style: TextStyle(
                                      color: StyleTheme.blue52Color,
                                      fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String ensureEndsWithColon(String input) {
    // 检查字符串是否为空
    if (input.isEmpty) return Utils.txt('xzdz');
    // 检查最后一个字符是否是 ':'
    if (input.endsWith(':') || input.endsWith('：')) {
      return input;
    } else {
      return '$input: ';
    }
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : InputContainer2(
                focusNode: focusNode,
                bg: StyleTheme.whiteColor,
                onEditingCompleteText: (value) {
                  if (isReplay) {
                    inputTxt(postid, commid, value);
                    isReplay = false;
                    tip = Utils.txt("wyddxf");
                  } else {
                    inputTxt(data["id"].toString(), "0", value);
                  }
                },
                labelText: tip,
                child: PullRefresh(
                  onRefresh: () {
                    page = 1;
                    return getData();
                  },
                  onLoading: () {
                    page++;
                    return getReviewData();
                  },
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        resetXcfocusNode();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Utils.convertEmojiAndHtml(data["title"] ?? ""),
                            style: StyleTheme.font_black_7716_16_blod
                                .toHeight(1.2),
                            maxLines: 10,
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 10.w),
                          Container(
                              height: 0.5.w, color: StyleTheme.devideLineColor),
                          SizedBox(height: 10.w),
                          Builder(builder: (cx) {
                            List tps = List.from(data['images'] ?? []);
                            return tps.isEmpty
                                ? Container()
                                : ListView.builder(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.w),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: tps.length,
                                    itemBuilder: (ctx, index) {
                                      dynamic e = tps[index];
                                      if (e['type'] == 2) {
                                        e["unlock_coins"] =
                                            data["unlock_coins"];
                                      }
                                      double width = ScreenUtil().screenWidth -
                                          StyleTheme.margin * 2;
                                      double w = (e["thumb_width"] == 0 ||
                                                  e["thumb_width"] == null
                                              ? width
                                              : e["thumb_width"])
                                          .toDouble();
                                      double h = (e["thumb_height"] == 0 ||
                                                  e["thumb_height"] == null
                                              ? width / 2
                                              : e["thumb_height"])
                                          .toDouble();
                                      double kwidth = w > width ? width : w;
                                      return e['type'] == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: kwidth,
                                                height: kwidth / w * h,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  onTap: () {
                                                    //删除视频的情况
                                                    List mp = List.from(tps);
                                                    mp.removeWhere((el) =>
                                                        el['type'] == 2);
                                                    List<String> pics = mp
                                                        .map((e) =>
                                                            Utils.getPICURL(e)
                                                                .toString())
                                                        .toList();
                                                    Map picMap = {
                                                      'resources': pics,
                                                      'index': index
                                                    };
                                                    String url =
                                                        EncDecrypt.encry(
                                                            jsonEncode(picMap));
                                                    Utils.navTo(context,
                                                        '/previewviewpage/$url');
                                                  },
                                                  child: ImageNetTool(
                                                      fit: BoxFit.contain,
                                                      url: Utils.getPICURL(
                                                          tps[index])),
                                                ),
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 10.w),
                                                RichText(
                                                    text: TextSpan(children: [
                                                  (data['unlock_coins'] ?? 0) >
                                                              0 &&
                                                          e["media_url"].isEmpty
                                                      ? TextSpan(
                                                          text:
                                                              "${data['unlock_coins']}${Utils.txt('jbjsw')}:",
                                                          style: StyleTheme
                                                              .font_blue52_14)
                                                      : TextSpan(
                                                          text: Utils.txt(
                                                                  'sping') +
                                                              ":",
                                                          style: StyleTheme
                                                              .font_gray_95_14)
                                                ])),
                                                SizedBox(height: 5.w),
                                                SizedBox(
                                                  width: width,
                                                  height: width / 16 * 9,
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () {},
                                                    child: Stack(
                                                      children: [
                                                        ImageNetTool(
                                                          url: e["cover"] ?? '',
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Center(
                                                            child: LocalPNG(
                                                                name:
                                                                    'ai_play_n',
                                                                width: 40.w,
                                                                height: 40.w))
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                    });
                          }),
                          (data["play_intro"] ?? "").isEmpty
                              ? Container()
                              : RichText(
                                  text: TextSpan(
                                    text: data["play_intro"] ?? "",
                                    style: StyleTheme.font_black_7716_14,
                                  ),
                                ),
                          _sourceArea(),
                          SizedBox(height: 15.w),
                          (data["intro"] ?? "").isEmpty
                              ? Container()
                              : RichText(
                                  text: TextSpan(
                                    text: data["intro"] ?? "",
                                    style: StyleTheme.font_black_7716_14,
                                  ),
                                ),
                          SizedBox(height: 15.w),
                          // _EndView(),
                          _TagsView(
                            tagFullString: data['tags'] ?? '',
                          ),
                          _LikeCollectShareArea(data: data),
                          banners.isEmpty
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(bottom: 10.w),
                                  child: useAppsList
                                      ? GeneralBannerAppsListWidget(
                                          width: 1.sw - 26.w, data: banners)
                                      : Utils.bannerSwiper(
                                          width: (ScreenUtil().screenWidth -
                                              2 * StyleTheme.margin),
                                          whRate: 2 / 7,
                                          radius: 3,
                                          data: banners,
                                        ),
                                ),
                          _PrevAndNextView(data: {
                            'prev': prevData,
                            'next': nextData,
                          }),

                          _RecommendView(
                            dataList: recdList,
                            // dataList: [data],
                          ), // recdList),
                          Container(
                              height: 0.5.w, color: StyleTheme.devideLineColor),
                          SizedBox(height: 13.w),
                          Row(
                            children: [
                              Text(Utils.txt("pl"),
                                  style: StyleTheme.font_blue52_16_medium),
                              Text(
                                  "（${data["comment_num"] ?? 0}${Utils.txt("t")}）",
                                  style: StyleTheme.font_gray_153_12),
                            ],
                          ),
                          comments.isEmpty
                              ? LoadStatus.noData()
                              : ListView.builder(
                                  padding: EdgeInsets.symmetric(vertical: 5.w),
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: comments.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    // return BaseCommentReview(data: comments[index], )
                                    return BaseCommentReview(
                                      data: comments[index],
                                      type: 'game',
                                      replyCall: (dp, pid, cmid) {
                                        isReplay = true;
                                        tip = dp;
                                        postid = pid;
                                        commid = cmid;
                                        focusNode.requestFocus();
                                        setState(() {});
                                      },
                                      resetCall: () {
                                        resetXcfocusNode();
                                      },
                                    );
                                  }),
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }

  void inputTxt(String post_id, String comment_id, String txt) {
    if (txt.isEmpty) {
      Utils.showText(Utils.txt("qsrplxx"));
      return;
    }
    Utils.startGif(tip: Utils.txt("fbioz"));
    reqCreatComment(
            id: post_id,
            type: 'game',
            //  comment_id: comment_id,
            content: txt)
        .then((value) {
      Utils.closeGif();
      Utils.showText(value?.msg ?? '');
    });
  }

  //帖子点赞
  Widget buildWithLike() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LocalPNG(
          name: data["is_like"] == 1
              ? "ai_community_like_on"
              : "ai_community_like_off",
          width: 25.w,
          height: 25.w,
        ),
        SizedBox(width: 2.w),
        Text(
          data["is_like"] == 1 ? Utils.txt("ydanzan") : Utils.txt("danzan"),
          style: StyleTheme.font_gray_95_12,
        ),
        SizedBox(width: 15.w),
      ],
    );
  }

  //帖子收藏
  Widget buildWithCollect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LocalPNG(
          name: data["is_favorite"] == 1
              ? "ai_video_favorite_on"
              : "ai_video_favorite_off",
          width: 20.w,
          height: 20.w,
        ),
        SizedBox(width: 2.w),
        Text(
          data["is_favorite"] == 1 ? Utils.txt("ysocang") : Utils.txt("socang"),
          style: StyleTheme.font_gray_95_12,
        ),
        SizedBox(width: 15.w),
      ],
    );
  }

  //关注
  Widget buildWithFocus() {
    return Container(
      width: 55.w,
      height: 26.w,
      decoration: BoxDecoration(
          color: data["user"]["is_follow"] == 1
              ? StyleTheme.blue52Color
              : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(13.w)),
          border: Border.all(
              color: data["user"]["is_follow"] == 1
                  ? Colors.transparent
                  : StyleTheme.blue52Color,
              width: 0.5.w)),
      child: Center(
        child: Text(
          data["user"]["is_follow"] == 1
              ? Utils.txt("ygz")
              : "+ ${Utils.txt("guanz")}",
          style: data["user"]["is_follow"] == 1
              ? StyleTheme.font_white_255_11
              : StyleTheme.font_blue_52_11,
        ),
      ),
    );
  }
}

class _EndView extends StatelessWidget {
  const _EndView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // MyImage.asset(
              //   MyImagePaths.appGameContentEndLeft,
              //   width: 87.w,
              //   height: 6.w,
              // ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  "THE END",
                  style: StyleTheme.font_white_255_12,
                ),
              ),
              // MyImage.asset(
              //   MyImagePaths.appGameContentEndRight,
              //   width: 87.w,
              //   height: 6.w,
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagsView extends StatelessWidget {
  _TagsView({this.tagFullString = ''});

  String tagFullString;

  @override
  Widget build(BuildContext context) {
    return tagFullString.isEmpty
        ? SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(bottom: 15.w),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.w,
              children: tagFullString.split(',').map((e) {
                return GestureDetector(
                  onTap: () {
                    Utils.navTo(context, '/gametagpage/$e');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 4),
                    decoration: BoxDecoration(
                        color: StyleTheme.blue52Color.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4.5.w)),
                    child: Text(
                      '#$e',
                      style: StyleTheme.font_white_255_12.toHeight(1),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
  }
}

class _LikeCollectShareArea extends StatefulWidget {
  const _LikeCollectShareArea({required this.data});

  final dynamic data;

  @override
  State<_LikeCollectShareArea> createState() => _LikeCollectShareAreaState();
}

class _LikeCollectShareAreaState extends State<_LikeCollectShareArea> {
  bool _isChangeLikeLoading = false;
  bool _isChangeCollectLoading = false;

  Future<void> _changeLike() async {
    if (_isChangeLikeLoading) return;
    _isChangeLikeLoading = true;

    try {
      final result = await reqUserLike(type: 17, id: widget.data['id'] ?? 0);
      if (result?.status == 1) {
        widget.data["is_like"] = result?.data['is_like'];
        int likeCt = widget.data['like_fct'];
        likeCt += widget.data["is_like"] == 1 ? 1 : -1;
        if (likeCt < 0) {
          likeCt = 0;
        }
        widget.data['like_fct'] = likeCt;

        if (mounted) {
          setState(() {});
        }
      } else {
        Utils.showText(result?.msg ?? '');
      }
    } catch (_) {}

    _isChangeLikeLoading = false;
  }

  Future<void> _changeCollect() async {
    if (_isChangeCollectLoading) return;
    _isChangeCollectLoading = true;

    try {
      final result =
          await reqUserFavorite(type: 17, id: widget.data['id'] ?? 0);
      if (result?.status == 1) {
        widget.data["is_favorite"] = result?.data['is_favorite'];
        int favoriteCt = widget.data['favorite_fct'];
        favoriteCt += widget.data["is_favorite"] == 1 ? 1 : -1;
        if (favoriteCt < 0) {
          favoriteCt = 0;
        }
        widget.data['favorite_fct'] = favoriteCt;

        if (mounted) {
          setState(() {});
        }
      } else {
        Utils.showText(result?.msg ?? '');
      }
    } catch (_) {}

    _isChangeCollectLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.w),
      child: Center(
        child: SizedBox(
          // width: 185.w,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GameTapButton(
                  // preText: Utils.txt('danzan'),
                  isHighlighted: widget.data['is_like'] == 1,
                  number: widget.data['like_fct'] ?? 0,
                  imageName: 'ai_game_like_off',
                  imageHighlightedName: 'ai_game_like_on',
                  onTap: _changeLike),

              SizedBox(width: 18.5.w),
              GameTapButton(
                  // preText: Utils.txt('danzan'),
                  isHighlighted: widget.data['is_favorite'] == 1,
                  number: widget.data['favorite_fct'] ?? 0,
                  imageName: 'ai_video_favorite_off',
                  imageHighlightedName: 'ai_video_favorite_on',
                  onTap: _changeCollect),

              SizedBox(width: 18.5.w),
              GameTapButton(
                // preText: Utils.txt('js'),ƒ
                isHighlighted: false,
                number: widget.data['pay_fct'] ?? 0,
                imageName: 'ai_game_unlock',
              ),

              // GameTapButton(
              //     isHighlighted: true, // widget.data.isLike == 1,
              //     number: 99, // widget.data.likeFct ?? 0,
              //     onTap: _changeLike),
            ],
          ),
        ),
      ),
    );
  }
}

class GameTapButton extends StatelessWidget {
  GameTapButton({
    this.preText,
    required this.isHighlighted,
    required this.number,
    this.onTap,
    this.imageName,
    this.imageHighlightedName,
  });

  final String? preText;
  final bool isHighlighted;
  final int number;
  final VoidCallback? onTap;
  String? imageName;
  String? imageHighlightedName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap?.call();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LocalPNG(
              name:
                  isHighlighted ? imageHighlightedName ?? '' : imageName ?? '',
              width: 20.w,
              height: 20.w),
          SizedBox(width: 1.5.w),
          preText == null
              ? SizedBox()
              : Text(
                  preText!,
                  style: StyleTheme.font_white_255_08_14,
                ),
          Text(
            '${Utils.renderFixedNumber(number)}',
            style: StyleTheme.font_black_7716_04_13,
          ),
        ],
      ),
    );
  }
}

class _PrevAndNextView extends StatelessWidget {
  _PrevAndNextView({
    required this.data,
  });

  dynamic data;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (data['prev'] != null || data['next'] != null)
          ? Container(
              margin: EdgeInsets.only(bottom: 15.w),
              child: Row(
                children: [
                  data['prev'] == null
                      ? const SizedBox.shrink()
                      : Expanded(
                          child: GestureDetector(
                          onTap: () {
                            Utils.navTo(context,
                                '/gamedetailpage/${data['prev']["id"]}');
                          },
                          child: Container(
                            height: 80.w,
                            padding: EdgeInsets.symmetric(
                                horizontal: StyleTheme.margin / 2, vertical: 0),
                            decoration: BoxDecoration(
                                color: StyleTheme.whiteColor,
                                borderRadius: BorderRadius.circular(10.w)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    // MyImage.asset(
                                    //   MyImagePaths.appGamePrev,
                                    //   height: 12.w,
                                    //   width: 12.w,
                                    // ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      Utils.txt('syp'),
                                      style: StyleTheme.font_blue52_12,
                                    )
                                  ],
                                ),
                                Text(
                                  data['prev']?['title'] ?? '',
                                  style: StyleTheme.font_black_7716_06_11,
                                  maxLines: 2,
                                )
                              ],
                            ),
                          ),
                        )),
                  (data['prev'] != null && data['next'] != null)
                      ? SizedBox(width: 10.w)
                      : SizedBox.shrink(),
                  data['next'] == null
                      ? SizedBox.shrink()
                      : Expanded(
                          child: GestureDetector(
                          onTap: () {
                            Utils.navTo(context,
                                '/gamedetailpage/${data['next']["id"]}');
                          },
                          child: Container(
                            height: 80.w,
                            padding: EdgeInsets.symmetric(
                                horizontal: StyleTheme.margin / 2, vertical: 0),
                            decoration: BoxDecoration(
                                color: StyleTheme.whiteColor,
                                borderRadius: BorderRadius.circular(10.w)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Spacer(),
                                    Text(
                                      Utils.txt('xyp'),
                                      style: StyleTheme.font_blue52_12,
                                    ),
                                    SizedBox(width: 10.w),
                                    // MyImage.asset(
                                    //   MyImagePaths.appGameNext,
                                    //   height: 12.w,
                                    //   width: 12.w,
                                    // ),
                                  ],
                                ),
                                Text(
                                  data['next']?['title'] ?? '',
                                  style: StyleTheme.font_black_7716_06_11,
                                  maxLines: 2,
                                )
                              ],
                            ),
                          ),
                        ))
                ],
              ),
            )
          : Container(),
    );
  }
}

class _RecommendView extends StatelessWidget {
  _RecommendView({
    required this.dataList,
  });

  List dataList;

  @override
  Widget build(BuildContext context) {
    // dataList = dataList + List.from(dataList);
    // dataList = dataList + List.from(dataList);
    // dataList = dataList + List.from(dataList);
    // dataList = dataList + List.from(dataList);
    return Container(
      child: dataList.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(bottom: 15.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        Utils.txt('wntj'),
                        style: StyleTheme.font_black_7716_16_blod,
                      ),
                    ],
                  ),
                  SizedBox(height: 13.w),
                  Container(
                    height: 86.w,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: dataList
                            .map((e) => ClipRRect(
                                  child: GestureDetector(
                                    onTap: () {
                                      Utils.navTo(context,
                                          '/gamedetailpage/${e["id"]}');
                                    },
                                    child: Container(
                                      width: 150.w,
                                      height: 86.w,
                                      clipBehavior: Clip.hardEdge,
                                      margin: EdgeInsets.only(right: 8.w),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.w),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                              child: ImageNetTool(
                                            url: Utils.getPICURL(e),
                                          )),
                                          Positioned.fill(
                                              child: Column(
                                            children: [
                                              const Spacer(),
                                              Container(
                                                height: 30.w,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w),
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromRGBO(
                                                          0, 0, 0, 0.7),
                                                      Color.fromRGBO(
                                                          0, 0, 0, 0),
                                                    ],
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                ),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  e['title'],
                                                  style: StyleTheme
                                                      .font_white_255_10,
                                                  maxLines: 1,
                                                ),
                                              )
                                            ],
                                          )),
                                          // Positioned(
                                          //     left: 0,
                                          //     bottom: 0,
                                          //     child: Row(
                                          //       children: [],
                                          //     ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                            .toList()),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }
}
