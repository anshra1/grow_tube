import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsInitialState());

  final PlaylistRepository _repository;

  Future<void> loadSettings() async {
    emit(const SettingsLoadingState());
    try {
      final playlists = await _repository.getAllPlaylists();
      final defaultPlaylist = playlists
          .where((p) => p.isSystemDefault)
          .firstOrNull;
      emit(
        SettingsLoadedState(
          allPlaylists: playlists,
          defaultPlaylistId: defaultPlaylist?.id,
        ),
      );
    } on Exception catch (e) {
      emit(SettingsErrorState(e.toString()));
    }
  }

  /// Atomically sets the given playlist as the system default and refreshes state.
  Future<void> setDefaultPlaylist(int playlistId) async {
    final currentState = state;
    if (currentState is! SettingsLoadedState) return;

    try {
      await _repository.setDefaultPlaylist(playlistId);
      emit(currentState.copyWith(defaultPlaylistId: playlistId));
    } on Exception catch (e) {
      emit(SettingsErrorState(e.toString()));
      // Recover back to the last good state
      emit(currentState);
    }
  }
}
