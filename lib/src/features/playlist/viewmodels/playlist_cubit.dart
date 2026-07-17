import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit(this._repository)
    : super(const PlaylistInitialState());

  final PlaylistRepository _repository;

  /// Load all playlists from DB.
  Future<void> loadPlaylists() async {
    emit(const PlaylistLoadingState());
    try {
      final playlists = await _repository.getAllPlaylists();
      if (playlists.isEmpty) {
        emit(const PlaylistEmptyState());
      } else {
        emit(PlaylistLoadedState(_pinnedFirst(playlists)));
      }
    } on Exception catch (e) {
      emit(PlaylistErrorState(_exceptionMessage(e)));
    }
  }

  /// Load playlists and then start importing.
  Future<void> loadAndImport(String url) async {
    try {
      await loadPlaylists();
      // Wait for the screen transition to finish before showing the importing state
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await importPlaylist(url);
    } on Exception catch (e) {
      emit(PlaylistErrorState(_exceptionMessage(e)));
      await loadPlaylists(); // recover UI
    }
  }

  /// Create a new custom (empty) playlist.
  Future<void> createPlaylist(String title) async {
    if (title.trim().isEmpty) {
      emit(
        const PlaylistErrorState('Playlist name cannot be empty.'),
      );
      await loadPlaylists(); // recover UI
      return;
    }
    try {
      await _repository.createCustomPlaylist(title);
      await loadPlaylists();
    } on Exception catch (e) {
      emit(PlaylistErrorState(_exceptionMessage(e)));
      await loadPlaylists(); // recover UI
    }
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
    } on Exception catch (e) {
      emit(PlaylistErrorState(_exceptionMessage(e)));
      await loadPlaylists(); // recover UI
    }
  }

  /// Delete a playlist.
  Future<void> deletePlaylist(int id) async {
    try {
      await _repository.deletePlaylist(id);
      await loadPlaylists();
    } on Exception catch (e) {
      emit(PlaylistErrorState(_exceptionMessage(e)));
      await loadPlaylists(); // recover UI
    }
  }

  Future<void> setPlaylistPinned(int playlistId, bool isPinned) async {
    try {
      await _repository.setPlaylistPinned(playlistId, isPinned);
      await loadPlaylists();
    } on Exception catch (e) {
      emit(PlaylistErrorState(_exceptionMessage(e)));
      await loadPlaylists();
    }
  }

  List<PlaylistModel> _pinnedFirst(List<PlaylistModel> playlists) => [
    ...playlists.where((playlist) => playlist.isPinned),
    ...playlists.where((playlist) => !playlist.isPinned),
  ];

  String _exceptionMessage(Object exception) {
    if (exception is AppException && exception.message.isNotEmpty) {
      return exception.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
