package com.awady.awady_music

import android.Manifest
import android.app.Dialog
import android.app.UiModeManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.webkit.CookieManager
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
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
                } else if (call.method == "isWatch") {
                    val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
                    val isWatch = uiModeManager?.currentModeType == Configuration.UI_MODE_TYPE_WATCH ||
                            packageManager.hasSystemFeature(PackageManager.FEATURE_WATCH)
                    result.success(isWatch)
                } else if (call.method == "bringToFront") {
                    try {
                        val intent = Intent(this, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                } else {
                    result.notImplemented()
                }
            }

        val ytmAuthChannel = "com.awady.awady_music/ytm_auth"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ytmAuthChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "loginYouTubeMusic" -> {
                        try {
                            val dialog = Dialog(this, android.R.style.Theme_Black_NoTitleBar_Fullscreen)
                            val rootLayout = LinearLayout(this).apply {
                                orientation = LinearLayout.VERTICAL
                                setBackgroundColor(Color.parseColor("#121212"))
                                layoutParams = ViewGroup.LayoutParams(
                                    ViewGroup.LayoutParams.MATCH_PARENT,
                                    ViewGroup.LayoutParams.MATCH_PARENT
                                )
                            }

                            val headerLayout = LinearLayout(this).apply {
                                orientation = LinearLayout.HORIZONTAL
                                gravity = Gravity.CENTER_VERTICAL
                                setBackgroundColor(Color.parseColor("#1E1E1E"))
                                setPadding(24, 16, 24, 16)
                                layoutParams = LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    LinearLayout.LayoutParams.WRAP_CONTENT
                                )
                            }

                            val titleView = TextView(this).apply {
                                text = "Sign in to YouTube Music"
                                setTextColor(Color.WHITE)
                                textSize = 16f
                                layoutParams = LinearLayout.LayoutParams(
                                    0,
                                    LinearLayout.LayoutParams.WRAP_CONTENT,
                                    1f
                                )
                            }

                            var completed = false
                            fun finishWithCookie(cookie: String?) {
                                if (completed) return
                                completed = true
                                dialog.dismiss()
                                result.success(cookie)
                            }

                            val doneButton = Button(this).apply {
                                text = "Done"
                                setTextColor(Color.parseColor("#4CAF50"))
                                setBackgroundColor(Color.TRANSPARENT)
                                setOnClickListener {
                                    val cookie = CookieManager.getInstance().getCookie("https://music.youtube.com")
                                    finishWithCookie(cookie)
                                }
                            }

                            val cancelButton = Button(this).apply {
                                text = "Cancel"
                                setTextColor(Color.parseColor("#B0B0B0"))
                                setBackgroundColor(Color.TRANSPARENT)
                                setOnClickListener {
                                    finishWithCookie(null)
                                }
                            }

                            headerLayout.addView(titleView)
                            headerLayout.addView(doneButton)
                            headerLayout.addView(cancelButton)
                            rootLayout.addView(headerLayout)

                            val webView = WebView(this).apply {
                                layoutParams = LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    LinearLayout.LayoutParams.MATCH_PARENT
                                )
                                settings.javaScriptEnabled = true
                                settings.domStorageEnabled = true
                                settings.userAgentString =
                                    "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36"
                                CookieManager.getInstance().setAcceptCookie(true)
                                CookieManager.getInstance().setAcceptThirdPartyCookies(this, true)
                                webViewClient = object : WebViewClient() {
                                    override fun onPageFinished(view: WebView?, url: String?) {
                                        super.onPageFinished(view, url)
                                        if (url != null && url.contains("music.youtube.com")) {
                                            val cookie = CookieManager.getInstance().getCookie("https://music.youtube.com")
                                            if (cookie != null && (cookie.contains("SAPISID") || cookie.contains("__Secure-3PAPISID"))) {
                                                finishWithCookie(cookie)
                                            }
                                        }
                                    }
                                }
                            }

                            rootLayout.addView(webView)
                            dialog.setContentView(rootLayout)
                            dialog.setOnCancelListener {
                                finishWithCookie(null)
                            }
                            dialog.show()

                            webView.loadUrl("https://accounts.google.com/ServiceLogin?service=youtube&continue=https%3A%2F%2Fmusic.youtube.com")
                        } catch (e: Exception) {
                            result.error("AUTH_ERROR", e.localizedMessage, null)
                        }
                    }
                    "logout" -> {
                        try {
                            CookieManager.getInstance().removeAllCookies(null)
                            CookieManager.getInstance().flush()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("LOGOUT_ERROR", e.localizedMessage, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
