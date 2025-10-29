package com.example.rutube_webview

import android.webkit.WebChromeClient.CustomViewCallback
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.MethodChannel

class CustomWebViewClient(private val methodChannel: MethodChannel) : WebViewClient() {
    override fun onPageFinished(view: WebView?, url: String?) {
        methodChannel.invokeMethod("onPageFinished", true)
        super.onPageFinished(view, url)
    }
}