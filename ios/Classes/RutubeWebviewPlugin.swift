import Flutter
import UIKit

public class RutubeWebviewPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = RutubeWebViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "rutube-webview")
    }
}
