package com.example.azan

import android.app.UiModeManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // =========================
    // Existing channels
    // =========================
    private val deviceKindChannel = "azan/device_kind"
    private val orientationChannel = "azan/orientation"

    // =========================
    // New channel: system time guard
    // =========================
    private val systemTimeGuardChannel = "system_time_guard/events"

    private var timeEventSink: EventChannel.EventSink? = null
    private var timeReceiver: BroadcastReceiver? = null

    // ✅ مهم جدًا لتفادي letterboxing في بعض الشاشات الكبيرة
    override fun getRenderMode(): RenderMode = RenderMode.texture

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // لا حاجة إضافية هنا حاليًا
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // =========================
        // Channel 1: Device Kind (Android TV)
        // =========================
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceKindChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAndroidTv" -> result.success(isAndroidTv())
                    else -> result.notImplemented()
                }
            }

        // =========================
        // Channel 2: Orientation (Force rotate)
        // =========================
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, orientationChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // استخدم SENSOR_* بدل PORTRAIT/LANDSCAPE الصريح
                    "portrait" -> forceOrientation(
                        ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT,
                        result
                    )

                    "landscape" -> forceOrientation(
                        ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
                        result
                    )

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

        // =========================
        // Channel 3: System Time Guard (EventChannel)
        // =========================
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, systemTimeGuardChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    timeEventSink = events
                    registerTimeChangeReceiver()
                }

                override fun onCancel(arguments: Any?) {
                    unregisterTimeChangeReceiver()
                    timeEventSink = null
                }
            })
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

    // =========================
    // System time/date/timezone receiver
    // =========================
    private fun registerTimeChangeReceiver() {
        // منع التسجيل المكرر
        if (timeReceiver != null) return

        timeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action ?: return

                val eventType = when (action) {
                    Intent.ACTION_TIME_CHANGED -> "time_changed"      // user/manual time set
                    Intent.ACTION_DATE_CHANGED -> "date_changed"
                    Intent.ACTION_TIMEZONE_CHANGED -> "timezone_changed"
                    else -> "unknown"
                }

                val payload = hashMapOf<String, Any?>(
                    "type" to eventType,
                    "action" to action,
                    "timestamp" to System.currentTimeMillis()
                )

                // EventSink الأفضل يتبعت من الـ main thread
                runOnUiThread {
                    timeEventSink?.success(payload)
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_TIME_CHANGED)
            addAction(Intent.ACTION_DATE_CHANGED)
            addAction(Intent.ACTION_TIMEZONE_CHANGED)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(timeReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                @Suppress("DEPRECATION")
                registerReceiver(timeReceiver, filter)
            }
        } catch (e: Exception) {
            // لو حصلت مشكلة أثناء التسجيل ابعت error لـ Flutter (اختياري لكنه مفيد)
            runOnUiThread {
                timeEventSink?.error(
                    "REGISTER_RECEIVER_ERROR",
                    e.message ?: "Failed to register time change receiver",
                    null
                )
            }
            // نظف المرجع لو التسجيل فشل
            timeReceiver = null
        }
    }

    private fun unregisterTimeChangeReceiver() {
        val receiver = timeReceiver ?: return
        try {
            unregisterReceiver(receiver)
        } catch (_: IllegalArgumentException) {
            // receiver was not registered / already unregistered
        } catch (_: Exception) {
            // تجاهل أي أخطاء غير متوقعة هنا حتى لا نكسر الإغلاق
        } finally {
            timeReceiver = null
        }
    }

    override fun onDestroy() {
        unregisterTimeChangeReceiver()
        super.onDestroy()
    }
}