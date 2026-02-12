import 'package:skill_tube/objectbox.g.dart';
import 'package:skill_tube/src/core/error/exception.dart';
import 'package:skill_tube/src/features/library/data/models/video_model.dart';

abstract class PlaybackLocalDataSource {
  Future<void> saveProgress(String youtubeId, int positionSeconds);
  Future<int> getProgress(String youtubeId);
  Future<VideoModel?> getVideo(String youtubeId);
}

class PlaybackLocalDataSourceImpl implements PlaybackLocalDataSource {
  PlaybackLocalDataSourceImpl(this._store);
  final Store _store;

  Box<VideoModel> get _box => _store.box<VideoModel>();

  @override
  Future<void> saveProgress(String youtubeId, int positionSeconds) async {
    try {
      final query = _box.query(VideoModel_.youtubeId.equals(youtubeId)).build();
      final video = query.findFirst();
      query.close();

      if (video != null) {
        video.lastWatchedPositionSeconds = positionSeconds;
        video.lastPlayedAt = DateTime.now();
        _box.put(video);
      }
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<int> getProgress(String youtubeId) async {
    try {
      final query = _box.query(VideoModel_.youtubeId.equals(youtubeId)).build();
      final video = query.findFirst();
      query.close();

      if (video == null) return 0;
      return video.lastWatchedPositionSeconds;
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
