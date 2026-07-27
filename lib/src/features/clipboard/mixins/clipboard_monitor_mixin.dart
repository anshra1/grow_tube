import 'package:flutter/material.dart';
import 'package:levelup_tube/src/features/clipboard/service/clipboard_service.dart';

mixin ClipboardMonitorMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  final ClipboardService _clipboardService = ClipboardService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboard();
    });
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

    if (_clipboardService.hasBeenProcessed(text)) {
      return;
    }

    // Check for Playlist first
    final playlistId = _clipboardService.extractYouTubePlaylistId(text);
    if (playlistId != null) {
      if (mounted) {
        _clipboardService.markAsProcessed(text);
        onClipboardPlaylistDetected(text, playlistId);
      }
      return;
    }

    // Fallback to Video check
    final videoId = _clipboardService.extractYouTubeId(text);
    if (videoId == null) return;

    if (mounted) {
      _clipboardService.markAsProcessed(text);
      onClipboardUrlDetected(text, videoId);
    }
  }

  /// Abstract method to be implemented by the widget using the mixin.
  /// This is called when a new, valid YouTube Video URL is detected.
  void onClipboardUrlDetected(String url, String videoId);

  /// Abstract method to be implemented by the widget using the mixin.
  /// This is called when a new, valid YouTube Playlist URL is detected.
  void onClipboardPlaylistDetected(String url, String playlistId);
}
