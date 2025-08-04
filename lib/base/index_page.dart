import 'dart:async';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:deepseek/acgn/acgn_page.dart';
import 'package:deepseek/ai/ai_area_page.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/update_sysalert.dart';
import 'package:deepseek/community/community_page.dart';
import 'package:deepseek/home/home_page.dart';
import 'package:deepseek/mine/mine_page.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/model/alert_ads_model.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/cache/cache_manager.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/general_banner_apps_list_widget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:deepseek/voice/voice_player_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;
import "package:universal_html/js.dart" as js;
import 'package:deepseek/util/platform_utils_native.dart'
    if (dart.library.html) 'package:deepseek/util/platform_utils_web.dart'
    as ui;

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int selectIndex = 0;
  List<Map> tabs = [
    {
      'title': Utils.txt('shy'),
      'icon': 'ai_tab_home_off',
      'icon_sel': 'ai_tab_home_on',
    },
    {
      'title': Utils.txt('azq'),
      'icon': 'ai_tab_ai_off',
      'icon_sel': 'ai_tab_ai_on',
    },
    {
      'title': Utils.txt('ciy'),
      'icon': 'ai_tab_acg_off',
      'icon_sel': 'ai_tab_acg_on',
    },
    {
      'title': Utils.txt('apcyq'),
      'icon': 'ai_tab_community_off',
      'icon_sel': 'ai_tab_community_on',
    },
    // {
    //   'title': Utils.txt('aity'),
    //   'icon': 'ai_tab_strip',
    //   'icon_sel': 'ai_tab_strip_h',
    // },
    {
      'title': Utils.txt('apwd'),
      'icon': 'ai_tab_mine_off',
      'icon_sel': 'ai_tab_mine_on',
    },
  ];
  bool netError = false;
  bool isHud = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  dynamic discrip;

  List<AdsModel> toADs = [];

  //初始化数据
  _getData() {
    reqConfig(context).then((value) {
      if (value?.status == 1) {
        toADs = Provider.of<BaseStore>(context, listen: false).conf?.buoy ?? [];
        AppGlobal.appBox?.put("lines_url", value?.data?.config?.lines_url);
        AppGlobal.appBox?.put("github_url", value?.data?.config?.github_url);
        AppGlobal.appBox?.put('office_web', value?.data?.config?.office_site);
        reqUserInfo(context).then((res) {
          isHud = false;
          netError = false;
          if (res?.status == 1) {
            _clipBoardText();
            _loadSysAlert(value?.data);
          } else {
            netError = true;
            Utils.showText(Utils.txt('hqsbcs'));
          }
          setState(() {});
        });
        //缓存广告AD
        Box box = AppGlobal.appBox!;
        Timer(Duration(seconds: 3), () {
          if ((value?.data?.start_screen_ads ?? []).isNotEmpty) {
            List<AdsModel> start_screen_ads =
                value?.data?.start_screen_ads ?? [];
            setImageInfo(String imgUrl, int idx) {
              if (imgUrl == null) {
                box.put('start_screen_ads', null);
                return;
              }
              CacheManager.image.downLoadImage(imgUrl).then((_) {
                if (idx == start_screen_ads.length - 1) {
                  box.put(
                      'start_screen_ads',
                      start_screen_ads.map((e) {
                        return {
                          'image': e.img_url,
                          'url': e.url,
                          'id': e.report_id ?? 0,
                          'type': e.report_type ?? 0,
                        };
                      }).toList());
                  debugPrint('广告加载成功');
                } else {
                  String imageUrl = start_screen_ads[idx + 1].img_url ?? '';
                  setImageInfo(imageUrl, idx + 1);
                }
              });
            }

            String imageUrl = start_screen_ads.first.img_url ?? '';
            setImageInfo(imageUrl, 0);
          } else {
            box.put('start_screen_ads', null);
          }
        });

        // String? _adurl = value?.data?.ads?.img_url;
        // if (_adurl != null) {
        //   ImageRequestAsync.getImageRequest(_adurl).then((_) {
        //     AppGlobal.appBox?.put('adsmap', {
        //       'image': _adurl,
        //       'url': value?.data?.ads?.url,
        //       'id': value?.data?.ads?.report_id ?? 0,
        //       'type': value?.data?.ads?.report_type ?? 0,
        //     });
        //   });
        // } else {
        //   AppGlobal.appBox?.put('adsmap', null);
        // }
      } else {
        netError = true;
        setState(() {});
      }
    });
  }

  //统计
  _initPlatformState() async {
    // if (!kIsWeb) {
    //   await Flurry.initialize(
    //     androidKey: "W2VR64X4QCHSBTX9HYF2",
    //     iosKey: "D9BF7G9HH6CDRT2ZKGGQ",
    //   );
    // }
  }

  //填写邀请码
  void _clipBoardText() {
    if (kIsWeb) {
      Uri u = Uri.parse(html.window.location.href);
      String? aff = u.queryParameters['dpk_aff'];
      if (aff != null) {
        reqInvitation(affCode: aff);
      }
    } else {
      Clipboard.getData(Clipboard.kTextPlain).then((value) {
        if (value?.text != null) {
          List cliptextList = value?.text?.split(":").toList() ?? [];
          if (cliptextList.length > 1) {
            if (cliptextList[0] == 'dpk_aff') {
              if (cliptextList[1] != '') {
                reqInvitation(affCode: cliptextList[1]);
              }
            }
          }
        }
      });
    }
  }

  //系统弹窗
  void _loadSysAlert(ConfigModel? data) {
    if (data == null) return;
    if (data.versionMsg != null) {
      var targetVersion = data.versionMsg?.version?.replaceAll('.', '');
      var currentVersion = AppGlobal.appinfo['version'].replaceAll('.', '');
      var needUpdate =
          int.parse(targetVersion ?? "100") > int.parse(currentVersion);
      if (kIsWeb) {
        //web不需要更新，只展示广告｜公告
        _showActivety(data);
        return;
      }
      //显示规则 版本更新 > AD弹窗 > 系统公告
      if (needUpdate) {
        _updateAlert(data);
      } else {
        _showActivety(data);
      }
    } else {
      _showActivety(data);
    }
  }

  //APPS显示
  void _appsAlert(ConfigModel? data) {
    var apps =
        Provider.of<BaseStore>(context, listen: false).conf?.notice_app ?? [];

    if (apps.isNotEmpty) {
      UpdateSysAlert.showAppAlert(
        apps,
        cancel: () {
          _noticeAlert(data);
        },
      );
    } else {
      _noticeAlert(data);
    }
  }

  //公告显示
  void _noticeAlert(ConfigModel? data) {
    if (data?.versionMsg?.mstatus == 1) {
      UpdateSysAlert.showAnnounceAlert(
        text: data?.versionMsg?.message,
        cancel: () {
          _addMainScreen();
        },
        confirm: () {
          _addMainScreen();
        },
      );
      return;
    }
    _addMainScreen();
  }

  //加载添加到主屏幕功能
  void _addMainScreen() async {
    return;
    if (!kIsWeb) return;
    Uri u = Uri.parse(html.window.location.href);
    String time = u.queryParameters['time'] ?? "";
    if (time.isNotEmpty) {
      BconfModel? cf =
          Provider.of<BaseStore>(context, listen: false).conf?.config;
      String webURL = cf?.office_site ?? "";
      int sinceDay = cf?.days ?? 10;
      DateTime cals =
          DateTime.fromMillisecondsSinceEpoch(int.parse(time) * 1000);
      int days = DateTime.now().difference(cals).inDays;
      if (days >= sinceDay) {
        Utils.showDialog(
          cancelTxt: Utils.txt('quxao'),
          confirmTxt: Utils.txt('quren'),
          setContent: () {
            return Utils.getContentSpan(
              Utils.txt("ymsxhqzx").replaceAll("00", webURL),
              style: StyleTheme.font_yellow_255_13,
              lightStyle: StyleTheme.font(
                  size: 13, color: const Color.fromRGBO(25, 103, 210, 1)),
            );
          },
          confirm: () {
            Utils.openURL(webURL);
          },
        );
        return;
      }
    }
    bool isSafari = js.context.callMethod("checkSafari") as bool;
    bool isInstall =
        (js.context.callMethod("getInstallValue") as String) == "1";
    if (!isSafari && !isInstall) {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setBottomSheetState) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.w),
                      topLeft: Radius.circular(5.w)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20.w),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 20.w, height: 20.w),
                        Text(
                          Utils.txt('tjwberk'),
                          style: StyleTheme.font_black_31_14,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.close,
                            size: 20.w,
                            color: StyleTheme.black31Color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.w),
                    Utils.getContentSpan(
                      Utils.txt('tjwbdes')
                          .replaceAll("000", html.window.location.href),
                      style: StyleTheme.font_blue_52_12,
                      lightStyle: StyleTheme.font(
                          size: 12,
                          color: const Color.fromRGBO(25, 103, 210, 1)),
                    ),
                    SizedBox(height: 20.w),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        final bool isDeferredNotNull =
                            js.context.callMethod("isDeferredNotNull") as bool;
                        if (isDeferredNotNull) {
                          js.context.callMethod("presentAddToHome");
                        } else {
                          Utils.showText(Utils.txt('tjpjg'), time: 2);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: StyleTheme.gradBlue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.w))),
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        height: 32.w,
                        alignment: Alignment.center,
                        child: Text(Utils.txt('tjwbzpm'),
                            style: StyleTheme.font(size: 13)),
                      ),
                    ),
                    SizedBox(height: 30.w),
                  ],
                ),
              );
            });
          });
    }
  }

  //版本更新
  void _updateAlert(ConfigModel? data) {
    UpdateSysAlert.showUpdateAlert(
      site: () {
        Utils.openURL(data?.config?.office_site ?? "");
      },
      guide: () {
        Utils.openURL(data?.config?.solution ?? "");
      },
      cancel: () {
        _showActivety(data);
      },
      confirm: () {
        if (Platform.isAndroid) {
          UpdateSysAlert.androidUpdateAlert(
              version: data?.versionMsg?.version, url: data?.versionMsg?.apk);
        } else {
          Utils.openURL(data?.versionMsg?.apk ?? "");
        }
      },
      version: "V${data?.versionMsg?.version}",
      text: data?.versionMsg?.tips,
      mustupdate: data?.versionMsg?.must == 1,
    );
  }

  //初始化下载状态
  Future<void> _initDownloadStatus() async {
    Box box = await Hive.openBox('deepseek_video_box');
    List tasks = box.get('download_video_tasks') ?? [];
    if (tasks.isNotEmpty) {
      tasks = tasks.map((element) {
        element["downloading"] = false;
        element["isWaiting"] = false;
        return element;
      }).toList();
    }
    box.put("download_video_tasks", tasks);
  }

  //显示弹窗
  void _showActivety(ConfigModel? data, {int index = 0}) {
    if (data?.pop_ads?.isEmpty == true) {
      _appsAlert(data);
      return;
    }
    AlertAdsModel? tp = data?.pop_ads?[index];
    UpdateSysAlert.showAvtivetysAlert(
        ads: tp,
        cancel: () {
          if (index == (data?.pop_ads?.length ?? 0) - 1) {
            _appsAlert(data);
          } else {
            _showActivety(data, index: index + 1);
          }
        },
        confirm: () {
          //上报点击量
          reqAdClickCount(id: tp?.report_id, type: tp?.report_type);
          if (tp?.type == "route") {
            String _url = tp?.url_str ?? "";
            List _urlList = _url.split('??');
            Map<String, dynamic> pramas = {};
            if (_urlList.first == "web") {
              pramas["url"] = _urlList.last.toString().substring(4);
              if (kIsWeb) {
                Utils.openURL(Uri.decodeComponent(pramas.values.first.trim()));
              } else {
                Utils.navTo(
                    context, "/${_urlList.first}/${pramas.values.first}");
              }
            } else {
              if (_urlList.length > 1 && _urlList.last != "") {
                _urlList[1].split("&").forEach((item) {
                  List stringText = item.split('=');
                  pramas[stringText[0]] =
                      stringText.length > 1 ? stringText[1] : null;
                });
              }
              String pramasStrs = "";
              if (pramas.values.isNotEmpty) {
                pramas.forEach((key, value) {
                  pramasStrs += "/$value";
                });
              }
              Utils.navTo(context, "/${_urlList.first}$pramasStrs");
            }
          } else {
            Utils.openURL(tp?.url_str?.trim() ?? "");
            if (index == (data?.pop_ads?.length ?? 0) - 1) {
              _appsAlert(data);
            } else {
              _showActivety(data, index: index + 1);
            }
          }
        });
  }

  //清理磁盘
  _initClearDisk() async {
    if (kIsWeb) {
      PaintingBinding.instance.imageCache.clear();
      AppGlobal.imageCacheBox?.clear();
      return;
    }
    String path = AppGlobal.imageCacheBox?.path ?? "";
    try {
      int size = await File(path).length();
      //大于500M就清理
      if (size / 1000 / 1000 > 500) await AppGlobal.imageCacheBox?.clear();
    } catch (e) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    VoicePlayerManager.instance.topContext = context;
    _getData();
    _initPlatformState();
    _initClearDisk();
    if (!kIsWeb) _initDownloadStatus();

    discrip = UtilEventbus().on<EventbusClass>().listen((event) {
      if (event.arg["name"] == 'IndexNavJump') {
        int index = event.arg["index"];

        selectIndex = index;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    discrip.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double pHeight = ScreenUtil().screenHeight - StyleTheme.pxBotHegiht;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: StyleTheme.bgColor,
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: kIsWeb && !ui.platformViewRegistry.isPWA()
              ? Padding(
                  padding: EdgeInsets.only(bottom: 80.w),
                  child: GestureDetector(
                    onTap: () {
                      Utils.downLoadApp(context);
                    },
                    child: Container(
                      height: 30.w,
                      width: 200.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: StyleTheme.blue52Color,
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.w))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LocalPNG(name: "ai_logo", width: 22.w, height: 22.w),
                          SizedBox(width: 5.w),
                          Text(Utils.txt("mrdxdk"),
                              style: StyleTheme.font_white_255_14_medium)
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          body: netError
              ? LoadStatus.netError(onTap: () {
                  _getData();
                })
              : isHud
                  ? LoadStatus.showLoading(mounted, text: Utils.txt('sjcshz'))
                  : SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        height: ScreenUtil().screenHeight,
                        child: Column(
                          children: [
                            Expanded(
                                child: Stack(
                              children: [
                                Positioned(
                                  left: -selectIndex * ScreenUtil().screenWidth,
                                  top: 0,
                                  bottom: 0,
                                  child: SizedBox(
                                    width: ScreenUtil().screenWidth,
                                    height: pHeight,
                                    child: const HomePage(
                                      isShow: true,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: (-selectIndex + 1) *
                                      ScreenUtil().screenWidth,
                                  top: 0,
                                  bottom: 0,
                                  child: SizedBox(
                                    width: ScreenUtil().screenWidth,
                                    height: pHeight,
                                    child: AIAreaPage(isShow: selectIndex == 1),
                                  ),
                                ),
                                Positioned(
                                  left: (-selectIndex + 2) *
                                      ScreenUtil().screenWidth,
                                  top: 0,
                                  bottom: 0,
                                  child: SizedBox(
                                    width: ScreenUtil().screenWidth,
                                    height: pHeight,
                                    child: ACGNPage(
                                      isShow: selectIndex == 2,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: (-selectIndex + 3) *
                                      ScreenUtil().screenWidth,
                                  top: 0,
                                  bottom: 0,
                                  child: SizedBox(
                                    width: ScreenUtil().screenWidth,
                                    height: pHeight,
                                    child:
                                        CommunityPage(isShow: selectIndex == 3),
                                  ),
                                ),

                                // Positioned(
                                //     left: (-selectIndex + 3) *
                                //         ScreenUtil().screenWidth,
                                //     top: 0,
                                //     bottom: 0,
                                //     child: SizedBox(
                                //       width: ScreenUtil().screenWidth,
                                //       height: pHeight,
                                //       child: FaceVideoPage(isShow: selectIndex == 3),
                                //     )),
                                // Positioned(
                                //     left: (-selectIndex + 4) *
                                //         ScreenUtil().screenWidth,
                                //     top: 0,
                                //     bottom: 0,
                                //     child: SizedBox(
                                //       width: ScreenUtil().screenWidth,
                                //       height: pHeight,
                                //       child: StripPage(
                                //         isShow: selectIndex == 4,
                                //       ),
                                //     )),
                                Positioned(
                                    left: (-selectIndex + 4) *
                                        ScreenUtil().screenWidth,
                                    top: 0,
                                    bottom: 0,
                                    child: SizedBox(
                                        width: ScreenUtil().screenWidth,
                                        height: pHeight,
                                        child: MinePage(
                                          isShow: selectIndex == 4,
                                        ))),
                              ],
                            )),
                            Container(
                              height: StyleTheme.botHegiht,
                              // margin: EdgeInsets.only(bottom: StyleTheme.bottom),
                              decoration:
                                  const BoxDecoration(color: Colors.white
                                      // border: Border(
                                      //     top: BorderSide(
                                      //         color: StyleTheme.blue52Color
                                      //             .withOpacity(0.2),
                                      //         width: 0.5.w)),
                                      ),
                              child: Row(
                                children: tabs.asMap().keys.map((x) {
                                  Map e = tabs[x];
                                  return Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        selectIndex = x;
                                        setState(() {});
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          LocalPNG(
                                            name: selectIndex == x
                                                ? e['icon_sel']
                                                : e['icon'],
                                            width: 28.w,
                                            height: 25.w,
                                          ),
                                          // SizedBox(height: 1.w),
                                          Text(
                                            e['title'],
                                            style: selectIndex == x
                                                ? StyleTheme.font_blue_52_11
                                                : StyleTheme.font_gray_153_11,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Container(
                              height: StyleTheme.bottom,
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
        ),
        //悬浮广告位
        Positioned(
                right: 13.w,
                bottom: 120.w,
                child: TopADWidget(toADs: toADs),
              )
      ],
    );
  }
}

//悬浮广告view
class TopADWidget extends StatefulWidget {
  const TopADWidget({Key? key, required this.toADs}) : super(key: key);

  final List<AdsModel> toADs;

  @override
  State<StatefulWidget> createState() => _TopADWidgetState();
}

class _TopADWidgetState extends State<TopADWidget> {

  bool offstage = false;

  @override
  Widget build(BuildContext context) {
    return widget.toADs.isEmpty
        ? Container()
        : _buildButton();
  }

  Widget _buildButton() {
    return Offstage(
      offstage: offstage,
      child: SizedBox(
        width: 120.w,
        height: 120.w,
        child: Stack(
          children: [
            Positioned.fill(
                child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.w))),
              child: Swiper(
                physics: const BouncingScrollPhysics(),
                autoplay: widget.toADs.length > 1,
                loop: widget.toADs.length > 1,
                itemBuilder: (BuildContext context, int index) {
                  double w = 80.w;
                  return GestureDetector(
                    onTap: () {
                      Utils.openRoute(context, widget.toADs[index].toJson());
                    },
                    child: SizedBox(
                        width: w,
                        height: w,
                        child: ImageNetTool(
                          url: Utils.getPICURL(widget.toADs[index].toJson()),
                          radius: BorderRadius.circular(5.w),
                        )),
                  );
                },
                itemCount: widget.toADs.length,
                pagination: widget.toADs.length > 1
                    ? SwiperPagination(
                        margin: EdgeInsets.only(bottom: 5.w),
                        builder:
                            SwiperCustomPagination(builder: (context, config) {
                          int count = widget.toADs.length;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(count, (index) {
                              return config.activeIndex == index
                                  ? Container(
                                      width: 4.w,
                                      height: 4.w,
                                      margin: EdgeInsets.only(right: 4.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.w)),
                                      ),
                                    )
                                  : Container(
                                      width: 4.w,
                                      height: 4.w,
                                      margin: EdgeInsets.only(right: 4.w),
                                      decoration: BoxDecoration(
                                        color: StyleTheme.gray150Color,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.w)),
                                      ),
                                    );
                            }),
                          );
                        }))
                    : null,
              ),
            )),
            Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        offstage = true;
                      });
                    },
                    child: LocalPNG(name: 'ai_dialog_close')),
                width: 20.w,
                height: 20.w)
          ],
        ),
      ),
    );
  }
}
