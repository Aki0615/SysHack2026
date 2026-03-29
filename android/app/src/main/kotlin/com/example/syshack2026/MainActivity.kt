package com.example.syshack2026

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "syshack/battery_optimization"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"isIgnoringBatteryOptimizations" -> {
						val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
						result.success(powerManager.isIgnoringBatteryOptimizations(packageName))
					}

					"requestIgnoreBatteryOptimizations" -> {
						try {
							val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
								data = Uri.parse("package:$packageName")
							}
							startActivity(intent)
							result.success(true)
						} catch (e: Exception) {
							try {
								val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
								startActivity(fallbackIntent)
								result.success(true)
							} catch (fallbackError: Exception) {
								result.error(
									"OPEN_SETTINGS_FAILED",
									fallbackError.message,
									null
								)
							}
						}
					}

					else -> result.notImplemented()
				}
			}
	}
}
