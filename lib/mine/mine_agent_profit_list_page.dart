import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';

class MineAgentProfitListPage extends BaseWidget {
  cState() => _MineAgentProfitListPageState();
}

class _MineAgentProfitListPageState extends BaseWidgetState {
  int page = 1;
  bool isAll = false;
  bool networkErr = false;
  bool isHud = true;
  late List _dataList;

  Future<bool> _getData() async {
    int status = 1;
    Map param = {'type': 1, 'page': page, 'limit': 10, 'status': status};

    try {
      ResponseModel<dynamic>? res = await getProxyProfitList(param);
      if (res?.status != 1) {
        Utils.showText(res?.msg as String);
        networkErr = true;
        setState(() {});
        return false;
      } else {
        if (res?.data.length == 0) {
          isAll = true;
        }
        if (page == 1) {
          isAll = false;
          _dataList = res?.data;
        } else {
          _dataList.addAll(res?.data);
        }
        setState(() {});
        return isAll;
      }
    } catch (e) {
      return false;
    }

    // _dataList = [
    //   {
    //     "created_at": "2022-03-02 03:02",
    //     "nickname": "nickname_1",
    //     "type": 1,
    //     "source": 2,
    //     "amount": "100"
    //   },
    //   {
    //     "created_at": "2022-03-02 03:02",
    //     "nickname": "nickname_1",
    //     "type": 1,
    //     "source": 2,
    //     "amount": "100"
    //   },
    //   {
    //     "created_at": "2022-03-02 03:02",
    //     "nickname": "nickname_1",
    //     "type": 2,
    //     "source": 3,
    //     "amount": "100"
    //   },
    // ];

    isHud = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    setAppTitle(
        titleW: Text(Utils.txt('yjmx'), style: StyleTheme.nav_title_font));
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
                      children: _dataList
                          .map(
                            (e) => MineAgentProfitListWidget(
                              data: e,
                            ),
                          )
                          .toList(),
                    ),
                  );
  }
}

class MineAgentProfitListWidget extends StatelessWidget {
  MineAgentProfitListWidget({this.data});
  dynamic data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 70.w,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(StyleTheme.margin),
          ),
          child: SizedBox(
            height: 42.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${data['nickname']}',
                        style: StyleTheme.font_black_7716_14),
                    Text(
                        (data['type'] == 1
                                ? '+'
                                : data['type'] == 2
                                    ? '-'
                                    : '') +
                            '${data['amount']}',
                        style: StyleTheme.font_black_7716_14),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        data['source'] == 1
                            ? Utils.txt('tx')
                            : data['source'] == 2
                                ? Utils.txt('txtk')
                                : data['source'] == 3
                                    ? Utils.txt('dlfc')
                                    : '',
                        style: StyleTheme.font_black_7716_14),
                    Text('${data['created_at']}',
                        style: StyleTheme.font_black_7716_14),
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
          height: 0.5.w,
          color: StyleTheme.devideLineColor,
        )
      ],
    );
  }
}
