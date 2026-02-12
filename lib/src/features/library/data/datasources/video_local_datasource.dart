import 'package:skill_tube/objectbox.g.dart'; // Generated bindings
import 'package:skill_tube/src/core/error/exception.dart';
import 'package:skill_tube/src/features/library/data/models/video_model.dart';

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
    try {
      final query = _box.query()..order(VideoModel_.addedAt, flags: Order.descending);
      return query.build().find();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<VideoModel?> getLastPlayedVideo() async {
    try {
      // Query: lastPlayedAt DESC LIMIT 1
      final queryPlayed = _box.query(VideoModel_.lastPlayedAt.notNull())
        ..order(VideoModel_.lastPlayedAt, flags: Order.descending);

      final lastPlayed = queryPlayed.build().findFirst();
      if (lastPlayed != null) return lastPlayed;

      // Fallback: addedAt DESC LIMIT 1
      final queryAdded = _box.query()
        ..order(VideoModel_.addedAt, flags: Order.descending);

      return queryAdded.build().findFirst();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addVideo(VideoModel video) async {
    try {
      // Check duplicate by unique youtubeId
      // ObjectBox throws UniqueViolationException if duplicate,
      // but we can also query to be safe/explicit with our error
      final existing = _box
          .query(VideoModel_.youtubeId.equals(video.youtubeId))
          .build()
          .findFirst();

      if (existing != null) {
        throw const VideoException('Video already exists', code: 'duplicate');
      }

      _box.put(video);
    } catch (e) {
      if (e is VideoException) rethrow;
      // ObjectBox unique violation might throw strictly, catch here if needed
      if (e.toString().contains('Unique constraint')) {
        throw const VideoException('Video already exists', code: 'duplicate');
      }
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteVideo(int id) async {
    try {
      _box.remove(id);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<VideoModel?> getVideo(String youtubeId) async {
    try {
      final query = _box.query(VideoModel_.youtubeId.equals(youtubeId)).build();
      final video = query.findFirst();
      query.close();
      return video;
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
