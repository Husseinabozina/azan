package com.example.azan

import android.app.UiModeManager
import android.content.Context
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val deviceKindChannel = "azan/device_kind"
    private val orientationChannel = "azan/orientation"

    // ✅ 1) مهم جدًا لتفادي letterboxing في بعض الشاشات الكبيرة
    override fun getRenderMode(): RenderMode = RenderMode.texture

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // مفيش حاجة لازم هنا حاليًا
        // لو عايز default orientation عند فتح التطبيق ممكن تعملها من Flutter
        // أو تحطها هنا بشرط منطق واضح.
    }

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

                    // ✅ 2) استخدم SENSOR_* بدل PORTRAIT/LANDSCAPE الصريح
                    // ✅ 3) Reset step قبل القفل لتفادي black bars بعد التبديل
                    "portrait" -> forceOrientation(
                        ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT,
                        result
                    )

                    "landscape" -> forceOrientation(
                        ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
                        result
                    )

                    // لو عايز تمييز يمين/شمال
                    "landscapeLeft" -> forceOrientation(
                        ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
                        result
                    )

                    "landscapeRight" -> forceOrientation(
                        ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE,
                        result
                    )

                    // يرجّع التحكم للنظام
                    "system" -> {
                        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // Reset step: UNSPECIFIED -> بعد شوية -> Orientation المطلوب
    private fun forceOrientation(ori: Int, result: MethodChannel.Result) {
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
        window.decorView.postDelayed({
            requestedOrientation = ori
            result.success(null)
        }, 80)
    }

    private fun isAndroidTv(): Boolean {
        val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as UiModeManager
        val modeType = uiModeManager.currentModeType

        val pm = packageManager
        val hasLeanback = pm.hasSystemFeature("android.software.leanback")
        val isTelevisionMode = modeType == Configuration.UI_MODE_TYPE_TELEVISION

        val hasTvFeature =
            pm.hasSystemFeature("com.google.android.tv") ||
            pm.hasSystemFeature("android.hardware.type.television")

        return isTelevisionMode || hasLeanback || hasTvFeature
    }
}
