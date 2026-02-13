import 'package:flutter/services.dart';

class ClipboardService {
  // Singleton pattern
  static final ClipboardService _instance = ClipboardService._internal();
  factory ClipboardService() => _instance;
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
    final regExp = RegExp(
      r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
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
