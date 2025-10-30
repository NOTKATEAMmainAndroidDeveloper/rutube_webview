import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rutube_webview/rutube_webview.dart';

/// Виджет для корректного отображения видео
///
/// [url] - ссылка на видео
///
/// [onFullScreenChange] - вызывается при изменении полноэкранного режима
/// возвращает контроллер виджета и значение полноэкранного режима,
///
/// [onFullScreenChangeStart] - вызывается при старте изменения полноэкранного режима
/// возвращает контроллер виджета и значение полноэкранного режима, который будет определен
///
/// [onPageFinished] - вызывается при завершении загрузки страницы
/// возвращает контроллер виджета
class RutubeWebview extends StatelessWidget {
  const RutubeWebview({
    super.key,
    required this.url,
    this.onFullScreenChange,
    this.onFullScreenChangeStart,
    this.onPageFinished,
    this.onNavigationRequest,
  });

  final String url;
  final void Function(RutubeWebviewController controller, bool value)? onFullScreenChange;
  final Future<bool> Function(RutubeWebviewController controller, bool value)? onFullScreenChangeStart;
  final void Function(RutubeWebviewController controller)? onPageFinished;
  final Future<bool> Function(RutubeWebviewController controller, String url)? onNavigationRequest;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      global: true,
      autoRemove: false,
      init: RutubeWebviewController(
        onFullScreenChange: onFullScreenChange,
        onFullScreenChangeStart: onFullScreenChangeStart,
        onPageFinished: onPageFinished,
      ),
      builder:
          (ctl) => Platform.isAndroid ? AndroidView(
            key: ValueKey(0),
            viewType: 'rutube-webview',
            creationParams: {'initialUrl': url},
            creationParamsCodec: const StandardMessageCodec(),
          ) : UiKitView(
            key: ValueKey(0),
            viewType: 'rutube-webview',
            creationParams: {'initialUrl': url},
            creationParamsCodec: const StandardMessageCodec(),
          ),
    );
  }
}
