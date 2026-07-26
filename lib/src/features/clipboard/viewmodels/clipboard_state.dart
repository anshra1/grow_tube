import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

sealed class ClipboardState extends Equatable {
  const ClipboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no playlists loaded yet.
final class ClipboardInitial extends ClipboardState {
  const ClipboardInitial();
}

/// Loading playlists from the repository.
final class ClipboardLoadingState extends ClipboardState {
  const ClipboardLoadingState();
}

/// Playlists loaded successfully — dropdown is ready to display.
final class ClipboardPlaylistsLoadedState extends ClipboardState {
  const ClipboardPlaylistsLoadedState({
    required this.playlists,
    required this.defaultPlaylistId,
    this.selectedPlaylistId,
  });

  final List<PlaylistModel> playlists;
  final int? defaultPlaylistId;
  /// Currently selected playlist in the dropdown (starts as defaultPlaylistId).
  final int? selectedPlaylistId;

  ClipboardPlaylistsLoadedState copyWith({int? selectedPlaylistId}) {
    return ClipboardPlaylistsLoadedState(
      playlists: playlists,
      defaultPlaylistId: defaultPlaylistId,
      selectedPlaylistId: selectedPlaylistId ?? this.selectedPlaylistId,
    );
  }

  @override
  List<Object?> get props => [playlists, defaultPlaylistId, selectedPlaylistId];
}

/// Video added to playlist successfully. Prompt should dismiss.
final class ClipboardVideoAddedState extends ClipboardState {
  const ClipboardVideoAddedState();
}

/// Video already exists in the selected playlist.
final class ClipboardVideoAlreadyExistsState extends ClipboardState {
  const ClipboardVideoAlreadyExistsState();
}

/// Watch Now pressed and selected playlist is the default.
/// MainScaffold listener should call PlaylistDetailCubit.addAndPlayVideo(url).
final class ClipboardNavigateToDashboardState extends ClipboardState {
  const ClipboardNavigateToDashboardState({required this.url});
  final String url;

  @override
  List<Object?> get props => [url];
}

/// Watch Now pressed and selected playlist is non-default.
/// MainScaffold listener should push /playlists/:id with url as extra.
final class ClipboardNavigateToPlaylistState extends ClipboardState {
  const ClipboardNavigateToPlaylistState({
    required this.playlistId,
    required this.url,
  });
  
  final int playlistId;
  final String url;

  @override
  List<Object?> get props => [playlistId, url];
}

/// Generic error (e.g. network failure, invalid URL).
final class ClipboardErrorState extends ClipboardState {
  const ClipboardErrorState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
