import 'package:deepseek/base/base_comment_review.dart';
import 'package:deepseek/base/input_container.dart';
import 'package:deepseek/base/input_container2.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseCommentPage extends StatefulWidget {
  BaseCommentPage({this.id = '0', this.type = ''});

  final String id;
  final String type;

  @override
  State<BaseCommentPage> createState() => _BaseCommentPageState();
}

class _BaseCommentPageState extends State<BaseCommentPage> {
  List comments = [];
  bool isHud = true;
  bool netError = false;
  bool noMore = false;

  bool isReplay = false;
  String tip = Utils.txt("wyddxf");
  FocusNode focusNode = FocusNode();

  int page = 1;
  String last_ix = "0";

  //加载评论
  Future<bool> getReviewData() {
    return reqCommentList(id: widget.id, type: widget.type, page: page).then((value) {
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

  void inputTxt(String txt) {
    if (txt.isEmpty) {
      Utils.showText(Utils.txt("qsrplxx"));
      return;
    }
    Utils.startGif(tip: Utils.txt("fbioz"));
    reqCreatComment(type: widget.type, id: widget.id, content: txt)
        .then((value) {
      Utils.closeGif();
      Utils.showText(value?.msg ?? '');
    });
  }

  @override
  void initState() {
    super.initState();
    getReviewData();
  }

  @override
  Widget build(BuildContext context) {
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getReviewData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : InputContainer2(
                focusNode: focusNode,
                bg: StyleTheme.whiteColor,
                onEditingCompleteText: (value) {
                  inputTxt(value);
                },
                labelText: tip,
                child: PullRefresh(
                  onRefresh: () {
                    page = 1;
                    return getReviewData();
                  },
                  onLoading: () {
                    page++;
                    return getReviewData();
                  },
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                    child: comments.isEmpty
                        ? LoadStatus.noData()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 5.w),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return BaseCommentReview(
                                type: widget.type,
                                data: comments[index],
                                resetCall: () {
                                  // resetXcfocusNode();
                                },
                              );
                            }),
                  ),
                ),
              );
  }
}
