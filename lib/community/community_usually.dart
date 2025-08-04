import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityUsally extends StatefulWidget {
  CommunityUsally({Key? key, this.id = 0, this.sort = "new", this.fun})
      : super(key: key);
  final int id;
  final String sort;
  final Function(dynamic)? fun;

  @override
  State<CommunityUsally> createState() => _CommunityUsallyState();
}

class _CommunityUsallyState extends State<CommunityUsally> {
  int page = 1;
  bool noMore = false;
  bool netError = false;
  bool isHud = true;
  List<dynamic> array = [];
  List<dynamic> topics = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<bool> getData() {
   return (widget.id == 100
            ? reqCommunityAiList(page: page)
            : reqCommunitySortList(
                id: widget.id, sort: widget.sort, page: page))
        .then((value) {
      if (value?.data == null) {
        netError = true;
        setState(() {});
        return false;
      }
      List st = List.from(value?.data["posts"] ?? []);
      if (page == 1) {
        noMore = false;
        topics = List.from(value?.data["topics"] ?? []);
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
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: array.length,
                        itemBuilder: (context, index) {
                          return Utils.postModuleUI(context, array[index]);
                        }),
                  );
  }
}
