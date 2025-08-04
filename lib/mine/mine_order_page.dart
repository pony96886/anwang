import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum MediaType {
  mv,
  vlog,
  post,
  voice,
  cartoon,
  comic,
  game,
  novel,
  girl,
  stripChat,
}

extension MediaTypeExtension on MediaType {
  String get name {
    switch (this) {
      case MediaType.mv:
        return Utils.txt('csp');
      case MediaType.vlog:
        return Utils.txt('dsp');
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

  String get typeInt {
    switch (this) {
      case MediaType.mv:
        return 'mv';
      case MediaType.vlog:
        return 'vlog';
      case MediaType.post:
        return 'post';
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

class MineOderPage extends BaseWidget {
  MineOderPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineOderPageState();
  }
}

class _MineOderPageState extends BaseWidgetState<MineOderPage> {
  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('wddd'), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody
    return GenCustomNav(
      type: GenCustomNavType.none,
      titles: [
        // Utils.txt('yp'),
        Utils.txt('lliao'),
      ],
      pages: [
        // BuyChildPage(
        //   type: MediaType.girl,
        // ),
        BuyChildPage(
          type: MediaType.stripChat,
        ),
      ],
      selectStyle: StyleTheme.font_blue52_15,
      defaultStyle: StyleTheme.font_black_7716_15,
    );
  }
}

class BuyChildPage extends StatefulWidget {
  BuyChildPage({Key? key, required this.type}) : super(key: key);
  final MediaType type;

  @override
  State<BuyChildPage> createState() => _BuyChildPageState();
}

class _BuyChildPageState extends State<BuyChildPage> {
  int page = 1;
  bool isMore = false;
  bool networkErr = false;
  bool isHud = true;
  String lastIx = "";
  List _dataList = [];

  Future<bool> getData() async {
    ResponseModel<dynamic>? res;

    res = await reqMineBuyList(
        type: widget.type.value, page: page, lastIx: lastIx);
    // switch (widget.type) {
    //   case MediaType.girl:
    //     res = await reqMineBuyList(type: 'girl', page: page, lastIx: lastIx);
    //     break;
    //   case MediaType.stripChat:
    //     res = await reqMineBuyList(type: 'chat', page: page, lastIx: lastIx);
    //     break;
    //   default:
    // }

    if (res?.status != 1) {
      networkErr = true;
      if (mounted) setState(() {});
      return false;
    }
    List tp = List.from(res?.data ?? []);
    if (page == 1) {
      isMore = false;
      _dataList = tp;
    } else if (tp.isNotEmpty) {
      _dataList.addAll(tp);
    } else {
      isMore = true;
    }
    isHud = false;
    if (mounted) setState(() {});
    return isMore;
  }

  Widget _listView() {
    if (widget.type == MediaType.girl) {
      return _girlListView();
    } else if (widget.type == MediaType.stripChat) {
      return _stripChatListView();
    }
    return Container();
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
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return networkErr
        ? LoadStatus.netError(onTap: () {
            networkErr = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : PullRefresh(
                onRefresh: () {
                  page = 1;
                  return getData();
                },
                onLoading: () {
                  page++;
                  return getData();
                },
                child: _dataList.isEmpty ? LoadStatus.noData() : _listView());
  }
}
