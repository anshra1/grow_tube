import 'package:equatable/equatable.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

class PlayerInitialState extends PlayerState {
  const PlayerInitialState();
}

class PlayerLoadingState extends PlayerState {
  const PlayerLoadingState();
}

class PlayerLoadedState extends PlayerState {
  final Video video;

  const PlayerLoadedState(this.video);

  @override
  List<Object?> get props => [video];
}

class PlayerFailureState extends PlayerState {
  final String message;

  const PlayerFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
