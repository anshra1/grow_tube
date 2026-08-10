import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository, this._prefs) : super(const SettingsInitialState());

  final PlaylistRepository _repository;
  final SharedPreferences _prefs;

  static const autoplayKey = 'is_autoplay_enabled';

  StreamSubscription<List<PlaylistModel>>? _playlistsSubscription;

  void watchPlaylists() {
    _playlistsSubscription?.cancel();
    emit(const SettingsLoadingState());
    _playlistsSubscription = _repository.watchAllPlaylists().listen(
      (playlists) {
        final defaultPlaylist = playlists.where((p) => p.isSystemDefault).firstOrNull;
        emit(
          SettingsLoadedState(
            allPlaylists: playlists,
            defaultPlaylistId: defaultPlaylist?.id,
            isAutoplayEnabled: _prefs.getBool(autoplayKey) ?? true,
          ),
        );
      },
      onError: (Object e, StackTrace st) {
        di.sl<AppLogger>().handle(e, st, 'SettingsCubit: watchPlaylists error');
        emit(SettingsErrorState(e.toString()));
      },
    );
  }

  /// Atomically sets the given playlist as the system default and refreshes state.
  Future<void> setDefaultPlaylist(int playlistId) async {
    final currentState = state;
    if (currentState is! SettingsLoadedState) return;

    try {
      await _repository.setDefaultPlaylist(playlistId);
      // We don't need to manually emit the new state here since the stream will trigger it!
      // But we can do it optimistically. Let's just let the stream handle it to avoid duplicate states.
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'SettingsCubit: setDefaultPlaylist error');
      emit(SettingsErrorState(e.toString()));
      // Recover back to the last good state
      emit(currentState);
    }
  }
  // ignore it
  // ignore: avoid_positional_boolean_parameters
  Future<void> toggleAutoplay(bool isEnabled) async {
    final currentState = state;
    if (currentState is! SettingsLoadedState) return;

    await _prefs.setBool(autoplayKey, isEnabled);
    emit(currentState.copyWith(isAutoplayEnabled: isEnabled));
  }

  @override
  Future<void> close() {
    _playlistsSubscription?.cancel();
    return super.close();
  }
}
