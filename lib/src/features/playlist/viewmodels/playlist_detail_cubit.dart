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
  String? _selectedHeroId;

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
      final videos = playlist.videos
          .map((m) => m.toEntity())
          .toList();

      if (videos.isEmpty) {
        emit(PlaylistDetailEmptyState(playlist));
        return;
      }

      // Hero = selected video, or fall back to first video in playlist
      Video heroVideo;
      if (_selectedHeroId != null) {
        heroVideo =
            videos
                .where((v) => v.youtubeId == _selectedHeroId)
                .firstOrNull ??
            videos.first;
      } else {
        heroVideo = videos.first;
      }
      _selectedHeroId = heroVideo.youtubeId;

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
      _selectedHeroId = video.youtubeId;
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
  /// The progress is saved to the shared VideoModel — same as library.
  Future<void> updateProgress(
    String youtubeId,
    int positionSeconds,
  ) async {
    try {
      await _repository.updateVideoProgress(
        youtubeId,
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
}
