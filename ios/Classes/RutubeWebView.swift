import Flutter
import UIKit
import WebKit

class RutubeWebView: NSObject, FlutterPlatformView {
    private var webView: WKWebView
    private var methodChannel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsPictureInPictureMediaPlayback = true

        if #available(iOS 15.4, *) {
            configuration.preferences.isElementFullscreenEnabled = true
        }

        self.webView = WKWebView(frame: frame, configuration: configuration)
        self.methodChannel = FlutterMethodChannel(
            name: "rutube_webview_channel_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.uiDelegate = self
        webView.navigationDelegate = self

        if let args = args as? [String: Any],
           let urlString = args["initialUrl"] as? String,
           let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        setupMethodChannel()
    }

    func view() -> UIView {
        return webView
    }

    private func setupMethodChannel() {
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "WebView disposed", details: nil))
                return
            }

            switch call.method {
            case "setOrientationPortrait":
                self.setOrientation(.portrait)
                result(true)

            case "setOrientationLandscape":
                self.setOrientation(.landscapeLeft)
                result(true)

            case "evaluateJavaScript":
                if let jsCode = call.arguments as? String {
                    self.webView.evaluateJavaScript(jsCode) { _, error in
                        if let error = error {
                            result(FlutterError(code: "JS_ERROR", message: error.localizedDescription, details: nil))
                        } else {
                            result(true)
                        }
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "JavaScript code required", details: nil))
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func setOrientation(_ orientation: UIInterfaceOrientation) {
        if #available(iOS 13.0, *) {
            if #available(iOS 16.0, *) {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    return
                }

                let orientationMask: UIInterfaceOrientationMask = orientation == .portrait ? .portrait : .landscapeRight
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationMask))

                if let viewController = windowScene.windows.first?.rootViewController {
                    viewController.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            } else {
                UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
                UINavigationController.attemptRotationToDeviceOrientation()
            }
        } else {
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}

extension RutubeWebView: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension RutubeWebView: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        let url = navigationAction.request.url?.absoluteString ?? ""
        methodChannel.invokeMethod("onNavigationRequest", url, result: { result in
            if let allow = result as? Bool, allow {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        })
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        methodChannel.invokeMethod("onPageFinished", arguments: true)
    }
}
