import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class AdsModel {
  AdsModel({
    this.id,
    this.title,
    this.description,
    this.img_url,
    this.url_config,
    this.position,
    this.android_down_url,
    this.ios_down_url,
    this.type,
    this.status,
    this.oauth_type,
    this.mv_m3u8,
    this.channel,
    this.created_at,
    this.router,
    this.url_str,
    this.link_url,
    this.url,
    this.resource_url,
    this.redirect_type,
    this.report_id,
    this.report_type,
  });
  int? id;
  String? title;
  String? description;
  String? img_url;
  String? url_config;
  int? position;
  String? android_down_url;
  String? ios_down_url;
  int? type;
  int? status;
  int? oauth_type;
  String? mv_m3u8;
  String? channel;
  String? created_at;
  String? router;
  String? url_str;
  String? link_url;
  String? url;
  String? resource_url;
  int? redirect_type;
  int? report_id;
  int? report_type;

  factory AdsModel.fromJson(Map<String, dynamic> json) => AdsModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? "",
        description: json['description'] ?? "",
        img_url: json['img_url'] ?? "",
        url_config: json['url_config'] ?? "",
        position: json['position'] ?? 0,
        android_down_url: json['android_down_url'] ?? "",
        ios_down_url: json['ios_down_url'] ?? "",
        type: json['type'] ?? 0,
        status: json['status'] ?? 0,
        oauth_type: json['oauth_type'] ?? 0,
        mv_m3u8: json['mv_m3u8'] ?? "",
        channel: json['channel'] ?? "",
        created_at: json['created_at'] ?? "",
        router: json['router'] ?? "",
        url_str: json['url_str'] ?? "",
        link_url: json['link_url'] ?? "",
        url: json['url'] ?? "",
        resource_url: json['resource_url'] ?? "",
        redirect_type: json['redirect_type'] ?? 0,
        report_id: json['report_id'] ?? 0,
        report_type: json['report_type'] ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "title": title,
        "description": description,
        "img_url": img_url,
        "url_config": url_config,
        "position": position,
        "android_down_url": android_down_url,
        "ios_down_url": ios_down_url,
        "type": type,
        "status": status,
        "oauth_type": oauth_type,
        "mv_m3u8": mv_m3u8,
        "channel": channel,
        "created_at": created_at,
        "router": router,
        "url_str": url_str,
        "link_url": link_url,
        "url": url,
        "resource_url": resource_url,
        "redirect_type": redirect_type,
        "report_id": report_id,
        "report_type": report_type,
      };
}
