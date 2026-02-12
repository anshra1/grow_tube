import 'package:equatable/equatable.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

final class LibraryInitialState extends LibraryState {
  const LibraryInitialState();
}

final class LibraryLoadingState extends LibraryState {
  const LibraryLoadingState();
}

final class LibraryEmptyState extends LibraryState {
  const LibraryEmptyState();
}

final class LibraryLoadedState extends LibraryState {
  const LibraryLoadedState({
    required this.videos,
    this.heroVideo,
  });

  final List<Video> videos;
  final Video? heroVideo;

  @override
  List<Object?> get props => [videos, heroVideo];
}

final class LibraryFailureState extends LibraryState {
  const LibraryFailureState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
