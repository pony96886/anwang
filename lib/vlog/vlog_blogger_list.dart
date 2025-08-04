// import 'package:deepseek/base/basewidget.dart';
// import 'package:deepseek/base/request_api.dart';
// import 'package:deepseek/util/cache/image_net_tool.dart';
// import 'package:deepseek/util/eventbus_class.dart';
// import 'package:deepseek/util/load_status.dart';
// import 'package:deepseek/util/local_png.dart';
// import 'package:deepseek/util/pull_refresh.dart';
// import 'package:deepseek/util/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:deepseek/base/base_store.dart';
// import 'package:deepseek/base/gen_custom_nav.dart';
// import 'package:deepseek/util/style_theme.dart';
// import 'package:deepseek/vlog/vlog_find_sub_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';

// class VlogBloggerList extends BaseWidget {
//   VlogBloggerList({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> cState() {
//     // TODO: implement cState
//     return _VlogBloggerListState();
//   }
// }

// class _VlogBloggerListState extends BaseWidgetState<VlogBloggerList> {
//   int page = 1;
//   bool noMore = false;
//   bool netError = false;
//   bool isHud = true;
//   List array = [];

//   _getData() {
//     reqFollowUserList(page: page).then((value) {
//       if (value?.status != 1) {
//         netError = true;
//         if (mounted) setState(() {});
//         return;
//       }
//       List tp = List.from(value?.data['list'] ?? []);
//       if (page == 1) {
//         noMore = false;
//         array = tp;
//       } else if (tp.isNotEmpty) {
//         array.addAll(tp);
//       } else {
//         noMore = true;
//       }
//       isHud = false;
//       if (mounted) setState(() {});
//     });
//   }

//   @override
//   Widget pageBody(BuildContext context) {
//     return netError
//         ? LoadStatus.netError(onTap: () {
//             netError = false;
//             _getData();
//           })
//         : isHud
//             ? LoadStatus.showLoading(mounted)
//             : PullRefresh(
//                 onRefresh: () {
//                   page = 1;
//                   _getData();
//                 },
//                 onLoading: () {
//                   page++;
//                   _getData();
//                 },
//                 noMore: noMore,
//                 child: array.isEmpty
//                     ? LoadStatus.noData()
//                     : ListView.builder(
//                         padding:
//                             EdgeInsets.symmetric(vertical: StyleTheme.margin),
//                         itemCount: array.length, //标签+帖子
//                         itemBuilder: (context, index) {
//                           dynamic data = array[index];
//                           return VlogBloggerItem(
//                             data: data,
//                             call: () {
//                               array.remove(data);
//                               UtilEventbus().fire(
//                                 EventbusClass({
//                                   "name": "refresh_focus",
//                                   "aff": data["aff"],
//                                 }),
//                               );
//                               if (mounted) setState(() {});
//                             },
//                           );
//                         }),
//               );
//   }

//   @override
//   void onCreate() {
//     // TODO: implement onCreate
//     setAppTitle(
//         titleW: Text(Utils.txt('apgz'), style: StyleTheme.nav_title_font));
//     _getData();
//   }

//   @override
//   void onDestroy() {
//     // TODO: implement onDestroy
//   }
// }

// // 有关注用户时的列表Item
// class VlogBloggerItem extends StatefulWidget {
//   const VlogBloggerItem({
//     Key? key,
//     required this.data,
//     this.call,
//   }) : super(key: key);

//   final dynamic data;
//   final Function? call;

//   @override
//   State<VlogBloggerItem> createState() => _VlogBloggerItemState();
// }

// class _VlogBloggerItemState extends State<VlogBloggerItem> {
//   void buttonClick() {
//     setState(() {
//       reqFollowUser(aff: widget.data["aff"].toString()).then((value) {
//         if (value?.status == 1) {
//           widget.data["is_follow"] = widget.data["is_follow"] == 1 ? 0 : 1;
//           if (mounted) {
//             setState(() {
//               widget.call!();
//             });
//           }
//         } else {
//           Utils.showText(value?.msg ?? "");
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: () {
//         Utils.navTo(context, '/mineotherusercenter/${widget.data["aff"]}');
//       },
//       child: Column(
//         children: [
//           SizedBox(height: 10.w),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
//             height: 40.w,
//             child: Row(
//               children: <Widget>[
//                 SizedBox(
//                   height: 40.w,
//                   width: 40.w,
//                   child: ImageNetTool(
//                       url: widget.data["thumb"] ?? '',
//                       radius: BorderRadius.all(Radius.circular(20.w))),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Text(
//                     widget.data['nickname'] ?? '',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.left,
//                     style: StyleTheme.font_white_255_06_14_medium,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 71.0.w,
//                   height: 25.0.w,
//                   child: IconButton(
//                     padding: EdgeInsets.only(right: 16.0.w),
//                     icon: LocalPNG(
//                       name: 'hls_vlog_following',
//                       fit: BoxFit.fill,
//                     ),
//                     onPressed: buttonClick,
//                     splashColor: Colors.transparent,
//                     highlightColor: Colors.transparent,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 10.w),
//           Container(
//             height: 0.5.w,
//             margin: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
//             color: StyleTheme.devideLineColor,
//           ),
//         ],
//       ),
//     );
//   }
// }
