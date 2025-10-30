import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rutube_webview/rutube_webview.dart';

/// Контроллер для работы с виджетом [RutubeWebview]
class RutubeWebviewController extends GetxController {
  MethodChannel? _channel;
  final String url;

  final void Function(RutubeWebviewController controller, bool value)? onFullScreenChange;
  final Future<bool> Function(RutubeWebviewController controller, bool value)? onFullScreenChangeStart;
  final void Function(RutubeWebviewController controller)? onPageFinished;
  final Future<bool> Function(RutubeWebviewController controller, String url)? onNavigationRequest;

  RutubeWebviewController({
    required this.url,
    this.onFullScreenChange,
    this.onFullScreenChangeStart,
    this.onPageFinished,
    this.onNavigationRequest,
  });

  void setPlatformViewId(int id) {
    _channel = MethodChannel('rutube_webview_channel_$id');
    _channel!.setMethodCallHandler((call) => _methodHandler(call));
  }

  /// Устанавливает ориентацию устройства
  Future<void> setOrientation({required WebViewOrientation orientation}) async {
    if (_channel == null) return;

    switch (orientation) {
      case WebViewOrientation.portrait:
        await _channel!.invokeMethod('setOrientationPortrait');
        break;
      case WebViewOrientation.landscape:
        await _channel!.invokeMethod('setOrientationLandscape');
        break;
    }
  }

  /// Выполняет JavaScript-скрипт в WebView
  Future<void> evaluateJavaScript(String javaScript) async =>
      await _channel!.invokeMethod('evaluateJavaScript', javaScript);

  Future<dynamic> _methodHandler(MethodCall call) async {
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

    if (call.method == 'onNavigationRequest') {
      var url = call.arguments as String;
      return await onNavigationRequest?.call(this, url) ?? false;
    }
  }
}
