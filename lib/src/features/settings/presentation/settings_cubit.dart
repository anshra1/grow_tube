import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsInitialState extends SettingsState {
  const SettingsInitialState();

  @override
  List<Object?> get props => [];
}

class SettingsLoadingState extends SettingsState {
  const SettingsLoadingState();

  @override
  List<Object?> get props => [];
}

class SettingsLoadedState extends SettingsState {
  const SettingsLoadedState({
    required this.allPlaylists,
    required this.defaultPlaylistId,
  });

  final List<PlaylistModel> allPlaylists;

  /// The ObjectBox ID of the current default playlist.
  /// Null only if there are no playlists at all.
  final int? defaultPlaylistId;

  SettingsLoadedState copyWith({
    List<PlaylistModel>? allPlaylists,
    int? defaultPlaylistId,
  }) {
    return SettingsLoadedState(
      allPlaylists: allPlaylists ?? this.allPlaylists,
      defaultPlaylistId: defaultPlaylistId ?? this.defaultPlaylistId,
    );
  }

  @override
  List<Object?> get props => [allPlaylists, defaultPlaylistId];
}

class SettingsErrorState extends SettingsState {
  const SettingsErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsInitialState());

  final PlaylistRepository _repository;

  /// Loads all playlists and identifies the current default.
  Future<void> loadSettings() async {
    emit(const SettingsLoadingState());
    try {
      final playlists = await _repository.getAllPlaylists();
      final defaultPlaylist =
          playlists.where((p) => p.isSystemDefault).firstOrNull;
      emit(SettingsLoadedState(
        allPlaylists: playlists,
        defaultPlaylistId: defaultPlaylist?.id,
      ));
    } catch (e) {
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
    } catch (e) {
      emit(SettingsErrorState(e.toString()));
      // Recover back to the last good state
      emit(currentState);
    }
  }
}
