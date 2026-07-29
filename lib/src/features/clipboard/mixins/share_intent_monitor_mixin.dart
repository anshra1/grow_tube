import 'dart:async';
import 'package:flutter/material.dart';
import 'package:levelup_tube/src/features/clipboard/service/clipboard_service.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

mixin ShareIntentMonitorMixin<T extends StatefulWidget> on State<T> {
  final ClipboardService _clipboardService = ClipboardService();
  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initShareIntent();
  }

  void _initShareIntent() {
    // 1. Listen for intent while app is already in memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty) {
        _processSharedText(value.first.path); // Contains the shared URL/Text
      }
    });

    // 2. Listen for intent when app is opened from a closed state
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        _processSharedText(value.first.path);
        ReceiveSharingIntent.instance.reset(); // Clear the intent
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  void _processSharedText(String text) {
    if (_clipboardService.hasBeenProcessed(text)) return;

    // Check for Playlist
    final playlistId = _clipboardService.extractYouTubePlaylistId(text);
    if (playlistId != null) {
      if (mounted) {
        _clipboardService.markAsProcessed(text);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) onSharePlaylistDetected(text, playlistId);
        });
      }
      return;
    }

    // Check for Video
    final videoId = _clipboardService.extractYouTubeId(text);
    if (videoId == null) return;

    if (mounted) {
      _clipboardService.markAsProcessed(text);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onShareUrlDetected(text, videoId);
      });
    }
  }

  void onShareUrlDetected(String url, String videoId);
  void onSharePlaylistDetected(String url, String playlistId);
}
