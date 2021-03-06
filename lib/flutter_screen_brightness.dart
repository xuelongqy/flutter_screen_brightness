import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 屏幕亮度插件
class ScreenBrightness extends StatefulWidget {
  /// 通道
  static const CHANNEL = 'flutter_screen_brightness';
  static const MethodChannel _channel =
      const MethodChannel('${CHANNEL}_method');
  static const EventChannel _eventChannel =
      const EventChannel('${CHANNEL}_event');

  /// Stream订阅
  static StreamSubscription _subscription;
  /// 监听事件
  static Map<int, Function> _events = {};

  /// event channel回调
  static void _onEvent(Object event) {
    _events.values.forEach((item) {
      if (item != null) {
        item(event);
      }
    });
  }

  /// event channel回调失败
  static void _onError(Object error) {
    print('Brightness status: unknown.' + error.toString());
  }

  /// 添加监听器
  /// 返回id, 用于删除监听器使用
  static int addListener(Function onEvent) {
    if (_subscription == null) {
      //event channel 注册
      _subscription = _eventChannel
          .receiveBroadcastStream('init')
          .listen(_onEvent, onError: _onError);
    }
    if (onEvent != null) {
      _events[onEvent.hashCode] = onEvent;
      brightness.then((value) {
        onEvent(value);
      });
      return onEvent.hashCode;
    }
    return null;
  }

  /// 删除监听器
  static void removeListener(int id) {
    if (id != null) {
      _events.remove(id);
    }
  }

  /// 获取屏幕亮度
  static Future<double> get brightness async {
    return await _channel.invokeMethod('getBrightness');
  }

  /// 设置屏幕亮度
  static set brightness(double value) {
    _channel.invokeMethod('setBrightness', {
      'brightness': value,
    });
  }

  /// 设置屏幕常亮
  static set keepScreenOn(bool keep) {
    _channel.invokeMethod('keepScreenOn', {
      'keep': keep,
    });
  }

  /// 恢复亮度
  static void restore() {
    _channel.invokeMethod('restore');
  }

  /// 亮度变化回调
  final ValueChanged<double> onBrightnessChange;

  /// 子组件
  final Widget child;

  const ScreenBrightness({
    Key key,
    @required this.onBrightnessChange,
    this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenBrightnessState();
  }
}

class ScreenBrightnessState extends State<ScreenBrightness> {
  int _listenerId;

  @override
  void initState() {
    super.initState();
    // 注册Steam事件
    _listenerId = ScreenBrightness.addListener(widget.onBrightnessChange);
  }

  @override
  void dispose() {
    ScreenBrightness.removeListener(_listenerId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? SizedBox();
  }
}
