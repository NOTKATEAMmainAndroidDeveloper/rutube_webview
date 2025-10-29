package com.example.rutube_webview

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.pm.ActivityInfo
import android.view.View
import android.webkit.WebView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

@SuppressLint("SetJavaScriptEnabled", "SourceLockedOrientationActivity")
class RutubeWebView(
    private val activity: Activity,
    id: Int,
    params: Map<String?, Any?>?,
    private val methodChannel: MethodChannel
) :
    PlatformView {
    private val webView: WebView = WebView(activity)

    init {
        webView.webChromeClient = FullscreenVideoChromeClient(activity, methodChannel)
        webView.webViewClient = CustomWebViewClient(methodChannel)
        webView.settings.javaScriptEnabled = true
        webView.setBackgroundColor(android.graphics.Color.BLACK)

        val initialUrl = params?.get("initialUrl") as? String

        if (initialUrl != null) webView.loadUrl(initialUrl)

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setOrientationPortrait" -> {
                    activity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
                    result.success(true)
                }
                "setOrientationLandscape" -> {
                    activity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
                    result.success(true)
                }
                "evaluateJavaScript" -> {
                    val jsCode = call.arguments as? String
                    if (jsCode != null) {
                        webView.evaluateJavascript(jsCode, null)
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun getView(): View = webView

    override fun dispose() {

    }
}
