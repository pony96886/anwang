import 'package:deepseek/base/input_container2.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/base/input_container.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityPostReview extends StatefulWidget {
  CommunityPostReview({
    Key? key,
    this.data,
    this.isSecond = false,
    this.replyCall,
    this.resetCall,
  }) : super(key: key);
  final dynamic data;
  final bool isSecond;
  final Function(String tip, String postid, String commid)? replyCall;
  final Function()? resetCall;

  @override
  State<CommunityPostReview> createState() => _CommunityPostReviewState();
}

class _CommunityPostReviewState extends State<CommunityPostReview> {
  dynamic _data;
  List<dynamic> _comments = [];
  List<dynamic> _tcoments = [];
  int max = 2;

  @override
  void initState() {
    super.initState();
    _data = widget.data;

    if (_data['is_like'] == 1 && _data['like_num'] == 0) {
      _data['like_num'] = 1;
    }

    _comments = List.from(_data["comments"] ?? []);
    //回复超过5条就显示更多评论
    _tcoments = _comments.length > max ? _comments.sublist(0, max) : _comments;
  }

  @override
  void didUpdateWidget(covariant CommunityPostReview oldWidget) {
    _data = widget.data;
    _comments = List.from(_data["comments"] ?? []);
    //回复超过5条就显示更多评论
    _tcoments = _comments.length > max ? _comments.sublist(0, max) : _comments;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 15.w),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30.w,
              height: 30.w,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // context.push('/mineUserCenter/${_data["user"]["aff"]}');
                },
                child: ImageNetTool(
                  url: _data["user"]["thumb"] ?? "",
                  radius: BorderRadius.all(Radius.circular(15.w)),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _data["user"]["nickname"] ?? "",
                          style: StyleTheme.font_black_7716_06_12,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      _data["user"]["agent"] == 1
                          ? Icon(Icons.verified_sharp,
                              size: 11.w, color: StyleTheme.blue52Color)
                          : Container(),
                    ],
                  ),
                  SizedBox(height: 4.w),
                  Row(
                    children: [
                      Utils.memberVip(
                        _data["user"]["vip_str"],
                        h: 14,
                        fontsize: 7,
                        margin: 5,
                      ),
                      Text(
                        "${_data["cityname"] ?? Utils.txt("csxq")}·${Utils.format(DateTime.parse(_data["created_at"] ?? ""))}",
                        style: StyleTheme.font_gray_153_11,
                      ),
                    ],
                  )
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                reqPostCommLike(type: "comment", id: _data["id"].toString())
                    .then((value) {
                  if (value?.status == 1) {
                    _data["is_like"] = _data["is_like"] == 1 ? 0 : 1;
                    _data["like_num"] = _data["is_like"] == 1
                        ? _data["like_num"] + 1
                        : _data["like_num"] - 1;
                    setState(() {});
                  } else {
                    Utils.showText(value?.msg ?? "");
                  }
                });
              },
              child: SizedBox(
                width: 40.w,
                child: Column(
                  children: [
                    LocalPNG(
                      name: _data["is_like"] == 1
                          ? "ai_comment_h"
                          : "ai_comment_n",
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(height: 1.w),
                    Text(
                      Utils.renderFixedNumber(_data["like_num"] ?? 0),
                      style: StyleTheme.font_gray_153_11,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 13.w),
        widget.isSecond
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 40.w),
                    child: Text(
                      _data["comment"] != null
                          ? Utils.convertEmojiAndHtml(_data["comment"])
                          : "",
                      style: StyleTheme.font_black_7716_06_14,
                      textAlign: TextAlign.left,
                      maxLines: 100,
                    ),
                  ),
                ],
              )
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  widget.replyCall?.call(
                      Utils.txt("hf") + "@${_data["user"]["nickname"] ?? ""}",
                      "0",
                      _data["id"].toString());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 40.w),
                      child: Text(
                        _data["comment"] != null
                            ? Utils.convertEmojiAndHtml(_data["comment"])
                            : "",
                        style: StyleTheme.font_black_7716_06_14,
                        textAlign: TextAlign.left,
                        maxLines: 100,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LocalPNG(
                          name: "ai_comm_replay_n",
                          width: 18.w,
                          height: 18.w,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          Utils.txt("hf"),
                          style: StyleTheme.font(
                              size: 13, color: StyleTheme.gray195Color),
                        )
                      ],
                    )
                  ],
                ),
              ),
        _tcoments.isEmpty || widget.isSecond
            ? SizedBox(height: 15.w)
            : Container(
                margin: EdgeInsets.symmetric(vertical: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _tcoments.asMap().keys.map((x) {
                    return Container(
                      margin: EdgeInsets.only(left: 40.w),
                      padding: EdgeInsets.only(
                        left: 10.w,
                        right: 10.w,
                        top: 10.w,
                        bottom: (x == _tcoments.length - 1 ? 10 : 0).w,
                      ),
                      width: double.infinity,
                      color: StyleTheme.whiteColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(children: [
                            _tcoments[x]["is_landlord"] == 1
                                ? WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 6.w),
                                      child: Container(
                                        height: 18.w,
                                        width: 36.w,
                                        decoration: BoxDecoration(
                                          gradient: StyleTheme.gradBlue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9.w)),
                                        ),
                                        child: Center(
                                          child: Text(Utils.txt("louzu"),
                                              style:
                                                  StyleTheme.font_white_255_11),
                                        ),
                                      ),
                                    ),
                                  )
                                : const TextSpan(),
                            TextSpan(
                              text:
                                  "${_tcoments[x]["user"]["nickname"] ?? ""} ${Utils.txt("hf")}：",
                              style: StyleTheme.font_black_7716_06_12,
                            )
                          ])),
                          SizedBox(height: 10.w),
                          Text(
                            _tcoments[x]["comment"] != null
                                ? Utils.convertEmojiAndHtml(
                                    _tcoments[x]["comment"])
                                : "",
                            style: StyleTheme.font_black_7716_06_14,
                            maxLines: 100,
                          ),
                          x == _tcoments.length - 1 && _comments.length > max
                              ? GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    widget.resetCall?.call();
                                    showMoreReview();
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10.w),
                                    child: Container(
                                      height: 30.w,
                                      decoration: BoxDecoration(
                                        color:
                                            StyleTheme.bgColor.withOpacity(1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.w)),
                                      ),
                                      child: Center(
                                        child: Text(Utils.txt("gdhf"),
                                            style: StyleTheme.font_gray_102_12),
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
        Container(height: 0.5.w, color: StyleTheme.devideLineColor)
      ],
    );
  }

  Future<Widget?> showMoreReview() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return CommunityPostReviewSecond(
              comment: _data,
            );
          });
        });
  }
}

