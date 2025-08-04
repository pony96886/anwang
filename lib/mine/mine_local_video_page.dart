import 'package:deepseek/base/shortv_mv_player.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineLocalVideoPage extends StatefulWidget {
  MineLocalVideoPage({Key? key, this.videoInfo}) : super(key: key);
  final Map<String, dynamic>? videoInfo;
  @override
  _MineLocalVideoPageState createState() => _MineLocalVideoPageState();
}

class _MineLocalVideoPageState extends State<MineLocalVideoPage> {
  // FijkPlayer实例

  @override
  void initState() {
    super.initState();
    Utils.setStatusBar(isLight: true);
    print(widget.videoInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: StyleTheme.topHeight),
          Container(
              height: ScreenUtil().screenWidth * 9 / 16,
              width: double.infinity,
              color: Colors.black45,
              child: ShortvMvPlayer(
                  info: widget.videoInfo, needCheckAspectRatio: true)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Utils.setStatusBar(isLight: false);
    super.dispose();
  }
}
