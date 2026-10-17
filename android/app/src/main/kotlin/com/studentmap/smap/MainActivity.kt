package com.studentmap.smap

import android.os.Build
import android.view.HapticFeedbackConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        registerHapticsChannel(flutterEngine)
    }

    /**
     * Notification feedback for `AppHaptics` (lib/core/services/app_haptics.dart).
     * Flutter's HapticFeedback has no success/error, so they come through this channel.
     *
     * CONFIRM and REJECT exist from API 30; below that LONG_PRESS and VIRTUAL_KEY are the
     * closest standard constants. The user's touch-feedback setting is respected: when it is
     * off, performHapticFeedback does nothing and the call completes quietly.
     */
    private fun registerHapticsChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HAPTICS_CHANNEL)
            .setMethodCallHandler { call, result ->
                val constant = when (call.method) {
                    "success" ->
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            HapticFeedbackConstants.CONFIRM
                        } else {
                            HapticFeedbackConstants.LONG_PRESS
                        }
                    "error" ->
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            HapticFeedbackConstants.REJECT
                        } else {
                            HapticFeedbackConstants.VIRTUAL_KEY
                        }
                    else -> {
                        result.notImplemented()
                        return@setMethodCallHandler
                    }
                }
                window?.decorView?.performHapticFeedback(constant)
                result.success(null)
            }
    }

    private companion object {
        const val HAPTICS_CHANNEL = "smap/haptics"
    }
}
