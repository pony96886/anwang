import 'package:deepseek/acgn/cartoon/cartoon_detail_page.dart';
import 'package:deepseek/acgn/cartoon/cartoon_more_page.dart';
import 'package:deepseek/acgn/comic/comic_categories_page.dart';
import 'package:deepseek/acgn/comic/comic_detail_page.dart';
import 'package:deepseek/acgn/comic/comic_more_page.dart';
import 'package:deepseek/acgn/comic/comic_reader_page.dart';
import 'package:deepseek/acgn/game/game_detail_page.dart';
import 'package:deepseek/acgn/game/game_more_page.dart';
import 'package:deepseek/acgn/game/game_tag_page.dart';
import 'package:deepseek/acgn/novel/novel_categories_page.dart';
import 'package:deepseek/acgn/novel/novel_detail_page.dart';
import 'package:deepseek/acgn/novel/novel_more_page.dart';
import 'package:deepseek/acgn/novel/novel_reader_page.dart';
import 'package:deepseek/ai/ai_girl_chat_page.dart';
import 'package:deepseek/ai/ai_girl_create_page.dart';
import 'package:deepseek/ai/ai_girl_detail_page.dart';
import 'package:deepseek/ai/ai_magic_details_page.dart';
import 'package:deepseek/mine/mine_message_center.dart';
import 'package:deepseek/mine/mine_order_page.dart';
import 'package:deepseek/mine/mine_vip_update_page.dart';
import 'package:deepseek/sex/chat/home_naked_chat_detail_page.dart';
import 'package:deepseek/sex/chat/home_naked_chat_page.dart';
import 'package:deepseek/sex/chat/home_naked_chat_publish_page.dart';
import 'package:deepseek/sex/girl/home_date_detail_page.dart';
import 'package:deepseek/sex/girl/home_date_page.dart';
import 'package:deepseek/sex/girl/home_date_publish_page.dart';
import 'package:deepseek/sex/sex_hobby_page.dart';
import 'package:deepseek/vlog/vlog_page.dart';
import 'package:deepseek/vlog/vlog_second_page.dart';
import 'package:deepseek/voice/voice_player_local_page.dart';
import 'package:deepseek/voice/voice_player_page.dart';
import 'package:deepseek/voice/voice_page.dart';
import 'package:deepseek/base/preview_view_page.dart';
import 'package:deepseek/base/unplayer_page.dart';
import 'package:deepseek/community/community_issue.dart';
import 'package:deepseek/community/community_post_detail.dart';
import 'package:deepseek/community/community_seltag_page.dart';
import 'package:deepseek/community/community_tag_detail.dart';
import 'package:deepseek/home/home_dark_net_page.dart';
import 'package:deepseek/home/homevideo_part_page.dart';
import 'package:deepseek/home/homevideo_more_page.dart';
import 'package:deepseek/home/home_more_video_page.dart';
import 'package:deepseek/home/home_search_page.dart';
import 'package:deepseek/home/home_task_page.dart';
import 'package:deepseek/home/home_video_detail_page.dart';
import 'package:deepseek/home/home_welfare_page.dart';
import 'package:deepseek/mine/mine_agent_invite_record_page.dart';
import 'package:deepseek/mine/mine_agent_page.dart';
import 'package:deepseek/mine/mine_agent_profit_list_page.dart';
import 'package:deepseek/mine/mine_agent_promotedata_page.dart';
import 'package:deepseek/mine/mine_blogger_page.dart';
import 'package:deepseek/mine/mine_buy_page.dart';
import 'package:deepseek/mine/mine_collect_page.dart';
import 'package:deepseek/mine/mine_community_page.dart';
import 'package:deepseek/mine/mine_follow_page.dart';
import 'package:deepseek/mine/mine_girl_manage_page.dart';
import 'package:deepseek/mine/mine_local_video_page.dart';
import 'package:deepseek/mine/mine_purchase_page.dart';
import 'package:deepseek/mine/mine_down_page.dart';
import 'package:deepseek/mine/mine_mate_page.dart';
import 'package:deepseek/mine/mine_other_user_center.dart';
import 'package:deepseek/mine/mine_strip_chat_manage_page.dart';
import 'package:deepseek/mine/mine_system_page.dart';
import 'package:deepseek/mine/mine_vip_page.dart';
import 'package:deepseek/face/face_pic_mate_page.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:deepseek/base/empty_page.dart';
import 'package:deepseek/base/normal_web.dart';
import 'package:deepseek/base/startup_page.dart';
import 'package:deepseek/mine/mine_bankcard_list_page.dart';
import 'package:deepseek/mine/mine_cash_record_page.dart';
import 'package:deepseek/mine/mine_consumption_page.dart';
import 'package:deepseek/mine/mine_earn_list_page.dart';
import 'package:deepseek/mine/mine_goldcenter_page.dart';
import 'package:deepseek/mine/mine_groups_page.dart';
import 'package:deepseek/mine/mine_login_page.dart';
import 'package:deepseek/mine/mine_norquestion_page.dart';
import 'package:deepseek/mine/mine_service_page.dart';
import 'package:deepseek/mine/mine_set_page.dart';
import 'package:deepseek/mine/mine_share_page.dart';
import 'package:deepseek/mine/mine_to_cash_page.dart';
import 'package:deepseek/mine/mine_update_page.dart';
import 'package:deepseek/mine/mine_vrecord_page.dart';
import 'package:deepseek/util/approute_observer.dart';
import 'package:deepseek/util/utils.dart';
import 'package:go_router/go_router.dart';

