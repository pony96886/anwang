import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/shortv_mv_player.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UNPlayerPage extends BaseWidget {
  UNPlayerPage({Key? key, this.cover, this.url}) : super(key: key);
  late String? cover;
  late String? url;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _UNPlayerPageState();
  }
}

class _UNPlayerPageState extends BaseWidgetState<UNPlayerPage> {
  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    Utils.setStatusBar(isLight: true);
    widget.cover = Uri.decodeComponent(widget.cover ?? "");
    widget.url = Uri.decodeComponent(widget.url ?? "");
    Utils.log(widget.url);
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    Utils.setStatusBar(isLight: false);
  }

  @override
  Widget pageBody(BuildContext context) {
    // TODO: implement pageBody

    return Container(
      color: Colors.black,
      child: widget.url?.isEmpty == true
          ? Container()
          : ShortvMvPlayer(
              info: {
                "source_240": widget.url ?? "",
                "preview_url": "",
                "cover": widget.cover ?? "",
                "title": "",
                "isSpeed": 1,
              },
              needCheckAspectRatio: true,
            ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
