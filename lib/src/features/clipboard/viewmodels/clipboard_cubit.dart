import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
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
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'ClipboardCubit: loadPlaylists error');
      emit(ClipboardErrorState(e.toString()));
    }
  }

  /// User changed the dropdown selection.
  void selectPlaylist(int playlistId) {
    final current = state;
    if (current is ClipboardPlaylistsLoadedState) {
      emit(current.copyWith(selectedPlaylistId: playlistId));
    }
  }

  /// "Add to Playlist" button tapped.
  Future<void> addToPlaylist(String url) async {
    final current = state;
    if (current is! ClipboardPlaylistsLoadedState) {
      return;
    }

    final selectedId = current.selectedPlaylistId;
    if (selectedId == null) {
      return;
    }

    try {
      if (selectedId == current.defaultPlaylistId) {
        await _repository.addVideoToLibrary(url);
      } else {
        await _repository.addVideoToPlaylist(selectedId, url);
      }
      emit(const ClipboardVideoAddedState());
    } on VideoException catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'ClipboardCubit: addToPlaylist VideoException');
      if (e.code == 'already_exists') {
        emit(const ClipboardVideoAlreadyExistsState());
        // Re-emit loaded state so the UI dropdown doesn't break
        emit(current);
      } else {
        emit(ClipboardErrorState(e.message));
      }
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'ClipboardCubit: addToPlaylist Exception');
      emit(ClipboardErrorState(e.toString()));
    }
  }

  /// "Watch Now" button tapped.
  Future<void> watchNow(String url) async {
    final current = state;
    if (current is! ClipboardPlaylistsLoadedState) {
      return;
    }

    final selectedId = current.selectedPlaylistId;
    if (selectedId == null) {
      return;
    }

    // We do NOT add the video here. We just emit the navigation state.
    // The addition and playing will be handled by PlaylistDetailCubit.addAndPlayVideo
    // which gracefully handles duplicates.
    if (selectedId == current.defaultPlaylistId) {
      emit(ClipboardNavigateToDashboardState(url: url));
    } else {
      emit(ClipboardNavigateToPlaylistState(playlistId: selectedId, url: url));
    }
  }
}
