import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

sealed class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

/// Initial state — data not yet loaded.
final class PlaylistInitialState extends PlaylistState {
  const PlaylistInitialState();
}

/// Loading playlists from DB or importing from YouTube.
final class PlaylistLoadingState extends PlaylistState {
  const PlaylistLoadingState();
}

/// Playlists loaded successfully.
final class PlaylistLoadedState extends PlaylistState {
  const PlaylistLoadedState(this.playlists);
  final List<PlaylistModel> playlists;

  @override
  List<Object?> get props => [playlists];
}

/// No playlists exist yet.
final class PlaylistEmptyState extends PlaylistState {
  const PlaylistEmptyState();
}

/// An error occurred.
final class PlaylistErrorState extends PlaylistState {
  const PlaylistErrorState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// YouTube playlist import in progress — show progress indicator.
/// This is separate from PlaylistLoadingState so the UI can show
/// the existing list while an import is happening.
final class PlaylistImportingState extends PlaylistState {
  const PlaylistImportingState({
    required this.playlists,
    this.message = 'Importing playlist...',
  });
  final List<PlaylistModel> playlists;
  final String message;

  @override
  List<Object?> get props => [playlists, message];
}

/// Playlist details (title/thumbnail) updated successfully.
final class PlaylistUpdateSuccessState extends PlaylistState {
  const PlaylistUpdateSuccessState();
}
