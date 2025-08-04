import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';

class MineAgentCashRecordPage extends BaseWidget {
  cState() => _MineAgentCashRecordPageState();
}

class _MineAgentCashRecordPageState extends BaseWidgetState {
  int page = 1;
  bool isAll = false;
  bool networkErr = false;
  bool isHud = true;
  List _dataList = [];

  Future<bool> _getData() async {
    // var t = {
    //   "updated_at": "2019-03-01   03:02",
    //   "status_str": "成功",
    //   "amount": "100.00"
    // };

    // var t2 = {
    //   "updated_at": "2019-03-02   03:02",
    //   "status_str": "失败",
    //   "amount": "50.00"
    // };
    // var t3 = {
    //   "updated_at": "2019-03-03   03:02",
    //   "status_str": "成功",
    //   "amount": "50"
    // };
    // _dataList = [t, t2, t3];
    // return;
    int status = 1;
    Map param = {'page': page, 'limit': 10, 'status': status};

    try {
      ResponseModel<dynamic>? res = await cashWithdrawList(param);

      isHud = false;

      if (res?.status != 1) {
        Utils.showText(res?.msg as String);
        networkErr = true;
        setState(() {});
        return false;
      }

      if (page == 1) {
        isAll = false;
        _dataList = res?.data;
      } else {
        _dataList.addAll(res?.data);
      }

      if (res?.data.length < 10 && _dataList.length > 0) {
        isAll = true;
      }
      setState(() {});
      return isAll;

    } catch (e) {
      isHud = false;
      networkErr = true;
      setState(() {});
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getData();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('txjl'), style: StyleTheme.nav_title_font));
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
  @override
  pageBody(BuildContext context) {
    return networkErr
        ? LoadStatus.netError()
        : isHud
            ? LoadStatus.showLoading(mounted)
            : _dataList.isEmpty
                ? LoadStatus.noData()
                : Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: StyleTheme.margin, right: StyleTheme.margin),
                        height: 30.w,
                        color: StyleTheme.gray244Color,
                        child: DefaultTextStyle(
                          textAlign: TextAlign.center,
                          style: StyleTheme.font_black_31_14,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 10,
                                  child: Text(
                                    Utils.txt('sj'),
                                    // textAlign: TextAlign.left,
                                  )),
                              Expanded(
                                  flex: 4,
                                  child: Text(
                                    Utils.txt('zt'),
                                    // textAlign: TextAlign.center,
                                  )),
                              Expanded(
                                  flex: 9,
                                  child: Text(
                                    Utils.txt('je2'),
                                    // textAlign: TextAlign.right,
                                  )),
                              // Expanded(
                              //   flex: 1,
                              //   child: Container(),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: PullRefresh(
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
                                  Widget widget = MineAgentCashRecordListWidget(
                                    data: e,
                                  );
                                  return widget;
                                },
                              ).toList()),
                        ),
                      ),
                    ],
                  );
  }
}

class MineAgentCashRecordListWidget extends StatelessWidget {
  MineAgentCashRecordListWidget({this.data});
  dynamic data;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: StyleTheme.font_white_215_14
      padding: EdgeInsets.only(left: StyleTheme.margin),
      height: 50.w,
      child: Column(
        children: [
          Expanded(
            child: DefaultTextStyle(
              textAlign: TextAlign.center,
              style: StyleTheme.font_black_31_14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 5,
                      child: Text(
                        '${data['updated_at']}',
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: StyleTheme.font_black_31_14,
                      )),
                  Expanded(
                      flex: 2,
                      child: Text('${data['status_str']}',
                          textAlign: TextAlign.center,
                          style: (data['status_str'] == "成功")
                              ? StyleTheme.font_blue52_14
                              : StyleTheme.font_black_31_14)),
                  Expanded(
                      flex: 5,
                      child: Text('${data['amount']}',
                          textAlign: TextAlign.center,
                          style: StyleTheme.font_black_31_14)),
                ],
              ),
            ),
          ),
          Container(
            height: 0.5,
            color: StyleTheme.gray235Color,
          )
        ],
      ),
    );
  }
}
