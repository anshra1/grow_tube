import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/services/clipboard_service.dart';

mixin ClipboardMonitorMixin<T extends StatefulWidget> on State<T> implements WidgetsBindingObserver {
  final ClipboardService _clipboardService = ClipboardService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final text = await _clipboardService.getClipboardText();
    if (text == null) return;

    if (_clipboardService.isNewUrl(text)) {
      final videoId = _clipboardService.extractYouTubeId(text);
      if (videoId != null && mounted) {
        onClipboardUrlDetected(text, videoId);
      }
    }
  }

  /// Abstract method to be implemented by the widget using the mixin.
  /// This is called when a new, valid YouTube URL is detected.
  void onClipboardUrlDetected(String url, String videoId);

  // Other WidgetsBindingObserver methods (empty implementations)
  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() => Future.value(false);

  @override
  Future<bool> didPushRoute(String route) => Future.value(false);
  
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) => Future.value(false);
  
  @override
  Future<AppExitResponse> didRequestAppExit() => Future.value(AppExitResponse.cancel);
}
