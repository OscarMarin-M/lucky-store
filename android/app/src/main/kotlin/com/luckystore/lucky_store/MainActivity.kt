package com.luckystore.lucky_store

import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Sends a quote straight to WhatsApp or WhatsApp Business, whichever the
    // owner taps, instead of the app Android opens wa.me links with.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lucky_store/share")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Which of the packages asked for are installed (they are
                    // listed in <queries> of the manifest, so they are visible).
                    "installedApps" -> {
                        val packages = call.argument<List<String>>("packages") ?: emptyList()
                        result.success(packages.filter(::isInstalled))
                    }
                    "sendText" -> {
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            setPackage(call.argument<String>("package"))
                            putExtra(Intent.EXTRA_TEXT, call.argument<String>("text"))
                        }
                        try {
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isInstalled(pkg: String): Boolean = try {
        packageManager.getPackageInfo(pkg, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }
}
