// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class BconfModel {
  BconfModel({
    this.img_upload_url,
    this.mp4_upload_url,
    this.mobile_mp4_upload_url,
    this.upload_img_key,
    this.upload_mp4_key,
    this.office_site,
    this.official_group,
    this.lines_url,
    this.tips_share_text,
    this.solution,
    this.proxy_join_num,
    this.img_base,
    this.github_url,
    this.custom_create_price,
    this.custom_custom_price,
    this.girl_unlock_price,
    this.forever_www,
    this.post_rule,
    this.tg_up_auth,
    this.days,
    this.strip_coins,
    this.img_coins,
    this.video_coins,
    this.upload_max,
    this.nav_id,
    this.aw_id,
    this.sort_nav,
    this.wdai_str,
    this.forum_nav,
    this.pay_ai,
    this.vip_level_str,
    this.vip_name_str,
  });
  String? img_upload_url;
  String? mp4_upload_url;
  String? mobile_mp4_upload_url;
  String? upload_img_key;
  String? upload_mp4_key;
  String? office_site;
  String? official_group;
  List<String>? lines_url;
  String? tips_share_text;
  String? forever_www;
  String? solution;
  int? proxy_join_num;
  String? img_base;
  String? github_url;
  int? custom_create_price;
  int? custom_custom_price;
  int? girl_unlock_price;
  String? post_rule;
  String? tg_up_auth;
  int? days;
  int? strip_coins;//每次脱衣金币数
  int? upload_max;
  int? img_coins;//每次图片换脸金币数
  int? video_coins;//每次视频换脸金币数
  int? nav_id;
  int? aw_id;
  List<dynamic>? sort_nav;
  String? wdai_str;
  List<dynamic>? forum_nav;
  int? pay_ai;

  List<String>? vip_level_str;
  String? vip_name_str;

  factory BconfModel.fromJson(Map<String, dynamic> json) => BconfModel(
        img_upload_url: json['img_upload_url'] ?? "",
        mp4_upload_url: json['mp4_upload_url'] ?? "",
        mobile_mp4_upload_url: json['mobile_mp4_upload_url'] ?? "",
        upload_img_key: json['upload_img_key'] ?? "",
        upload_mp4_key: json['upload_mp4_key'] ?? "",
        office_site: json['office_site'] ?? "",
        official_group: json['official_group'] ?? "",
        forever_www: json['forever_www'] ?? "",
        lines_url: json['lines_url'] == null
            ? []
            : List<String>.from(json['lines_url'].map((x) => x)),
        sort_nav: json["sort_nav"] == null
            ? []
            : List<dynamic>.from(json["sort_nav"].map((x) => x)),
        tips_share_text: json['tips_share_text'] ?? "",
        solution: json['solution'] ?? "",
        proxy_join_num: json['proxy_join_num'] ?? 0,
        img_base: json['img_base'] ?? "",
        github_url: json['github_url'] ?? "",
        custom_create_price: json["custom_create_price"] ?? 0,
        custom_custom_price: json["custom_custom_price"] ?? 0,
        girl_unlock_price: json["girl_unlock_price"] ?? 0,
        post_rule: json["post_rule"] ?? "",
        tg_up_auth: json["tg_up_auth"] ?? "",
        days: json["days"] ?? 10,
        strip_coins: json["strip_coins"] ?? 0,
        upload_max: json["upload_max"] ?? 30,
        img_coins: json["img_coins"] ?? 0,
        video_coins: json["video_coins"] ?? 0,
        nav_id: json['nav_id'] ?? 1,
        aw_id: json['aw_id'] ?? 1,
        wdai_str: json['wdai_str'] ?? '',
        forum_nav: json["forum_nav"] == null
            ? []
            : List<dynamic>.from(json["forum_nav"].map((x) => x)),
        pay_ai: json['pay_ai'] ?? 0,
        vip_level_str: json["vip_level_str"] == null
            ? []
            : List<String>.from(json["vip_level_str"].map((x) => x.toString())),
        vip_name_str: json['vip_name_str'] ?? "",
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "img_upload_url": img_upload_url,
        "mp4_upload_url": mp4_upload_url,
        "mobile_mp4_upload_url": mobile_mp4_upload_url,
        "upload_img_key": upload_img_key,
        "upload_mp4_key": upload_mp4_key,
        "forever_www": forever_www,
        "office_site": office_site,
        "official_group": official_group,
        "lines_url": lines_url?.map((e) => e),
        "tips_share_text": tips_share_text,
        "solution": solution,
        "proxy_join_num": proxy_join_num,
        "img_base": img_base,
        "github_url": github_url,
        "custom_create_price": custom_create_price,
        "custom_custom_price": custom_custom_price,
        "girl_unlock_price": girl_unlock_price,
        "post_rule": post_rule,
        "tg_up_auth": tg_up_auth,
        "days": days,
        "strip_coins": strip_coins,
        "upload_max": upload_max,
        "img_coins": img_coins,
        "video_coins": video_coins,
        "nav_id": nav_id,
        "aw_id": aw_id,
        "sort_nav":
            sort_nav == null ? [] : List<dynamic>.from(sort_nav!.map((x) => x)),
        "wdai_str": wdai_str,
        "forum_nav": forum_nav == null
            ? []
            : List<dynamic>.from(forum_nav!.map((x) => x)),
        "pay_ai": pay_ai,
        "vip_level_str": vip_level_str,
        "vip_name_str": vip_name_str,
      };
}
