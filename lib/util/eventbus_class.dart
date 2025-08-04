import 'package:event_bus/event_bus.dart';

//事件总线，全局响应
class EventbusClass {
  Map arg; //{"name":事件名，"data": 数据}
  EventbusClass(this.arg);
}

class UtilEventbus extends EventBus {
  static UtilEventbus? _instance;
  UtilEventbus._internal() {
    _instance = this;
  }
  factory UtilEventbus() => _instance ?? UtilEventbus._internal();
}

final EventBus eventBus = EventBus();

class MyEvent {
  final String message;
  final Map? param;
  MyEvent(this.message, {this.param});
}