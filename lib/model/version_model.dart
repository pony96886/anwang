import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class VersionModel {
  VersionModel({
    this.id,
    this.version,
    this.type,
    this.apk,
    this.tips,
    this.must,
    this.created_at,
    this.status,
    this.message,
    this.mstatus,
    this.channel,
  });
  int? id;
  String? version;
  String? type;
  String? apk;
  String? tips;
  int? must;
  String? created_at;
  int? status;
  String? message;
  int? mstatus;
  String? channel;

  factory VersionModel.fromJson(Map<String, dynamic> json) => VersionModel(
        id: json['id'] ?? 0,
        version: json['version'] ?? "",
        type: json['type'] ?? "",
        apk: json['apk'] ?? "",
        tips: json['tips'] ?? "",
        must: json['must'] ?? 0,
        created_at: json['created_at'] ?? "",
        status: json['status'] ?? 0,
        message: json['message'] ?? "",
        mstatus: json['mstatus'] ?? 0,
        channel: json['channel'] ?? "",
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "version": version,
        "type": type,
        "apk": apk,
        "tips": tips,
        "must": must,
        "created_at": created_at,
        "status": status,
        "message": message,
        "mstatus": mstatus,
        "channel": channel,
      };
}
