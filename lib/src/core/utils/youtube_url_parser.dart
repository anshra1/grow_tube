class YoutubeUrlParser {
  static final _videoIdRegex = RegExp(
    r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live|shorts)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
  );

  /// Regex to extract playlist ID from YouTube playlist URLs.
  /// Matches: youtube.com/playlist?list=PLxxxxxx
  ///          youtube.com/watch?v=xxx&list=PLxxxxxx
  static final _playlistIdRegex = RegExp(
    r'(?:youtube\.com\/(?:playlist\?|watch\?.*&)list=)([a-zA-Z0-9_-]+)',
  );

  /// Extracts the YouTube video ID from a URL.
  static String? extractVideoId(String url) {
    // Try direct 11-char ID (e.g. pasted from share)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url.trim())) {
      return url.trim();
    }
    final match = _videoIdRegex.firstMatch(url);
    return match?.group(1);
  }

  /// Extracts a YouTube playlist ID from a URL.
  /// Returns null if the URL does not contain a playlist ID.
  static String? extractPlaylistId(String url) {
    final match = _playlistIdRegex.firstMatch(url);
    return match?.group(1);
  }
}
