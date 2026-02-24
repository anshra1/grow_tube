import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
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
    on<LibraryVideoAddedAndPlayRequested>(_onVideoAddedAndPlay);
    on<LibraryVideoSelectedEvent>(_onVideoSelected);
  }

  /// Tracks the YouTube ID of the video explicitly chosen by the user.
  /// When set, [_refreshLibrary] uses this instead of [getLastPlayedVideo].
  String? _selectedHeroId;

  final GetAllVideos getAllVideos;
  final GetLastPlayedVideo getLastPlayedVideo;
  final AddVideo addVideo;
  final DeleteVideo deleteVideo;
  final UpdateVideoProgress updateVideoProgress;

  Future<void> _onVideoSelected(
    LibraryVideoSelectedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final state = this.state;
    if (state is LibraryLoadedState) {
      _selectedHeroId = event.video.youtubeId;
      emit(LibraryLoadedState(videos: state.videos, heroVideo: event.video));
    }
  }

  Future<void> _onVideoAddedAndPlay(
    LibraryVideoAddedAndPlayRequested event,
    Emitter<LibraryState> emit,
  ) async {
    final result = await addVideo(event.url);

    await result.fold((failure) async => emit(LibraryFailureState(failure.message)), (
      video,
    ) async {
      // Refresh library to get updated list/hero.
      // The repo's getLastPlayedVideo logic (lastPlayed ?? addedAt)
      // should pick up this new video as the hero automatically
      // because it's the most recently added/interacted with.
      await _refreshLibrary(emit);
    });
  }

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
    final result = await updateVideoProgress(
      UpdateVideoProgressParams(
        youtubeId: event.youtubeId,
        positionSeconds: event.positionSeconds,
      ),
    );

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

  /// Helper to fetch videos + hero and emit appropriate state.
  ///
  /// If the user has explicitly selected a video ([_selectedHeroId] is set),
  /// that video is kept as the hero so that progress-save callbacks don't
  /// reset the player to whatever the DB considers "last played".
  Future<void> _refreshLibrary(Emitter<LibraryState> emit) async {
    final videosResult = await getAllVideos();

    if (videosResult.isLeft()) {
      final failure = videosResult.getLeft().toNullable()!;
      emit(LibraryFailureState(failure.message));
      return;
    }

    final videos = videosResult.getRight().toNullable()!;
    if (videos.isEmpty) {
      _selectedHeroId = null;
      emit(const LibraryEmptyState());
      return;
    }

    // If the user explicitly picked a video, keep it as the hero.
    // Otherwise fall back to the DB's last-played video.
    Video? heroVideo;
    if (_selectedHeroId != null) {
      heroVideo = videos.where((v) => v.youtubeId == _selectedHeroId).firstOrNull;
    }

    if (heroVideo == null) {
      final heroResult = await getLastPlayedVideo();
      heroVideo = heroResult.fold((failure) => null, (video) => video);
      // Sync _selectedHeroId so future refreshes stay on this video.
      _selectedHeroId = heroVideo?.youtubeId;
    }

    emit(LibraryLoadedState(videos: videos, heroVideo: heroVideo));
  }
}
