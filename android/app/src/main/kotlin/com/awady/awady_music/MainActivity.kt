package com.awady.awady_music

import android.Manifest
import android.app.UiModeManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import androidx.core.content.FileProvider
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val updaterChannel = "com.awady.awady_music/updater"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= 33) {
            if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1001)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, updaterChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "installApk") {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrBlank()) {
                        result.error("INVALID_PATH", "File path cannot be empty", null)
                        return@setMethodCallHandler
                    }
                    val file = File(filePath)
                    if (!file.exists()) {
                        result.error("FILE_NOT_FOUND", "APK file does not exist at path: $filePath", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val targetFile = if (file.canonicalPath.startsWith(cacheDir.canonicalPath)) {
                            file
                        } else {
                            val copied = File(cacheDir, file.name)
                            file.copyTo(copied, overwrite = true)
                            copied
                        }
                        val uri = FileProvider.getUriForFile(
                            this,
                            "$packageName.fileprovider",
                            targetFile
                        )
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, "application/vnd.android.package-archive")
                            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_ERROR", e.localizedMessage, null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        val castChannel = "com.awady.awady_music/cast"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, castChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "openCastSettings") {
                    try {
                        val intent = Intent("com.android.settings.panel.action.MEDIA_OUTPUT").apply {
                            putExtra("com.android.settings.panel.extra.PACKAGE_NAME", packageName)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val fallbackIntent = Intent(android.provider.Settings.ACTION_CAST_SETTINGS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(fallbackIntent)
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("CAST_SETTINGS_ERROR", e2.localizedMessage, null)
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }

        val tvChannel = "com.awady.awady_music/tv"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, tvChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "isTelevision") {
                    val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
                    val isTv = uiModeManager?.currentModeType ==
                            Configuration.UI_MODE_TYPE_TELEVISION ||
                            packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
                    result.success(isTv)
                } else {
                    result.notImplemented()
                }
            }
    }
}
