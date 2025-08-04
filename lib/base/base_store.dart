import 'package:deepseek/model/config_model.dart';
import 'package:deepseek/model/sysnotice_model.dart';
import 'package:deepseek/model/user_model.dart';
import 'package:flutter/foundation.dart';

//数据状态持久化
class BaseStore with ChangeNotifier, DiagnosticableTreeMixin {
  //基础数据
  ConfigModel? _conf;
  ConfigModel? get conf => _conf;
  //用户数据
  UserModel? _user;
  UserModel? get user => _user;
  //消息中心
  SysNoticeModel? _notice;
  SysNoticeModel? get notice => _notice;

  void setConf(ConfigModel newConf) {
    _conf = newConf;
    notifyListeners();
  }

  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  void setMoney(int newMoney) {
    _user?.money = newMoney;
    notifyListeners();
  }

  void setCharacterValue(int newCount) {
    _user?.ai_girlfriend_create_value = newCount;
    notifyListeners();
  }

  void setImageFaceValue(int newCount) {
    _user?.img_face_value = newCount;
    notifyListeners();
  }

  void setVideoFaceValue(int newCount) {
    _user?.video_face_value = newCount;
    notifyListeners();
  }

  void setStripValue(int newCount) {
    _user?.strip_value = newCount;
    notifyListeners();
  }

  void setImChatValue(int chatValue) {
    _user?.ai_girlfriend_chat_value = chatValue;
    notifyListeners();
  }

  void setUnread(int newCount) {
    _user?.unread_reply = newCount;
    notifyListeners();
  }

  void setNotice(SysNoticeModel newNotice) {
    _notice = newNotice;
    notifyListeners();
  }
}
