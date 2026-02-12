import 'package:equatable/equatable.dart';

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
