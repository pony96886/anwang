import 'package:deepseek/acgn/cartoon/cartoon_rec_page.dart';
import 'package:deepseek/acgn/cartoon/cartoon_sub_page.dart';
import 'package:deepseek/acgn/comic/comic_rec_page.dart';
import 'package:deepseek/acgn/comic/comic_sub_page.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/home/home_rec_page.dart';
import 'package:deepseek/home/home_sub_page.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ComicPage extends StatefulWidget {
  ComicPage({this.isShow = true});
  final bool isShow;

  @override
  State<ComicPage> createState() => _ComicPageState();
}

class _ComicPageState extends State<ComicPage> {
  bool isHud = true;
  bool netError = false;

  List topNavs = [];

  List<String> titles = [];
  List pageIDs = [];
  List pages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
  }

  getData() {
    topNavs =
        Provider.of<BaseStore>(context, listen: false).conf?.comic_top_nav ??
            [];

    pageIDs = topNavs.map((e) => e["id"]).toList();
    isHud = false;
    if (mounted) setState(() {});
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
            : GenCustomNav(
                initialIndex: 0,
                titles: topNavs
                    .map((e) => (e["name"] ?? e["title"]) as String)
                    .toList(),
                pages: topNavs.asMap().keys.map((e) {
                  LinkModel _link = LinkModel.fromJson(topNavs[e]);

                  _link.params = {
                    'id': topNavs[e]['id'],
                  };
                  if (topNavs[e]['type'] == 2) {
                    return ComicRecPage(
                      linkModel: _link,
                      isShow: widget.isShow,
                    );
                  }

                  return ComicSubPage(
                    linkModel: _link,
                    // isDiscover: topNavs[e]['type'] == 2,
                  );
                }).toList(),
              );
  }
}
