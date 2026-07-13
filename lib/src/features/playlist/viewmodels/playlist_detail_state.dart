import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

sealed class PlaylistDetailState extends Equatable {
  const PlaylistDetailState();

  @override
  List<Object?> get props => [];
}

final class PlaylistDetailInitialState extends PlaylistDetailState {
  const PlaylistDetailInitialState();
}

final class PlaylistDetailLoadingState extends PlaylistDetailState {
  const PlaylistDetailLoadingState();
}

/// Loaded: holds the playlist info and the list of Video entities.
final class PlaylistDetailLoadedState extends PlaylistDetailState {
  const PlaylistDetailLoadedState({
    required this.playlist,
    required this.videos,
    this.heroVideo,
    this.forcePlayTimestamp,
  });

  final PlaylistModel playlist;
  final List<Video> videos;
  final Video? heroVideo;
  final int? forcePlayTimestamp;

  @override
  List<Object?> get props => [playlist, videos, heroVideo, forcePlayTimestamp];
}

final class PlaylistDetailEmptyState extends PlaylistDetailState {
  const PlaylistDetailEmptyState(this.playlist);
  final PlaylistModel playlist;

  @override
  List<Object?> get props => [playlist];
}

final class PlaylistDetailErrorState extends PlaylistDetailState {
  const PlaylistDetailErrorState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
