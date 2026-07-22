import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

// Top-level overall state
sealed class PlaylistDetailState extends Equatable {
  const PlaylistDetailState();

  @override
  List<Object?> get props => [];
}

// Sub-state for playlist and videos (only changes when list/metadata changes)
class PlaylistVideosState extends Equatable {
  const PlaylistVideosState({required this.playlist, required this.videos});

  final PlaylistModel playlist;
  final List<Video> videos;

  @override
  List<Object?> get props => [playlist, videos];
}

// Sub-state for hero video (only changes when selected video changes)
class HeroVideoState extends Equatable {
  const HeroVideoState({this.heroVideo, this.forcePlayTimestamp});

  final Video? heroVideo;
  final int? forcePlayTimestamp;

  @override
  List<Object?> get props => [heroVideo, forcePlayTimestamp];
}

final class PlaylistDetailInitial extends PlaylistDetailState {
  const PlaylistDetailInitial();
}

final class PlaylistDetailLoading extends PlaylistDetailState {
  const PlaylistDetailLoading();
}

// adding success state
final class VideoAddPlaylistSuccessState extends PlaylistDetailState {
  const VideoAddPlaylistSuccessState();
}

final class PlaylistDetailEmpty extends PlaylistDetailState {
  const PlaylistDetailEmpty(this.playlist);
  final PlaylistModel playlist;

  @override
  List<Object?> get props => [playlist];
}

final class PlaylistDetailLoaded extends PlaylistDetailState {
  const PlaylistDetailLoaded({required this.videosState, required this.heroVideoState});

  final PlaylistVideosState videosState;
  final HeroVideoState heroVideoState;

  @override
  List<Object?> get props => [videosState, heroVideoState];
}

final class PlaylistDetailError extends PlaylistDetailState {
  const PlaylistDetailError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
