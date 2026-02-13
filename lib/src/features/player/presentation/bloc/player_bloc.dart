import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/src/features/library/domain/usecases/library_usecases.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_event.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final GetVideo getVideo;

  PlayerBloc({required this.getVideo}) : super(const PlayerInitialState()) {
    on<PlayerVideoLoadedEvent>(_onVideoLoaded);
  }

  Future<void> _onVideoLoaded(
    PlayerVideoLoadedEvent event,
    Emitter<PlayerState> emit,
  ) async {
    emit(const PlayerLoadingState());

    final result = await getVideo(event.videoId);

    result.fold(
      (failure) => emit(PlayerFailureState(failure.message)),
      (video) {
        if (video == null) {
          emit(const PlayerFailureState('Video not found in library'));
        } else {
          emit(PlayerLoadedState(video));
        }
      },
    );
  }
}
