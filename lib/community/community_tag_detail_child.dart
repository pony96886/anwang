import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityTagDetailChild extends StatefulWidget {
  CommunityTagDetailChild({Key? key, this.topic_id = "0", this.cate = ""})
      : super(key: key);
  final String topic_id;
  final String cate;

  @override
  State<CommunityTagDetailChild> createState() =>
      _CommunityTagDetailChildState();
}

class _CommunityTagDetailChildState extends State<CommunityTagDetailChild> {
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
    return reqTopicPostList(topic_id: widget.topic_id, cate: widget.cate, page: page)
        .then((value) {
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
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: array.length,
                        itemBuilder: (context, index) {
                          return Utils.postModuleUI(context, array[index]);
                        }),
                  );
  }
}
