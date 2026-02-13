import 'package:equatable/equatable.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

sealed class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

final class PlayerInitialState extends PlayerState {
  const PlayerInitialState();
}

final class PlayerLoadingState extends PlayerState {
  const PlayerLoadingState();
}

final class PlayerLoadedState extends PlayerState {
  final Video video;

  const PlayerLoadedState(this.video);

  @override
  List<Object?> get props => [video];
}

final class PlayerFailureState extends PlayerState {
  final String message;

  const PlayerFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
