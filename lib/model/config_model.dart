import 'package:deepseek/model/ads_model.dart';
import 'package:deepseek/model/bconf_model.dart';
import 'package:deepseek/model/help_model.dart';
import 'package:deepseek/model/alert_ads_model.dart';
import 'package:deepseek/model/version_model.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class ConfigModel {
  ConfigModel({
    this.timestamp,
    this.help,
    this.config,
    this.versionMsg,
    this.ads,
    this.pop_ads,
    this.face_nav,
    this.video_nav,
    this.video_sort,
    this.face_sort,
    this.nav_prepend,
    this.nav_prepend_default,
    this.mv_discover_sort_nav,
    this.mv_second_sort_nav,
    this.voice_nav,
    this.voice_sort_nav,
    this.vlog_tag_sort_nav,
    this.vlog_discover_sort_nav,
    this.featured_nav,
    this.acg_nav,
    this.cartoon_top_nav,
    this.cartoon_sort_nav,
    this.comic_top_nav,
    this.comic_sort_nav,
    this.game_top_nav,
    this.game_sort_nav,
    this.game_tag_sort_nav,
    this.comic_type_nav,
    this.novel_nav,
    this.novel_sort,
    this.novel_type_nav,
    this.album_nav,
    this.album_sort,
    this.album_tag_sort,
    this.star_filter_nav,
    this.star_sort_nav,
    this.star_mv_sort_nav,
    this.vlog_sort_nav,
    this.ai_girlfriend_sort,
    this.ai_girlfriend_tag,
    this.character_coins,
    this.ai_girlfriend_chat_coins,
    this.ai_girlfriend_chat_msg_ct,
    this.girl_sort,
    this.chat_nav,
    this.chat_select_nav,
    this.notice_app,
    this.start_screen_ads,
    this.pwaDownloadUrl,
    this.r2URL,
    this.r2Key,
    this.r2CompleteURL,
    this.pwa_apk,
    this.keywords,
    this.description,
    this.title,
    this.adVersion,
    this.buoy,
  });

  int? timestamp;
  List<ItemsModel>? help;
  BconfModel? config;
  List<AlertAdsModel>? pop_ads;
  VersionModel? versionMsg;
  AdsModel? ads;
  List<dynamic>? face_nav;
  List<dynamic>? video_nav;
  List<dynamic>? video_sort;
  List<dynamic>? face_sort;
  List<dynamic>? nav_prepend;
  int? nav_prepend_default;
  List<dynamic>? mv_discover_sort_nav;
  List<dynamic>? mv_second_sort_nav;
  List<dynamic>? voice_nav;
  List<dynamic>? voice_sort_nav;
  List<dynamic>? vlog_tag_sort_nav;
  List<dynamic>? vlog_discover_sort_nav;
  List<dynamic>? featured_nav;
  List<dynamic>? acg_nav;
  List<dynamic>? cartoon_top_nav;
  List<dynamic>? cartoon_sort_nav;
  List<dynamic>? comic_top_nav;
  List<dynamic>? comic_sort_nav;
  List<dynamic>? game_top_nav;
  List<dynamic>? game_sort_nav;
  List<dynamic>? game_tag_sort_nav;
  List<dynamic>? comic_type_nav;
  List<dynamic>? novel_nav;
  List<dynamic>? novel_sort;
  List<dynamic>? novel_type_nav;
  List<dynamic>? album_nav;
  List<dynamic>? album_sort;
  List<dynamic>? album_tag_sort;
  List<dynamic>? star_filter_nav;
  List<dynamic>? star_sort_nav;
  List<dynamic>? star_mv_sort_nav;
  List<dynamic>? vlog_sort_nav;
  List<dynamic>? ai_girlfriend_sort;
  List<dynamic>? ai_girlfriend_tag;
  int? character_coins;
  int? ai_girlfriend_chat_coins;
  int? ai_girlfriend_chat_msg_ct;

  List<dynamic>? girl_sort;
  List<dynamic>? chat_nav;
  List<dynamic>? chat_select_nav;

  List<dynamic>? notice_app;
  List<AdsModel>? start_screen_ads;
  final String? pwaDownloadUrl;
  List<AdsModel>? buoy;

  //R2分片上传
  final String? r2URL;
  final String? r2Key;
  final String? r2CompleteURL;

  //paw_apk下载
  final String? pwa_apk;

  //seo
  final String? keywords;
  final String? description;
  final String? title;

  final int? adVersion;

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        buoy: json["buoy"] == null
            ? []
            : List.from(json["buoy"])
            .map((e) => AdsModel.fromJson(e))
            .toList(),
        timestamp: json['timestamp'] ?? 0,
        help: json['help'] == null
            ? []
            : List<ItemsModel>.from(
                json['help'].map((x) => ItemsModel.fromJson(x))),
        face_nav: List.from(json['face_nav'] ?? []),
        video_nav: List.from(json['video_nav'] ?? []),
        video_sort: List.from(json['video_sort'] ?? []),
        face_sort: List.from(json['face_sort'] ?? []),
        nav_prepend: List.from(json['nav_prepend'] ?? []),
        nav_prepend_default: json['nav_prepend_default'] ?? 0,
        mv_discover_sort_nav: List.from(json['mv_discover_sort_nav'] ?? []),
        mv_second_sort_nav: List.from(json['mv_second_sort_nav'] ?? []),
        voice_nav: json["voice_nav"] == null
            ? []
            : List<dynamic>.from(json["voice_nav"].map((x) => x)),
        voice_sort_nav: json["voice_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["voice_sort_nav"].map((x) => x)),
        vlog_tag_sort_nav: json["vlog_tag_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["vlog_tag_sort_nav"].map((x) => x)),
        vlog_discover_sort_nav: json["vlog_discover_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["vlog_discover_sort_nav"].map((x) => x)),
        featured_nav: json["featured_nav"] == null
            ? []
            : List<dynamic>.from(json["featured_nav"].map((x) => x)),
        acg_nav: json["acg_nav"] == null
            ? []
            : List<dynamic>.from(json["acg_nav"].map((x) => x)),
        cartoon_top_nav: json["cartoon_top_nav"] == null
            ? []
            : List<dynamic>.from(json["cartoon_top_nav"].map((x) => x)),
        cartoon_sort_nav: json["cartoon_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["cartoon_sort_nav"].map((x) => x)),
        comic_top_nav: json["comic_top_nav"] == null
            ? []
            : List<dynamic>.from(json["comic_top_nav"].map((x) => x)),
        comic_sort_nav: json["comic_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["comic_sort_nav"].map((x) => x)),
        game_top_nav: json["game_top_nav"] == null
            ? []
            : List<dynamic>.from(json["game_top_nav"].map((x) => x)),
        game_sort_nav: json["game_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["game_sort_nav"].map((x) => x)),
        game_tag_sort_nav: json["game_tag_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["game_tag_sort_nav"].map((x) => x)),
        comic_type_nav: json["comic_type_nav"] == null
            ? []
            : List<dynamic>.from(json["comic_type_nav"].map((x) => x)),
        novel_nav: json["novel_nav"] == null
            ? []
            : List<dynamic>.from(json["novel_nav"].map((x) => x)),
        novel_sort: json["novel_sort"] == null
            ? []
            : List<dynamic>.from(json["novel_sort"].map((x) => x)),
        novel_type_nav: json["novel_type_nav"] == null
            ? []
            : List<dynamic>.from(json["novel_type_nav"].map((x) => x)),
        album_nav: json["album_nav"] == null
            ? []
            : List<dynamic>.from(json["album_nav"].map((x) => x)),
        album_sort: json["album_sort"] == null
            ? []
            : List<dynamic>.from(json["album_sort"].map((x) => x)),
        album_tag_sort: json["album_tag_sort"] == null
            ? []
            : List<dynamic>.from(json["album_tag_sort"].map((x) => x)),
        star_filter_nav: json["star_filter_nav"] == null
            ? []
            : List<dynamic>.from(json["star_filter_nav"].map((x) => x)),
        star_sort_nav: json["star_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["star_sort_nav"].map((x) => x)),
        star_mv_sort_nav: json["star_mv_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["star_mv_sort_nav"].map((x) => x)),
        vlog_sort_nav: json["vlog_sort_nav"] == null
            ? []
            : List<dynamic>.from(json["vlog_sort_nav"].map((x) => x)),
        ai_girlfriend_sort: json["ai_girlfriend_sort"] == null
            ? []
            : List<dynamic>.from(json["ai_girlfriend_sort"].map((x) => x)),
        ai_girlfriend_tag: json["ai_girlfriend_tag"] == null
            ? []
            : List<dynamic>.from(json["ai_girlfriend_tag"].map((x) => x)),
        character_coins: json['character_coins'] ?? 0,
        ai_girlfriend_chat_coins: json['ai_girlfriend_chat_coins'] ?? 0,
        ai_girlfriend_chat_msg_ct: json['ai_girlfriend_chat_msg_ct'] ?? 0,
        config:
            json['config'] == null ? null : BconfModel.fromJson(json['config']),
        versionMsg: json['versionMsg'] == null
            ? null
            : VersionModel.fromJson(json['versionMsg']),
        ads: json['ads'] == null ? null : AdsModel.fromJson(json['ads']),
        pop_ads: json['pop_ads'] == null
            ? []
            : List<AlertAdsModel>.from(
                json['pop_ads'].map((x) => AlertAdsModel.fromJson(x))),
        girl_sort: json["girl_sort"] == null
            ? []
            : List<dynamic>.from(json["girl_sort"].map((x) => x)),
        chat_nav: json["chat_nav"] == null
            ? []
            : List<dynamic>.from(json["chat_nav"].map((x) => x)),
        chat_select_nav: json["chat_select_nav"] == null
            ? []
            : List<dynamic>.from(json["chat_select_nav"].map((x) => x)),
        notice_app:
            json["notice_app"] == null ? [] : List.from(json["notice_app"]),
        start_screen_ads: json["start_screen_ads"] == null
            ? []
            : List.from(json["start_screen_ads"])
                .map((e) => AdsModel.fromJson(e))
                .toList(),
        pwaDownloadUrl: json['pwa_download_url'] ?? '',
        r2URL: json['r2URL'] ?? '',
        r2Key: json['r2Key'] ?? '',
        r2CompleteURL: json['r2CompleteURL'] ?? '',
        pwa_apk: json['pwa_apk'] ?? '',
        keywords: json['keywords'] ?? '',
        description: json['description'] ?? '',
        title: json['title'] ?? '',
        adVersion: json['ad_version'] ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "buoy": buoy?.map((e) => e.toJson()).toList(),
        "timestamp": timestamp,
        "help": help?.map((e) => e.toJson()),
        "config": config?.toJson(),
        "versionMsg": versionMsg?.toJson(),
        "ads": ads?.toJson(),
        "pop_ads": pop_ads?.map((e) => e.toJson()),
        "face_nav": face_nav,
        "video_nav": video_nav,
        "video_sort": video_sort,
        "face_sort": face_sort,
        "nav_prepend": nav_prepend,
        "nav_prepend_default": nav_prepend_default,
        "mv_discover_sort_nav": mv_discover_sort_nav,
        "mv_second_sort_nav": mv_second_sort_nav,
        "voice_nav": voice_nav == null
            ? []
            : List<dynamic>.from(voice_nav!.map((x) => x)),
        "voice_sort_nav": voice_sort_nav == null
            ? []
            : List<dynamic>.from(voice_sort_nav!.map((x) => x)),
        "vlog_tag_sort_nav": vlog_tag_sort_nav == null
            ? []
            : List<dynamic>.from(vlog_tag_sort_nav!.map((x) => x)),
        "vlog_discover_sort_nav": vlog_discover_sort_nav == null
            ? []
            : List<dynamic>.from(vlog_discover_sort_nav!.map((x) => x)),
        "featured_nav": featured_nav == null
            ? []
            : List<dynamic>.from(featured_nav!.map((x) => x)),
        "acg_nav":
            acg_nav == null ? [] : List<dynamic>.from(acg_nav!.map((x) => x)),
        "cartoon_top_nav": cartoon_top_nav == null
            ? []
            : List<dynamic>.from(cartoon_top_nav!.map((x) => x)),
        "cartoon_sort_nav": cartoon_sort_nav == null
            ? []
            : List<dynamic>.from(cartoon_sort_nav!.map((x) => x)),
        "comic_top_nav": comic_top_nav == null
            ? []
            : List<dynamic>.from(comic_top_nav!.map((x) => x)),
        "comic_sort_nav": comic_sort_nav == null
            ? []
            : List<dynamic>.from(comic_sort_nav!.map((x) => x)),
        "game_top_nav": game_top_nav == null
            ? []
            : List<dynamic>.from(game_top_nav!.map((x) => x)),
        "game_sort_nav": game_sort_nav == null
            ? []
            : List<dynamic>.from(game_sort_nav!.map((x) => x)),
        "game_tag_sort_nav": game_tag_sort_nav == null
            ? []
            : List<dynamic>.from(game_tag_sort_nav!.map((x) => x)),
        "comic_type_nav": comic_type_nav == null
            ? []
            : List<dynamic>.from(comic_type_nav!.map((x) => x)),
        "novel_nav": novel_nav == null
            ? []
            : List<dynamic>.from(novel_nav!.map((x) => x)),
        "novel_sort": novel_sort == null
            ? []
            : List<dynamic>.from(novel_sort!.map((x) => x)),
        "novel_type_nav": novel_type_nav == null
            ? []
            : List<dynamic>.from(novel_type_nav!.map((x) => x)),
        "album_nav": album_nav == null
            ? []
            : List<dynamic>.from(album_nav!.map((x) => x)),
        "album_sort": album_sort == null
            ? []
            : List<dynamic>.from(album_sort!.map((x) => x)),
        "album_tag_sort": album_tag_sort == null
            ? []
            : List<dynamic>.from(album_tag_sort!.map((x) => x)),
        "star_filter_nav": star_filter_nav == null
            ? []
            : List<dynamic>.from(star_filter_nav!.map((x) => x)),
        "star_sort_nav": star_sort_nav == null
            ? []
            : List<dynamic>.from(star_sort_nav!.map((x) => x)),
        "star_mv_sort_nav": star_mv_sort_nav == null
            ? []
            : List<dynamic>.from(star_mv_sort_nav!.map((x) => x)),
        "vlog_sort_nav": vlog_sort_nav == null
            ? []
            : List<dynamic>.from(vlog_sort_nav!.map((x) => x)),
        "ai_girlfriend_sort": ai_girlfriend_sort == null
            ? []
            : List<dynamic>.from(ai_girlfriend_sort!.map((x) => x)),
        "ai_girlfriend_tag": ai_girlfriend_tag == null
            ? []
            : List<dynamic>.from(ai_girlfriend_tag!.map((x) => x)),
        "character_coins": character_coins,
        "ai_girlfriend_chat_coins": ai_girlfriend_chat_coins,
        "ai_girlfriend_chat_msg_ct": ai_girlfriend_chat_msg_ct,
        "girl_sort": girl_sort == null
            ? []
            : List<dynamic>.from(girl_sort!.map((x) => x)),
        "chat_nav":
            chat_nav == null ? [] : List<dynamic>.from(chat_nav!.map((x) => x)),
        "chat_select_nav": chat_select_nav == null
            ? []
            : List<dynamic>.from(chat_select_nav!.map((x) => x)),
        "notice_app": notice_app?.map((e) => e.toJson()),
        "start_screen_ads": start_screen_ads?.map((e) => e.toJson()),
        'pwa_download_url': pwaDownloadUrl,
        'r2URL': r2URL,
        'r2Key': r2Key,
        'r2CompleteURL': r2CompleteURL,
        'pwa_apk': pwa_apk,
        'keywords': keywords,
        'description': description,
        'title': title,
        'ad_version': adVersion,
      };
}
