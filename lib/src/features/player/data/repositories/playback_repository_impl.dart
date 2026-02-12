import 'package:fpdart/fpdart.dart';
import 'package:skill_tube/src/core/common/typedef.dart';
import 'package:skill_tube/src/core/error/exception.dart';
import 'package:skill_tube/src/core/error/failure.dart';
import 'package:skill_tube/src/features/player/data/datasources/playback_local_datasource.dart';
import 'package:skill_tube/src/features/player/domain/repositories/playback_repository.dart';

class PlaybackRepositoryImpl implements PlaybackRepository {
  PlaybackRepositoryImpl(this._dataSource);
  final PlaybackLocalDataSource _dataSource;

  @override
  ResultFuture<void> saveProgress({
    required String youtubeId,
    required int positionSeconds,
  }) async {
    try {
      // 1. Get video to check duration
      final video = await _dataSource.getVideo(youtubeId);
      if (video == null) {
        // Video not found in DB? Should not happen if playing from library.
        // Fail silently or throw? Logic implies we only play what we have.
        // Return Right(null) as "saved nothing" is effectively "done".
        return const Right(null);
      }

      // 2. Apply completion logic (>95% -> reset to 0)
      final duration = video.durationSeconds;
      var savePosition = positionSeconds;
      if (duration > 0 && positionSeconds >= (duration * 0.95)) {
        savePosition = 0;
      }

      // 3. Save
      await _dataSource.saveProgress(youtubeId, savePosition);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<int> getProgress(String youtubeId) async {
    try {
      // 1. Get raw progress
      final progress = await _dataSource.getProgress(youtubeId);
      if (progress == 0) return const Right(0);

      // 2. Validate against duration (Duration Mismatch logic)
      final video = await _dataSource.getVideo(youtubeId);
      if (video == null) return const Right(0);

      if (progress > video.durationSeconds) {
        // Reset to 0? Or just return 0? Doc says "Returns 0 if ... mismatch".
        // Should we correct the DB? Ideally yes, but lazy correction is fine.
        return const Right(0);
      }

      return Right(progress);
    } on DatabaseException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
