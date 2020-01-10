package com.qingyi.flutter_screen_brightness

import android.app.Activity
import android.content.Context
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import io.flutter.BuildConfig

/**
 * 屏幕亮度观察器
 */
class ScreenBrightnessObserver(private val activity: Activity) {
    companion object {
        private val TAG = ScreenBrightnessObserver::class.java.simpleName
    }

    // 最大亮度[1.0]
    private var maxBrightness: Int = 255
    
    // 屏幕亮度监听器
    var screenBrightnessListener: ScreenBrightnessListener? = null

    init {
        // 获取最大亮度
        try {
            val powerManager = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
            val clazz = powerManager::class.java
            val method = clazz.getDeclaredMethod("getMaximumScreenBrightnessSetting")
            val max = method.invoke(powerManager) as Int
            this.maxBrightness = max
            if (BuildConfig.DEBUG) {
                Log.d(TAG, "MaximumScreenBrightnessSetting -> $max")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // 屏幕亮度
    var brightness: Double
        get() {
            val brightness = activity.window.attributes.screenBrightness
            return if (brightness == WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE) {
                // 如果为系统亮度，则获取系统亮度
                val systemBrightness = Settings.System.getInt(activity.contentResolver, Settings.System.SCREEN_BRIGHTNESS).toDouble() / maxBrightness
                if (systemBrightness > 1.0) 1.0 else systemBrightness
            } else {
                brightness.toDouble()
            }
        }
        set(value) {
            activity.window.attributes = activity.window.attributes.apply {
                screenBrightness = when {
                    value > 1.0 -> 1.0f
                    value < 0.1 -> 0.1f
                    else -> value.toFloat()
                }
            }
            // 通知当前亮度
            screenBrightnessListener?.onBrightnessChanged(brightness)
        }

    // 设置屏幕常亮
    var keepScreenOn: Boolean
        get() = Settings.System.getInt(activity.contentResolver, Settings.System.SCREEN_OFF_TIMEOUT) == -1
        set(value) {
            if (value) {
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            } else {
                activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            }
        }

    // 恢复屏幕亮度
    fun restore() {
        activity.window.attributes = activity.window.attributes.apply {
            screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        }
    }
}

/**
 * 屏幕亮度监听器
 */
interface ScreenBrightnessListener {
    fun onBrightnessChanged(brightness: Double)
}