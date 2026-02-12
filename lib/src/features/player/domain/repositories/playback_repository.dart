import 'package:skill_tube/src/core/common/typedef.dart';

/// Contract for video playback progress operations.
///
/// Handles saving and retrieving watch position for the player feature.
/// Implemented by `PlaybackRepositoryImpl` in the Data Layer.
abstract class PlaybackRepository {
  /// Saves the current watch position for a video.
  ///
  /// Also updates `lastPlayedAt` to `DateTime.now()`.
  ///
  /// **Completion rule:** If `positionSeconds` exceeds 95% of the video's
  /// `durationSeconds`, the position is reset to `0` so the next session
  /// starts from the beginning. (PRD §6.6)
  ResultFuture<void> saveProgress({
    required String youtubeId,
    required int positionSeconds,
  });

  /// Retrieves the stored `lastWatchedPositionSeconds` for a video.
  ///
  /// Returns `0` if:
  /// - The video has never been played.
  /// - The stored position exceeds the video's current duration
  ///   (duration mismatch — PRD §6.6).
  ResultFuture<int> getProgress(String youtubeId);
}
