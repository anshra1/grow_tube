import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/features/library/data/datasources/youtube_api_service.dart';
import 'package:levelup_tube/src/features/library/data/models/video_model.dart';
import 'package:talker_flutter/talker_flutter.dart';

abstract class VideoRemoteDataSource {
  /// Fetches video metadata from YouTube URL.
  /// Returns a [VideoModel] ready for insertion (id=0).
  Future<VideoModel> fetchVideoDetails(String url);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  VideoRemoteDataSourceImpl(this._apiService);
  final YoutubeApiService _apiService;

  /// Regex to extract video ID from various YouTube URL formats.
  static final _videoIdRegex = RegExp(
    r'(?:youtube\.com\/(?:watch\?v=|embed\/|v\/|shorts\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
  );

  @override
  Future<VideoModel> fetchVideoDetails(String url) async {
    talker.log(
      'RemoteDataSource: Fetching video details for $url',
      logLevel: LogLevel.info,
    );

    // 1. Extract video ID from URL
    final videoId = _extractVideoId(url);

    // 2. Fetch metadata via YouTube Data API v3
    talker.log(
      'RemoteDataSource: Calling YouTube API for ID: $videoId',
      logLevel: LogLevel.debug,
    );

    final data = await _apiService.fetchVideoDetails(videoId);

    talker.log(
      'RemoteDataSource: Metadata fetched: ${data['title']}',
      logLevel: LogLevel.info,
    );

    // 3. Map to Model (id=0, new entry)
    return VideoModel(
      youtubeId: data['id'] as String,
      title: data['title'] as String,
      channelName: data['channelTitle'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String,
      durationSeconds: data['durationSeconds'] as int,
      addedAt: DateTime.now(),
    );
  }

  /// Extracts an 11-char YouTube video ID from various URL formats.
  /// Throws [VideoException] if the URL is invalid.
  String _extractVideoId(String url) {
    // Try direct 11-char ID (e.g. pasted from share)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url.trim())) {
      return url.trim();
    }

    final match = _videoIdRegex.firstMatch(url);
    if (match == null || match.group(1) == null) {
      talker.error('RemoteDataSource: Invalid URL: $url');
      throw const VideoException('Invalid YouTube URL', code: 'invalidUrl');
    }
    return match.group(1)!;
  }
}
