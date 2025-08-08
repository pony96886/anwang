import 'dart:math';

import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as ImgLib;

class AiDrawPage extends StatelessWidget {
  const AiDrawPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  Widget build(BuildContext context) {
    return _AiDrawPage(isShow: isShow);
  }
}

class _AiDrawPage extends BaseWidget {
  const _AiDrawPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return __AiDrawPageState();
  }
}

class __AiDrawPageState extends BaseWidgetState<_AiDrawPage>
    with TickerProviderStateMixin {
  bool isHud = true;
  bool netError = false;
  bool noMore = false;
  late TabController _tabController;

  dynamic data;
  List<dynamic> formItems = [];

  dynamic formData = {};

  @override
  void didUpdateWidget(covariant _AiDrawPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && isHud) {
      isHud = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void onCreate() {
    // TODO: implement initState
    _tabController = new TabController(length: 2, vsync: this);

    setAppTitle(
      titleW: Text(Utils.txt('aimf'), style: StyleTheme.nav_title_font),
      rightW: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Utils.navTo(context, "/minepurchasepage/0");
        },
        child: Text(Utils.txt('record'), style: StyleTheme.font_black_7716_14),
      ),
    );
    getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget appbar() {
    // TODO: implement appbar
    return Container();
  }

  Future<bool> getData({bool isShow = false}) {
    if (isShow) Utils.startGif(tip: Utils.txt('jzz'));
    return reqGetAidrawListFormElement().then((value) {
      if (isShow) Utils.closeGif();
      if (value?.data == null) {
        netError = true;
        if (mounted) setState(() {});
        return false;
      }
      data = value?.data;
      formItems = value
          ?.data[['label_mode_form', 'expert_mode_form'][_tabController.index]];
      isHud = false;
      if (mounted) setState(() {});
      return noMore;
    });
  }

  @override
  Widget pageBody(BuildContext context) {
    int coins = Provider.of<BaseStore>(context, listen: false)
            .conf
            ?.config
            ?.img_coins ??
        0;
    UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
    int money = user?.money ?? 0;
    int remainMagicValue = user?.ai_draw_value ?? 0;
    String btnTxt = remainMagicValue > 0
        ? Utils.txt('ljscsyac').replaceAll('aa', '$remainMagicValue')
        : Utils.txt('ddjs')
            .replaceAll("00", coins.toString())
            .replaceAll("##", money.toString());

    return isHud
        ? LoadStatus.showLoading(mounted)
        : netError
            ? LoadStatus.netError(onTap: () {
                netError = false;
                getData();
              })
            : Scaffold(
                backgroundColor: Color(0xff0b0a21),
                body: NestedScrollView(
                  headerSliverBuilder: (cx, flag) {
                    return [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: Color(0xff0b0a21),
                        toolbarHeight: 40.w,
                        title: TabBar(
                          controller: _tabController,
                          onTap: (index) {
                            setState(() {
                              formData = {};
                              formItems = data[[
                                'label_mode_form',
                                'expert_mode_form'
                              ][index]];
                            });
                          },
                          tabs: [
                            Tab(text: Utils.txt("bqms")),
                            Tab(text: Utils.txt("zjms")),
                          ],
                          labelStyle: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF40a5fe)),
                          unselectedLabelStyle: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFffffff).withOpacity(.8)),
                          dividerColor: Colors.transparent,
                          indicatorColor: Colors.transparent,
                          physics: const BouncingScrollPhysics(),
                        ),
                      ),
                    ];
                  },
                  body: PullRefresh(
                    onRefresh: () {
                      return getData();
                    },
                    child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 20.w),
                        itemCount: formItems.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 18.5.w);
                        },
                        itemBuilder: (cx, index) {
                          dynamic e = formItems[index];
                          return _getFormItem(e);
                        }),
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 24.w, horizontal: 15.w),
                  child: SizedBox(
                    height: 45.w,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        int mon = Provider.of<BaseStore>(context, listen: false)
                                .user
                                ?.money ??
                            0;
                        int magicValue =
                            Provider.of<BaseStore>(context, listen: false)
                                    .user
                                    ?.ai_draw_value ??
                                0;

                        if (mon - coins < 0 && magicValue <= 0) {
                          Utils.navTo(context, "/minegoldcenterpage");
                          return;
                        }

                        if (magicValue > 0) {
                          // 有次数不扣金币
                          magicValue = magicValue - 1;
                        } else {
                          mon = mon - coins;
                        }

                        Utils.startGif(tip: Utils.txt('scz'));
                        dynamic data = {};
                        formData.forEach((key, value) {
                          if (value is Map) {
                            // 取子项的所有值并用 , 拼接
                            data[key] = value.values.join(",");
                          } else {
                            // 如果不是 Map，直接转字符串
                            data[key] = value.toString();
                          }
                        });
                        reqGenerateImage(data).then((val) {
                          Utils.closeGif();
                          if (val == null) {
                            Utils.showText("网络异常，请稍后再试");
                            return;
                          }
                          Utils.showText(val.msg!);

                          if (val.status != 1) {
                          } else {
                            formData = {};
                            setState(() {});
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF579bf1),
                              Color(0xFF3D54F5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(45.w),
                        ),
                        child: Text(
                          btnTxt,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }

  Widget _getFormItem(dynamic e) {
    List<dynamic> element = e['element'] as List ?? [];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (e['layout_type'] != 2) ...[
          Text(e['title'],
              style: TextStyle(
                  color: Colors.white.withOpacity(.8),
                  fontSize: 15.w,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 7.w)
        ],
        buildTagWrap(element, e)
      ],
    );
  }

  Widget buildTagWrap(List<dynamic> tags, dynamic form) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double minItemWidth = 75.w;
      double spacing = 8.5.w;

      int countPerRow =
          max(1, ((maxWidth + spacing) / (minItemWidth + spacing)).floor());
      double itemWidth =
          (maxWidth - (spacing * (countPerRow - 1))) / countPerRow;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: tags.map((tag) {
          if (formData[tag['key']] == null) {
            formData[tag['key']] = {};
          }
          bool isSelected = formData[tag['key']][form['id']] == tag['val'];
          return GestureDetector(
            onTap: () {
              if (form['layout_type'] != 2) {
                if (formData[tag['key']][form['id']] == tag['val']) {
                  formData[tag['key']][form['id']].remove(form['id']);
                } else {
                  formData[tag['key']][form['id']] = tag['val'];
                }
              }

              if (mounted) setState(() {});
            },
            child: SizedBox(
              width: form['layout_type'] != 2 ? itemWidth : double.infinity,
              child: form['layout_type'] == 0
                  ? Container(
                      height: 30.w,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xff5da3f7) : Color(0xff1b1c2b),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      alignment: Alignment.center,
                      child: Text(tag['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.w)),
                    )
                  : form['layout_type'] == 1
                      ? Column(
                          children: [
                            Container(
                              width: 63.w,
                              height: 63.w,
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(
                                        color: Color(0xff5da3f7),
                                        width: 1.w,
                                      )
                                    : null,
                              ),
                              child: ImageNetTool(
                                url: tag["cover"],
                                radius: BorderRadius.all(Radius.circular(2.w)),
                              ),
                            ),
                            SizedBox(
                              height: 5.w,
                            ),
                            Text(
                              tag['name'],
                              style: TextStyle(
                                  color: isSelected
                                      ? Color(0xff5da3f7)
                                      : Color(0xFFffffff).withOpacity(.7),
                                  fontSize: 13.w),
                            )
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tag['name'],
                                style: TextStyle(
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 15.w,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: 7.w),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xff1b1c2b),
                                borderRadius: BorderRadius.circular(4.w),
                              ),
                              child: TextField(
                                maxLines: null,
                                minLines: 3,
                                controller: TextEditingController(
                                    text:
                                        formData[tag['key']][tag['id']] ?? ''),
                                onChanged: (value) {
                                  formData[tag['key']][tag['id']] = value;
                                  setState(() {});
                                },
                                keyboardType: TextInputType.multiline,
                                style: TextStyle(
                                    color: Color(0xFFffffff).withOpacity(.8),
                                    fontSize: 13.w),
                                decoration: InputDecoration(
                                  hintText: '输入提示词，描述您想要的图像效果',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFffffff).withOpacity(.4),
                                      fontSize: 13.w),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 6.w, horizontal: 10.w),
                                ),
                              ),
                            ),
                            SizedBox(height: 7.w),
                          ],
                        ),
            ),
          );
        }).toList(),
      );
    });
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
    _tabController.dispose();
    super.dispose();
  }
}
