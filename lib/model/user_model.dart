import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  UserModel({
    this.uid,
    this.uuid,
    this.username,
    this.created_at,
    this.updated_at,
    this.role_id,
    this.gender,
    this.regip,
    this.regdate,
    this.lastip,
    this.expired_at,
    this.lastpost,
    this.oltime,
    this.pageviews,
    this.score,
    this.aff,
    this.channel,
    this.invited_by,
    this.invited_num,
    this.ban_post,
    this.post_num,
    this.login_count,
    this.app_version,
    this.validate,
    this.thumb,
    this.coins,
    this.money,
    this.proxy_money,
    this.vip_level,
    this.auth_status,
    this.exp,
    this.chat_uid,
    this.phone,
    this.phone_prefix,
    this.free_view_cnt,
    this.income_money,
    this.lastactivity,
    this.income_total,
    this.post_count,
    this.topic_count,
    this.follow_count,
    this.tags,
    this.fans_count,
    this.new_user,
    this.share,
    this.nickname,
    this.point,
    this.broker_auth,
    this.girl_auth,
    this.unread_reply,
    this.post_club_month,
    this.post_club_quarter,
    this.post_club_year,
    this.post_club_total,
    this.post_club_number_num,
    this.is_fans,
    this.post_club_id,
    this.is_club_pop,
    this.vip_str,
    // this.pass,
    this.agent,
    this.video_download_value,
    this.video_long_down_type,
    this.video_long_down_value,
    this.video_short_down_type,
    this.video_short_down_value,
    this.voice_down_type,
    this.voice_down_value,
    this.img_face_type,
    this.img_face_value,
    this.video_face_type,
    this.video_face_value,
    this.strip_type,
    this.strip_value,
    this.cartoon_down_type,
    this.cartoon_down_value,
    this.ai_girlfriend_create_type,
    this.ai_girlfriend_create_value,
    this.ai_girlfriend_chat_type,
    this.ai_girlfriend_chat_value,
    this.is_set_password,
    this.vip_upgrade,
    this.aw_privilege
  });
  int? aw_privilege;
  int? vip_upgrade;
  String? vip_str;
  int? post_club_id;
  int? uid;
  int? is_fans;
  String? uuid;
  String? username;
  String? nickname;
  String? created_at;
  String? updated_at;
  int? role_id;
  int? gender;
  // int? pass;
  int? video_download_value;

  int? video_long_down_type;
  int? video_long_down_value;
  int? video_short_down_type;
  int? video_short_down_value;
  int? voice_down_type;
  int? voice_down_value;
  int? img_face_type;
  int? img_face_value;
  int? video_face_type;
  int? video_face_value;

  int? strip_type;
  int? strip_value;
  int? cartoon_down_type;
  int? cartoon_down_value;
  int? ai_girlfriend_create_type;
  int? ai_girlfriend_create_value;
  int? ai_girlfriend_chat_type;
  int? ai_girlfriend_chat_value;
  int? is_set_password;
  String? regip;
  String? regdate;
  String? lastip;
  String? expired_at;
  int? lastpost;
  int? oltime;
  int? pageviews;
  int? score;
  int? aff;
  String? channel;
  String? invited_by;
  int? invited_num;
  int? ban_post;
  int? post_num;
  int? login_count;
  String? app_version;
  int? validate;
  String? thumb;
  int? coins;
  int? money;
  String? proxy_money;
  int? vip_level;
  int? auth_status;
  int? broker_auth;
  int? girl_auth;
  int? exp;
  int? point;
  String? chat_uid;
  String? phone;
  String? phone_prefix;
  int? free_view_cnt;
  String? lastactivity;
  int? income_total;
  int? income_money;
  int? post_count;
  int? topic_count;
  int? follow_count;
  String? tags;
  int? fans_count;
  bool? new_user;
  int? unread_reply;
  int? post_club_month;
  int? post_club_quarter;
  int? post_club_year;
  int? post_club_total;
  int? post_club_number_num;
  int? is_club_pop;
  int? agent;

  ShareModel? share;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        aw_privilege: json['aw_privilege'] ?? 0,
        vip_upgrade: json['vip_upgrade'] ?? 0,
        post_club_id: json['post_club_id'] ?? 0,
        uid: json['uid'] ?? 0,
        is_fans: json['is_fans'] ?? 0,
        uuid: json['uuid'] ?? "",
        username: json['username'] ?? "",
        nickname: json['nickname'] ?? "",
        created_at: json['created_at'] ?? "",
        role_id: json['role_id'] ?? 0,
        gender: json['gender'] ?? 0,
        regip: json['regip'] ?? "",
        regdate: json['regdate'] ?? "",
        lastip: json['lastip'] ?? "",
        expired_at: json['expired_at'] ?? "",
        lastpost: json['lastpost'] ?? 0,
        oltime: json['oltime'] ?? 0,
        agent: json['agent'] ?? 0,
        pageviews: json['pageviews'] ?? 0,
        score: json['score'] ?? 0,
        aff: json['aff'] ?? 0,
        channel: json['channel'] ?? "",
        invited_by: "${json['invited_by'] ?? ""}",
        invited_num: json['invited_num'] ?? 0,
        ban_post: json['ban_post'] ?? 0,
        post_num: json['post_num'] ?? 0,
        login_count: json['login_count'] ?? 0,
        app_version: json['app_version'] ?? "",
        validate: json['validate'] ?? 0,
        thumb: json['thumb'] ?? "",
        coins: json['coins'] ?? 0,
        money: json['money'] ?? 0,
        proxy_money: json['proxy_money'] ?? "",
        vip_level: json['vip_level'] ?? 0,
        auth_status: json['auth_status'] ?? 0,
        broker_auth: json['broker_auth'] ?? 0,
        girl_auth: json['girl_auth'] ?? 0,
        exp: json['exp'] ?? 0,
        point: json['point'] ?? 0,
        chat_uid: json['chat_uid'] ?? "",
        phone: json['phone'] ?? "",
        phone_prefix: json['phone_prefix'] ?? "",
        free_view_cnt: json['free_view_cnt'] ?? 0,
        income_money: json['income_money'] ?? 0,
        lastactivity: json['lastactivity'] ?? "",
        unread_reply: json['unread_reply'] ?? 0,
        income_total: json['income_total'] ?? 0,
        post_count: json['post_count'] ?? 0,
        topic_count: json['topic_count'] ?? 0,
        follow_count: json['follow_count'] ?? 0,
        tags: json['tags'] ?? "",
        fans_count: json['fans_count'] ?? 0,
        post_club_month: json['post_club_month'] ?? 0,
        post_club_quarter: json['post_club_quarter'] ?? 0,
        post_club_year: json['post_club_year'] ?? 0,
        post_club_total: json['post_club_total'] ?? 0,
        post_club_number_num: json['post_club_number_num'] ?? 0,
        new_user: json['new_user'] ?? false,
        share: json['share'] == null || json['share'] == 0
            ? null
            : ShareModel.fromJson(json['share']),
        vip_str: json['vip_str'] ?? '',
        is_club_pop: json["is_club_pop"] ?? 0,
        // pass: json["pass"] ?? 0,
        video_download_value: json["video_download_value"] ?? 0,
        video_long_down_type: json["video_long_down_type"] ?? 0,
        video_long_down_value: json["video_long_down_value"] ?? 0,
        video_short_down_type: json["video_short_down_type"] ?? 0,
        video_short_down_value: json["video_short_down_value"] ?? 0,
        voice_down_type: json["voice_down_type"] ?? 0,
        voice_down_value: json["voice_down_value"] ?? 0,
        img_face_type: json["img_face_type"] ?? 0,
        img_face_value: json["img_face_value"] ?? 0,
        video_face_type: json["video_face_type"] ?? 0,
        video_face_value: json["video_face_value"] ?? 0,
        strip_type: json["strip_type"] ?? 0,
        strip_value: json["strip_value"] ?? 0,
        cartoon_down_type: json["cartoon_down_type"] ?? 0,
        cartoon_down_value: json["cartoon_down_value"] ?? 0,
        ai_girlfriend_create_type: json["ai_girlfriend_create_type"] ?? 0,
        ai_girlfriend_create_value: json["ai_girlfriend_create_value"] ?? 0,
        ai_girlfriend_chat_type: json["ai_girlfriend_chat_type"] ?? 0,
        ai_girlfriend_chat_value: json["ai_girlfriend_chat_value"] ?? 0,
        is_set_password: json["is_set_password"] ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'aw_privilege': aw_privilege,
        'vip_upgrade': vip_upgrade,
        "post_club_id": post_club_id,
        "uid": uid,
        "is_fans": is_fans,
        "agent": agent,
        "uuid": uuid,
        "username": username,
        "nickname": nickname,
        "created_at": created_at,
        "role_id": role_id,
        "gender": gender,
        "regip": regip,
        "regdate": regdate,
        "lastip": lastip,
        "expired_at": expired_at,
        "lastpost": lastpost,
        "oltime": oltime,
        "pageviews": pageviews,
        "score": score,
        "aff": aff,
        "channel": channel,
        "invited_by": invited_by,
        "invited_num": invited_num,
        "ban_post": ban_post,
        "post_num": post_num,
        "login_count": login_count,
        "app_version": app_version,
        "validate": validate,
        "thumb": thumb,
        "coins": coins,
        "money": money,
        "proxy_money": proxy_money,
        "vip_level": vip_level,
        "auth_status": auth_status,
        "broker_auth": broker_auth,
        "girl_auth": girl_auth,
        "exp": exp,
        "point": point,
        "chat_uid": chat_uid,
        "phone": phone,
        "phone_prefix": phone_prefix,
        "free_view_cnt": free_view_cnt,
        "lastactivity": lastactivity,
        "unread_reply": unread_reply,
        "income_total": income_total,
        "income_money": income_money,
        "post_count": post_count,
        "topic_count": topic_count,
        "follow_count": follow_count,
        "tags": tags,
        "fans_count": fans_count,
        "new_user": new_user,
        "post_club_month": post_club_month,
        "post_club_quarter": post_club_quarter,
        "post_club_year": post_club_year,
        "post_club_total": post_club_total,
        "post_club_number_num": post_club_number_num,
        "share": share?.toJson(),
        "vip_str": vip_str,
        "is_club_pop": is_club_pop,
        // "pass": pass,
        "video_download_value": video_download_value,
        "video_long_down_type": video_long_down_type,
        "video_long_down_value": video_long_down_value,
        "video_short_down_type": video_short_down_type,
        "video_short_down_value": video_short_down_value,
        "voice_down_type": voice_down_type,
        "voice_down_value": voice_down_value,
        "img_face_type": img_face_type,
        "img_face_value": img_face_value,
        "video_face_type": video_face_type,
        "video_face_value": video_face_value,
        "strip_type": strip_type,
        "strip_value": strip_value,
        "cartoon_down_type": cartoon_down_type,
        "cartoon_down_value": cartoon_down_value,
        "ai_girlfriend_create_type": ai_girlfriend_create_type,
        "ai_girlfriend_create_value": ai_girlfriend_create_value,
        "ai_girlfriend_chat_type": ai_girlfriend_chat_type,
        "ai_girlfriend_chat_value": ai_girlfriend_chat_value,
        "is_set_password": is_set_password,
      };
}

@JsonSerializable(explicitToJson: true)
class ShareModel {
  ShareModel({this.aff_code, this.share_url, this.share_text});
  String? aff_code;
  String? share_url;
  String? share_text;

  factory ShareModel.fromJson(Map<String, dynamic> json) => ShareModel(
        aff_code: json['aff_code'] ?? "",
        share_url: json['share_url'] ?? "",
        share_text: json['share_text'] ?? "",
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        "aff_code": aff_code,
        "share_url": share_url,
        "share_text": share_text,
      };
}

@JsonSerializable(explicitToJson: true)
class ActivityModel {
  ActivityModel({this.ad_big, this.ad1, this.ad2});

// ad_big = 奖励公告
// ad1 = 第一个
// ad2 = 第二个
  dynamic ad_big;
  dynamic ad1;
  dynamic ad2;

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        ad_big: json['ad_big'],
        ad1: json['ad1'],
        ad2: json['ad2'],
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        "ad_big": ad_big,
        "ad1": ad1,
        "ad2": ad2,
      };
}
