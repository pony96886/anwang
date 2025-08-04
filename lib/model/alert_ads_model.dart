import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class AlertAdsModel {
  AlertAdsModel({
    this.id,
    this.url,
    this.img_url,
    this.title,
    this.content,
    this.router,
    this.visible_type,
    this.type,
    this.height,
    this.width,
    this.url_str,
    this.report_id,
    this.report_type,
  });
  int? id;
  String? url;
  String? img_url;
  String? title;
  String? content;
  String? router;
  int? visible_type;
  String? type;
  int? height;
  int? width;
  String? url_str;
  int? report_id;
  int? report_type;

  factory AlertAdsModel.fromJson(Map<String, dynamic> json) => AlertAdsModel(
        id: json['id'] ?? 0,
        url: json['url'] ?? "",
        img_url: json['img_url'] ?? "",
        title: json['title'] ?? "",
        content: json['content'] ?? "",
        router: json['router'] ?? "",
        visible_type: json['visible_type'] ?? "",
        type: json['type'] ?? "",
        height: json['height'] ?? 100,
        width: json['width'] ?? 100,
        url_str: json['url_str'] ?? "",
        report_id: json['report_id'] ?? 0,
        report_type: json['report_type'] ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "url": url,
        "img_url": img_url,
        "title": title,
        "content": content,
        "router": router,
        "visible_type": visible_type,
        "type": type,
        "height": height,
        "width": width,
        "url_str": url_str,
        "report_id": report_id,
        "report_type": report_type,
      };
}
