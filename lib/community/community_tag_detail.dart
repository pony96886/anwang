import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/community/community_tag_detail_child.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CommunityTagDetail extends BaseWidget {
  const CommunityTagDetail({Key? key, this.topic_id = "0"}) : super(key: key);
  final String topic_id;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _CommunityTagDetailState();
  }
}

class _CommunityTagDetailState extends BaseWidgetState<CommunityTagDetail> {
  dynamic topic;
  List<dynamic> tps = [];

  @override
  void onCreate() {
    // TODO: implement onCreate
    tps = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.forum_nav ??
        [];
    getData();
  }

  void getData() {
    reqTopicsDetail(topic_id: widget.topic_id).then((value) {
      if (value?.status == 1) {
        topic = value?.data;
        setAppTitle(
            titleW:
                Text(topic["name"] ?? "", style: StyleTheme.nav_title_font));
        if (mounted) setState(() {});
      } else {
        Utils.showText(value?.msg ?? "", call: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) finish();
          });
        });
      }
    });
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return topic == null
        ? Container()
        : NestedScrollView(
            headerSliverBuilder: (context, res) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                    child: Column(
                      children: [
                        SizedBox(height: 15.w),
                        Row(
                          children: [
                            SizedBox(
                              width: 90.w,
                              height: 90.w,
                              child: ImageNetTool(
                                url: topic["thumb"] ?? "",
                                radius: BorderRadius.all(Radius.circular(5.w)),
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic["intro"] ?? "",
                                    style: StyleTheme.font_black_7716_14,
                                    maxLines: 3,
                                  ),
                                  SizedBox(height: 10.w),
                                  Text(
                                    "${Utils.renderFixedNumber(topic["post_num"] ?? 0)}${Utils.txt("tiez")}    ${Utils.renderFixedNumber(topic["view_num"] ?? 0)}${Utils.txt("llan")}",
                                    style: StyleTheme.font_gray_153_12,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 7.w),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                //话题关注/取消关注
                                reqFollowTopic(topic_id: topic["id"].toString())
                                    .then((value) {
                                  if (value?.status == 1) {
                                    topic["is_follow"] =
                                        topic["is_follow"] == 1 ? 0 : 1;
                                    if (mounted) setState(() {});
                                  } else {
                                    Utils.showText(value?.msg ?? "");
                                  }
                                });
                              },
                              child: Container(
                                width: 55.w,
                                height: 26.w,
                                decoration: BoxDecoration(
                                    color: topic["is_follow"] == 1
                                        ? StyleTheme.blue52Color
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(13.w)),
                                    border: Border.all(
                                        color: topic["is_follow"] == 1
                                            ? Colors.transparent
                                            : StyleTheme.blue52Color,
                                        width: 0.5.w)),
                                child: Center(
                                  child: Text(
                                    topic["is_follow"] == 1
                                        ? Utils.txt("ygz")
                                        : "+ ${Utils.txt("guanz")}",
                                    style: topic["is_follow"] == 1
                                        ? StyleTheme.font_white_255_11
                                        : StyleTheme.font_blue_52_11,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10.w),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: GenCustomNav(
              labelPadding: 15,
              titles: tps.map((e) => (e["title"] ?? "") as String).toList(),
              pages: tps.map((e) {
                return CommunityTagDetailChild(
                  topic_id: widget.topic_id,
                  cate: e["type"],
                );
              }).toList(),
              type: GenCustomNavType.none,
              selectStyle: StyleTheme.font_blue52_14,
              defaultStyle: StyleTheme.font_black_7716_14,
            ),
          );
  }
}
