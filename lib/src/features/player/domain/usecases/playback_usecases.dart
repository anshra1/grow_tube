import 'package:equatable/equatable.dart';
import 'package:skill_tube/src/core/common/typedef.dart';
import 'package:skill_tube/src/core/common/usecase.dart';
import 'package:skill_tube/src/features/player/domain/repositories/playback_repository.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SAVE WATCH PROGRESS
// ══════════════════════════════════════════════════════════════════════════════

/// Params for saving watch progress.
class SaveWatchProgressParams extends Equatable {
  const SaveWatchProgressParams({
    required this.youtubeId,
    required this.positionSeconds,
  });

  final String youtubeId;
  final int positionSeconds;

  @override
  List<Object?> get props => [youtubeId, positionSeconds];
}

/// Persists the current watch position for a video.
///
/// Fires on: Pause, Navigation exit, App background, Dispose, 60s heartbeat.
/// Applies >95% completion reset automatically (handled in repository).
class SaveWatchProgress extends FutureUseCaseWithParams<void, SaveWatchProgressParams> {
  const SaveWatchProgress(this._repository);
  final PlaybackRepository _repository;

  @override
  ResultFuture<void> call(SaveWatchProgressParams params) => _repository.saveProgress(
    youtubeId: params.youtubeId,
    positionSeconds: params.positionSeconds,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// GET WATCH PROGRESS
// ══════════════════════════════════════════════════════════════════════════════

/// Retrieves the stored watch position for auto-resume.
///
/// Returns `0` if the video has never been played or if there is a
/// duration mismatch (stored position > current duration).
class GetWatchProgress extends FutureUseCaseWithParams<int, String> {
  const GetWatchProgress(this._repository);
  final PlaybackRepository _repository;

  @override
  ResultFuture<int> call(String params) => _repository.getProgress(params);
}
