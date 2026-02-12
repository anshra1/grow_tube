import 'package:equatable/equatable.dart';

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the player page loads with a video ID.
final class PlayerVideoLoadedEvent extends PlayerEvent {
  const PlayerVideoLoadedEvent(this.videoId);
  final String videoId;

  @override
  List<Object?> get props => [videoId];
}

/// Triggered periodically or on pause to save progress.
final class PlayerProgressUpdatedEvent extends PlayerEvent {
  const PlayerProgressUpdatedEvent({
    required this.videoId,
    required this.positionSeconds,
  });

  final String videoId;
  final int positionSeconds;

  @override
  List<Object?> get props => [videoId, positionSeconds];
}

/// Triggered when user taps the screen to toggle HUD visibility.
final class PlayerControlsToggledEvent extends PlayerEvent {
  const PlayerControlsToggledEvent();
}
