import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerVideoLoadedEvent extends PlayerEvent {
  final String videoId;

  const PlayerVideoLoadedEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}
