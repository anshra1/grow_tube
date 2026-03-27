import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/library/domain/entities/video.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

/// The initial state before the library is loaded or any action is taken.
final class LibraryInitialState extends LibraryState {
  const LibraryInitialState();
}

/// A state representing that a background operation (fetching, adding, deleting) is in progress.
final class LibraryLoadingState extends LibraryState {
  const LibraryLoadingState();
}

/// A state where the library has been loaded successfully, but there are no videos present.
final class LibraryEmptyState extends LibraryState {
  const LibraryEmptyState();
}

/// A state representing the successful load of the library data, holding the actual list of videos and the chosen hero video.
final class LibraryVideoLoadedState extends LibraryState {
  const LibraryVideoLoadedState({required this.libraryVideos, this.lastPlayVideo});

  final List<Video> libraryVideos;
  final Video? lastPlayVideo;

  @override
  List<Object?> get props => [libraryVideos, lastPlayVideo];
}

/// A state representing an error that occurred during a library operation, holding the error message.
final class LibraryFailureState extends LibraryState {
  const LibraryFailureState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
