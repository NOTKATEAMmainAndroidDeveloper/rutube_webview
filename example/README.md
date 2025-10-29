# rutube_webview

**Flutter-плагин для интеграции RuTube WebView с поддержкой полноэкранного видео, смены ориентации и инъекции JavaScript для Android и iOS.**

## Использование

Простой пример использования:

```dart 
import 'package:rutube_webview/rutube_webview.dart';

RutubeWebview(
  url: 'https://rutube.ru/play/embed/123456',
  onFullScreenChange: (controller, isFullscreen) {
    print('Fullscreen: $isFullscreen');
  },
  onFullScreenChangeStart: (controller, isFullscreen) async {
    return true;
  },
  onPageFinished: (controller) {
    print('Страница загружена!');
  },
)
```

## API контроллера

    RutubeWebviewController controller; // Получаете из колбэков выше

    // Смена ориентации
    await controller.setOrientation(orientation: WebViewOrientation.landscape);

    // Инъекция JavaScript
    await controller.evaluateJavaScript('alert("Hello from JS!");');

## Параметры

| Параметр                       | Тип                                             | Описание                                |
|---------------------------------|-------------------------------------------------|-----------------------------------------|
| url                            | String                                          | URL для загрузки в WebView              |
| onFullScreenChange             | Function(RutubeWebviewController, bool)         | Событие входа/выхода в fullscreen       |
| onFullScreenChangeStart        | Future<bool> Function(RutubeWebviewController, bool) | Событие попытки входа/выхода в fullscreen |
| onPageFinished                 | Function(RutubeWebviewController)               | Событие окончания загрузки              |

## Лицензия

MIT
