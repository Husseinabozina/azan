package com.example.azan

import android.app.UiModeManager
import android.content.Context
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "azan/device_kind"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAndroidTv" -> result.success(isAndroidTv())
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
