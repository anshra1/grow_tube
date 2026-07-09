import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit(this._repository) : super(const PlaylistInitialState());

  final PlaylistRepository _repository;

  /// Load all playlists from DB.
  Future<void> loadPlaylists() async {
    emit(const PlaylistLoadingState());
    final playlists = await _repository.getAllPlaylists();
    if (playlists.isEmpty) {
      emit(const PlaylistEmptyState());
    } else {
      emit(PlaylistLoadedState(playlists));
    }
  }

  /// Create a new custom (empty) playlist.
  Future<void> createPlaylist(String title) async {
    if (title.trim().isEmpty) {
      emit(const PlaylistErrorState('Playlist name cannot be empty.'));
      await loadPlaylists(); // recover UI
      return;
    }
    await _repository.createCustomPlaylist(title);
    await loadPlaylists();
  }

  /// Import a YouTube playlist by URL.
  Future<void> importPlaylist(String url) async {
    // Show importing state (overlay on top of existing list)
    final currentPlaylists = state is PlaylistLoadedState
        ? (state as PlaylistLoadedState).playlists
        : <PlaylistModel>[];
    emit(PlaylistImportingState(playlists: currentPlaylists));

    try {
      await _repository.importYoutubePlaylist(url);
      await loadPlaylists();
    } catch (e) {
      emit(PlaylistErrorState(e.toString()));
      await loadPlaylists(); // recover UI
    }
  }

  /// Delete a playlist.
  Future<void> deletePlaylist(int id) async {
    await _repository.deletePlaylist(id);
    await loadPlaylists();
  }
}