class CommunityPostReviewSecond extends StatefulWidget {
  CommunityPostReviewSecond({Key? key, this.comment}) : super(key: key);
  final dynamic comment;

  @override
  State<CommunityPostReviewSecond> createState() =>
      _CommunityPostReviewSecondState();
}

class _CommunityPostReviewSecondState extends State<CommunityPostReviewSecond> {
  int page = 1;
  bool noMore = false;
  bool netError = false;
  bool isHud = true;
  List<dynamic> comments = [];
  List<dynamic> comentsList = [];
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    comments = List.from(widget.comment["comments"] ?? []);
    getData();
  }

  @override
  void didUpdateWidget(covariant CommunityPostReviewSecond oldWidget) {
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
   return reqPostCommentsSecond(
            comment_id: widget.comment["id"].toString(), page: page)
        .then((value) {
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      List st = List.from(value?.data ?? []);
      if (page == 1) {
        noMore = false;
        comentsList = st;
      } else if (st.isNotEmpty) {
        comentsList.addAll(st);
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
              topLeft: Radius.circular(5.w),
              topRight: Radius.circular(5.w),
            ),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              focusNode.unfocus();
            },
            child: netError
                ? LoadStatus.netError(onTap: () {
                    netError = false;
                    getData();
                  })
                : isHud
                    ? LoadStatus.showLoading(mounted)
                    : InputContainer2(
                        focusNode: focusNode,
                        bg: StyleTheme.whiteColor,
                        labelText: Utils.txt("hf") +
                            "@${widget.comment["user"]["nickname"] ?? ""}",
                        onEditingCompleteText: (value) {
                          inputTxt(value);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                left: 20.w,
                                right: 20.w,
                                top: 20.w,
                                bottom: 10.w,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(Icons.close,
                                        size: 12.w,
                                        color: StyleTheme.blak7716_07_Color),
                                  ),
                                  Text(
                                    "${comments.length}${Utils.txt('t')}${Utils.txt('hf')}",
                                    style:
                                        StyleTheme.font_black_7716_06_16_semi,
                                  ),
                                  Container(),
                                ],
                              ),
                            ),
                            Expanded(
                              child: PullRefresh(
                                onLoading: () {
                                  page++;
                                  return getData();
                                },
                                child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: StyleTheme.margin,
                                    ),
                                    itemCount: comentsList.length,
                                    itemBuilder: (context, index) {
                                      return CommunityPostReview(
                                          data: comentsList[index],
                                          isSecond: true);
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
          )),
    );
  }

  void inputTxt(String txt) {
    if (txt.isEmpty) {
      Utils.showText(Utils.txt("qsrplxx"));
      return;
    }
    Utils.startGif(tip: Utils.txt("fbioz"));
    reqPostComment(
            post_id: "0",
            comment_id: widget.comment["id"].toString(),
            content: txt)
        .then((value) {
      Utils.closeGif();
      Utils.showText(value?.msg ?? "");
    });
  }
}
