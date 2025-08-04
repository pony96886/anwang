import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';

import 'package:provider/provider.dart';

class MineAgentRulePage extends BaseWidget {
  cState() => _MineAgentRulePageState();
}

class _MineAgentRulePageState extends BaseWidgetState {
  List<String> levelList = [
    'dld',
    'zs',
    'bj',
    'hj',
    'by',
    'qt',
    'pt',
  ];
  Color tableBorderColor = StyleTheme.blue52Color;

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('dlgz'), style: StyleTheme.nav_title_font));
  }

  @override
  Widget backGroundView() {
    // TODO: implement backGroundView
    return Container(
      alignment: Alignment.topCenter,
      width: double.infinity,
      height: double.infinity,
      // color: Colors.cyan,
      color: StyleTheme.blue52Color,
      child: LocalPNG(name: 'dlbj'),
    );
  }

  @override
  Widget appbar() {
    return super.appbar();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }

  @override
  Widget pageBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              LocalPNG(
                name: 'dlzs',
                width: ScreenUtil().setWidth(320),
                height: ScreenUtil().setWidth(126),
              ),
              Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                decoration: BoxDecoration(
                    color: StyleTheme.blue52Color,
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(5))),
                child: Column(
                  children: [
                    AegntTitleWidget(Utils.txt('czjd')),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(Utils.txt('czsm'),
                          style: StyleTheme.font_black_31_14),
                    ),
                    Text(
                      Utils.txt('czsmza'),
                      style: StyleTheme.font_black_31_14,
                      maxLines: 3,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(Utils.txt('syly'),
                          style: StyleTheme.font_black_31_14),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text('1.' + Utils.txt('ztsy'),
                          style: StyleTheme.font_black_31_14),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text('2.' + Utils.txt('cjsy'),
                          style: StyleTheme.font_black_31_14),
                    ),
                  ]
                      .map((e) => Column(
                            children: [
                              e,
                              SizedBox(
                                height: ScreenUtil().setWidth(15),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
              Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  decoration: BoxDecoration(
                      color: StyleTheme.blue52Color,
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(5))),
                  child: Column(children: [
                    AegntTitleWidget(Utils.txt('dldjsm')),
                    SizedBox(
                      height: ScreenUtil().setWidth(20),
                    ),
                    Table(
                      border: TableBorder.all(
                        color: tableBorderColor,
                        width: ScreenUtil().setWidth(1),
                      ),
                      children: levelList.asMap().keys.map(
                        (index) {
                          TextStyle style = index == 0
                              ? StyleTheme.font_black_31_14
                              : StyleTheme.font_black_31_14;
                          double height =
                              ScreenUtil().setWidth(index == 0 ? 30 : 46);

                          return TableRow(children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 71,
                                    child: Container(
                                      height: height,
                                      alignment: Alignment.center,
                                      child: Text(
                                        Utils.txt(levelList[index] + "j"),
                                        style: style,
                                      ),
                                    )),
                                Container(
                                  color: tableBorderColor,
                                  height: height,
                                  width: 1,
                                ),
                                // LayoutBuilder(builder: (context, constraints) {
                                //   return Container(
                                //     color: Colors.cyan,
                                //     height: constraints.maxHeight,
                                //     width: 1,
                                //   );
                                // }),
                                Expanded(
                                    flex: 71,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        Utils.txt(levelList[index] + "jp"),
                                        style: style,
                                      ),
                                    )),
                                Container(
                                  color: tableBorderColor,
                                  height: height,
                                  width: 1,
                                ),
                                Expanded(
                                    flex: 176,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil().setWidth(20),
                                      ),
                                      // vertical: ScreenUtil().setWidth(10)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        Utils.txt(levelList[index] + "jc"),
                                        style: style,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                    )),
                              ],
                            ),
                          ]);
                        },
                      ).toList(),
                    ),
                  ])),
              Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  decoration: BoxDecoration(
                      color: StyleTheme.blue52Color,
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(5))),
                  child: Column(children: [
                    AegntTitleWidget(Utils.txt('ztsy')),
                    SizedBox(
                      height: ScreenUtil().setWidth(20),
                    ),
                    Text(
                      Utils.txt('ztsyx'),
                      style: StyleTheme.font_black_31_14,
                      maxLines: 3,
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(20),
                    ),
                    LocalPNG(
                      name: 'dlcj',
                      width: ScreenUtil().setWidth(283),
                      height: ScreenUtil().setWidth(121),
                    ),
                  ])),
              Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                decoration: BoxDecoration(
                    color: StyleTheme.blue52Color,
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(5))),
                child: Column(
                    children: [
                  AegntTitleWidget(Utils.txt('cjsyt')),
                  Text(
                    Utils.txt('cjsyx'),
                    style: StyleTheme.font_black_31_14,
                    maxLines: 3,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    width: double.infinity,
                    // height: 20,
                    // color: Colors.red,
                    child: LocalPNG(
                      name: 'dlcy',
                      width: ScreenUtil().setWidth(244),
                      height: ScreenUtil().setWidth(161),
                    ),
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: Utils.txt('cjsyy'),
                        style: StyleTheme.font_black_31_14),
                    TextSpan(
                      text: Utils.txt('cjsyyw'),
                      style: TextStyle(
                          color: Color.fromRGBO(0, 188, 9, 1),
                          fontSize: ScreenUtil().setSp(11),
                          overflow: TextOverflow.ellipsis,
                          decoration: TextDecoration.none),
                    ),
                  ])),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: Utils.txt('cjsye'),
                        style: StyleTheme.font_black_31_14),
                    TextSpan(
                      text: Utils.txt('cjsyew'),
                      style: TextStyle(
                          color: Color.fromRGBO(36, 98, 239, 1),
                          fontSize: ScreenUtil().setSp(11),
                          overflow: TextOverflow.ellipsis,
                          decoration: TextDecoration.none),
                    ),
                  ])),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: Utils.txt('cjsyys'),
                        style: StyleTheme.font_black_31_14),
                    TextSpan(
                      text: Utils.txt('cjsysw'),
                      style: TextStyle(
                          color: Color.fromRGBO(239, 127, 36, 1),
                          fontSize: ScreenUtil().setSp(11),
                          overflow: TextOverflow.ellipsis,
                          decoration: TextDecoration.none),
                    ),
                  ]))
                ]
                        .map((e) => Column(
                              children: [
                                e,
                                SizedBox(
                                  height: ScreenUtil().setWidth(15),
                                ),
                              ],
                            ))
                        .toList()),
              ),
              Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                decoration: BoxDecoration(
                    color: StyleTheme.blue52Color,
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(5))),
                child: Column(children: [
                  AegntTitleWidget(
                    Utils.txt(
                      'zj',
                    ),
                    hideIcon: false,
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(20),
                  ),
                  Text(
                    Utils.txt('zjy'),
                    style: StyleTheme.font_black_31_14,
                    maxLines: 5,
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(20),
                  ),
                  Text(
                    Utils.txt('zje'),
                    style: StyleTheme.font_black_31_14,
                    maxLines: 5,
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(40),
                  ),
                  AegntTitleWidget(
                    Utils.txt('gzkd'),
                    hideIcon: true,
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(20),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Config config =
                      //     Provider.of<HomeConfig>(context, listen: false)
                      //         .config;
                      // Utils.launchURL(config.officialGroup);
                    },
                    child: LocalPNG(
                      name: 'dljq',
                      width: ScreenUtil().setWidth(255),
                      height: ScreenUtil().setWidth(35),
                    ),
                  )
                ]),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(50),
              )
            ]
                .map((e) => Column(
                      children: [
                        SizedBox(
                          height: ScreenUtil().setWidth(15),
                        ),
                        e
                      ],
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}

class AegntTitleWidget extends StatelessWidget {
  AegntTitleWidget(this.title, {this.hideIcon = false});
  String title;
  bool hideIcon;
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        // padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: UnconstrainedBox(
            child: Row(
          children: [
            hideIcon
                ? Container()
                : LocalPNG(
                    name: 'dlbtw',
                    width: ScreenUtil().setWidth(43),
                    height: ScreenUtil().setWidth(14.5),
                  ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(7)),
              child: Text(
                title,
                style: kIsWeb
                    ? StyleTheme.font_black_31_14
                    : TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: ScreenUtil().setSp(19),
                        foreground: Paint()
                          ..shader = LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  // begin: Alignment.centerLeft,
                                  // end: Alignment.centerRight,
                                  colors: <Color>[
                                    Color.fromRGBO(236, 180, 129, 1),

                                    Color.fromRGBO(255, 238, 216, 1),

                                    // Colors.green,
                                    // Colors.red
                                  ],
                                  tileMode: TileMode.repeated)
                              .createShader(
                            //Rect.largest
                            Rect.fromLTWH(
                                0.0, 0.0, 3.0, ScreenUtil().setWidth(19)),
                          )),
              ),
            ),
            hideIcon
                ? Container()
                : LocalPNG(
                    name: 'dlbtw2',
                    width: ScreenUtil().setWidth(43),
                    height: ScreenUtil().setWidth(14.5),
                  ),
          ],
        )));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // double scale = 0.8;
    // double roundFactor = size.height * (1 - scale);
    double roundFactor = ScreenUtil().setWidth(40);

    // path.moveTo(0, size.height * 0.8);
    // path.addRRect(RRect.)

    // path.moveTo(0, size.height / 3.3);
    // path.lineTo(0, 0);
    path.lineTo(0, size.height - roundFactor);
    path.quadraticBezierTo(
        size.width / 2.0, size.height, size.width, size.height - roundFactor);
    // path.lineTo(size.width - roundFactor, size.height);
    path.lineTo(size.width, 0);

    // path.lineTo(0, size.height / 3.3);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
