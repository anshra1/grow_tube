import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/src/features/library/domain/usecases/library_usecases.dart';
import 'package:skill_tube/src/features/player/domain/usecases/playback_usecases.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_event.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({
    required this.getVideo,
    required this.getWatchProgress,
    required this.saveWatchProgress,
  }) : super(const PlayerInitialState()) {
    on<PlayerVideoLoadedEvent>(_onVideoLoaded);
    on<PlayerProgressUpdatedEvent>(_onProgressUpdated);
    on<PlayerControlsToggledEvent>(_onControlsToggled);
  }

  final GetVideo getVideo;
  final GetWatchProgress getWatchProgress;
  final SaveWatchProgress saveWatchProgress;

  Future<void> _onVideoLoaded(
    PlayerVideoLoadedEvent event,
    Emitter<PlayerState> emit,
  ) async {
    emit(const PlayerLoadingState());

    // 1. Fetch Video Details
    final videoResult = await getVideo(event.videoId);

    // 2. Fetch Progress (if available)
    final progressResult = await getWatchProgress(event.videoId);

    videoResult.fold(
      (failure) => emit(PlayerErrorState(failure.message)),
      (video) {
        if (video == null) {
          emit(const PlayerErrorState('Video not found'));
          return;
        }

        final position = progressResult.fold(
          (l) => 0, // Ignore progress error, start from 0
          (r) => r,
        );

        emit(
          PlayerReadyState(
            video: video,
            initialPosition: position,
          ),
        );
      },
    );
  }

  Future<void> _onProgressUpdated(
    PlayerProgressUpdatedEvent event,
    Emitter<PlayerState> emit,
  ) async {
    // Fire and forget save? Or await?
    // Usually fire and forget for UI responsiveness, but standard practice is await in Bloc.
    // However, this event might fire frequently (if used for heartbeat).
    // If used only for pause/exit, await is fine.

    // Note: This handler doesn't necessarily emit a new state unless we track current position in state.
    // PlayerReadyState has `initialPosition` (start point). It doesn't track *current* live position
    // because that would cause 60fps rebuilds.
    // So we just save to DB here.

    final params = SaveWatchProgressParams(
      youtubeId: event.videoId,
      positionSeconds: event.positionSeconds,
    );

    await saveWatchProgress(params);
    // No emit needed unless we want to show "Saved" toast? F7 doesn't specify.
  }

  void _onControlsToggled(
    PlayerControlsToggledEvent event,
    Emitter<PlayerState> emit,
  ) {
    if (state is PlayerReadyState) {
      final s = state as PlayerReadyState;
      emit(s.copyWith(areControlsVisible: !s.areControlsVisible));
    }
  }
}
