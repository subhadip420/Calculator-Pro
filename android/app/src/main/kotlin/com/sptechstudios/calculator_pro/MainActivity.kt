package com.sptechstudios.calculator_pro

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.sptechstudios/app"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "minimizeApp") {
                moveTaskToBack(true)
                result.success(null)
            } else if (call.method == "openApp") {
                // NAYA FIX: Soye hue (minimized) app ko wapas screen par laane ke liye
                val intent = Intent(this, MainActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                startActivity(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}