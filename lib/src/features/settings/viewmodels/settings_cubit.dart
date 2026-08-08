import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository, this._prefs) : super(const SettingsInitialState());

  final PlaylistRepository _repository;
  final SharedPreferences _prefs;

  static const autoplayKey = 'is_autoplay_enabled';

  Future<void> loadAllPlaylist() async {
    emit(const SettingsLoadingState());
    try {
      final playlists = await _repository.getAllPlaylists();
      final defaultPlaylist = playlists.where((p) => p.isSystemDefault).firstOrNull;
      emit(
        SettingsLoadedState(
          allPlaylists: playlists,
          defaultPlaylistId: defaultPlaylist?.id,
          isAutoplayEnabled: _prefs.getBool(autoplayKey) ?? true,
        ),
      );
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'SettingsCubit: loadAllPlaylist error');
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
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'SettingsCubit: setDefaultPlaylist error');
      emit(SettingsErrorState(e.toString()));
      // Recover back to the last good state
      emit(currentState);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> toggleAutoplay(bool isEnabled) async {
    final currentState = state;
    if (currentState is! SettingsLoadedState) return;

    await _prefs.setBool(autoplayKey, isEnabled);
    emit(currentState.copyWith(isAutoplayEnabled: isEnabled));
  }
}
