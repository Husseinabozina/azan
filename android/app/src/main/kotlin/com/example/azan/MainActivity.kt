package com.example.azan

import android.app.UiModeManager
import android.content.Context
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // القديم: معرفة هل الجهاز Android TV
    private val deviceKindChannel = "azan/device_kind"

    // الجديد: تدوير الشاشة فورًا
    private val orientationChannel = "azan/orientation"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ===== Channel 1: Device Kind (Android TV) =====
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceKindChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAndroidTv" -> result.success(isAndroidTv())
                    else -> result.notImplemented()
                }
            }

        // ===== Channel 2: Orientation (Force rotate) =====
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, orientationChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "portrait" -> {
                        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
                        result.success(null)
                    }
                    "landscape" -> {
                        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
                        result.success(null)
                    }
                    // في أندرويد "landscapeLeft" و "landscape" غالبًا نفس القيمة
                    "landscapeLeft" -> {
                        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
                        result.success(null)
                    }
                    "landscapeRight" -> {
                        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE
                        result.success(null)
                    }
                    // يرجّع التحكم للنظام
                    "system" -> {
                        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isAndroidTv(): Boolean {
        val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as UiModeManager
        val modeType = uiModeManager.currentModeType

        val pm = packageManager
        val hasLeanback = pm.hasSystemFeature("android.software.leanback")
        val isTelevisionMode = modeType == Configuration.UI_MODE_TYPE_TELEVISION

        // بعض الأجهزة بتعلن نفسها TV بطرق مختلفة
        val hasTvFeature =
            pm.hasSystemFeature("com.google.android.tv") ||
            pm.hasSystemFeature("android.hardware.type.television")

        return isTelevisionMode || hasLeanback || hasTvFeature
    }
}
