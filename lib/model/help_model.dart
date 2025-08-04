import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class ItemsModel {
  ItemsModel({
    this.id,
    this.question,
    this.answer,
    this.status,
    this.type,
    this.views,
    this.created_at,
    this.updated_at,
  });
  int? id;
  String? question;
  String? answer;
  int? status;
  int? type;
  int? views;
  String? created_at;
  String? updated_at;

  factory ItemsModel.fromJson(Map<String, dynamic> json) => ItemsModel(
        id: json['id'] ?? 0,
        question: json['question'] ?? "",
        answer: json['answer'] ?? "",
        status: json['status'] ?? 0,
        type: json['type'] ?? 0,
        views: json['views'] ?? 0,
        created_at: json['created_at'] ?? "",
        updated_at: json['updated_at'] ?? "",
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "question": question,
        "answer": answer,
        "status": status,
        "type": type,
        "views": views,
        "created_at": created_at,
        "updated_at": updated_at,
      };
}
