import 'package:deepseek/ai/ai_girl_list_page.dart';
import 'package:deepseek/ai/ai_girl_mine_page.dart';
import 'package:deepseek/base/gen_custom_nav.dart';
import 'package:deepseek/home/home_page.dart';
import 'package:deepseek/home/home_search_page.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/sex/chat/home_naked_chat_page.dart';
import 'package:deepseek/sex/girl/home_date_page.dart';
import 'package:flutter/material.dart';
import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/base/request_api.dart';
import 'package:deepseek/util/local_png.dart';
import 'package:deepseek/util/style_theme.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AIGirlPage extends StatefulWidget {
  const AIGirlPage({Key? key, this.isShow = false}) : super(key: key);
  final bool isShow;

  @override
  State<AIGirlPage> createState() => _AIGirlPageState();
}

class _AIGirlPageState extends State<AIGirlPage> {
  List navs = [];

  bool _showSearchContent = false;
  final searchTextEditController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ConfigModel? conf = Provider.of<BaseStore>(context, listen: false).conf;
    navs = conf?.ai_girlfriend_sort ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
                height: 36.w,
                decoration: BoxDecoration(
                    color: StyleTheme.whiteColor,
                    borderRadius: BorderRadius.all(Radius.circular(18.w))),
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                    left: StyleTheme.margin, right: StyleTheme.margin, bottom: 5.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: searchTextEditController,
                        cursorColor: StyleTheme.blue52Color,
                        onSubmitted: onSubmitted,
                        onChanged: onChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: Utils.txt('srsgjs'),
                          hintStyle: StyleTheme.font_gray_153_13,
                          isDense: true, // 紧凑模式
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                        style: StyleTheme.font_black_7716_13,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        onSubmitted(searchTextEditController.text);
                      },
                      child: LocalPNG(
                          name: "ai_nav_search", width: 20.w, height: 20.w),
                    ),
                    SizedBox(width: 10.w),
                  ],
                )),
            Expanded(
              child: _showSearchContent
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: 5.w,
                      ),
                      child: SearchChildPage(
                        isStartSearch: true,
                        word: searchTextEditController.text,
                        type: MediaType.aiGirlFriend,
                      ),
                    )
                  : GenCustomNav(
                      titles: navs
                          .map(
                            (e) => e['label'].toString(),
                          )
                          .toList(),
                      pages: navs
                          .map(
                            (e) => e['type'] == 2
                                ? const AIGirlMineListPage()
                                : AIGirlListPage(
                                    isShow: widget.isShow,
                                    nav: e,
                                  ),
                          )
                          .toList()),
            ),
          ],
        ),
      ],
    );
  }

  void onSubmitted(String keyword) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (keyword.trim().isEmpty) {
      Utils.showText(Utils.txt('qsrgjz'));
      return;
    }
    setState(() {
      _showSearchContent = true;
    });
  }

  void onChanged(String keyword) {
    if (keyword.isEmpty && _showSearchContent == true) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (_showSearchContent == true) {
        setState(() {
          _showSearchContent = false;
        });
      }
    }
  }
}
