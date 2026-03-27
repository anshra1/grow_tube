import 'dart:convert';

import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:http/http.dart' as http;
import 'package:talker_flutter/talker_flutter.dart';

/// Thin wrapper around the YouTube Data API v3 `videos.list` endpoint.
///
/// Fetches video metadata (title, channel, thumbnail, duration) using a
/// stable REST API instead of scraping YouTube HTML.
class YoutubeApiService {
  YoutubeApiService({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  static const _baseUrl = 'https://www.googleapis.com/youtube/v3/videos';

  /// Fetches video details for [videoId].
  ///
  /// Returns a map with keys: `id`, `title`, `channelTitle`,
  /// `thumbnailUrl`, `durationSeconds`.
  ///
  /// Throws [VideoException] on failure.
  Future<Map<String, dynamic>> fetchVideoDetails(String videoId) async {
    final uri = Uri.parse(
      '$_baseUrl?id=$videoId&part=snippet,contentDetails&key=$_apiKey',
    );

    talker.log(
      'YoutubeApiService: Fetching details for $videoId',
      logLevel: LogLevel.debug,
    );

    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw VideoException('Network error: unable to reach YouTube API', code: 'offline');
    }

    if (response.statusCode == 403) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final reason = _extractErrorReason(body);

      talker.error('YoutubeApiService: 403 Forbidden - reason: $reason');
      talker.debug('YoutubeApiService: Error body: ${response.body}');

      if (reason == 'quotaExceeded' || reason == 'rateLimitExceeded') {
        throw const VideoException(
          'YouTube API daily quota exceeded. Please try again tomorrow.',
          code: 'rateLimited',
        );
      }
      throw const VideoException(
        'Access denied by YouTube API. Check your API key.',
        code: 'forbidden',
      );
    }

    if (response.statusCode != 200) {
      throw VideoException(
        'YouTube API returned status ${response.statusCode}',
        code: 'serverError',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>?;

    if (items == null || items.isEmpty) {
      throw const VideoException(
        'Video not found — it may be private or deleted',
        code: 'videoUnavailable',
      );
    }

    final item = items[0] as Map<String, dynamic>;
    final snippet = item['snippet'] as Map<String, dynamic>;
    final contentDetails = item['contentDetails'] as Map<String, dynamic>;
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>;

    // Prefer high > medium > default thumbnail
    final thumbUrl =
        (thumbnails['high'] as Map<String, dynamic>?)?['url'] ??
        (thumbnails['medium'] as Map<String, dynamic>?)?['url'] ??
        (thumbnails['default'] as Map<String, dynamic>?)?['url'] ??
        '';

    return {
      'id': item['id'] as String,
      'title': snippet['title'] as String,
      'channelTitle': snippet['channelTitle'] as String,
      'thumbnailUrl': thumbUrl as String,
      'durationSeconds': _parseIsoDuration(contentDetails['duration'] as String),
    };
  }

  /// Parses ISO 8601 duration (e.g. `PT1H2M10S`) to total seconds.
  static int _parseIsoDuration(String iso) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(iso);
    if (match == null) return 0;

    final hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  /// Extracts the error `reason` from a YouTube API error response.
  static String _extractErrorReason(Map<String, dynamic> body) {
    try {
      final error = body['error'] as Map<String, dynamic>?;
      final errors = error?['errors'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        return (errors[0] as Map<String, dynamic>)['reason'] as String? ?? '';
      }
    } catch (_) {}
    return '';
  }
}
