import 'package:flutter/material.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart';
import 'package:levelup_tube/src/core/services/clipboard_service.dart';
import 'package:levelup_tube/src/features/library/domain/usecases/library_usecases.dart';

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

    final videoId = _clipboardService.extractYouTubeId(text);
    if (videoId == null) return;

    talker.debug('ClipboardMonitorMixin: Clipboard text: $text, videoId: $videoId');

    // DB is the authoritative source — always check it first
    final getVideoResult = await sl<GetVideo>()(videoId);
    final isAlreadyAdded = getVideoResult.fold(
      (failure) {
        talker.error('ClipboardMonitorMixin: DB Error checking videoId: $failure');
        return true; // On error, assume already added (safe default)
      },
      (video) {
        talker.debug('ClipboardMonitorMixin: DB result for $videoId: ${video?.title}');
        return video != null;
      },
    );

    if (isAlreadyAdded) {
      talker.debug('ClipboardMonitorMixin: Video $videoId already in library, skipping');
      return;
    }

    // Same-session dedup: don't show popup for same URL twice in one session
    if (!_clipboardService.isNewUrl(text)) {
      talker.debug('ClipboardMonitorMixin: Already prompted for $videoId this session');
      return;
    }

    if (mounted) {
      talker.debug('ClipboardMonitorMixin: Showing popup for $videoId');
      onClipboardUrlDetected(text, videoId);
    }
  }

  /// Abstract method to be implemented by the widget using the mixin.
  /// This is called when a new, valid YouTube URL is detected.
  void onClipboardUrlDetected(String url, String videoId);
}
