import Flutter
import UIKit

public class SwiftFlutterScreenBrightnessPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  // 通道
  private static let CHANNEL: String = "flutter_screen_brightness"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftFlutterScreenBrightnessPlugin()
    let channel = FlutterMethodChannel(name: CHANNEL + "_method", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
    let eventChannel = FlutterEventChannel(name: CHANNEL + "_event", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  // Stream通道事件槽
  private var eventSink: FlutterEventSink? = nil

  // 记录初始亮度
  private var initBrightness: CGFloat? = nil

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // 获取亮度
    if (call.method == "getBrightness") {
      result(UIScreen.main.brightness);
    }
    // 设置亮度
    else if (call.method == "setBrightness") {
      var brightness: Double? = (call.arguments as! Dictionary)["brightness"]
      if (brightness != nil) {
        if (brightness! > 1.0) {
            brightness = 1.0
        } else if (brightness! < 0.1) {
            brightness = 0.1
        }
        UIScreen.main.brightness = CGFloat(brightness!)
        self.eventSink?(UIScreen.main.brightness)
        result(true)
      } else {
        result(false)
      }
    }
    // 设置屏幕常亮
    else if (call.method == "keepScreenOn") {
      let keep: Bool? = (call.arguments as! Dictionary)["keep"]
      if (keep != nil) {
        UIApplication.shared.isIdleTimerDisabled = keep!
        result(true)
      } else {
        result(false)
      }
    }
    // 恢复亮度
    else if (call.method == "restore") {
      UIScreen.main.brightness = self.initBrightness!
      result(true)
    }
  }

  // Stream通道事件监听
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    self.initBrightness = UIScreen.main.brightness
    self.eventSink?(initBrightness)
    //NotificationCenter.default.addObserver(self, selector: #selector(onBrightnessChanged), name: UIScreen.brightnessDidChangeNotification, object: nil)
    return nil
  }

  // Stream通道事件取消
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    //NotificationCenter.default.removeObserver(self, name: UIScreen.brightnessDidChangeNotification, object: nil)
    self.eventSink = nil
    return nil
  }

  // 监听亮度变化通知
  @objc func onBrightnessChanged(notfication: NSNotification){
    self.eventSink?(UIScreen.main.brightness)
  }
}
