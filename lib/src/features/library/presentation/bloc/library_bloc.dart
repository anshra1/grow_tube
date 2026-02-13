import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/src/features/library/domain/usecases/library_usecases.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({
    required this.getAllVideos,
    required this.getLastPlayedVideo,
    required this.addVideo,
    required this.deleteVideo,
    required this.updateVideoProgress,
  }) : super(const LibraryInitialState()) {
    on<LibraryInitializedEvent>(_onInitialized);
    on<LibraryVideoAddedEvent>(_onVideoAdded);
    on<LibraryVideoDeletedEvent>(_onVideoDeleted);
    on<LibraryVideoProgressUpdatedEvent>(_onProgressUpdated);
  }

  final GetAllVideos getAllVideos;
  final GetLastPlayedVideo getLastPlayedVideo;
  final AddVideo addVideo;
  final DeleteVideo deleteVideo;
  final UpdateVideoProgress updateVideoProgress;

  Future<void> _onInitialized(
    LibraryInitializedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoadingState());
    await _refreshLibrary(emit);
  }

  Future<void> _onProgressUpdated(
    LibraryVideoProgressUpdatedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final result = await updateVideoProgress(UpdateVideoProgressParams(
      youtubeId: event.youtubeId,
      positionSeconds: event.positionSeconds,
    ));

    await result.fold(
      (failure) async => emit(LibraryFailureState(failure.message)),
      (_) async => _refreshLibrary(emit),
    );
  }

  Future<void> _onVideoAdded(
    LibraryVideoAddedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    // Optimistic or waiting? "LibraryLoading -> LibraryLoaded / LibraryError" (F3 spec)
    emit(const LibraryLoadingState());

    final result = await addVideo(event.url);

    await result.fold(
      (failure) async => emit(LibraryFailureState(failure.message)),
      (_) async => _refreshLibrary(emit),
    );
  }

  Future<void> _onVideoDeleted(
    LibraryVideoDeletedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    // F5: "remove from DB -> re-emit video list".
    // We could stay in LoadedState and emit modified list, but let's be safe.
    emit(const LibraryLoadingState());

    final result = await deleteVideo(event.id);

    await result.fold(
      (failure) async => emit(LibraryFailureState(failure.message)),
      (_) async => _refreshLibrary(emit),
    );
  }

  /// Helper to fetch videos + hero and emit appropriate state
  Future<void> _refreshLibrary(Emitter<LibraryState> emit) async {
    // Parallel fetch?
    // Use UseCases.
    final videosResult = await getAllVideos();
    final heroResult = await getLastPlayedVideo();

    // Check failures
    // If videos fail, it's a critical failure.
    // If hero fails, we can probably tolerate it (null)?

    // Simplest: Check both.
    // We can use fpdart's TaskEither or just explicit checks.

    if (videosResult.isLeft()) {
      final failure = videosResult.getLeft().toNullable()!;
      emit(LibraryFailureState(failure.message));
      return;
    }

    final videos = videosResult.getRight().toNullable()!;
    if (videos.isEmpty) {
      emit(const LibraryEmptyState());
      return;
    }

    // Determine hero video
    // GetLastPlayedVideo logic: lastPlayed ?? addedAt.
    // If getLastPlayedVideo returns failure, we might fallback to first in list?
    // Or just treat as "no hero".
    // Let's assume repo handles logic (it does).

    // We unwrap hero result slightly leniently?
    // If failure, we just show list without hero? Or fail?
    // Let's strict fail for now to surface bugs, or log.
    // Repo shouldn't fail unless DB error.

    final heroVideo = heroResult.fold(
      (failure) => null, // Swallow error for hero?
      (video) => video,
    );

    // Ensure hero is separate from list? Or highlight it?
    // F8: "Sticky top widget... No floating mini-player".
    // "Holds heroVideo state".

    emit(
      LibraryLoadedState(
        videos: videos,
        heroVideo: heroVideo,
      ),
    );
  }
}
