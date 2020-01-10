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
  /// Stream订阅
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    // 注册Steam事件
    _subscription = ScreenBrightness._eventChannel
        .receiveBroadcastStream("init")
        .listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  /// event channel回调
  void _onEvent(Object event) {
    if (mounted) {
      if (widget.onBrightnessChange != null) {
        widget.onBrightnessChange(event);
      }
    }
  }

  /// event channel回调失败
  void _onError(Object error) {
    print('Screen brightness: unknown.' + error.toString());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? SizedBox();
  }
}
