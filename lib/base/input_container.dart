// import 'package:deepseek/base/base_store.dart';
// import 'package:deepseek/model/user_model.dart';
// import 'package:deepseek/util/local_png.dart';
// import 'package:deepseek/util/cache/image_net_tool.dart';
// import 'package:deepseek/util/style_theme.dart';
// import 'package:deepseek/util/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
//
// class InputContainer extends StatelessWidget {
//   InputContainer({
//     Key? key,
//     this.child,
//     this.onEditingCompleteText,
//     this.onSelectPicComplete,
//     this.onOutEventComplete,
//     this.onCollectEventComplete,
//     this.labelText,
//     this.bg = Colors.white,
//     this.focusNode,
//     this.isCollect = false,
//   }) : super(key: key);
//   final bool isCollect;
//   final Color bg;
//   final Widget? child;
//   final String? labelText;
//   final TextEditingController controller = TextEditingController();
//   final ValueChanged? onEditingCompleteText;
//   final Function? onSelectPicComplete;
//   final Function? onOutEventComplete;
//   final Function? onCollectEventComplete;
//   final FocusNode? focusNode;
//
//   final List<Map<String, dynamic>> medias = [];
//
//   @override
//   Widget build(BuildContext context) {
//     UserModel? user = Provider.of<BaseStore>(context, listen: false).user;
//     return Container(
//       color: Colors.transparent,
//       child: Column(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () {
//                 onOutEventComplete?.call();
//                 Utils.unFocusNode(context);
//               },
//               child: child ?? Container(),
//             ),
//           ),
//           Divider(
//             height: 0.5.w,
//             color: StyleTheme.devideLineColor, // const Color.fromRGBO(216, 216, 216, 1),
//           ),
//           Container(
//             color: bg,
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: onSelectPicComplete == null
//                       ? SizedBox(
//                           height: 30.w,
//                           width: 30.w,
//                           child: ImageNetTool(
//                             url: user?.thumb ?? "",
//                             radius: BorderRadius.all(Radius.circular(15.w)),
//                           ),
//                         )
//                       : GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           onTap: () {
//                             Utils.unFocusNode(context);
//                             onSelectPicComplete?.call();
//                           },
//                           child: Padding(
//                             padding: EdgeInsets.only(top: 2.w),
//                             child: LocalPNG(
//                               fit: BoxFit.fill,
//                                 name: "ai_mine_imgpicker",
//                                 width: 22.w,
//                                 height: 20.w),
//                           ),
//                         ),
//                   title: TextField(
//                     focusNode: focusNode,
//                     controller: controller,
//                     style: StyleTheme.font_black_7716_14,
//                     cursorColor: StyleTheme.blue52Color,
//                     decoration: InputDecoration(
//                       hintText: labelText,
//                       hintStyle: StyleTheme.font_black_7716_06_14,
//                       isDense: true,
//                       contentPadding: EdgeInsets.zero,
//                       border: const OutlineInputBorder(
//                         gapPadding: 0,
//                         borderSide: BorderSide(
//                           width: 0,
//                           style: BorderStyle.none,
//                         ),
//                       ),
//                     ),
//                     minLines: 1,
//                     maxLines: 2,
//                     onTap: () {
//                       FocusScope.of(context).requestFocus(focusNode);
//                     },
//                     onSubmitted: (_) {},
//                   ),
//                   trailing: onCollectEventComplete == null
//                       ? GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           onTap: () {
//                             Utils.unFocusNode(context);
//                             onEditingCompleteText?.call(controller.text);
//                             controller.text = "";
//                           },
//                           child: LocalPNG(
//                             name: "ai_mine_send",
//                             width: 30.w,
//                             height: 30.w,
//                           ),
//                         )
//                       : SizedBox(
//                           width: 70.w,
//                           height: 40.w,
//                           child: Row(
//                             children: [
//                               GestureDetector(
//                                 behavior: HitTestBehavior.translucent,
//                                 onTap: () {
//                                   Utils.unFocusNode(context);
//                                   onCollectEventComplete?.call();
//                                 },
//                                 child: LocalPNG(
//                                   name: isCollect
//                                       ? "ai_collect_h"
//                                       : "ai_collect_n",
//                                   width: 26.w,
//                                   height: 26.w,
//                                 ),
//                               ),
//                               SizedBox(width: 20.w),
//                               GestureDetector(
//                                 behavior: HitTestBehavior.translucent,
//                                 onTap: () {
//                                   Utils.unFocusNode(context);
//                                   onEditingCompleteText?.call(controller.text);
//                                   controller.text = "";
//                                 },
//                                 child: LocalPNG(
//                                   name: "ai_mine_send",
//                                   width: 30.w,
//                                   height: 30.w,
//                                 ),
//                               ),
//                               SizedBox(width: 1.w),
//                             ],
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
