import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(
    genericArgumentFactories: true, fieldRename: FieldRename.snake)
class ResponseModel<T> {
  ResponseModel({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  @JsonKey(name: 'status')
  int? status;
  @JsonKey(name: 'msg')
  String? msg;
  @JsonKey(name: 'crypt')
  bool? crypt;
  @JsonKey(name: 'isVip')
  bool? isVip;
  @JsonKey(name: 'data')
  late final T? data;

  factory ResponseModel.fromJson(
          Map<String, dynamic> json, T Function(dynamic json) fromJsonT) =>
      ResponseModel<T>(
        data: fromJsonT(json['data']),
        status: json['status'] ?? 0,
        msg: json['msg'] ?? '',
        crypt: json['crypt'] ?? false,
        isVip: json['isVip'] ?? false,
      );

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      <String, dynamic>{
        'status': status,
        'msg': msg,
        'crypt': crypt,
        'isVip': isVip,
        'data': toJsonT(data as T),
      };
}
