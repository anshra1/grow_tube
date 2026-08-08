import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

sealed class SettingsState extends Equatable {
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
    required this.isAutoplayEnabled,
  });

  final List<PlaylistModel> allPlaylists;

  /// The ObjectBox ID of the current default playlist.
  /// Null only if there are no playlists at all.
  final int? defaultPlaylistId;

  /// Whether autoplay next video is enabled
  final bool isAutoplayEnabled;

  SettingsLoadedState copyWith({
    List<PlaylistModel>? allPlaylists,
    int? defaultPlaylistId,
    bool? isAutoplayEnabled,
  }) {
    return SettingsLoadedState(
      allPlaylists: allPlaylists ?? this.allPlaylists,
      defaultPlaylistId: defaultPlaylistId ?? this.defaultPlaylistId,
      isAutoplayEnabled: isAutoplayEnabled ?? this.isAutoplayEnabled,
    );
  }

  @override
  List<Object?> get props => [allPlaylists, defaultPlaylistId, isAutoplayEnabled];
}

class SettingsErrorState extends SettingsState {
  const SettingsErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
