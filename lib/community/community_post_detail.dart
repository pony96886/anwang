import 'dart:convert';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/input_container2.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/input_container.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/community/community_post_review.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CommunityPostDetail extends BaseWidget {
  CommunityPostDetail({Key? key, this.id = "0"}) : super(key: key);
  final String id;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _CommunityPostDetailState();
  }
}

class _CommunityPostDetailState extends BaseWidgetState<CommunityPostDetail> {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;

  bool isReplay = false;
  String commid = "0";
  String postid = "0";
  String tip = Utils.txt("wyddxf");
  FocusNode focusNode = FocusNode();

  int page = 1;

  dynamic data;
  List comments = [];
  Map picMap = {};

  @override
  Widget appbar() {
    return Column(
      children: [
        SizedBox(height: StyleTheme.topHeight),
        Container(
          padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
          height: StyleTheme.navHegiht,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 22.w,
                  height: 40.w,
                  child: LocalPNG(
                    name: "ai_nav_back_w",
                    width: 17.w,
                    height: 17.w,
                    fit: BoxFit.contain,
                  ),
                ),
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  finish();
                },
              ),
              Expanded(
                  child: data == null
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Utils.navTo(context,
                                    '/mineotherusercenter/${data["user"]["aff"]}');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 30.w,
                                    width: 30.w,
                                    child: ImageNetTool(
                                      url: data["user"]["thumb"] ?? "",
                                      radius: BorderRadius.all(
                                          Radius.circular(15.w)),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    data["user"]["nickname"] ?? "",
                                    style: StyleTheme.font_black_7716_14_blod,
                                  ),
                                  SizedBox(width: 2.w),
                                  data["user"]['agent'] == 1
                                      ? Icon(Icons.verified_sharp,
                                          size: 14.w,
                                          color: StyleTheme.blue52Color)
                                      : Container(),
                                ],
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                resetXcfocusNode();
                                reqFollowUser(
                                        aff: data["user"]["aff"].toString())
                                    .then((value) {
                                  if (value?.status == 1) {
                                    data["user"]["is_follow"] =
                                        data["user"]["is_follow"] == 1 ? 0 : 1;
                                    if (mounted) setState(() {});
                                  } else {
                                    Utils.showText(value?.msg ?? "");
                                  }
                                });
                              },
                              child: buildWithFocus(),
                            )
                          ],
                        ))
            ],
          ),
        )
      ],
    );
  }

  void resetXcfocusNode() {
    isReplay = false;
    tip = Utils.txt("wyddxf");
    focusNode.unfocus();
    if (mounted) setState(() {});
  }

  Future<bool> getData() {
   return reqPostDetailContent(id: widget.id).then((value) {
      if (value?.data == null) {
        netError = true;
        isHud = false;
        if (mounted) setState(() {});
      }
      if (value?.status == 1) {
        data = value?.data;
        page = 1;
        getReviewData();
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) finish();
          });
        });
      }
      return false;
    });
  }

  //加载评论
  Future<bool> getReviewData() {
   return reqPostDetailComment(id: widget.id, page: page).then((value) {
      if (value?.data == null) {
        Utils.showText(value?.msg ?? "");
        return false;
      }
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
  void onCreate() {
    // TODO: implement onCreate
    getData();
  }

  @override
  void didUpdateWidget(covariant CommunityPostDetail oldWidget) {
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
                          SizedBox(height: 15.w),
                          Text(
                            Utils.convertEmojiAndHtml(data["title"] ?? ""),
                            style: StyleTheme.font_black_7716_18,
                            maxLines: 10,
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 10.w),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "${Utils.renderFixedNumber(data["view_num"] ?? 0)}${Utils.txt("llan")}",
                                  style: StyleTheme.font_gray_95_12),
                              Text(
                                  "${Utils.txt('fbsj')}：${Utils.format(DateTime.parse(data["created_at"] ?? ""))}",
                                  style: StyleTheme.font_gray_95_12)
                            ],
                          ),
                          SizedBox(height: 10.w),
                          Container(
                              height: 0.5.w, color: StyleTheme.devideLineColor),
                          SizedBox(height: 10.w),
                          (data["content"] ?? "").isEmpty
                              ? Container()
                              : RichText(
                                  text: TextSpan(
                                    text: data["content"] ?? "",
                                    style: StyleTheme.font_black_7716_14,
                                  ),
                                ),
                          Builder(builder: (cx) {
                            List tps = List.from(data['medias'] ?? []);
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
                                                              .font_black_7716_14)
                                                ])),
                                                SizedBox(height: 5.w),
                                                SizedBox(
                                                  width: width,
                                                  height: width / 16 * 9,
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .translucent,
                                                    onTap: () {
                                                      buyPostVideo(e);
                                                    },
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
                          data["topic"]["type"] == 1
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.w),
                                  child: RichText(
                                      text: TextSpan(children: [
                                    data["contact"].contains("***")
                                        ? TextSpan(
                                            text:
                                                "${data['unlock_coins']}${Utils.txt('jbkqawjy')}",
                                            style: StyleTheme.font_blue52_14,
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                int userMoney =
                                                    Provider.of<BaseStore>(
                                                                context,
                                                                listen: false)
                                                            .user
                                                            ?.money ??
                                                        0;
                                                int unlock_coins =
                                                    data['unlock_coins'] ?? 0;
                                                int money =
                                                    userMoney - unlock_coins;

                                                Utils.startGif(
                                                    tip: Utils.txt('jzz'));
                                                reqGetPostURL(
                                                        id: data['id'],
                                                        money: money,
                                                        context: context)
                                                    .then((value) {
                                                  Utils.closeGif();
                                                  if (value?.status == 1) {
                                                    data['contact'] = value
                                                            ?.data['contact'] ??
                                                        '';
                                                    if (mounted)
                                                      setState(() {});
                                                  } else {
                                                    Utils.showText(
                                                        value?.msg ?? '');
                                                  }
                                                });
                                              })
                                        : data["contact"].isEmpty
                                            ? const TextSpan()
                                            : TextSpan(
                                                text: Utils.txt('sjlxfs') +
                                                    "${data["contact"]}【${Utils.txt('djfz')}】",
                                                style:
                                                    StyleTheme.font_blue52_14,
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        Utils.copyToClipboard('${data["contact"]}', showToast: true, tip: Utils.txt('fzcglx'));
                                                      }),
                                  ])))
                              : Container(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    resetXcfocusNode();
                                    reqUserFavorite(id: data["id"], type: 14)
                                        .then((value) {
                                      if (value?.status == 1) {
                                        data["is_favorite"] =
                                            data["is_favorite"] == 1 ? 0 : 1;
                                        if (mounted) setState(() {});
                                      } else {
                                        Utils.showText(value?.msg ?? '');
                                      }
                                    });
                                  },
                                  child: buildWithCollect(),
                                ),
                                SizedBox(width: 20.w),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    resetXcfocusNode();
                                    Utils.navTo(context, "/minesharepage");
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LocalPNG(
                                        name: "ai_video_share",
                                        width: 20.w,
                                        height: 20.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        Utils.txt("fenx"),
                                        style: StyleTheme.font_black_7716_04_12,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                              height: 0.5.w, color: StyleTheme.devideLineColor),
                          SizedBox(height: 20.w),
                          Row(
                            children: [
                              Text(Utils.txt("pl"),
                                  style: StyleTheme.font_black_7716_06_15),
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
                                    return CommunityPostReview(
                                      data: comments[index],
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

  //购买帖子
  void buyPostVideo(dynamic e) {
    if (data['unlock_coins'] > 0 && e["media_url"].isEmpty) {
      UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
      if (user == null) return;
      int money = user.money ?? 0;
      int needmoney = data['unlock_coins'] ?? 0;
      bool isInsufficient = money < needmoney;

      Utils.showDialog(
          cancelTxt: Utils.txt('quxao'),
          confirmTxt: isInsufficient ? Utils.txt('qwcz') : Utils.txt('gmgk'),
          setContent: () {
            return Column(
              children: [
                Text(
                    Utils.txt('qsrtcjgr')
                        .replaceAll("00", "${data['unlock_coins']}"),
                    style: StyleTheme.font_gray_153_13),
                SizedBox(height: 15.w),
                Text(Utils.txt('ktvpzk') + "：$money",
                    style: StyleTheme.font_yellow_255_13,
                    textAlign: TextAlign.center),
              ],
            );
          },
          confirm: () {
            if (isInsufficient) {
              Utils.navTo(context, "/minegoldcenterpage");
            } else {
              Utils.startGif(tip: Utils.txt("gmzz"));
              reqGetPostURL(
                id: data["id"],
                money: money - needmoney,
                context: context,
              ).then((value) {
                Utils.closeGif();
                if (value?.status == 1) {
                  e['media_url'] = value?.data['url'] ?? '';
                  if (mounted) setState(() {});
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Utils.navTo(context,
                        "/unplayerpage/${Uri.encodeComponent(e["cover"] ?? "")}/${Uri.encodeComponent(e["media_url"] ?? "")}");
                  });
                } else {
                  Utils.showText(value?.msg ?? '');
                }
              });
            }
          });
    } else {
      Utils.navTo(context,
          "/unplayerpage/${Uri.encodeComponent(e["cover"] ?? "")}/${Uri.encodeComponent(e["media_url"] ?? "")}");
    }
  }

  void inputTxt(String post_id, String comment_id, String txt) {
    if (txt.isEmpty) {
      Utils.showText(Utils.txt("qsrplxx"));
      return;
    }
    Utils.startGif(tip: Utils.txt("fbioz"));
    reqPostComment(post_id: post_id, comment_id: comment_id, content: txt)
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
          style: StyleTheme.font_black_7716_04_12,
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
