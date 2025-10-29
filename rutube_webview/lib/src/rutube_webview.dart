import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rutube_webview/rutube_webview.dart';

class RutubeWebview extends StatelessWidget {
  const RutubeWebview({
    super.key,
    required this.url,
    this.onFullScreenChange,
    this.onFullScreenChangeStart,
    this.onPageFinished,
  });

  final String url;
  final void Function(RutubeWebviewController controller, bool value)? onFullScreenChange;
  final Future<bool> Function(RutubeWebviewController controller, bool value)? onFullScreenChangeStart;
  final void Function(RutubeWebviewController controller)? onPageFinished;

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
