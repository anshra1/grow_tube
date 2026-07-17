import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_state.dart';

class PlaylistDetailCubit extends Cubit<PlaylistDetailState> {
  PlaylistDetailCubit({
    required this.playlistId,
    required PlaylistRepository repository,
  }) : _repository = repository,
       super(const PlaylistDetailInitialState());

  final int playlistId;
  final PlaylistRepository _repository;

  /// Tracks which video the user explicitly selected as hero.
  int? _selectedHeroId;

  /// Load the playlist and its videos.
  Future<void> loadPlaylist() async {
    emit(const PlaylistDetailLoadingState());

    try {
      final playlist = await _repository.getPlaylist(playlistId);
      if (playlist == null) {
        emit(const PlaylistDetailErrorState('Playlist not found.'));
        return;
      }

      // Convert VideoModel → Video entity for UI consumption
      final normalVideos = playlist.videos
          .map((m) => m.toEntity())
          .toList();

      if (normalVideos.isEmpty) {
        emit(PlaylistDetailEmptyState(playlist));
        return;
      }

      // Hero = selected video, then the most recently played video in this
      // playlist, or the first video when this playlist has no history.
      Video heroVideo;
      if (_selectedHeroId != null) {
        heroVideo =
            normalVideos
                .where((v) => v.id == _selectedHeroId)
                .firstOrNull ??
            normalVideos.first;
      } else {
        final lastPlayedVideo = normalVideos
            .where((v) => v.lastPlayedAt != null)
            .fold<Video?>(null, (latest, video) {
              if (latest == null ||
                  video.lastPlayedAt!.isAfter(latest.lastPlayedAt!)) {
                return video;
              }
              return latest;
            });
        heroVideo = lastPlayedVideo ?? normalVideos.first;
      }
      _selectedHeroId = heroVideo.id;

      final videos = _pinnedFirst(normalVideos);

      emit(
        PlaylistDetailLoadedState(
          playlist: playlist,
          videos: videos,
          heroVideo: heroVideo,
        ),
      );
    } on Object catch (e) {
      emit(PlaylistDetailErrorState(e.toString()));
    }
  }

  /// User tapped a video in the list — set as hero and auto-play.
  void selectVideo(Video video) {
    final currentState = state;
    if (currentState is PlaylistDetailLoadedState) {
      _selectedHeroId = video.id;
      emit(
        PlaylistDetailLoadedState(
          playlist: currentState.playlist,
          videos: currentState.videos,
          heroVideo: video,
          forcePlayTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  /// Save watch progress (called by the player's heartbeat).
  /// The progress is saved to this playlist's own video row.
  Future<void> updateProgress(
    int playlistVideoId,
    int positionSeconds,
  ) async {
    try {
      await _repository.updateVideoProgress(
        playlistVideoId,
        positionSeconds,
      );
    } on Exception catch (e) {
      emit(PlaylistDetailErrorState(e.toString()));
      // Progress save runs in the background, ignore errors to not interrupt UI
    }
    // Don't reload playlist here — that would reset the player.
    // Progress is silently saved and will be visible when playlist reloads.
  }

  /// Remove a video from this playlist (not from the library).
  Future<void> removeVideo(int videoModelId) async {
    try {
      await _repository.removeVideoFromPlaylist(
        playlistId,
        videoModelId,
      );
      await loadPlaylist();
    }on Exception catch (e) {
      emit(PlaylistDetailErrorState(e.toString()));
      await loadPlaylist(); // Recover UI
    }
  }

  /// Add a video to this playlist by URL.
  Future<void> addVideo(String url) async {
    // We can emit a loading state or just keep the current state and show a toast on error
    try {
      await _repository.addVideoToPlaylist(playlistId, url);
      await loadPlaylist();
    } on Exception catch (e) {
      emit(PlaylistDetailErrorState(e.toString()));
      await loadPlaylist(); // Recover UI
    }
  }

  Future<void> setVideoPinned(int videoId, bool isPinned) async {
    try {
      await _repository.setVideoPinned(videoId, isPinned);
      await loadPlaylist();
    } on Exception catch (e) {
      emit(PlaylistDetailErrorState(e.toString()));
      await loadPlaylist();
    }
  }

  List<Video> _pinnedFirst(List<Video> videos) => [
    ...videos.where((video) => video.isPinned),
    ...videos.where((video) => !video.isPinned),
  ];
}
