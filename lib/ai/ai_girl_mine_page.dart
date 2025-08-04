import 'package:deepseek/ai/ai_chat_notifier.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/util/cache/image_net_tool.dart';
import 'package:deepseek/util/custom_gird_banner.dart';
import 'package:deepseek/util/load_status.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/pull_refresh.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AIGirlMineListPage extends StatefulWidget {
  const AIGirlMineListPage({Key? key, this.isShow = false, this.nav})
      : super(key: key);
  final bool isShow;
  final dynamic nav;

  @override
  State<AIGirlMineListPage> createState() => _AIGirlMineListPageState();
}

class _AIGirlMineListPageState extends State<AIGirlMineListPage> {
  late final chatNotifier = context.read<AIChatNotifier>();
  bool isHud = true;
  bool netError = false;
  List list = [];
  List tags = [];
  int page = 1;
  bool noMore = false;

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AIGirlMineListPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  Future<bool> getData() async {
    final res = await reqMineCharactorList(page: page);
    if (res?.status != 1) {
      netError = true;
      setState(() {});
      return false;
    }
    List tp = List.from(res?.data);
    if (page == 1) {
      noMore = false;
      list = tp;
    } else if (tp.isNotEmpty) {
      list.addAll(tp);
    } else {
      noMore = true;
    }
    isHud = false;
    setState(() {});
    return noMore;
  }

  @override
  Widget build(BuildContext context) {
    return netError
        ? LoadStatus.netError(onTap: () {
            netError = false;
            getData();
          })
        : isHud
            ? LoadStatus.showLoading(mounted)
            : PullRefresh(
                onRefresh: () {
                  page = 1;
                  return getData();
                },
                onLoading: () {
                  page++;
                  return getData();
                },
                child: list.isEmpty
                    ? LoadStatus.noData()
                    : ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        itemBuilder: (context, index) {
                          return Utils.aiGirlModuleUI(context, list[index]);
                        },
                        itemCount: list.length,
                      ),
              );

    //使用缓存数据加载--暂不使用
    // return Selector<AIChatNotifier, List<AIChatList>>(
    //     shouldRebuild: (_, __) => true,
    //     selector: (_, notifier) {
    //       return notifier.chats;
    //     },
    //     builder: (_, chats, __) {
    //       return Container(
    //         child: chats.isEmpty
    //             ? LoadStatus.noData()
    //             : ListView.builder(
    //                 itemCount: chats.length,
    //                 shrinkWrap: true,
    //                 physics: const BouncingScrollPhysics(),
    //                 padding: EdgeInsets.symmetric(
    //                     horizontal: StyleTheme.margin, vertical: 5.w),
    //                 itemBuilder: (BuildContext context, int index) {
    //                   AIChatList data = chats[index];
    //                   return ChatMeaasageCard(
    //                       data: data,
    //                       tap: () {
    //                         //跳转AI聊天界面
    //                         Utils.navTo(context,
    //                             '/aigirlchatpage/${data.id}/${Uri.encodeComponent(data.name ?? '')}/${Uri.encodeComponent(data.avatar ?? '')}');
    //                       },
    //                       delete: () {
    //                         _showDeleteAlert(chats[index]);
    //                       });
    //                 }),
    //       );
    //     });
  }

  _showDeleteAlert(AIChatList chat) {
    Utils.showDialog(
        cancelTxt: Utils.txt('qx'),
        confirmTxt: Utils.txt('sch'),
        setContent: () {
          return Column(
            children: [
              Text(Utils.txt('scwfhf'),
                  style: StyleTheme.font_black_7716_15,
                  maxLines: 2,
                  textAlign: TextAlign.center),
            ],
          );
        },
        confirm: () async {
          await chatNotifier.removeChat(chat.id ?? 0);
          setState(() {});
        });
  }
}

class ChatMeaasageCard extends StatelessWidget {
  const ChatMeaasageCard(
      {super.key, required this.data, required this.delete, required this.tap});

  final AIChatList data;
  final Function delete;
  final Function tap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70.w,
      margin: EdgeInsets.only(bottom: 10.w),
      decoration: BoxDecoration(
          color: StyleTheme.whiteColor,
          borderRadius: BorderRadius.circular(5.w)),
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              tap.call();
            },
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 45.w,
                      height: 45.w,
                      child: ImageNetTool(
                          url: data.avatar ?? '',
                          radius: BorderRadius.all(Radius.circular(22.5.w)))),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                data.name ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: StyleTheme.font_black_7716_14,
                              ),
                            ),
                            Text(
                              (data.list?.last.timeStr.substring(6, 16)) ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: StyleTheme.font_black_7716_04_12,
                            ),
                          ],
                        ),
                        Text(
                          data.list?.last.greeting ?? '',
                          maxLines: 1,
                          style: StyleTheme.font_black_7716_04_12,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 5.w)
                ],
              ),
            ),
          ),
          Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  //删除AI消息
                  delete.call();
                },
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                      color: StyleTheme.whiteColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.w),
                          bottomRight: Radius.circular(5.w))),
                  child: Center(
                    child: LocalPNG(
                      name: 'ai_voice_player_list_delete',
                      width: 18.w,
                      height: 18.w,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
