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

final class PlayerReadyState extends PlayerState {
  const PlayerReadyState({
    required this.video,
    required this.initialPosition,
    this.areControlsVisible = true,
  });

  final Video video;

  /// The position to seek to when player initializes.
  final int initialPosition;

  final bool areControlsVisible;

  @override
  List<Object?> get props => [video, initialPosition, areControlsVisible];

  /// Helper to update control visibility without full rewrite
  PlayerReadyState copyWith({
    Video? video,
    int? initialPosition,
    bool? areControlsVisible,
  }) {
    return PlayerReadyState(
      video: video ?? this.video,
      initialPosition: initialPosition ?? this.initialPosition,
      areControlsVisible: areControlsVisible ?? this.areControlsVisible,
    );
  }
}

final class PlayerErrorState extends PlayerState {
  const PlayerErrorState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
