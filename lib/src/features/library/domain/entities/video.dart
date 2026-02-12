import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';

/// Domain entity for a saved video in the user's library.
///
/// This is a Pure Dart entity — no ObjectBox, no JSON, no Flutter imports.
/// See `doc/data/video_entity_schema.md` for the full schema.
@freezed
abstract class Video with _$Video {
  const factory Video({
    required int id,
    required String youtubeId,
    required String title,
    required String channelName,
    required String thumbnailUrl,
    required int durationSeconds,
    required int lastWatchedPositionSeconds,
    required DateTime addedAt,
    DateTime? lastPlayedAt,
  }) = _Video;
  const Video._();

  /// Fraction of video watched (0.0 to 1.0).
  /// Returns 0.0 if `durationSeconds` is 0 to avoid division by zero.
  double get progressPercent =>
      durationSeconds > 0 ? lastWatchedPositionSeconds / durationSeconds : 0.0;

  /// Whether the video is considered finished (>95% watched).
  /// When true, the next play session should start from 0:00.
  bool get isCompleted => progressPercent > 0.95;

  /// Whether this video has ever been played.
  /// Used by Hero Header to decide "Play" vs "Resume" badge.
  bool get hasBeenPlayed => lastPlayedAt != null;
}
