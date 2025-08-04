import 'dart:convert';
import 'dart:io';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/base/update_sysalert.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MineSetPage extends BaseWidget {
  MineSetPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _MineSetPageState();
  }
}

class _MineSetPageState extends BaseWidgetState<MineSetPage> {
  String? fileUrl;
  final ImagePicker _picker = ImagePicker();

  Widget setupItem({
    String? title,
    String? rightText,
    Function? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title ?? "",
                  style: StyleTheme.font_black_7716_14,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    rightText != null
                        ? SizedBox(
                            width: 100.w,
                            child: Text(
                              rightText,
                              style: StyleTheme.font_black_7716_14,
                              textAlign: TextAlign.right,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      width: 3.5.w,
                    ),
                    LocalPNG(
                      name: 'ai_mine_parrow',
                      width: 25.w,
                      height: 25.w,
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 10.w),
            Container(color: StyleTheme.devideLineColor, height: 0.5.w)
          ],
        ),
      ),
    );
  }

  Future<void> imagePickerAssets() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await Utils.pngLimitSize(file);
      if (flag) return;
      uploadFileImg(file);
    } else {
      // User canceled the picker
    }
  }

  void uploadFileImg(XFile file) async {
    Utils.startGif(tip: Utils.txt('scz'));
    var data;
    if (kIsWeb) {
      data = await NetworkHttp.xfileHtmlUploadImage(
          file: file, position: 'upload');
    } else {
      data = await NetworkHttp.xfileUploadImage(file: file, position: 'upload');
    }
    if (data['code'] == 1) {
      var newImagePath = data['msg'];
      var result = await reqUpdateUserInfo(thumb: newImagePath);
      Utils.closeGif();
      if (result?.status == 1) {
        if (!kIsWeb) fileUrl = file.path;
        UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
        user?.thumb = AppGlobal.imgBaseUrl + newImagePath;
        if (user != null) {
          Provider.of<BaseStore>(context, listen: false).setUser(user);
        }
        Utils.showText(result?.msg ?? "");
        setState(() {});
      } else {
        Utils.showText(result?.msg ?? "");
      }
    } else {
      Utils.closeGif();
      Utils.showText(data['msg'] ?? "failed");
    }
  }

  void showImagePicker() {
    imagePickerAssets();
  }

  @override
  Widget pageBody(BuildContext context) {
    UserModel? user = Provider.of<BaseStore>(context, listen: true).user;
    bool isLogin = AppGlobal.apiToken.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.w),
                child: Center(
                    child: SizedBox(
                  width: 90.w,
                  height: 140.w,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showImagePicker();
                            },
                            child: SizedBox(
                              width: 90.w,
                              height: 90.w,
                              child: ImageNetTool(
                                url: user?.thumb ?? "",
                                radius: BorderRadius.all(Radius.circular(45.w)),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.w),
                          GestureDetector(
                            onTap: () {
                              showImagePicker();
                            },
                            child: Text(
                              Utils.txt('xgtx'),
                              style: StyleTheme.font_black_7716_14,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )),
              ),
              setupItem(
                  title: Utils.txt('pnch'),
                  rightText: user?.nickname ?? "",
                  onTap: () {
                    Utils.navTo(context,
                        "/mineupdatepage/nickname/${Utils.txt('pnch')}");
                  }),
              setupItem(
                  title: Utils.txt('qchc'),
                  onTap: () async {
                    reqClearCached();
                    if (kIsWeb) {
                      PaintingBinding.instance.imageCache.clear();
                    }
                    await AppGlobal.imageCacheBox?.clear();
                    Utils.showText(Utils.txt('qhcg'));
                  }),
              setupItem(
                title: Utils.txt('dgqbb'),
                rightText: '${AppGlobal.appinfo['version']}',
                onTap: () {
                  ConfigModel? cf =
                      Provider.of<BaseStore>(context, listen: false).conf;

                  var targetVersion =
                      cf?.versionMsg?.version?.replaceAll('.', '');
                  var currentVersion =
                      AppGlobal.appinfo['version'].replaceAll('.', '');
                  var needUpdate = int.parse(targetVersion ?? "100") >
                      int.parse(currentVersion);

                  if (kIsWeb) {
                    //web不需要更新
                    Utils.openURL(cf?.config?.office_site ?? "");
                    return;
                  }

                  if (needUpdate) {
                    _updateAlert(cf);
                  } else {
                    Utils.showText('您当前已是最新版本');
                  }
                },
              ),
            ],
          ),
        )),
        isLogin
            ? GestureDetector(
                onTap: () {
                  Utils.startGif(tip: Utils.txt('tuichz'));
                  reqClearCached().then((_) {
                    AppGlobal.apiToken = '';
                    AppGlobal.appBox?.delete('deepseek_token');
                    reqUserInfo(context).then((_) {
                      Utils.closeGif();
                      context.pop();
                      UtilEventbus().fire(EventbusClass({"name": "logout"}));
                    });
                  });
                },
                child: Container(
                  height: ScreenUtil().setWidth(49),
                  decoration: BoxDecoration(
                    gradient: StyleTheme.gradBlue,
                  ),
                  child: Center(
                    child: Text(
                      Utils.txt('tcdl'),
                      style: StyleTheme.font(
                          size: 16, color: StyleTheme.whiteColor),
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
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
      cancel: () {},
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

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('gerensz'), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
