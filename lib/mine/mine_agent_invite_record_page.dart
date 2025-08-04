import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';

/// 邀请记录-代理
class MineAgentInviteRecordPage extends BaseWidget {
  cState() => _MineAgentInviteRecordPageState();
}

class _MineAgentInviteRecordPageState extends BaseWidgetState {
  int page = 1;
  bool isAll = false;
  bool networkErr = false;
  bool isHud = true;
  late List _dataList;

  Future<bool> _getData() async {
    Map param = {
      'page': page,
      'limit': 10,
    };

    try {
      ResponseModel<dynamic>? res = await getProxyInviteRecord(param);
      isHud = false;
      if (res?.status != 1) {
        Utils.showText(res?.msg as String);
        networkErr = true;
        setState(() {});
        return false;
      } else {
        networkErr = false;
        List list = List.from(res?.data["list"] ?? []);
        if (page == 1) {
          isAll = false;
          _dataList = list;
        } else {
          _dataList.addAll(list);
        }
        if (list.isEmpty && _dataList.isNotEmpty) {
          isAll = true;
        }
        setState(() {});
        return isAll;
      }
    } catch (e) {
      isHud = false;
      networkErr = true;
      setState(() {});
      return false;
    }
  }

  @override
  Widget appbar() {
    return Stack(children: [
      super.appbar(),
      Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
            alignment: Alignment.centerRight,
            height: StyleTheme.navHegiht,
            child: GestureDetector(
              onTap: () {
                Utils.navTo(context, "/mineservicepage");
              },
              child: Text(Utils.txt('zuxkf'),
                  style: StyleTheme.font_black_7716_14),
            ),
          ))
    ]);
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('yqjl'), style: StyleTheme.nav_title_font));
    _getData();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
  @override
  pageBody(BuildContext context) {
    return networkErr
        ? LoadStatus.netError(onTap: _getData)
        : isHud == true
            ? LoadStatus.showLoading(mounted)
            : _dataList.isEmpty
                ? LoadStatus.noData()
                : PullRefresh(
                    onRefresh: () {
                      page = 1;
                      return _getData();
                    },
                    onLoading: () {
                      page++;
                      return _getData();
                    },
                    child: Wrap(
                      // runSpacing: ScreenUtil().setWidth(10),
                      spacing: ScreenUtil().setWidth(10),
                      children: _dataList.map(
                        (e) {
                          Widget widget = MineAgentInviteRecordListWidget(
                            data: e,
                          );
                          return widget;
                        },
                      ).toList()
                        ..insert(
                            0,
                            Container(
                              color: Colors.transparent,
                              height: ScreenUtil().setWidth(32),
                              child: DefaultTextStyle(
                                textAlign: TextAlign.center,
                                style: StyleTheme.font_black_31_14,
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      Utils.txt('tgm'),
                                    )),
                                    Expanded(
                                        child: Text(
                                      Utils.txt('sjh'),
                                    )),
                                    Expanded(
                                        child: Text(
                                      Utils.txt('zt'),
                                    )),
                                    Expanded(
                                        child: Text(
                                      Utils.txt('sj'),
                                    )),
                                  ],
                                ),
                              ),
                            ))
                        ..add(SizedBox(height: ScreenUtil().setWidth(44))),
                    ),
                  );
  }
}

class MineAgentInviteRecordListWidget extends StatefulWidget {
  MineAgentInviteRecordListWidget({required this.data});
  Map data;

  @override
  State<StatefulWidget> createState() =>
      _MineAgentInviteRecordListWidgetState();
}

class _MineAgentInviteRecordListWidgetState
    extends State<MineAgentInviteRecordListWidget> {
  dynamic _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: StyleTheme.margin),
        // height: ScreenUtil().setWidth(32),
        child: DefaultTextStyle(
          style: StyleTheme.font_gray_153_12,
          textAlign: TextAlign.center,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: Text('${_data['aff_code']}')),
              Expanded(child: Text('${_data['phone']}')),
              Expanded(child: Text('${_data['reg_status']}')),
              Expanded(
                  child: Text(
                '${_data['log_date']}',
                maxLines: 2,
              )),
            ],
          ),
        ));
  }
}
