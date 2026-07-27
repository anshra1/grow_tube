import 'package:flutter/services.dart';
import 'package:levelup_tube/objectbox.g.dart';
import 'package:levelup_tube/src/features/clipboard/models/clipboard_history_model.dart';

class ClipboardService {
  factory ClipboardService() => _instance;
  ClipboardService._internal();
  // Singleton pattern
  static final ClipboardService _instance =
      ClipboardService._internal();

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

  Box<ClipboardHistoryModel>? _box;
  final List<String> _recentUrls = [];

  /// Initializes the service with the ObjectBox store.
  void init(Box<ClipboardHistoryModel> box) {
    _box = box;
    final history = _box?.getAll() ?? [];
    _recentUrls.addAll(history.map((e) => e.copiedText));
  }

  /// Checks if the given URL is in the recent history.
  bool hasBeenProcessed(String url) {
    if (url.isEmpty) return true;
    return _recentUrls.contains(url);
  }

  /// Marks a URL as processed and saves it to history.
  void markAsProcessed(String url) {
    if (url.isEmpty || _recentUrls.contains(url)) return;
    
    _recentUrls.add(url);
    if (_recentUrls.length > 3) {
      _recentUrls.removeAt(0); // keep only last 3
    }

    // Update ObjectBox
    if (_box != null) {
      _box!.removeAll(); // Clear old
      _box!.putMany(
        _recentUrls.map((e) => ClipboardHistoryModel(copiedText: e)).toList(),
      );
    }
  }
}
