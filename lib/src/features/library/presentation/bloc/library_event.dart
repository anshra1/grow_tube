import 'package:equatable/equatable.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

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

/// Triggered when a video's watch progress changes.
final class LibraryVideoProgressUpdatedEvent extends LibraryEvent {
  const LibraryVideoProgressUpdatedEvent({
    required this.youtubeId,
    required this.positionSeconds,
  });
  final String youtubeId;
  final int positionSeconds;

  @override
  List<Object?> get props => [youtubeId, positionSeconds];
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
