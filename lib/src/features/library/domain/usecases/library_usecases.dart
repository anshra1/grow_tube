import 'package:skill_tube/src/core/common/typedef.dart';
import 'package:skill_tube/src/core/common/usecase.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/domain/repositories/video_repository.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GET ALL VIDEOS
// ══════════════════════════════════════════════════════════════════════════════

/// Retrieves every saved video, ordered by `addedAt` descending (newest first).
class GetAllVideos extends FutureUseCaseWithoutParams<List<Video>> {
  const GetAllVideos(this._repository);
  final VideoRepository _repository;

  @override
  ResultFuture<List<Video>> call() => _repository.getAllVideos();
}

/// Retrieves a specific video by its YouTube ID.
class GetVideo extends FutureUseCaseWithParams<Video?, String> {
  const GetVideo(this._repository);
  final VideoRepository _repository;

  @override
  ResultFuture<Video?> call(String params) => _repository.getVideo(params);
}

// ══════════════════════════════════════════════════════════════════════════════
// GET LAST PLAYED VIDEO
// ══════════════════════════════════════════════════════════════════════════════

/// Retrieves the most recently played video for the Hero Header.
///
/// Falls back to the most recently added video if none have been played.
class GetLastPlayedVideo extends FutureUseCaseWithoutParams<Video?> {
  const GetLastPlayedVideo(this._repository);
  final VideoRepository _repository;

  @override
  ResultFuture<Video?> call() => _repository.getLastPlayedVideo();
}

// ══════════════════════════════════════════════════════════════════════════════
// ADD VIDEO
// ══════════════════════════════════════════════════════════════════════════════

/// Adds a new video to the library from a YouTube URL.
///
/// Fetches metadata via `youtube_explode_dart` and persists to ObjectBox.
class AddVideo extends FutureUseCaseWithParams<Video, String> {
  const AddVideo(this._repository);
  final VideoRepository _repository;

  @override
  ResultFuture<Video> call(String params) => _repository.addVideo(params);
}

// ══════════════════════════════════════════════════════════════════════════════
// DELETE VIDEO
// ══════════════════════════════════════════════════════════════════════════════

/// Deletes a video and its watch history from the database.
class DeleteVideo extends FutureUseCaseWithParams<void, int> {
  const DeleteVideo(this._repository);
  final VideoRepository _repository;

  @override
  ResultFuture<void> call(int params) => _repository.deleteVideo(params);
}

// ══════════════════════════════════════════════════════════════════════════════
// UPDATE VIDEO PROGRESS
// ══════════════════════════════════════════════════════════════════════════════

class UpdateVideoProgressParams {
  const UpdateVideoProgressParams({
    required this.youtubeId,
    required this.positionSeconds,
  });
  final String youtubeId;
  final int positionSeconds;
}

/// Updates the watch progress and last played timestamp of a video.
class UpdateVideoProgress extends FutureUseCaseWithParams<void, UpdateVideoProgressParams> {
  const UpdateVideoProgress(this._repository);
  final VideoRepository _repository;

  @override
  ResultFuture<void> call(UpdateVideoProgressParams params) =>
      _repository.updateVideoProgress(params.youtubeId, params.positionSeconds);
}
