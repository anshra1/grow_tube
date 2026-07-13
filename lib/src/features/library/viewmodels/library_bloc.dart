import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/core/error/failure.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/library/viewmodels/library_event.dart';
import 'package:levelup_tube/src/features/library/viewmodels/library_state.dart';
import 'package:levelup_tube/src/core/utils/youtube_url_parser.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._repository) : super(const LibraryInitialState()) {
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

    // Reloads the library when the default playlist changes in Settings
    on<LibraryDefaultPlaylistChangedEvent>(_onDefaultPlaylistChanged);
  }

  /// Tracks the YouTube ID of the video explicitly chosen by the user.
  /// When set, [_refreshLibrary] uses this instead of the repository's last played.
  String? _selectedHeroId;

  final PlaylistRepository _repository;

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
          forcePlayTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  Future<void> _onDefaultPlaylistChanged(
    LibraryDefaultPlaylistChangedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    // Clear the pinned hero so the new default playlist's
    // last-played video becomes the hero naturally.
    _selectedHeroId = null;
    await _refreshLibrary(emit);
  }

  Future<void> _onVideoAddedAndPlay(
    LibraryVideoAddedAndPlayRequested event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.addVideoToLibrary(event.url);
      final videoId = YoutubeUrlParser.extractVideoId(event.url);
      if (videoId == null) {
        emit(LibraryFailureState(_mapFailureMessage(const ServerFailure(message: 'Invalid YouTube URL', statusCode: 400))));
        return;
      }
      await _refreshLibrary(emit);
    } catch (e) {
      emit(LibraryFailureState(_mapFailureMessage(_exceptionToFailure(e))));
    }
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
    try {
      await _repository.updateVideoProgress(event.youtubeId, event.positionSeconds);
    } catch (e) {
      // Progress save runs in the background and should not interrupt the UI
      // or show user-facing error toasts for stale callbacks.
    }
    await _refreshLibrary(emit);
  }

  Future<void> _onVideoAdded(
    LibraryVideoAddedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoadingState());

    try {
      await _repository.addVideoToLibrary(event.url);
      await _refreshLibrary(emit);
    } catch (e) {
      emit(LibraryFailureState(_mapFailureMessage(_exceptionToFailure(e))));
      // Recover the UI back to the loaded list so it doesn't stay deadlocked
      await _refreshLibrary(emit);
    }
  }

  Future<void> _onVideoDeleted(
    LibraryVideoDeletedEvent event,
    Emitter<LibraryState> emit,
  ) async {
    // F5: "remove from DB -> re-emit video list".
    emit(const LibraryLoadingState());

    try {
      await _repository.removeVideoFromLibrary(event.id);
      await _refreshLibrary(emit);
    } catch (e) {
      emit(LibraryFailureState(_mapFailureMessage(_exceptionToFailure(e))));
      // Recover the UI back to the loaded list so it doesn't stay deadlocked
      await _refreshLibrary(emit);
    }
  }

  /// Helper to fetch videos + hero and emit appropriate state.
  ///
  /// If the user has explicitly selected a video ([_selectedHeroId] is set),
  /// that video is kept as the hero so that progress-save callbacks don't
  /// reset the player to whatever the DB considers "last played".
  Future<void> _refreshLibrary(Emitter<LibraryState> emit) async {
    try {
      final library = await _repository.getDefaultLibrary();
      final videos = library.videos.map((v) => v.toEntity()).toList();
      videos.sort((a, b) => b.addedAt.compareTo(a.addedAt));

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
        final sortedForHero = List<Video>.from(videos);
        sortedForHero.sort((a, b) {
          if (a.lastPlayedAt != null && b.lastPlayedAt != null) {
            return b.lastPlayedAt!.compareTo(a.lastPlayedAt!);
          }
          if (a.lastPlayedAt != null) return -1;
          if (b.lastPlayedAt != null) return 1;
          return b.addedAt.compareTo(a.addedAt);
        });
        heroVideo = sortedForHero.firstOrNull;
        // Sync _selectedHeroId so future refreshes stay on this video.
        _selectedHeroId = heroVideo?.youtubeId;
      }

      emit(LibraryVideoLoadedState(libraryVideos: videos, lastPlayVideo: heroVideo));
    } catch (e) {
      emit(LibraryFailureState(_mapFailureMessage(_exceptionToFailure(e))));
    }
  }
  
  Failure _exceptionToFailure(dynamic e) {
    if (e is VideoException) {
      return VideoFailure(message: e.message, code: e.code);
    }
    return ServerFailure(message: e.toString(), statusCode: 500);
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
          return AppStrings.actionOfflineMessage;
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
      return AppStrings.actionOfflineMessage;
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
