import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class SysNoticeModel {
  SysNoticeModel({
    this.systemNoticeCount = 0,
    this.feedCount = 0,
    this.systemNotice,
    this.feed,
  });

  int systemNoticeCount;
  int feedCount;
  final Feed? systemNotice;
  final Feed? feed;

  factory SysNoticeModel.fromJson(Map<String, dynamic> json) => SysNoticeModel(
        systemNoticeCount: json["systemNoticeCount"] ?? 0,
        feedCount: json["feedCount"] ?? 0,
        systemNotice: json['systemNotice'] == null
            ? null
            : Feed.fromJson(json['systemNotice']),
        feed: json['feed'] == null ? null : Feed.fromJson(json['feed']),
      );

  Map<String, dynamic> toJson() => {
        "systemNoticeCount": systemNoticeCount,
        "feedCount": feedCount,
        'systemNotice': systemNotice?.toJson(),
        'feed': feed?.toJson(),
      };
}

class Feed {
  Feed({
    required this.id,
    this.uuid,
    this.userIp,
    required this.question,
    this.messageType,
    this.helpType,
    this.image1,
    this.status,
    this.isRead,
    this.evaluation,
    required this.createdAt,
    required this.updatedAt,
    this.isReplay,
  });

  final int id;
  final String? uuid;
  final String? userIp;
  final String question;
  final int? messageType;
  final dynamic helpType;
  final String? image1;
  final int? status;
  final int? isRead;
  final int? evaluation;
  final String createdAt;
  final String updatedAt;
  final int? isReplay;

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        id: json['id'],
        uuid: json['uuid'],
        userIp: json['user_ip'],
        question: json['question'],
        messageType: json['message_type'],
        helpType: json['help_type'],
        image1: json['image_1'],
        status: json['status'],
        isRead: json['is_read'],
        evaluation: json['evaluation'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        isReplay: json['is_replay'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'user_ip': userIp,
        'question': question,
        'message_type': messageType,
        'help_type': helpType,
        'image_1': image1,
        'status': status,
        'is_read': isRead,
        'evaluation': evaluation,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'is_replay': isReplay,
      };
}
