import 'package:deepseek/base/base_store.dart';
import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/model/element_model.dart';
import 'package:deepseek/model/home_list_construct_model.dart';
import 'package:deepseek/model/home_list_pure_list_model.dart';
import 'package:deepseek/model/response_model.dart';
import 'package:deepseek/model/sysnotice_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/network_http.dart';
import 'package:deepseek/util/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

//新人福利 领取
Future<ResponseModel<dynamic>?> reqTaskAccept(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/sign/accept_task', data: reqdata);
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//福利任务
Future<ResponseModel<dynamic>?> reqTaskList() async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/sign/list_task');
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//福利 签到
Future<ResponseModel<dynamic>?> reqSignUp() async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/sign/sign_up');
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 积分兑换列表
Future<ResponseModel<dynamic>?> reqExpList() async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/sign/list_exp_vip', data: {'type': 1});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 我的 购买列表
Future<ResponseModel<dynamic>?> reqMineBuyList({
  String type = '',
  int page = 1,
  String lastIx = "",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/$type/list_buy', data: {
      "page": page,
      "lastIx": lastIx,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 我的 购买列表
Future<ResponseModel<dynamic>?> reqMineFavoriteList({
  String type = '',
  int page = 1,
  String lastIx = "",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/$type/list_favorite', data: {
      "page": page,
      "lastIx": lastIx,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 搜索
Future<ResponseModel<dynamic>?> reqSearchitems({
  String word = "",
  String type = '',
  int page = 1,
  int limit = 15,
  String lastIx = "",
  Map<dynamic, dynamic>? extraParam,
}) async {
  try {
    Map data = {
      "word": word,
      "page": page,
      "limit": limit,
      "lastIx": lastIx,
    };

    if (extraParam != null) {
      data.addAll(extraParam);
    }
    Response<dynamic> res =
        await NetworkHttp.post('/api/$type/search', data: data);
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// mv
// girl
// chat
// material
// album
// comic
// novel
//评论 列表
Future<ResponseModel<dynamic>?> reqCommentList(
    {String id = "0",
    int page = 1,
    String type = '',
    int limit = 15,
    String lastIx = ""}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/$type/list_comment', data: {
      "id": id,
      "page": page,
      "limit": limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// mv
// girl
// chat
// material
// album
// comic
// novel
//发布 评论
Future<ResponseModel<dynamic>?> reqCreatComment({
  String type = '',
  String id = "0",
  String content = "",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/$type/comment',
        data: {"id": id, "text": content});
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//帖子或评论点赞/取消点赞
Future<ResponseModel<dynamic>?> reqCommLike(
    {String type = "community", String id = "0"}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/$type/comment_like', data: {"id": id});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//积分兑换
Future<ResponseModel<dynamic>?> reqExpExchange({
  int id = 0,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/sign/convert_vip', data: {
      "id": id,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//短视频-我的关注页面
Future<ResponseModel<dynamic>?> reqMyFollowPageData(
    {int page = 1, int limit = 15}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/vlog/list_follow2',
        data: {"page": page, "limit": limit});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

/// 短视频 播放上报
Future<ResponseModel<dynamic>?> reqVlogPlay({
  dynamic id,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/vlog/play', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//购买短视频
Future<ResponseModel<dynamic>?> reqBuyVlog(
    {int id = 0, int money = 0, BuildContext? context}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/vlog/buy', data: {'id': id});

    ResponseModel<dynamic>? data =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (data.status == 1) {
      Provider.of<BaseStore>(context!, listen: false).setMoney(money);
    }
    return data;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取短视频接口
Future<ResponseModel<dynamic>?> reqShortApiList(
    {String apiUrl = '', Map? param}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(apiUrl, data: param);
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//他人短视频
Future<ResponseModel<dynamic>?> reqOthersVlog({
  String aff = "0",
  int page = 1,
  int limit = 15,
  String last_ix = "",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/vlog/list_peer', data: {
      "aff": aff,
      "page": page,
      "limit": limit,
      "last_ix": last_ix,
    });

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//关注的帖子话题列表
Future<ResponseModel<dynamic>?> reqFollowTopicList(
    {int page = 1, int limit = 15, String last_ix = ""}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/community/followTopics',
        data: {"page": page, "limit": limit, "last_ix": last_ix});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//关注的用户列表
Future<ResponseModel<dynamic>?> reqFollowUserList(
    {int page = 1, int limit = 15, String last_ix = ""}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/list_follow',
        data: {"page": page, "limit": limit, "last_ix": last_ix});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//搜索视频信息
Future<ResponseModel<dynamic>?> reqSearchVideos({
  String word = "",
  String last_ix = "0",
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/mv/search', data: {
      "word": word,
      "page": page,
      "last_ix": last_ix,
      "limit": limit,
      "type": 1,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//热门搜索结果
Future<ResponseModel<dynamic>?> reqPopularSearch({int limit = 50}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/search/index', data: {"limit": limit});
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//内容-帖子收藏列表
Future<ResponseModel<dynamic>?> reqPostCollectList({
  int page = 1,
  String lastIx = "",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/list_favorite', data: {
      "page": page,
      "lastIx": lastIx,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 我的 视频收藏列表
Future<ResponseModel<dynamic>?> reqCollectList({
  int page = 1,
  String lastIx = "",
  int type = 0,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/user/getUserFavor', data: {
      "page": page,
      "lastIx": lastIx,
      'type': type,
      'limit': limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//内容-帖子购买列表
Future<ResponseModel<dynamic>?> reqPostBuyList({
  int page = 1,
  String lastIx = "",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/list_buy', data: {
      "page": page,
      "lastIx": lastIx,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 我的 视频购买列表
Future<ResponseModel<dynamic>?> reqMvBuyList({
  int page = 1,
  String lastIx = "",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/mv/list_buy', data: {
      "page": page,
      "lastIx": lastIx,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//搜索帖子信息
Future<ResponseModel<dynamic>?> reqSearchPosts({
  String word = "",
  String last_ix = "0",
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/search', data: {
      "word": word,
      "page": page,
      "last_ix": last_ix,
      "limit": limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//0-待审核 1-已通过 2-未通过 3-回调中
Future<ResponseModel<dynamic>?> reqPostStatusList(
    {int status = 0, int page = 1, int limit = 15}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/community/list_my_post',
        data: {'status': status, 'page': page, 'limit': limit});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//他人帖子
Future<ResponseModel<dynamic>?> reqOthersCenterPost({
  String aff = "0",
  int page = 1,
  int limit = 15,
  String last_ix = "",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/peer_center_post', data: {
      "aff": aff,
      "page": page,
      "limit": limit,
      "last_ix": last_ix,
    });

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//社区排序列表
Future<ResponseModel<dynamic>?> reqCommunitySortList({
  int id = 0,
  String sort = "",
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/construct', data: {
      "id": id,
      "sort": sort,
      "page": page,
      "limit": limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//我的AI列表
Future<ResponseModel<dynamic>?> reqCommunityAiList({
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/ai_posts', data: {
      "page": page,
      "limit": limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//话题关注/取消关注
Future<ResponseModel<dynamic>?> reqFollowTopic({String topic_id = "0"}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/community/follow_topic',
        data: {"topic_id": topic_id});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//话题详情
Future<ResponseModel<dynamic>?> reqTopicsDetail({String topic_id = "0"}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/community/topic_detail',
        data: {"topic_id": topic_id});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//话题详情-帖子分页
Future<ResponseModel<dynamic>?> reqTopicPostList({
  String topic_id = "0",
  String cate = "",
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/list_topic_post', data: {
      "topic_id": topic_id,
      "cate": cate,
      "page": page,
      "limit": limit
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//发帖获取全部标签
Future<ResponseModel<dynamic>?> reqTopicsAll(
    {int page = 1, int limit = 20}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/topics', data: {
      'page': page,
      'limit': limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//评论详情列表
Future<ResponseModel<dynamic>?> reqPostCommentsSecond(
    {String comment_id = "0", int page = 1, int limit = 15}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/comments', data: {
      "comment_id": comment_id,
      "page": page,
      "limit": limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//帖子或评论点赞/取消点赞
Future<ResponseModel<dynamic>?> reqPostCommLike(
    {String type = "post", String id = "0"}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/community/like',
        data: {"type": type, "id": id});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//发布评论
Future<ResponseModel<dynamic>?> reqPostComment({
  String post_id = "0",
  String comment_id = "0",
  String content = "",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/community/comment',
        data: {
          "post_id": post_id,
          "comment_id": comment_id,
          "content": content
        });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取帖子的播放链接
Future<ResponseModel<dynamic>?> reqGetPostURL(
    {int id = 0, int money = 0, required BuildContext? context}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/unlock', data: {'id': id});
    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && money >= 0) {
      Provider.of<BaseStore>(context!, listen: false).setMoney(money);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//内容-帖子详情页评论
Future<ResponseModel<dynamic>?> reqPostDetailComment({
  String id = "0",
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/post_comments', data: {
      "id": id,
      "page": page,
      "limit": limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//内容-帖子详情
Future<ResponseModel<dynamic>?> reqPostDetailContent({String id = "0"}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/post_detail', data: {"id": id});
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//关注用户/取消关注
Future<ResponseModel<dynamic>?> reqFollowUser({String aff = "0"}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/user/toggle_follow', data: {"aff": aff});
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// const TYPE_MV = 1;
// const TYPE_SHORT_MV = 11;
// const TYPE_POST = 14;
// const TYPE_CARTOON = 15;
// const TYPE_COMIC = 16;
// const TYPE_GAME = 17;
// const TYPE_NOVEL = 18;
// const TYPE_VOICE = 19;
// const TYPE_CHAT = 20;
// const TYPE_GIRL = 21;

// const TYPE_TIPS = [
//     self::TYPE_MV        => '长视频',  1;
//     self::TYPE_SHORT_MV  => '短视频',  11;
//     self::TYPE_POST      => '帖子',  14;
//     self::TYPE_CARTOON   => '动漫', 15;
//     self::TYPE_COMIC     => '漫画', 16;
//     self::TYPE_GAME      => '黄游', 17;
//     self::TYPE_NOVEL     => '小说', 18;
//     self::TYPE_VOICE     => '语音', 19;
//     self::TYPE_CHAT      => '裸聊', 20;
//     self::TYPE_GIRL      => '约炮', 21;
//     self::TYPE_CHARACTER => 'AI女友', 22;
// ];
Future<ResponseModel<dynamic>?> reqUserFavorite(
    {int type = 0, int id = 0}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/favorite',
        data: {"type": type, "id": id});
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// const TYPE_MV = 1;
// const TYPE_SHORT_MV = 11;
// const TYPE_POST = 14;
// const TYPE_CARTOON = 15;
// const TYPE_COMIC = 16;
// const TYPE_GAME = 17;
// const TYPE_NOVEL = 18;
// const TYPE_VOICE = 19;
// const TYPE_CHAT = 20;
// const TYPE_GIRL = 21;
// const TYPE_CHARACTER = 22;

// const TYPE_TIPS = [
//     self::TYPE_MV        => '长视频',  1;
//     self::TYPE_SHORT_MV  => '短视频',  11;
//     self::TYPE_POST      => '帖子',  14;
//     self::TYPE_CARTOON   => '动漫', 15;
//     self::TYPE_COMIC     => '漫画', 16;
//     self::TYPE_GAME      => '黄游', 17;
//     self::TYPE_NOVEL     => '小说', 18;
//     self::TYPE_VOICE     => '语音', 19;
//     self::TYPE_CHAT      => '裸聊', 20;
//     self::TYPE_GIRL      => '约炮', 21;
//     self::TYPE_CHARACTER => 'AI女友', 22;
// ];
Future<ResponseModel<dynamic>?> reqUserLike({int type = 0, int id = 0}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/like',
        data: {"type": type, "id": id});
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// const TYPE_MV = 1;
// const TYPE_SHORT_MV = 2;
// const TYPE_COMIC = 3;
// const TYPE_POST = 4;
// const TYPE_CARTOON = 8;
// const TYPE_GAME = 9;
// const TYPE_NOVEL = 10;

// const TYPE_TIPS = [
//     self::TYPE_MV       => '长视频评论',
//     self::TYPE_SHORT_MV => '短视频评论',
//     self::TYPE_COMIC    => '漫画评论',
//     self::TYPE_POST     => '帖子评论',
//     self::TYPE_CARTOON  => '动漫评论',
//     self::TYPE_GAME     => '黄游评论',
//     self::TYPE_NOVEL    => '小说评论',
// ];
Future<ResponseModel<dynamic>?> reqCommentLike(
    {int type = 0, int id = 0}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/comment_like',
        data: {"type": type, "id": id});
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//发布帖子
Future<ResponseModel<dynamic>?> reqPublishPost(
  BuildContext context, {
  String topic_id = "0",
  String title = "",
  String content = "",
  String medias = "",
  String coins = "0",
  String contact = "",
  int money = 0,
  int is_public = 0,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/community/post', data: {
      "topic_id": topic_id,
      "title": title,
      "content": content,
      "medias": medias,
      "coins": coins,
      "is_public": is_public,
      "contact": contact,
    });
    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && money > 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(money);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取帖子
Future<ResponseModel<dynamic>?> reqGetPostNav() async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/community/nav');

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//购买视频
Future<ResponseModel<dynamic>?> reqBuyVideo(
    {int id = 0, int money = 0, BuildContext? context}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/mv/buy', data: {'id': id});

    ResponseModel<dynamic>? data =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (data.status == 1) {
      Provider.of<BaseStore>(context!, listen: false).setMoney(money);
    }
    return data;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//常规更多
Future<ResponseModel<dynamic>?> reqListConstruct(
    {required String id, int page = 1, String sort = "hot"}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/mv/list_construct',
        data: {'id': id, 'page': page, "sort": sort});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//对视频发布评论
Future<ResponseModel<dynamic>?> reqCreateMvComment(
    {int id = 0, String content = ''}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/mv/create_comment_mv', data: {
      "content": content,
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//视频评论
Future<ResponseModel<dynamic>?> reqMvComment(
    {int id = 0, String last_ix = '', int page = 1, int limit = 15}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/mv/list_comment_mv', data: {
      "last_ix": last_ix,
      "page": page,
      "limit": limit,
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//下载次数验证
Future<ResponseModel<dynamic>?> reqDownLoadNum({int id = 0}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/privilege/download', data: {"id": id});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取视频详情
Future<ResponseModel<dynamic>?> reqVideoDetail({String id = '0'}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/mv/getDetail', data: {'id': id});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//视频详情推荐视频
Future<ResponseModel<dynamic>?> reqVideoDetailRecList({String id = '0'}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/mv/getDetailRecommendList',
        data: {'id': id});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//首页视频列表 纯列表
Future<ResponseModel<HomePureListConstructModel>?> reqPureListByApiLink(
    {required String apiLink, Map? params}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(apiLink, data: params);

    ResponseModel<HomePureListConstructModel>? result =
        ResponseModel<HomePureListConstructModel>.fromJson(
            res.data, ((json) => HomePureListConstructModel.fromJson(json)));
    result.data?.api = apiLink;
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//首页视频列表 结构体
Future<ResponseModel<HomeListConstructModel>?> reqConstructByApiLink(
    {required String apiLink, Map? params}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(apiLink, data: params);

    ResponseModel<HomeListConstructModel>? result =
        ResponseModel<HomeListConstructModel>.fromJson(
            res.data, ((json) => HomeListConstructModel.fromJson(json)));
    result.data?.api = apiLink;
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 视频 更多
Future<ResponseModel<dynamic>?> reqMoreVideos({
  int cate_id = 0,
  int page = 1,
  int limit = 15,
  int has_ad = 0, //是否需要广告，1:需要，0:不需要
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/index/sort', data: {
      "id": cate_id,
      "has_ad": has_ad,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 视频 更多
Future<ResponseModel<dynamic>?> reqPartVideos({
  int id = 0,
  dynamic sort,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/index/part', data: {
      "id": id,
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//获取首页顶部导航
Future<ResponseModel<ElementModel>?> reqTopNavConfig({int id = 7}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/element/getElementById', data: {'id': id});

    return ResponseModel<ElementModel>.fromJson(
        res.data, ((json) => ElementModel.fromJson(json)));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//  audio 更多
Future<ResponseModel<dynamic>?> reqVoiceIndex({
  dynamic sort,
  dynamic id,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/voice/index', data: {
      "sort": sort,
      "id": id,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//  audio 队列列表
Future<ResponseModel<dynamic>?> reqVoiceListQueue({
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/voice/list_queue', data: {
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///  audio 加入 队列
Future<ResponseModel<dynamic>?> reqVoiceAddQueue({
  dynamic id,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/voice/add_queue', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///  audio 删除 from 队列
Future<ResponseModel<dynamic>?> reqVoiceDeleteQueue({
  dynamic id,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/voice/del_queue', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

/// audio 播放上报
Future<ResponseModel<dynamic>?> reqVoicePlay({
  dynamic id,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/voice/play', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// audio  购买
Future<ResponseModel<dynamic>?> reqVoiceBuy(
  BuildContext context, {
  dynamic id,
  int money = 0,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/voice/buy', data: {
      "id": id,
    });
    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && money > 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(money);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// audio  下载
Future<ResponseModel<dynamic>?> reqVoiceDownload({
  dynamic id,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/voice/download', data: {
      "id": id,
    });
    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 裸聊 列表
Future<ResponseModel<dynamic>?> reqNakedChatList({
  int id = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/chat/index', data: {
      "id": id,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 裸聊 分类数据列表
Future<ResponseModel<dynamic>?> reqNakedChatSortList({
  String sort = '',
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/chat/list_sort', data: {
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 裸聊 详情
Future<ResponseModel<dynamic>?> reqNakedChatDetail({
  String id = "0",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/chat/detail', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 裸聊 购买
Future<ResponseModel<dynamic>?> reqChatBuy(
  BuildContext context, {
  dynamic id,
  int money = 0,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/chat/buy', data: {
      "id": id,
    });
    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && money > 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(money);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 裸聊 发布
Future<ResponseModel<dynamic>?> reqNakedChatCreat({
  dynamic cateId = "",
  String name = "",
  String price = "",
  String age = "",
  String height = "",
  String weight = "",
  String cup = "",
  String option = "",
  String time = "",
  String contact = "",
  String intro = "",
  String medias = "",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/chat/create', data: {
      "cate_id": cateId,
      "name": name,
      "price": price,
      "age": age,
      "height": height,
      "weight": weight,
      "cup": cup,
      "option": option,
      "time": time,
      "contact": contact,
      "intro": intro,
      "medias": medias,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//  "待审核",1
// "未通过",2
// "处理中", 3
// "已发布",4
// 约炮管理
Future<ResponseModel<dynamic>?> reqChatManageList({
  int status = 1,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/chat/list_my', data: {
      "status": status,
      "page": page,
      "limit": limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 约炮 筛选 列表
Future<ResponseModel<dynamic>?> reqGirlIndexList({
  String sort = '0',
  Map options = const {},
  int page = 1,
  int limit = 15,
}) async {
  try {
    Map data = {
      "sort": sort,
      "page": page,
      "limit": limit,
    };

    data.addAll(options);
    Response<dynamic> res =
        await NetworkHttp.post('/api/girl/index', data: data);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 约炮 详情
Future<ResponseModel<dynamic>?> reqGirlDetail({
  String id = "0",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/girl/detail', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 约炮 购买
Future<ResponseModel<dynamic>?> reqGirlBuy(
  BuildContext context, {
  dynamic id,
  int money = 0,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/girl/buy', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 约炮 发布
Future<ResponseModel<dynamic>?> reqGirlCreat({
  dynamic cateId = "",
  dynamic tag = "",
  String name = "",
  String price = "",
  String age = "",
  String height = "",
  String weight = "",
  String cup = "",
  String option = "",
  String time = "",
  String contact = "",
  String intro = "",
  String medias = "",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/girl/create', data: {
      "title": name,
      "class": cateId,
      "tag": tag,
      "price": price,
      "age": age,
      "height": height,
      "weight": weight,
      "cup": cup,
      "serv": option,
      "time": time,
      "contact": contact,
      "intro": intro,
      "medias": medias,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 约炮 筛选项目
Future<ResponseModel<dynamic>?> reqGirlOption() async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/girl/option', data: {});
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//  "待审核",1
// "未通过",2
// "处理中", 3
// "已发布",4
// 约炮管理
Future<ResponseModel<dynamic>?> reqGirlManageList({
  int status = 1,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/girl/list_my', data: {
      "status": status,
      "page": page,
      "limit": limit,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 动漫推荐
Future<ResponseModel<dynamic>?> reqCartoonRec({
  int id = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/cartoon/rec', data: {
      "id": id,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 动漫 分类列表
Future<ResponseModel<dynamic>?> reqCartoonThemeList({
  int id = 0,
  dynamic sort = '',
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/cartoon/theme', data: {
      "id": id,
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 动漫 更多
Future<ResponseModel<dynamic>?> reqMoreCartoons({
  dynamic sort,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/cartoon/more', data: {
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//获取动漫详情
Future<ResponseModel<dynamic>?> reqCartoonDetail({String id = '0'}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/cartoon/detail', data: {'id': id});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//购买动漫
Future<ResponseModel<dynamic>?> reqBuyCartoon(
    {int id = 0, int money = 0, BuildContext? context}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/cartoon/buy', data: {'id': id});

    ResponseModel<dynamic>? data =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (data.status == 1) {
      Provider.of<BaseStore>(context!, listen: false).setMoney(money);
    }
    return data;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//动漫下载次数验证
Future<ResponseModel<dynamic>?> reqCartoonDownLoadNum({int id = 0}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/cartoon/download', data: {"id": id});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 漫画推荐
Future<ResponseModel<dynamic>?> reqComicRec({
  int id = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/comic/rec', data: {
      "id": id,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 漫画 分类列表
Future<ResponseModel<dynamic>?> reqComicThemeList({
  int id = 0,
  dynamic sort = '',
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/comic/theme', data: {
      "id": id,
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 漫画 更多
Future<ResponseModel<dynamic>?> reqMoreComics({
  dynamic sort,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/comic/more', data: {
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 漫画
Future<ResponseModel<dynamic>?> reqComicsSort({
  dynamic sort,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/comic/$sort', data: {
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 漫画 分类列表
Future<ResponseModel<dynamic>?> reqComicType({
  int page = 1,
  int limit = 15,
  Map options = const {},
}) async {
  try {
    Map data = {
      "page": page,
      "limit": limit,
    };
    data.addAll(options);

    Response<dynamic> res =
        await NetworkHttp.post('/api/comic/type', data: data);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取漫画详情
Future<ResponseModel<dynamic>?> reqComicDetail({String id = '0'}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/comic/detail', data: {'id': id});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 漫画  章节 详情
Future<ResponseModel<dynamic>?> reqComicChapterDetail({
  dynamic id,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/comic/chapter_detail', data: {
      "id": id,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 漫画 购买
Future<ResponseModel<dynamic>?> reqComicChapterBuy(
  BuildContext context, {
  dynamic id,
  int money = 0,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/comic/buy', data: {
      "id": id,
    });
    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && money > 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(money);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 小说推荐
Future<ResponseModel<dynamic>?> reqNovelRec({
  int id = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/novel/rec', data: {
      "id": id,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 小说 分类列表
Future<ResponseModel<dynamic>?> reqNovelThemeList({
  int id = 0,
  dynamic sort = '',
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/novel/more', data: {
      "id": id,
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 小说 更多
Future<ResponseModel<dynamic>?> reqMoreNovels({
  dynamic sort,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/novel/rec_more', data: {
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 小说
Future<ResponseModel<dynamic>?> reqNovelsSort({
  dynamic sort,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/novel/$sort', data: {
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 小说 分类列表
Future<ResponseModel<dynamic>?> reqNovelType({
  int page = 1,
  int limit = 15,
  Map options = const {},
}) async {
  try {
    Map data = {
      "page": page,
      "limit": limit,
    };
    data.addAll(options);

    Response<dynamic> res =
        await NetworkHttp.post('/api/novel/type', data: data);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取小说详情
Future<ResponseModel<dynamic>?> reqNovelDetail({String id = '0'}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/novel/detail', data: {'id': id});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 小说  章节 详情
Future<ResponseModel<dynamic>?> reqNovelChapterDetail({
  dynamic id,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/novel/chapter_detail', data: {
      "id": id,
    });
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 小说 购买
Future<ResponseModel<dynamic>?> reqNovelChapterBuy(
  BuildContext context, {
  dynamic id,
  int money = 0,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/novel/buy', data: {
      "id": id,
    });
    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && money > 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(money);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 游戏推荐
Future<ResponseModel<dynamic>?> reqGameRec({
  int id = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/game/rec', data: {
      "id": id,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 游戏 分类列表
Future<ResponseModel<dynamic>?> reqGameThemeList({
  int id = 0,
  dynamic sort = '',
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/game/theme', data: {
      "id": id,
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 游戏 更多
Future<ResponseModel<dynamic>?> reqMoreGames({
  dynamic sort,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/game/more', data: {
      "sort": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 游戏
Future<ResponseModel<dynamic>?> reqGamesSort({
  dynamic sort,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/game/nav', data: {
      "type": sort,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

// 游戏 分类列表
Future<ResponseModel<dynamic>?> reqGameType({
  int page = 1,
  int limit = 15,
  Map options = const {},
}) async {
  try {
    Map data = {
      "page": page,
      "limit": limit,
    };
    data.addAll(options);

    Response<dynamic> res =
        await NetworkHttp.post('/api/game/type', data: data);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 游戏 分类列表
Future<ResponseModel<dynamic>?> reqGameTag({
  int page = 1,
  int limit = 15,
  String tag = '',
  String type = 'hot',
}) async {
  try {
    Map data = {
      "page": page,
      "limit": limit,
      "tag": tag,
      "type": type,
    };

    Response<dynamic> res = await NetworkHttp.post('/api/game/tag', data: data);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取游戏详情
Future<ResponseModel<dynamic>?> reqGameDetail({String id = '0'}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/game/detail', data: {'id': id});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 游戏 购买
Future<ResponseModel<dynamic>?> reqGameBuy(
  BuildContext context, {
  dynamic id,
  int money = 0,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/game/buy', data: {
      "id": id,
    });
    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && money > 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(money);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//我推荐的换脸视频
Future<ResponseModel<dynamic>?> reqRecVideos({
  int status = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/my_video_face_material', data: {
      "status": status,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//我推荐的图片素材
Future<ResponseModel<dynamic>?> reqRecPics({
  int status = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/my_face_material', data: {
      "status": status,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//上传视频素材
Future<ResponseModel<dynamic>?> reqMateVideos({
  int cate_id = 0,
  String title = "",
  String thumb = "",
  String video = "",
  int width = 0,
  int height = 0,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/upload_video_face_material', data: {
      'cate_id': cate_id,
      'title': title,
      'thumb': thumb,
      'thumb_w': width,
      'thumb_h': height,
      'video': video,
    });

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//上传图片素材
Future<ResponseModel<dynamic>?> reqMatePics({
  int cate_id = 0,
  String title = "",
  String thumb = "",
  int width = 0,
  int height = 0,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/upload_face_material', data: {
      'cate_id': cate_id,
      'title': title,
      'thumb': thumb,
      'thumb_w': width,
      'thumb_h': height,
    });

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//我的去衣
Future<ResponseModel<dynamic>?> reqMyStrip({
  int status = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/ai/my_strip', data: {
      "status": status,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//我的生成视频
Future<ResponseModel<dynamic>?> reqMyAimagicVideo({
  int status = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aimagic/my_generate_video', data: {
      "status": status,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//删除生成的视频记录
Future<ResponseModel<dynamic>?> reqDelMyAimagic({String ids = ""}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/aimagic/del_generate_video',
        data: {"ids": ids});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//删除我的去衣
Future<ResponseModel<dynamic>?> reqDelMyStrip({String ids = ""}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/del_strip', data: {"ids": ids});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//我的图片换脸
Future<ResponseModel<dynamic>?> reqMyVideos({
  int status = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/my_video_face', data: {
      "status": status,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//删除我的图片换脸
Future<ResponseModel<dynamic>?> reqDelMyVideos({String ids = ""}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/del_video_face', data: {"ids": ids});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//我的图片换头
Future<ResponseModel<dynamic>?> reqMyFaces({
  int status = 0,
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/ai/my_face', data: {
      "status": status,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//删除我的图片换头
Future<ResponseModel<dynamic>?> reqDelMyFaces({String ids = ""}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/del_face', data: {"ids": ids});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//魔法素材列表
Future<ResponseModel<dynamic>?> reqGetAiMagicListMaterial({
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aimagic/list_material', data: {
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//魔法素材列表
Future<ResponseModel<dynamic>?> reqGenerateVideo(
    int material_id, String thumb, int thumb_w, int thumb_h) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aimagic/generate_video', data: {
      "material_id": material_id,
      "thumb": thumb,
      "thumb_w": "$thumb_w",
      "thumb_h": "$thumb_h",
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//图片列表
Future<ResponseModel<dynamic>?> reqGetPics({
  int cate_id = 0,
  int page = 1,
  int limit = 15,
  String sort = "desc",
  String type = "used",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/list_face_material', data: {
      "cate_id": cate_id,
      "page": page,
      "limit": limit,
      "sort": sort,
      "type": type,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//图片列表
Future<ResponseModel<dynamic>?> reqGetVideos({
  int cate_id = 0,
  int page = 1,
  int limit = 15,
  String sort = "asc",
  String type = "used",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/list_video_face_material', data: {
      "cate_id": cate_id,
      "page": page,
      "limit": limit,
      "sort": sort,
      "type": type,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//获取商品-VIP
Future<ResponseModel<dynamic>?> reqProductOfVIP() async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/order/goodsList', data: {'type': 1});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取可升级的VIP
Future<ResponseModel<dynamic>?> userUpgradeVIPGoods() async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/upgrade_goods');

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//升级VIP
Future<ResponseModel<dynamic>?> userVIPUpgrade({required int id}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/user/upgrade', data: {'id': id});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

///代理 收益明细
Future<ResponseModel<dynamic>?> getProxyProfitList(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/proxy/list', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//上报信息
Future<ResponseModel<dynamic>?> reqGetRequestInfo({
  String text = '',
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/home/error_report', data: {'text': text});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

//消费明细
Future<ResponseModel<dynamic>?> reqConsumption({
  int page = 1,
  String? last_ix,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/user/listMoneyDetail', data: {
      "last_ix": last_ix,
      "page": page,
      "limit": limit,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//Ad点击统计
Future<ResponseModel<dynamic>?> reqAdClickCount({int? id, int? type}) async {
  try {
    if (id == null || type == null) throw Exception('id or type not null');
    Response<dynamic> res =
        await NetworkHttp.post('/api/home/click_report', data: {
      'id': id,
      'type': type,
    });

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取全局config接口
Future<ResponseModel<ConfigModel>?> reqConfig(BuildContext context) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/home/config');

    ResponseModel<ConfigModel> tp = ResponseModel<ConfigModel>.fromJson(
        res.data, (json) => ConfigModel.fromJson(json));
    if (tp.data != null) {
      //存储基础数据
      Provider.of<BaseStore>(context, listen: false).setConf(tp.data!);
      AppGlobal.imgBaseUrl = tp.data?.config?.img_base ?? "";
      AppGlobal.uploadImgKey = tp.data?.config?.upload_img_key ?? "";
      AppGlobal.uploadImgUrl = tp.data?.config?.img_upload_url ?? "";
      AppGlobal.uploadMp4Key = tp.data?.config?.upload_mp4_key ?? "";
      AppGlobal.uploadMp4Url = tp.data?.config?.mp4_upload_url ?? "";
    }

    //seo设置
    if (kIsWeb) {
      final descTag = html.document.head!
          .querySelector('meta[name="description"]') as html.MetaElement?;
      final kwTag = html.document.head!.querySelector('meta[name="keywords"]')
          as html.MetaElement?;
      if (kwTag != null && descTag != null) {
        kwTag.content = tp.data?.keywords ?? "";
        descTag.content = tp.data?.description ?? "";
        html.document.title = tp.data?.title ?? "";
      }
    }

    return tp;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//上传失效地址
Future<ResponseModel<dynamic>?> reqReportLine({List? list}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/home/domainCheckReport',
        data: {"list": list});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// AI
Future<ResponseModel<dynamic>?> reqCharactorOptions() async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/character_opt');

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// AI 生成女友
Future<ResponseModel<dynamic>?> reqCharactorCreate(
    {dynamic name = "",
    dynamic figure = "",
    dynamic race = "",
    dynamic age = "",
    dynamic eye_color = "",
    dynamic hairstyle = "",
    dynamic hair_color = "",
    dynamic body_shape = "",
    dynamic breast_size = "",
    dynamic hip_size = "",
    dynamic personality = "",
    dynamic hobby = "",
    dynamic relation = "",
    dynamic clothes = "",
    int? money = 0,
    int? count = 0,
    BuildContext? context}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/generate', data: {
      "name": name,
      "figure": figure,
      "race": race,
      "age": age,
      "eye_color": eye_color,
      "hairstyle": hairstyle,
      "hair_color": hair_color,
      "body_shape": body_shape,
      "breast_size": breast_size,
      "hip_size": hip_size,
      "personality": personality,
      "hobby": hobby,
      "relation": relation,
      "clothes": clothes,
    });

    ResponseModel<dynamic>? result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && money != null && money >= 0) {
      Provider.of<BaseStore>(context!, listen: false).setMoney(money);
    }

    if (result.status == 1 && count != null && count >= 0) {
      Provider.of<BaseStore>(context!, listen: false).setCharacterValue(count);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// AI 女友详情
Future<ResponseModel<dynamic>?> reqCharactorDetail({
  dynamic id,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/detail', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);

    return null;
  }
}

Future<ResponseModel<dynamic>?> reqCharactorLike({int id = 0}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/like', data: {"id": id});
    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// AI女友列表
Future<ResponseModel<dynamic>?> reqCharactorList(
    {String tag = "", String sort = "", int page = 1}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/index', data: {
      "tag": tag,
      "sort": sort,
      'page': page,
      'limit': 15,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 我的AI女友列表
Future<ResponseModel<dynamic>?> reqMineCharactorList({int page = 1}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/my', data: {
      'page': page,
      'limit': 15,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// AI 开始聊天
Future<ResponseModel<dynamic>?> reqCharactorStartChat({
  dynamic id,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/start_chat', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// AI 聊天
Future<ResponseModel<dynamic>?> reqCharactorChat({
  dynamic id,
  dynamic text = "",
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/chat', data: {
      "id": id,
      "text": text,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 我的AI女友聊天历史记录
Future<ResponseModel<dynamic>?> reqMineCharactorHistoryList(
    {int id = 1}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/history', data: {
      'id': id,
      'page': 1,
      'limit': 1000, //一次性请求所有数据
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// AI 聊天扣费
Future<ResponseModel<dynamic>?> reqCharactoPay({
  dynamic id,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/aigirlfriend/pay', data: {
      "id": id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取用户信息数据
Future<ResponseModel<UserModel>?> reqUserInfo(BuildContext context) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/userInfo');

    ResponseModel<UserModel> tp = ResponseModel<UserModel>.fromJson(
        res.data, (json) => UserModel.fromJson(json));
    if (tp.data != null) {
      //存储用户数据
      Provider.of<BaseStore>(context, listen: false).setUser(tp.data!);
      AppGlobal.vipLevel = tp.data?.vip_level ?? 0;
    }
    return tp;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//填写邀请码
Future<ResponseModel<dynamic>?> reqInvitation({String? affCode}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/invitation',
        data: {'aff_code': affCode});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//兑换
Future<ResponseModel<dynamic>?> reqOnExchange({String? cdk}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/home/exchange', data: {'cdk': cdk});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//用户名注册
Future<ResponseModel<dynamic>?> reqLoginByReg({
  String username = "",
  String password = "",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/account/registerByPassword',
        data: {'username': username, 'password': password});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//用户名登录
Future<ResponseModel<dynamic>?> reqLoginByAccount({
  String username = "",
  String password = "",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/account/loginByPassword',
        data: {'username': username, 'password': password});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//修改用户头像、昵称、签名
Future<ResponseModel<dynamic>?> reqUpdateUserInfo({
  String nickname = "",
  String thumb = "",
  String intro = "",
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/updateUserInfo',
        data: {'nickname': nickname, 'thumb': thumb, 'intro': intro});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//清除线上缓存
Future<ResponseModel<dynamic>?> reqClearCached() async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/user/clear_cached');

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//联系官方
Future<ResponseModel<dynamic>?> reqContactList() async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/home/getContactList');

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//生成换头模版AI
Future<ResponseModel<dynamic>?> reqFaceModuleAI(
  BuildContext context, {
  String ground = "",
  int ground_w = 0,
  int ground_h = 0,
  String thumb = "",
  int thumb_w = 0,
  int thumb_h = 0,
  int coins = 0,
  int faceValue = 0,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/customize_face', data: {
      'ground': ground,
      'ground_w': ground_w,
      'ground_h': ground_h,
      'thumb': thumb,
      'thumb_w': thumb_w,
      'thumb_h': thumb_h,
    });

    ResponseModel<dynamic> result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && coins >= 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(coins);
    }
    if (result.status == 1 && faceValue >= 0) {
      Provider.of<BaseStore>(context, listen: false)
          .setImageFaceValue(faceValue);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//生成换头AI
Future<ResponseModel<dynamic>?> reqFaceAI(
  BuildContext context, {
  int id = 0,
  String thumb = "",
  int width = 0,
  int height = 0,
  int coins = 0,
  int faceValue = 0,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/change_face', data: {
      'material_id': id,
      'thumb': thumb,
      'thumb_w': width,
      'thumb_h': height,
    });

    ResponseModel<dynamic> result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && coins >= 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(coins);
    }

    if (result.status == 1 && faceValue >= 0) {
      Provider.of<BaseStore>(context, listen: false)
          .setImageFaceValue(faceValue);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//生成换脸AI
Future<ResponseModel<dynamic>?> reqFaceVideoAI(
  BuildContext context, {
  int id = 0,
  String thumb = "",
  int width = 0,
  int height = 0,
  int coins = 0,
  int faceValue = 0,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/ai/change_video_face', data: {
      'material_id': id,
      'thumb': thumb,
      'thumb_w': width,
      'thumb_h': height,
    });

    ResponseModel<dynamic> result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && coins >= 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(coins);
    }

    if (result.status == 1 && faceValue >= 0) {
      Provider.of<BaseStore>(context, listen: false)
          .setVideoFaceValue(faceValue);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//生成脱衣AI
Future<ResponseModel<dynamic>?> reqStripAI(
  BuildContext context, {
  String thumb = "",
  int width = 0,
  int height = 0,
  int coins = 0,
  int remainValue = 0,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/ai/strip', data: {
      'thumb': thumb,
      'thumb_w': width,
      'thumb_h': height,
    });

    ResponseModel<dynamic> result =
        ResponseModel<dynamic>.fromJson(res.data, (json) => json);
    if (result.status == 1 && coins >= 0) {
      Provider.of<BaseStore>(context, listen: false).setMoney(coins);
    }
    if (result.status == 1 && remainValue >= 0) {
      Provider.of<BaseStore>(context, listen: false).setStripValue(remainValue);
    }
    return result;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取反馈列表
Future<ResponseModel<dynamic>?> reqChatList({int page = 1}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/message/feedback', data: {'page': page});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//发送反馈信息
Future<ResponseModel<dynamic>?> reqSendContent(
  String content,
  int type,
  int helpType,
) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/message/feeding',
        data: {'content': content, 'type': type, 'helpType': helpType});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取消息读取状态
Future<ResponseModel<SysNoticeModel>?> reqSystemNotice(
    BuildContext context) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/message/getUnreadCount');

    ResponseModel<SysNoticeModel> tp = ResponseModel<SysNoticeModel>.fromJson(
        res.data, (json) => SysNoticeModel.fromJson(json));
    if (tp.data != null) {
      Provider.of<BaseStore>(context, listen: false).setNotice(tp.data!);
    }
    return tp;
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取消息列表
Future<ResponseModel<dynamic>?> reqSystemNoticeList({
  int page = 1,
  int limit = 15,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post(
        '/api/message/getSystemNoticeList',
        data: {'page': page, 'limit': limit});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//获取商品VIP
Future<ResponseModel<dynamic>?> reqProductOfVipOrGold({int type = 1}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/order/goodsList', data: {'type': type});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

// 扣币兑换
Future<ResponseModel<dynamic>?> reqOrderExchange({
  int product_id = 0,
}) async {
  try {
    Response<dynamic> res = await NetworkHttp.post('/api/order/exchange',
        data: {'product_id': product_id});

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//在线支付
Future<ResponseModel<dynamic>?> reqCreatePaying({
  String pay_way = "",
  String pay_type = "",
  int product_id = 0,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/order/createPaying', data: {
      'pay_way': pay_way,
      'pay_type': pay_type,
      'product_id': product_id,
    });

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//充值记录
Future<ResponseModel<dynamic>?> reqOrderList({
  int page = 1,
  dynamic type = '1',
  int limit = 15,
}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post("/api/order/orderList", data: {
      'limit': limit,
      'page': page,
      'type': type,
    });

    return ResponseModel<dynamic>.fromJson(res.data, (json) => json);
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

///代理 推广数据 | 等级信息
Future<ResponseModel<dynamic>?> getProxyDetail() async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/proxy/detail', data: {});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    Utils.log(e);
    return null;
  }
}

//收益明细
Future<ResponseModel<dynamic>?> getEarnProfitList({Map? reqdata}) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/user/list_income_log', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///代理 申请代理
Future<ResponseModel<dynamic>?> applyProxyWithContact(String contact) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/proxy/apply', data: {'contact': contact});

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///代理 邀请记录
Future<ResponseModel<dynamic>?> getProxyInviteRecord(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/proxy/list_log', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///提现  添加银行卡
Future<ResponseModel<dynamic>?> cashAddBankCard(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/user/add_bankcard', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///提现  银行卡列表
Future<ResponseModel<dynamic>?> cashBankCardList(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/user/list_bankcard', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///提现  删除银行卡
Future<ResponseModel<dynamic>?> cashDeleteBankCard(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/user/del_bankcard', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///提现  申请提现
Future<ResponseModel<dynamic>?> cashApplyWithdraw(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/order/withdraw', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///提现  收益 申请提现
Future<ResponseModel<dynamic>?> incomeApplyWithdraw(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/order/withdraw', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///提现 规则
Future<ResponseModel<dynamic>?> cashWithdrawRule(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/withdraw/index', data: reqdata);

    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}

///提现  提现列表
Future<ResponseModel<dynamic>?> cashWithdrawList(Map reqdata) async {
  try {
    Response<dynamic> res =
        await NetworkHttp.post('/api/order/listWithdraw', data: reqdata);
    return ResponseModel<dynamic>.fromJson(res.data, ((json) => json));
  } catch (e) {
    return null;
  }
}
