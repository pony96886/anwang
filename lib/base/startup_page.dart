import 'dart:async';

import 'package:deepseek/base/index_page.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({Key? key}) : super(key: key);

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  DateTime? lastPopTime;
  Map? adsmap = AppGlobal.appBox?.get('adsmap');
  List? start_screen_ads = AppGlobal.appBox?.get('start_screen_ads');

  String weburl = AppGlobal.appBox?.get('office_web') ?? "";
  int count = 6;
  int startIndex = 0;
  bool isCheck = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLines();
  }

  @override
  Widget build(BuildContext context) {
    AppGlobal.context = context;
    return WillPopScope(
        child: Scaffold(
          backgroundColor: StyleTheme.bgColor,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Utils.unFocusNode(context);
            },
            child: AppGlobal.apiBaseURL.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Center(
                      child: isCheck
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                      text: Utils.txt('jcxlsd'),
                                      style: StyleTheme.font(
                                          size: 14,
                                          color: StyleTheme.blak7716Color)),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20.w),
                                weburl.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          Utils.openURL(weburl);
                                        },
                                        child: Text(
                                          Utils.txt('gwdzdz') + '：$weburl',
                                          style: StyleTheme.font_blue52_14,
                                          maxLines: 3,
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : Container()
                              ],
                            )
                          : LoadStatus.netError(
                              text: Utils.txt('wfljqsz'),
                              onTap: () {
                                checkLines();
                              }),
                    ),
                  )
                // : adsmap == null
                : start_screen_ads == null
                    ? const IndexPage()
                    : startLaunchDoublePNG(),
          ),
        ),
        onWillPop: () async {
          //点击返回键的操作
          if (lastPopTime == null ||
              DateTime.now().difference(lastPopTime!) >
                  const Duration(seconds: 2)) {
            lastPopTime = DateTime.now();
            Utils.showText(Utils.txt('zatck'));
            return false;
          } else {
            // AppGlobal.proxy?.close();
            lastPopTime = DateTime.now();
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            return true;
          }
        });
  }

  //加载AD图
  Widget startLaunchPNG() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (adsmap?['url'] == '' || adsmap?['url'] == null) return;
            //上报点击量
            reqAdClickCount(id: adsmap?['id'], type: adsmap?['type']);
            Utils.openURL(adsmap?['url']);
          },
          child: ImageNetTool(url: adsmap?['image']),
        ),
        Positioned(
          top: StyleTheme.topHeight + 10.w,
          right: 15.w,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (count > 0) return;
              adsmap = null;
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 15.w),
              height: 35.w,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                borderRadius: BorderRadius.circular(35.w),
              ),
              child: Center(
                child: Text(
                  '${count > 0 ? count : Utils.txt('tggg')}',
                  style: StyleTheme.font(size: 15, weight: FontWeight.w500),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  //加载AD图 3秒轮播版
  Widget startLaunchDoublePNG() {
    List addMapList = start_screen_ads ?? [];
    return Stack(
      children: [
        StatefulBuilder(builder: (context, sss) {
          int idx = 0;
          return GestureDetector(
            onTap: () {
              if (addMapList[idx]['url'] == '' ||
                  addMapList[idx]['url'] == null) return;
              reqAdClickCount(
                  id: addMapList[idx]['id'], type: addMapList[idx]['type']);

              Utils.openURL(addMapList[idx]['url']);
            },
            child: AbsorbPointer(
              absorbing: false,
              child: Swiper(
                itemCount: addMapList.length,
                autoplay: addMapList.length > 1, // && count >= 1,
                autoplayDelay: 2800,
                duration: 300,
                onIndexChanged: (index) {
                  idx = index;

                  // print('idx = $idx');
                },
                itemBuilder: (context, index) {
                  return ImageNetTool(
                    url: addMapList[index]['image'],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          );
        }),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.w,
          right: 15.w,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (count > 0) return;
              start_screen_ads = null;
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 15.w),
              height: 35.w,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                borderRadius: BorderRadius.circular(35.w),
              ),
              child: Center(
                child: Text(
                  '${count > 0 ? count : Utils.txt('tggg')}',
                  style: StyleTheme.font(size: 15, weight: FontWeight.w500),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void adsWatch() {
    if (start_screen_ads == null) {
      setState(() {});
      return;
    }
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (count <= 0) {
        timer.cancel();
        return;
      }
      count--;
      setState(() {});
    });
  }

  void checkLines() {
    //检测线路
    Utils.checkline(
      onFailed: () {
        isCheck = false;
        setState(() {});
      },
      onSuccess: () {
        if (startIndex == 0) {
          startIndex = 1;
          adsWatch();
        }
      },
    );
  }
}
