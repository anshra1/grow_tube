import 'package:skill_tube/src/core/common/typedef.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

/// Contract for video library data operations.
///
/// Implemented by `VideoRepositoryImpl` in the Data Layer.
abstract class VideoRepository {
  /// Returns all saved videos, ordered by `addedAt` descending.
  ResultFuture<List<Video>> getAllVideos();

  /// Returns the most recently played video.
  ///
  /// Query: `lastPlayedAt DESC LIMIT 1`.
  /// Fallback: if no video has been played (`lastPlayedAt` is null for all),
  /// returns the most recently added video (`addedAt DESC LIMIT 1`).
  ResultFuture<Video?> getLastPlayedVideo();

  /// Adds a new video to the library from a YouTube URL.
  ///
  /// Fetches metadata (title, thumbnail, channel, duration) via
  /// `youtube_explode_dart` and saves to ObjectBox.
  ///
  // ignore: comment_references
  /// Returns a [VideoFailure] if:
  /// - URL is invalid (`invalidUrl`)
  /// - Video is private/deleted (`videoUnavailable`)
  /// - Video already exists (`duplicate`)
  /// - No internet connection (`offline`)
  ResultFuture<Video> addVideo(String url);

  /// Deletes a video and its watch history from the database.
  ResultFuture<void> deleteVideo(int id);

  /// Retrieves a specific video by its YouTube ID.
  /// Used by the Player to fetch metadata.
  ResultFuture<Video?> getVideo(String youtubeId);

  /// Updates the watch progress and last played timestamp of a video.
  ResultFuture<void> updateVideoProgress(String youtubeId, int positionSeconds);
}
