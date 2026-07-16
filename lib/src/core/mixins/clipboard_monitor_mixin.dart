import 'package:flutter/material.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart';
import 'package:levelup_tube/src/core/services/clipboard_service.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';

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

    // Check for Playlist first
    final playlistId = _clipboardService.extractYouTubePlaylistId(text);
    if (playlistId != null) {
      talker.debug(
        'ClipboardMonitorMixin: Clipboard text: $text, playlistId: $playlistId',
      );

      var isAlreadyImported = false;
      try {
        isAlreadyImported = await sl<PlaylistRepository>().isPlaylistImported(
          playlistId,
        );
      } on Exception catch (e) {
        talker.error('ClipboardMonitorMixin: DB Error checking playlistId: $e');
        isAlreadyImported = true; // safe default
      }

      if (isAlreadyImported) {
        talker.debug(
          'ClipboardMonitorMixin: Playlist $playlistId already in library, skipping',
        );
        return;
      }

      if (!_clipboardService.isNewUrl(text)) {
        talker.debug(
          'ClipboardMonitorMixin: Already prompted for playlist $playlistId this session',
        );
        return;
      }

      if (mounted) {
        talker.debug(
          'ClipboardMonitorMixin: Showing playlist popup for $playlistId',
        );
        onClipboardPlaylistDetected(text, playlistId);
      }
      return;
    }

    // Fallback to Video check
    final videoId = _clipboardService.extractYouTubeId(text);
    if (videoId == null) return;

    talker.debug(
      'ClipboardMonitorMixin: Clipboard text: $text, videoId: $videoId',
    );

    // DB is the authoritative source — always check it first
    var isAlreadyAdded = true; // safe default
    try {
      final library = await sl<PlaylistRepository>().getDefaultLibrary();
      final video = library.videos
          .where((v) => v.youtubeId == videoId)
          .firstOrNull;
      if (video != null) {
        talker.debug(
          'ClipboardMonitorMixin: DB result for $videoId: ${video.title}',
        );
        isAlreadyAdded = true;
      } else {
        isAlreadyAdded = false;
      }
    } on Exception catch (e) {
      talker.error('ClipboardMonitorMixin: DB Error checking videoId: $e');
    }

    if (isAlreadyAdded) {
      talker.debug(
        'ClipboardMonitorMixin: Video $videoId already in library, skipping',
      );
      return;
    }

    // Same-session dedup: don't show popup for same URL twice in one session
    if (!_clipboardService.isNewUrl(text)) {
      talker.debug(
        'ClipboardMonitorMixin: Already prompted for $videoId this session',
      );
      return;
    }

    if (mounted) {
      talker.debug('ClipboardMonitorMixin: Showing popup for $videoId');
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
