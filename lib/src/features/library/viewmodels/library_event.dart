import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the dashboard initializes.
final class LibraryInitializedEvent extends LibraryEvent {
  const LibraryInitializedEvent();
}

/// Triggered when user submits a YouTube URL.
final class LibraryVideoAddedEvent extends LibraryEvent {
  const LibraryVideoAddedEvent(this.url);
  final String url;

  @override
  List<Object?> get props => [url];
}

/// Triggered when user requests to delete a video.
final class LibraryVideoDeletedEvent extends LibraryEvent {
  const LibraryVideoDeletedEvent(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

/// Triggered when a video is pinned or unpinned in the default playlist.
final class LibraryVideoPinnedEvent extends LibraryEvent {
  const LibraryVideoPinnedEvent({required this.id, required this.isPinned});

  final int id;
  final bool isPinned;

  @override
  List<Object?> get props => [id, isPinned];
}

/// Triggered when a video's watch progress changes.
final class LibraryVideoProgressUpdatedEvent extends LibraryEvent {
  const LibraryVideoProgressUpdatedEvent({
    required this.playlistVideoId,
    required this.positionSeconds,
  });
  
  final int playlistVideoId;
  final int positionSeconds;

  @override
  List<Object?> get props => [playlistVideoId, positionSeconds];
}

/// Triggered when the clipboard monitor adds a video and requests to play it.
final class LibraryVideoAddedAndPlayRequested extends LibraryEvent {
  const LibraryVideoAddedAndPlayRequested(this.url);
  final String url;

  @override
  List<Object?> get props => [url];
}

/// Triggered when a user selects a video from the list to play inline.
final class LibraryVideoSelectedEvent extends LibraryEvent {
  const LibraryVideoSelectedEvent(this.video);
  final Video video;

  @override
  List<Object?> get props => [video];
}

/// Triggered when the default playlist changes in Settings.
/// Forces the Home tab to reload its video list from the new default.
final class LibraryDefaultPlaylistChangedEvent extends LibraryEvent {
  const LibraryDefaultPlaylistChangedEvent();
}
