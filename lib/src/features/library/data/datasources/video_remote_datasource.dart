import 'package:skill_tube/main.dart';
import 'package:skill_tube/src/core/error/exception.dart';
import 'package:skill_tube/src/features/library/data/models/video_model.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class VideoRemoteDataSource {
  /// Fetches video metadata from YouTube URL.
  /// Returns a [VideoModel] ready for insertion (id=0).
  Future<VideoModel> fetchVideoDetails(String url);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  VideoRemoteDataSourceImpl(this._yt);
  final YoutubeExplode _yt;

  @override
  Future<VideoModel> fetchVideoDetails(String url) async {
    talker.log('RemoteDataSource: Fetching video details for $url', logLevel: LogLevel.info);
    try {
      // 1. Parse URL / Get ID
      final VideoId videoId;
      try {
        videoId = VideoId(url);
      } catch (_) {
        talker.error('RemoteDataSource: Invalid URL: $url');
        throw const VideoException(
          'Invalid YouTube URL',
          code: 'invalidUrl',
        );
      }

      // 2. Fetch Metadata
      talker.log('RemoteDataSource: Calling YouTube Explode for ID: ${videoId.value}', logLevel: LogLevel.debug);
      final video = await _yt.videos.get(videoId);
      talker.log('RemoteDataSource: Metadata fetched: ${video.title}', logLevel: LogLevel.info);

      // 3. Map to Model (id=0, new entry)
      return VideoModel(
        youtubeId: video.id.value,
        title: video.title,
        channelName: video.author,
        thumbnailUrl: video.thumbnails.highResUrl,
        durationSeconds: video.duration?.inSeconds ?? 0,
        addedAt: DateTime.now(),
      );
    } on VideoException {
      rethrow; // Pass through our own exceptions
    } catch (e, st) {
      talker.handle(e, st, 'RemoteDataSource: Error fetching video details');
      // Map platform/network errors
      if (e.toString().contains('VideoUnavailable')) {
        throw const VideoException(
          'Video is private or deleted',
          code: 'videoUnavailable',
        );
      }
      throw VideoException(
        e.toString(),
        code: 'offline', // Default to offline/network error if unsure
      );
    }
  }
}
