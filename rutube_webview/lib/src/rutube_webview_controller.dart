import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rutube_webview/rutube_webview.dart';

class RutubeWebviewController extends GetxController {
  static const _channel = MethodChannel('rutube_webview_channel_0');

  final Function(RutubeWebviewController controller, bool value)? onFullScreenChange;
  final Function(RutubeWebviewController controller, bool value)? onFullScreenChangeStart;
  final Function(RutubeWebviewController controller)? onPageFinished;

  RutubeWebviewController({this.onFullScreenChange, this.onFullScreenChangeStart, this.onPageFinished});

  @override
  void onInit() {
    super.onInit();
    _channel.setMethodCallHandler((call) => _methodHandler(call));
  }

  Future<void> setOrientation({required WebViewOrientation orientation}) async {
    switch (orientation) {
      case WebViewOrientation.portrait:
        await _channel.invokeMethod('setOrientationPortrait');
        break;
      case WebViewOrientation.landscape:
        await _channel.invokeMethod('setOrientationLandscape');
        break;
    }
  }

  Future<void> evaluateJavaScript(String javaScript) async =>
      await _channel.invokeMethod('evaluateJavaScript', javaScript);

  Future<void> _methodHandler(MethodCall call) async {
    if (call.method == 'onFullscreenChanged') {
      var value = call.arguments as bool;
      onFullScreenChange?.call(this, value);
    }

    if (call.method == 'onFullscreenChangeStart') {
      var value = call.arguments as bool;
      await onFullScreenChangeStart?.call(this, value);
    }

    if (call.method == 'onPageFinished') {
      onPageFinished?.call(this);
    }
  }
}