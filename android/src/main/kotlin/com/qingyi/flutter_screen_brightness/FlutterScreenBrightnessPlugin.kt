package com.qingyi.flutter_screen_brightness

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.BuildConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/**
 * Flutter 屏幕亮度插件
 */
class FlutterScreenBrightnessPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware, ScreenBrightnessListener {

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    private val TAG = FlutterScreenBrightnessPlugin::class.java.simpleName
    // 通道
    private const val CHANNEL = "flutter_screen_brightness"
    
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val plugin = FlutterScreenBrightnessPlugin()
      plugin.screenBrightnessObserver = ScreenBrightnessObserver(registrar.activity())
      plugin.screenBrightnessObserver.screenBrightnessListener = plugin
      val channel = MethodChannel(registrar.messenger(), "${CHANNEL}_method")
      channel.setMethodCallHandler(plugin)
      val eventChannel = EventChannel(registrar.messenger(),  "${CHANNEL}_event")
      eventChannel.setStreamHandler(plugin)
    }
  }

  // 屏幕亮度观察器
  private lateinit var screenBrightnessObserver: ScreenBrightnessObserver
  // Stream通道事件槽
  private var eventSink: EventChannel.EventSink? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "${CHANNEL}_method")
    channel.setMethodCallHandler(this)
    val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger,  "${CHANNEL}_event")
    eventChannel.setStreamHandler(this)
  }

  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.screenBrightnessObserver = ScreenBrightnessObserver(binding.activity)
    this.screenBrightnessObserver.screenBrightnessListener = this
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  /**
   * Stream通道事件监听
   */
  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    if (BuildConfig.DEBUG) {
      Log.d(TAG, "onListen")
    }
    this.eventSink = events
    val initBrightness = this.screenBrightnessObserver.brightness
    if (BuildConfig.DEBUG) {
      Log.d(TAG, "initBrightness = $initBrightness")
    }
    this.eventSink?.success(initBrightness)
  }

  /**
   * Stream通道事件取消
   */
  override fun onCancel(arguments: Any?) {
    this.eventSink = null
  }

  /**
   * 亮度变化监听
   */
  override fun onBrightnessChanged(brightness: Double) {
    if (BuildConfig.DEBUG) {
      Log.d(TAG, "BrightnessChanged -> $brightness")
    }
    this.eventSink?.success(brightness)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      // 获取亮度
      "getBrightness" -> {
        result.success(this.screenBrightnessObserver.brightness)
      }
      // 设置亮度
      "setBrightness" -> {
        val brightness = call.argument<Double>("brightness")
        if (brightness != null) {
          this.screenBrightnessObserver.brightness = brightness
          result.success(true)
        } else {
          result.success(false)
        }
      }
      // 设置屏幕常亮
      "keepScreenOn" -> {
        val keep = call.argument<Boolean>("keep")
        if (keep != null) {
          this.screenBrightnessObserver.keepScreenOn = keep
          result.success(true)
        } else {
          result.success(false)
        }
      }
      // 恢复亮度
      "restore" -> {
        this.screenBrightnessObserver.restore()
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
