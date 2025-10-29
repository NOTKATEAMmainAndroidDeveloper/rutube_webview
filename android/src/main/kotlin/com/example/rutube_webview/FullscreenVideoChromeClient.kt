package com.example.rutube_webview

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.webkit.WebChromeClient
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.view.WindowInsets
import android.view.WindowInsetsController
import androidx.core.view.WindowInsetsCompat

class FullscreenVideoChromeClient(
    private val activity: Activity,
    private val methodChannel: MethodChannel
) : WebChromeClient() {
    private var customView: View? = null
    private var customViewCallback: CustomViewCallback? = null
    private var fullscreenContainer: FrameLayout? = null
    private var hideNavBarRunnable: Runnable? = null

    override fun onShowCustomView(view: View, callback: CustomViewCallback) {
        methodChannel.invokeMethod(
            "onFullscreenChangeStart",
            true,
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    showCustomViewInternal(view, callback)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    TODO("Not yet implemented")
                }

                override fun notImplemented() {}
            })
    }

    private fun showCustomViewInternal(view: View, callback: CustomViewCallback) {
        if (customView != null) {
            callback.onCustomViewHidden()
            return
        }

        customView = view
        customViewCallback = callback

        fullscreenContainer = FrameLayout(activity).apply {
            setOnApplyWindowInsetsListener{ _, insets ->
                val orientation = context.resources.configuration.orientation

                val topInset = if (orientation == android.content.res.Configuration.ORIENTATION_PORTRAIT)
                    getSafeTopInset(activity)
                else
                    0

                view.setPadding(0, topInset, 0, 0)

                insets
            }

            val blackBack = View(context).apply {
                setBackgroundColor(android.graphics.Color.BLACK)
                layoutParams = FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                )
            }
            addView(blackBack)

            addView(
                view, FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
            )
        }

        val decorView = activity.window.decorView as ViewGroup
        decorView.addView(
            fullscreenContainer, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )

        hideNavBarRunnable = Runnable {
            hideBars()
            activity.window.decorView.postDelayed(hideNavBarRunnable!!, 3000)
        }
        activity.window.decorView.post(hideNavBarRunnable!!)

        hideBars()

        methodChannel.invokeMethod("onFullscreenChanged", true)
    }

    override fun onHideCustomView() {
        methodChannel.invokeMethod(
            "onFullscreenChangeStart",
            false,
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    hideCustomViewInternal()
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    TODO("Not yet implemented")
                }

                override fun notImplemented() {}
            })
    }

    private fun hideCustomViewInternal() {
        if (customView == null) return

        val decorView = activity.window.decorView as ViewGroup
        decorView.removeView(fullscreenContainer)
        fullscreenContainer = null
        customView = null
        customViewCallback?.onCustomViewHidden()

        hideNavBarRunnable?.let { activity.window.decorView.removeCallbacks(it) }
        hideNavBarRunnable = null

        showBars()

        methodChannel.invokeMethod("onFullscreenChanged", false)
    }

    private fun hideBars() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val windowInsetsController = activity.window.insetsController

            windowInsetsController?.hide(
                WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars()
            )

            windowInsetsController?.systemBarsBehavior =
                WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        } else {
            activity.window.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        }
    }



    private fun showBars() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val windowInsetsController = activity.window.insetsController

            windowInsetsController?.show(
                WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars()
            )
        } else {
            activity.window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
        }
    }

    private fun getSafeTopInset(activity: Activity): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val windowInsets = activity.window.decorView.rootWindowInsets
            val cutout = windowInsets?.displayCutout
            if (cutout != null && cutout.safeInsetTop > 0) {
                return cutout.safeInsetTop
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val insets = activity.window.decorView.rootWindowInsets
            val topInset = insets?.getInsets(WindowInsets.Type.statusBars())?.top
            if (topInset != null && topInset > 0) {
                return topInset
            }
        } else {
            val insets = activity.window.decorView.rootWindowInsets
            val topInset = insets?.systemWindowInsetTop
            if (topInset != null && topInset > 0) {
                return topInset
            }
        }

        return 0
    }

}
