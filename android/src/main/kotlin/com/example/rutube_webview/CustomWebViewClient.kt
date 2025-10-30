package com.example.rutube_webview

import android.webkit.WebChromeClient.CustomViewCallback
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.MethodChannel

class CustomWebViewClient(private val methodChannel: MethodChannel) : WebViewClient() {
    override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
        val url = request?.url?.toString() ?: ""

        methodChannel.invokeMethod("onNavigationRequest", url, object : MethodChannel.Result {
            override fun success(result: Any?) {
                val allow = result as? Boolean ?: false
                if (allow) {
                    view?.loadUrl(url)
                }
            }
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
            override fun notImplemented() {}
        })

        return true
    }

    override fun onPageFinished(view: WebView?, url: String?) {
        methodChannel.invokeMethod("onPageFinished", true)
        super.onPageFinished(view, url)
    }
}