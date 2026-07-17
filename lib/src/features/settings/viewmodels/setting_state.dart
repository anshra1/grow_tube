import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

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
