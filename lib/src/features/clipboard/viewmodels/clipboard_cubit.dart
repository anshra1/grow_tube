import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_state.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';

class ClipboardCubit extends Cubit<ClipboardState> {
  ClipboardCubit({required PlaylistRepository repository})
    : _repository = repository,
      super(const ClipboardInitial());

  final PlaylistRepository _repository;

  /// Called from ClipboardVideoPrompt.initState() — always fetches fresh data.
  Future<void> loadPlaylists() async {
    talker.debug('ClipboardCubit: loadPlaylists called');
    emit(const ClipboardLoadingState());
    try {
      final playlists = await _repository.getAllPlaylists();
      final defaultPlaylist = playlists.where((p) => p.isSystemDefault).firstOrNull;
      emit(
        ClipboardPlaylistsLoadedState(
          playlists: playlists,
          defaultPlaylistId: defaultPlaylist?.id,
          selectedPlaylistId: defaultPlaylist?.id,
        ),
      );
      talker.debug(
        'ClipboardCubit: Playlists loaded. Count: ${playlists.length}, Default ID: ${defaultPlaylist?.id}',
      );
    } on Exception catch (e, st) {
      talker.error('ClipboardCubit: loadPlaylists error', e, st);
      emit(ClipboardErrorState(e.toString()));
    }
  }

  /// User changed the dropdown selection.
  void selectPlaylist(int playlistId) {
    talker.debug('ClipboardCubit: selectPlaylist called with id: $playlistId');
    final current = state;
    if (current is ClipboardPlaylistsLoadedState) {
      emit(current.copyWith(selectedPlaylistId: playlistId));
    }
  }

  /// "Add to Playlist" button tapped.
  Future<void> addToPlaylist(String url) async {
    talker.debug('ClipboardCubit: addToPlaylist called for url: $url');
    final current = state;
    if (current is! ClipboardPlaylistsLoadedState) {
      talker.debug(
        'ClipboardCubit: Cannot add, state is not ClipboardPlaylistsLoadedState',
      );
      return;
    }

    final selectedId = current.selectedPlaylistId;
    if (selectedId == null) {
      talker.debug('ClipboardCubit: Cannot add, selectedId is null');
      return;
    }

    try {
      if (selectedId == current.defaultPlaylistId) {
        talker.debug('ClipboardCubit: Adding video to default library');
        await _repository.addVideoToLibrary(url);
      } else {
        talker.debug('ClipboardCubit: Adding video to custom playlist $selectedId');
        await _repository.addVideoToPlaylist(selectedId, url);
      }
      talker.debug(
        'ClipboardCubit: Video added successfully, emitting ClipboardVideoAddedState',
      );
      emit(const ClipboardVideoAddedState());
    } on VideoException catch (e, st) {
      talker.error('ClipboardCubit: addToPlaylist VideoException', e, st);
      if (e.code == 'already_exists') {
        emit(const ClipboardVideoAlreadyExistsState());
        // Re-emit loaded state so the UI dropdown doesn't break
        emit(current);
      } else {
        emit(ClipboardErrorState(e.message));
      }
    } on Exception catch (e, st) {
      talker.error('ClipboardCubit: addToPlaylist Exception', e, st);
      emit(ClipboardErrorState(e.toString()));
    }
  }

  /// "Watch Now" button tapped.
  Future<void> watchNow(String url) async {
    talker.debug('ClipboardCubit: watchNow called for url: $url');
    final current = state;
    if (current is! ClipboardPlaylistsLoadedState) {
      talker.debug('ClipboardCubit: watchNow failed, state is not loaded');
      return;
    }

    final selectedId = current.selectedPlaylistId;
    if (selectedId == null) {
      talker.debug('ClipboardCubit: watchNow failed, selectedId is null');
      return;
    }

    // We do NOT add the video here. We just emit the navigation state.
    // The addition and playing will be handled by PlaylistDetailCubit.addAndPlayVideo
    // which gracefully handles duplicates.
    if (selectedId == current.defaultPlaylistId) {
      talker.debug('ClipboardCubit: watchNow emitting ClipboardNavigateToDashboardState');
      emit(ClipboardNavigateToDashboardState(url: url));
    } else {
      talker.debug('ClipboardCubit: watchNow emitting ClipboardNavigateToPlaylistState');
      emit(ClipboardNavigateToPlaylistState(playlistId: selectedId, url: url));
    }
  }
}
