import 'package:skill_tube/main.dart';
import 'package:skill_tube/objectbox.g.dart'; // Generated bindings
import 'package:skill_tube/src/core/error/exception.dart';
import 'package:skill_tube/src/features/library/data/models/video_model.dart';
import 'package:talker_flutter/talker_flutter.dart';

abstract class VideoLocalDataSource {
  Future<List<VideoModel>> getAllVideos();
  Future<VideoModel?> getLastPlayedVideo();
  Future<void> addVideo(VideoModel video);
  Future<void> deleteVideo(int id);
  Future<VideoModel?> getVideo(String youtubeId);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  VideoLocalDataSourceImpl(this._store);
  final Store _store;

  Box<VideoModel> get _box => _store.box<VideoModel>();

  @override
  Future<List<VideoModel>> getAllVideos() async {
    talker.log('LocalDataSource: Fetching all videos', logLevel: LogLevel.debug);
    try {
      final query = _box.query()..order(VideoModel_.addedAt, flags: Order.descending);
      final videos = query.build().find();
      talker.log('LocalDataSource: Found ${videos.length} videos', logLevel: LogLevel.debug);
      return videos;
    } catch (e, st) {
      talker.handle(e, st, 'LocalDataSource: Error fetching all videos');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<VideoModel?> getLastPlayedVideo() async {
    talker.log('LocalDataSource: Fetching last played video', logLevel: LogLevel.debug);
    try {
      // Query: lastPlayedAt DESC LIMIT 1
      final queryPlayed = _box.query(VideoModel_.lastPlayedAt.notNull())
        ..order(VideoModel_.lastPlayedAt, flags: Order.descending);

      final lastPlayed = queryPlayed.build().findFirst();
      if (lastPlayed != null) {
        talker.log('LocalDataSource: Found last played: ${lastPlayed.title}', logLevel: LogLevel.debug);
        return lastPlayed;
      }

      // Fallback: addedAt DESC LIMIT 1
      final queryAdded = _box.query()
        ..order(VideoModel_.addedAt, flags: Order.descending);

      final lastAdded = queryAdded.build().findFirst();
      talker.log('LocalDataSource: Found fallback last added: ${lastAdded?.title}', logLevel: LogLevel.debug);
      return lastAdded;
    } catch (e, st) {
      talker.handle(e, st, 'LocalDataSource: Error fetching last played video');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addVideo(VideoModel video) async {
    talker.log('LocalDataSource: Adding video: ${video.title} (${video.youtubeId})', logLevel: LogLevel.info);
    try {
      // Check duplicate by unique youtubeId
      final existing = _box
          .query(VideoModel_.youtubeId.equals(video.youtubeId))
          .build()
          .findFirst();

      if (existing != null) {
        talker.error('LocalDataSource: Video already exists: ${video.youtubeId}');
        throw const VideoException('Video already exists', code: 'duplicate');
      }

      final id = _box.put(video);
      talker.log('LocalDataSource: Video added successfully with ID: $id', logLevel: LogLevel.info);
    } catch (e, st) {
      if (e is VideoException) rethrow;
      talker.handle(e, st, 'LocalDataSource: Error adding video');
      if (e.toString().contains('Unique constraint')) {
        throw const VideoException('Video already exists', code: 'duplicate');
      }
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteVideo(int id) async {
    talker.log('LocalDataSource: Deleting video ID: $id', logLevel: LogLevel.info);
    try {
      _box.remove(id);
      talker.log('LocalDataSource: Video deleted successfully', logLevel: LogLevel.info);
    } catch (e, st) {
      talker.handle(e, st, 'LocalDataSource: Error deleting video');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<VideoModel?> getVideo(String youtubeId) async {
    talker.log('LocalDataSource: Getting video by youtubeId: $youtubeId', logLevel: LogLevel.debug);
    try {
      final query = _box.query(VideoModel_.youtubeId.equals(youtubeId)).build();
      final video = query.findFirst();
      query.close();
      return video;
    } catch (e, st) {
      talker.handle(e, st, 'LocalDataSource: Error getting video');
      throw DatabaseException(e.toString());
    }
  }
}
