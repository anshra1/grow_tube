import 'package:flutter/services.dart';

class ClipboardService {
  factory ClipboardService() => _instance;
  ClipboardService._internal();
  // Singleton pattern
  static final ClipboardService _instance =
      ClipboardService._internal();

  String? _lastProcessedUrl;

  /// Reads text from the system clipboard.
  Future<String?> getClipboardText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  /// Validates a string to see if it's a YouTube URL and extracts the ID.
  /// Returns the video ID if valid, otherwise null.
  String? extractYouTubeId(String url) {
    // False positive in Dart 3.10
    // ignore: deprecated_member_use
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/|v\/|shorts\/|live\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.group(1) != null) {
      return match.group(1);
    }

    // Fallback: check if the string itself is just an 11-char ID
    // False positive in Dart 3.10
    // ignore: deprecated_member_use
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url.trim())) {
      return url.trim();
    }

    return null;
  }

  /// Validates a string to see if it's a YouTube playlist URL and extracts the ID.
  /// Returns the playlist ID if valid, otherwise null.
  String? extractYouTubePlaylistId(String url) {
    // False positive in Dart 3.10
    // ignore: deprecated_member_use
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:playlist\?|watch\?.*&)list=)([a-zA-Z0-9_-]+)',
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.group(1) != null) {
      return match.group(1);
    }
    return null;
  }

  /// Checks if the given URL is new and hasn't been processed yet.
  bool isNewUrl(String url) {
    if (url.isNotEmpty && url != _lastProcessedUrl) {
      _lastProcessedUrl = url;
      return true;
    }
    return false;
  }

  /// Clears the last processed URL, allowing it to be processed again.
  void clearLastUrl() {
    _lastProcessedUrl = null;
  }
}
