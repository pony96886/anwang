import 'dart:async';
import 'dart:convert';
import 'package:deepseek/model/user_model.dart';
import 'package:deepseek/util/cache/cache_manager.dart';
import 'package:flutter/material.dart';
// import 'package:wtdl/domain/domain.dart';
// import 'package:wtdl/domain/model/member_model.dart';

class AIChatNotifier extends ChangeNotifier {
  AIChatNotifier({required this.user});

  late final UserModel user;
  late CacheManager cache = CacheManager.instance;

  List<AIChatList> get chats => [..._chats];

  List<AIChatList> _chats = [];

  //获取本地AI消息列表
  Future<List<AIChatList>> readChats() async {
    final data = await cache.readAIChats(key: 'AI_${user.aff}');
    if (data.isEmpty) return [];
    final st = jsonDecode(data);
    _chats = List<AIChatList>.from(st.map((x) => AIChatList.fromJson(x)));
    notifyListeners();
    return _chats;
  }

  Future saveChats() =>
      cache.upsertAIChats(chats: jsonEncode(chats), key: 'AI_${user.aff}');

  removeChat(int id) {
    _chats.removeWhere((el) => el.id == id);
    saveChats();
    notifyListeners();
  }

  clearChats() {
    _chats = [];
    cache.upsertAIChats(chats: '', key: 'AI_${user.aff}');
    notifyListeners();
  }

  //根据AI女友的id,name,avatar去更新chats列表
  updateChatIM(Message chat, int id, String name, String avatar) {
    AIChatList? child;
    for (var item in _chats) {
      if (item.id == id) {
        //找到对应AI女友
        child = item;
        break;
      }
    }
    if (child == null) {
      //如果没有找到则创建一个新的数据
      AIChatList tp = AIChatList(
        id: id,
        name: name,
        avatar: avatar,
        list: [],
      );

      tp.list?.add(chat);
      _chats.add(tp);
    } else {
      child.list?.add(chat);
    }

    saveChats();
    notifyListeners();
  }
}

class AIChatList {
  AIChatList({
    required this.id,
    required this.name,
    required this.avatar,
    required this.list,
  });

  int? id;
  String? name;
  String? avatar;
  List<Message>? list;

  factory AIChatList.fromJson(Map<String, dynamic> json) => AIChatList(
        id: json['id'],
        name: json['name'],
        avatar: json['avatar'],
        list: json['list'] == null
            ? []
            : List<Message>.from(json['list'].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'list': list?.map((e) => e.toJson()).toList(),
      };
}

class Message {
  String avatar;
  String greeting;
  String audioUrl;
  String nickname;
  bool isUser;
  bool isDone;
  String timeStr;

  Message(
      {required this.greeting,
      required this.avatar,
      required this.nickname,
      this.audioUrl = '',
      this.isUser = false,
      this.isDone = false,
      required this.timeStr});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        greeting: json["greeting"] ?? '',
        avatar: json["avatar"] ?? '',
        nickname: json["nickname"] ?? '',
        timeStr: json["timeStr"] ?? '',
        isUser: json["isUser"] ?? false,
        isDone: json["isDone"] ?? false,
        audioUrl: json["audioUrl"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "greeting": greeting,
        "avatar": avatar,
        "nickname": nickname,
        "timeStr": timeStr,
        "isUser": isUser,
        "isDone": isDone,
        "audioUrl": audioUrl,
      };
}
