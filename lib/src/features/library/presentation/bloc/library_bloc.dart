import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/error/failure.dart';
import 'package:levelup_tube/src/features/library/domain/entities/video.dart';
import 'package:levelup_tube/src/features/library/domain/usecases/library_usecases.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({
    required GetAllVideos getAllVideos,
    required GetLastPlayedVideo getLastPlayedVideo,
    required AddVideo addVideo,
    required DeleteVideo deleteVideo,
    required UpdateVideoProgress updateVideoProgress,
  }) : _getAllVideos = getAllVideos,
       _getLastPlayedVideo = getLastPlayedVideo,
       _addVideo = addVideo,
       _deleteVideo = deleteVideo,
       _updateVideoProgress = updateVideoProgress,
       super(const LibraryInitialState()) {
    // Fetches initial library data and determines the hero video
    on<LibraryInitializedEvent>(_onInitialized);

    // Adds video to the library manually from a URL
    on<LibraryVideoAddedEvent>(_onVideoAdded);

    // Removes a video from the local database
    on<LibraryVideoDeletedEvent>(_onVideoDeleted);

    // Silently updates the progress and last played timestamp of a video
    on<LibraryVideoProgressUpdatedEvent>(_onProgressUpdated);

    // Adds a video from the smart clipboard and prepares it to be played
    on<LibraryVideoAddedAndPlayRequested>(_onVideoAddedAndPlay);

    // Selects a specific video to be displayed as the hero video
    on<LibraryVideoSelectedEvent>(_onVideoSelected);
  }

  /// Tracks the YouTube ID of the video explicitly chosen by the user.
  /// When set, [_refreshLibrary] uses this instead of [getLastPlayedVideo].
  String? _selectedHeroId;

  final GetAllVideos _getAllVideos;
  final GetLastPlayedVideo _getLastPlayedVideo;
  final AddVideo _addVideo;
  final DeleteVideo _deleteVideo;
  final UpdateVideoProgress _updateVideoProgress;

  Future<void> _onVideoSelected(
    LibraryVideoSelectedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final state = this.state;
    if (state is LibraryVideoLoadedState) {
      _selectedHeroId = event.video.youtubeId;
      emit(
        LibraryVideoLoadedState(
          libraryVideos: state.libraryVideos,
          lastPlayVideo: event.video,
        ),
      );
    }
  }

  Future<void> _onVideoAddedAndPlay(
    LibraryVideoAddedAndPlayRequested event,
    Emitter<LibraryState> emit,
  ) async {
    final result = await _addVideo(event.url);

    await result.fold((failure) async => emit(LibraryFailureState(_mapFailureMessage(failure))), (
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
    final result = await _updateVideoProgress(
      UpdateVideoProgressParams(
        youtubeId: event.youtubeId,
        positionSeconds: event.positionSeconds,
      ),
    );

    await result.fold(
      (failure) async => emit(LibraryFailureState(_mapFailureMessage(failure))),
      (_) async => _refreshLibrary(emit),
    );
  }

  Future<void> _onVideoAdded(
    LibraryVideoAddedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoadingState());

    final result = await _addVideo(event.url);

    await result.fold((failure) async {
      emit(LibraryFailureState(_mapFailureMessage(failure)));
      // Recover the UI back to the loaded list so it doesn't stay deadlocked
      await _refreshLibrary(emit);
    }, (_) async => _refreshLibrary(emit));
  }

  Future<void> _onVideoDeleted(
    LibraryVideoDeletedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    // F5: "remove from DB -> re-emit video list".
    emit(const LibraryLoadingState());

    final result = await _deleteVideo(event.id);

    await result.fold((failure) async {
      emit(LibraryFailureState(_mapFailureMessage(failure)));
      // Recover the UI back to the loaded list so it doesn't stay deadlocked
      await _refreshLibrary(emit);
    }, (_) async => _refreshLibrary(emit));
  }

  /// Helper to fetch videos + hero and emit appropriate state.
  ///
  /// If the user has explicitly selected a video ([_selectedHeroId] is set),
  /// that video is kept as the hero so that progress-save callbacks don't
  /// reset the player to whatever the DB considers "last played".
  Future<void> _refreshLibrary(Emitter<LibraryState> emit) async {
    final videosResult = await _getAllVideos();

    if (videosResult.isLeft()) {
      final failure = videosResult.getLeft().toNullable()!;
      emit(LibraryFailureState(_mapFailureMessage(failure)));
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
      final heroResult = await _getLastPlayedVideo();
      heroVideo = heroResult.fold((failure) => null, (video) => video);
      // Sync _selectedHeroId so future refreshes stay on this video.
      _selectedHeroId = heroVideo?.youtubeId;
    }

    emit(LibraryVideoLoadedState(libraryVideos: videos, lastPlayVideo: heroVideo));
  }

  String _mapFailureMessage(Failure failure) {
    if (failure is VideoFailure) {
      switch (failure.code) {
        case 'invalidUrl':
          return 'Please enter a valid YouTube URL.';
        case 'videoUnavailable':
          return 'Video not found. It may be private or deleted.';
        case 'duplicate':
          return 'This video is already in your library.';
        case 'offline':
          return AppStrings.networkOfflineMessage;
        case 'rateLimited':
          return 'YouTube API limit reached. Try again later.';
        case 'forbidden':
          return 'Access denied. Check your YouTube API key.';
        case 'serverError':
          return 'YouTube is having trouble. Please try again.';
      }
      if (failure.message.isNotEmpty) {
        return failure.message;
      }
    }

    if (failure is ConnectionFailure) {
      return AppStrings.networkOfflineMessage;
    }
    if (failure is ValidationFailure) {
      return failure.message;
    }
    if (failure is AuthFailure) {
      return 'Authentication failed. Please sign in again.';
    }
    if (failure is CacheFailure) {
      return 'Could not access local storage. Please try again.';
    }
    if (failure is ServerFailure) {
      return 'Server error. Please try again later.';
    }
    if (failure is UnknownFailure) {
      return 'Something went wrong. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }
}
