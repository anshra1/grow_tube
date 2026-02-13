import 'package:equatable/equatable.dart';

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

final class PlayerVideoLoadedEvent extends PlayerEvent {
  final String videoId;

  const PlayerVideoLoadedEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}