class GoRouters {
  //初始化
  static GoRouter init() {
    //二级页面
    final List<GoRoute> childTwoRouters = [
      //视频详情
      GoRoute(
          path: 'homevideodetailpage/:id',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: HomeVideoDetailPage(id: state.params["id"] ?? '0'))),
      //更多视频页面
      GoRoute(
          path: 'homemorevideopage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: HomeMoreVideoPage(data: state.extra))),
      //播放页
      GoRoute(
          path: 'unplayerpage/:cover/:url',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: UNPlayerPage(
                  cover: state.params['cover'], url: state.params['url']))),
      //图片预览
      GoRoute(
          path: 'previewviewpage/:url',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: PreviewViewPage(url: state.params['url'] ?? ""))),
      //VIP
      GoRoute(
          path: 'minevippage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineVipPage())),
      //VIP
      GoRoute(
          path: 'vip',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineVipPage())),
      //VIP Update
      GoRoute(
          path: 'vipupdatepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineVipUpdatePage())),
      //推广数据
      GoRoute(
          path: 'mineagentpromotedatapage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineAgentPromoteDataPage())),
      //代理提现
      GoRoute(
          path: 'mineagenttocashpage/:isbance',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: MineAgentToCashPage(
                isbance: state.params["isbance"] ?? "0",
              ))),
      //代理收益列表
      GoRoute(
          path: 'mineagentprofitlistpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineAgentProfitListPage())),
      //邀请记录
      GoRoute(
          path: 'mineagentinviterecordpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineAgentInviteRecordPage())),
      //代理提现记录
      GoRoute(
          path: 'minecashrecordpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineCashRecordPage())),
      //代理银行卡列表
      GoRoute(
          path: 'minebankcardlistpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineBankcardListPage())),
      //收益提现
      GoRoute(
          path: 'minetocashpage/:isbance',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: MineAgentToCashPage(
                isbance: state.params["isbance"] ?? "0",
              ))),
      //收益明细
      GoRoute(
          path: 'mineearnlistpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineEarnListPage())),
      //金币明细
      GoRoute(
          path: 'mineconsumptionpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineConsumptionPage())),
      //充值记录
      GoRoute(
          path: 'minevrecordpage/:type',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: MineVrecordPage(type: state.params["type"] ?? "0"))),
      //代理
      GoRoute(
          path: 'mineagentpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineAgentPage())),
      //金币充值
      GoRoute(
          path: 'minegoldcenterpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineGoldCenterPage())),
      GoRoute(
          path: 'web/:url',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: NormalWeb(url: state.params['url']))),
      //更新文本信息
      GoRoute(
          path: 'mineupdatepage/:type/:title',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: MineUpdatePage(
                type: state.params['type'],
                title: state.params['title'],
              ))),
      //常见问题
      GoRoute(
          path: 'minenorquestionpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineNorquestionPage())),
      //选择帖子板块
      GoRoute(
          path: 'communityseltagpage/:id/:type',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: CommunitySeltagPage(
                id: int.parse(state.params['id'] ?? '0'),
                type: int.parse(state.params['type'] ?? '0'),
              ))),
      //他人中心
      GoRoute(
          path: 'mineotherusercenter/:aff',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: MineOtherUserCenter(aff: state.params["aff"] ?? "0"))),
      //本地播放
      GoRoute(
          path: 'minelocalvideopage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: MineLocalVideoPage(
                videoInfo: {
                  'source_240': AppGlobal.mediaMap?['url'],
                  'title': AppGlobal.mediaMap?['title'],
                  'cover_thumb': AppGlobal.mediaMap?['cover_thumb'],
                  'isLocal': 1,
                },
              ))),
    ];

    //一级页面
    final List<GoRoute> childOneRouters = [
      // 短视频
      GoRoute(
          path: 'vlogpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: const VlogPage()),
          routes: childTwoRouters),

      // 短视频 二级
      GoRoute(
          path: 'vlogsecondpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: VlogSecondPage()),
          routes: childTwoRouters),

      // ASMR
      GoRoute(
          path: 'voicepage',
          pageBuilder: (context, state) =>
              Utils.buildSlideTransitionPage(state: state, child: VoicePage()),
          routes: childTwoRouters),
      // ASMR详情
      GoRoute(
        path: 'voiceplayerpage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: VoicePlayerPage(
              data: state.extra,
            )),
      ),
      // ASMR详情
      GoRoute(
        path: 'voiceplayerlocalpage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: VoicePlayerLocalPage(
              data: state.extra,
            )),
      ),
      //创建AI女友
      GoRoute(
          path: 'aigirlcreatepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: AIGirlCreatePage()),
          routes: childTwoRouters),
      //AI女友 信息页
      GoRoute(
          path: 'aigirldetailpage/:id',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: AIGirlDetailPage(id: state.params["id"] ?? '0')),
          routes: childTwoRouters),

      //AI女友 聊天
      GoRoute(
          path: 'aigirlchatpage/:id/:name/:avatar',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: AIGirlChatPage(
                id: int.parse(state.params["id"] ?? '0'),
                name: state.params["name"] ?? '',
                avatar: state.params["avatar"] ?? '',
              )),
          routes: childTwoRouters),

      //性趣
      GoRoute(
          path: 'sexhobby',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: SexHobbyPage()),
          routes: childTwoRouters),

      //裸聊
      GoRoute(
          path: 'nakedchatpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: HomeNakedChatPage())),
      //裸聊详情
      GoRoute(
          path: 'homenakedchatdetailpage/:id',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: HomeNakedChatDetailPage(id: state.params["id"] ?? '0'))),
      // 发布裸聊
      GoRoute(
        path: 'homenakedchatpublishpage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: HomeNakedChatPublishPage()),
      ),
      //约炮
      GoRoute(
          path: 'datepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: HomeDatePage())),
      //约炮详情
      GoRoute(
        path: 'homedatedetailpage/:id',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: HomeDateDetailPage(id: state.params["id"] ?? '0')),
      ),
      // 发布约炮
      GoRoute(
        path: 'homedatepublishpage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: HomeDatePublishPage()),
      ),
      //暗网
      GoRoute(
          path: 'homedartnetpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: HomeDarkNetPage()),
          routes: childTwoRouters),

      // 视频 更多
      GoRoute(
          path: 'homevideomorepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: HomeVideoMorePage(
                param: state.extra,
              )),
          routes: childTwoRouters),

      // 动漫 更多
      GoRoute(
          path: 'cartoonmorepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: CartoonMorePage(
                param: state.extra,
              )),
          routes: childTwoRouters),

      // 漫画 分类
      GoRoute(
          path: 'comiccategoriespage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: ComicCategoriesPage()),
          routes: childTwoRouters),

      // 漫画 分类 更多
      GoRoute(
          path: 'comicsortpage/:sort',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: ComicMorePage(
                sort: state.params['sort'] ?? '0',
                param: state.extra,
              )),
          routes: childTwoRouters),
      // 漫画 更多
      GoRoute(
          path: 'comicmorepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: ComicMorePage(
                param: state.extra,
              )),
          routes: childTwoRouters),

      // 色游 更多
      GoRoute(
          path: 'gamemorepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: GameMorePage(
                param: state.extra,
              )),
          routes: childTwoRouters),
      // 色游 分类 更多
      GoRoute(
          path: 'gamesortpage/:sort',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: GameMorePage(
                sort: state.params['sort'] ?? '0',
                param: state.extra,
              )),
          routes: childTwoRouters),
      // 色游 tag
      GoRoute(
          path: 'gametagpage/:tag',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: GameTagPage(
                tag: state.params['tag'] ?? '',
              )),
          routes: childTwoRouters),

      //色游详情
      GoRoute(
        path: 'gamedetailpage/:id',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: GameDetailPage(id: state.params["id"] ?? '0')),
      ),
      // 长视频 更多
      GoRoute(
          path: 'homevideomorepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: CartoonMorePage(
                param: state.extra,
              )),
          routes: childTwoRouters),
      // 长视频 part 更多
      GoRoute(
          path: 'homevideopartpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: HomeVideoPartPage(
                param: state.extra,
              )),
          routes: childTwoRouters),
      // 小说 更多
      GoRoute(
          path: 'novelmorepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: NovelMorePage(
                param: state.extra,
              )),
          routes: childTwoRouters),
      // 小说 分类
      GoRoute(
          path: 'novelcategoriespage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: NovelCategoriesPage()),
          routes: childTwoRouters),

      // 小说 分类 更多
      GoRoute(
          path: 'novelsortpage/:sort',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: NovelMorePage(
                sort: state.params['sort'] ?? '0',
                param: state.extra,
              )),
          routes: childTwoRouters),

      //动漫详情
      GoRoute(
        path: 'cartoondetailpage/:id',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: CartoonDetailPage(id: state.params["id"] ?? '0')),
      ),
      //漫画详情
      GoRoute(
        path: 'comicdetailpage/:id',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: ComicDetailPage(id: state.params["id"] ?? '0')),
      ),
      //漫画章节详情
      GoRoute(
        path: 'comicreaderpage/:chapter',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: ComicReaderPage(
              chapterIndex: int.parse(state.params["chapter"] ?? '0'),
              comicInfo: state.extra,
            )),
      ),
      //小说详情
      GoRoute(
        path: 'noveldetailpage/:id',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: NovelDetailPage(id: state.params["id"] ?? '0')),
      ),
      //小说章节详情
      GoRoute(
        path: 'novelreaderpage/:chapter',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: NovelReaderPage(
              chapterIndex: int.parse(state.params["chapter"] ?? '0'),
              novelInfo: state.extra,
            )),
      ),

      //福利列表
      GoRoute(
          path: 'homewelfarepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: HomeWelfarePage()),
          routes: childTwoRouters),
      //关注粉丝列表
      GoRoute(
          path: 'minefollowpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineFollowPage()),
          routes: childTwoRouters),
      //搜索页面
      GoRoute(
          path: 'homesearchpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: HomeSearchPage(
                searchStr: state.queryParams['searchStr'],
                index: state.queryParams['index'],
              )),
          routes: childTwoRouters),
      //系统消息
      GoRoute(
          path: 'minesystempage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: const MineSystemPage()),
          routes: childTwoRouters),
      //消息中心
      GoRoute(
          path: 'minemessagecenter',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: const MineMessageCenterPage()),
          routes: childTwoRouters),
      //我的社区
      GoRoute(
          path: 'minecommunitypage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineCommunityPage()),
          routes: childTwoRouters),
      //博主申请
      GoRoute(
        path: 'minebloggerpage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: MineBloggerPage()),
        routes: childTwoRouters,
      ),
      //我的收藏
      GoRoute(
        path: 'minecollectpage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: MineCollectPage()),
        routes: childTwoRouters,
      ),
      //我的购买
      GoRoute(
        path: 'minebuypage',
        pageBuilder: (context, state) =>
            Utils.buildSlideTransitionPage(state: state, child: MineBuyPage()),
        routes: childTwoRouters,
      ),

      //我的订单
      GoRoute(
        path: 'mineorderpage',
        pageBuilder: (context, state) =>
            Utils.buildSlideTransitionPage(state: state, child: MineOderPage()),
        routes: childTwoRouters,
      ),

      //我的下载
      GoRoute(
        path: 'minedownpage',
        pageBuilder: (context, state) =>
            Utils.buildSlideTransitionPage(state: state, child: MineDownPage()),
        routes: childTwoRouters,
      ),
      //他人中心
      GoRoute(
          path: 'mineotherusercenter/:aff',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: MineOtherUserCenter(aff: state.params["aff"] ?? "0")),
          routes: childTwoRouters),
      //帖子详情
      GoRoute(
          path: 'communitypostdetail/:id',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
                state: state,
                child: CommunityPostDetail(id: state.params['id'] ?? '0'),
              ),
          routes: childTwoRouters),
      //板块详情
      GoRoute(
          path: 'communitytagdetail/:topic_id',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child: CommunityTagDetail(
                  topic_id: state.params['topic_id'] ?? '0')),
          routes: childTwoRouters),
      //帖子发布
      GoRoute(
          path: 'communityissue/:type',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state,
              child:
                  CommunityIssue(type: int.parse(state.params['type'] ?? '0'))),
          routes: childTwoRouters),
      //金币充值
      GoRoute(
          path: 'minegoldcenterpage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineGoldCenterPage()),
          routes: childTwoRouters),
      //WEB页面
      GoRoute(
        path: 'web/:url',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: NormalWeb(url: state.params['url'])),
        routes: childTwoRouters,
      ), //帖子详情
      //登录页
      GoRoute(
        path: 'mineloginpage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: const MineLoginPage()),
        routes: childTwoRouters,
      ),
      //个人设置
      GoRoute(
        path: 'minesetpage',
        pageBuilder: (context, state) =>
            Utils.buildSlideTransitionPage(state: state, child: MineSetPage()),
        routes: childTwoRouters,
      ),
      GoRoute(
        path: 'minesharepage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: MineSharePage()),
        routes: childTwoRouters,
      ),
      //车友群
      GoRoute(
          path: 'minegroupspage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineGroupsPage())),
      //约炮管理
      GoRoute(
          path: 'minegirlmanagepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineGirlManagePage())),
      //裸聊管理
      GoRoute(
          path: 'minestripchatmanagepage',
          pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
              state: state, child: MineStripChatManagePage())),
      //在线客服
      GoRoute(
        path: 'mineservicepage',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state, child: MineServicePage()),
        routes: childTwoRouters,
      ),
      //生成记录
      GoRoute(
        path: 'minepurchasepage/:index',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
            state: state,
            child: MinePurchasePage(
              index: int.parse(state.params['index'] ?? "0"),
            )),
        routes: childTwoRouters,
      ),
      //AI魔法详情
      GoRoute(
        path: 'aimagicdetails',
        pageBuilder: (context, state) {
          return Utils.buildSlideTransitionPage(
              state: state, child: AiMagicDetailsPage(material: state.extra));
        },
        routes: childTwoRouters,
      ),
      //素材记录
      GoRoute(
        path: 'minematepage',
        pageBuilder: (context, state) =>
            Utils.buildSlideTransitionPage(state: state, child: MineMatePage()),
        routes: childTwoRouters,
      ),
      //推荐素材
      GoRoute(
        path: 'picmatepage/:type',
        pageBuilder: (context, state) => Utils.buildSlideTransitionPage(
          state: state,
          child: FacePicMatePage(type: int.parse(state.params['type'] ?? "0")),
        ),
        routes: childTwoRouters,
      ),
    ];

    // GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
    return GoRouter(
      debugLogDiagnostics: true,
      routerNeglect: true,
      initialLocation: "/",
      routes: [
        //根目录
        GoRoute(
          path: '/',
          builder: (context, state) => const StartupPage(),
          routes: childOneRouters + childTwoRouters,
        ),
      ],
      errorBuilder: (context, state) => const EmptyPage(),
      observers: [
        BotToastNavigatorObserver(),
        AppRouteObserver().routeObserver
      ],
      redirect: (state) {
        Utils.log(state.location);
      },
    );
  }
}
