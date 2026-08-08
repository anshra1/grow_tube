import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/core/services/analytics_service.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/core/utils/youtube_url_parser.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_state.dart';

import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistDetailCubit extends Cubit<PlaylistDetailState> {
  PlaylistDetailCubit({required PlaylistRepository repository, required SharedPreferences prefs, this.playlistId})
    : _repository = repository,
      _prefs = prefs,
      super(const PlaylistDetailInitial());

  final int? playlistId;
  final PlaylistRepository _repository;
  final SharedPreferences _prefs;

  /// Tracks which video the user explicitly selected as hero.
  int? _selectedHeroId;

  /// Debouncing variables to prevent excessive state emissions
  DateTime _lastProgressEmit = DateTime.now();
  int _lastEmittedPosition = 0;

  /// If true, we're managing the default library playlist
  bool get _isDefaultLibrary => playlistId == null;

  /// Load the playlist and its videos.
  Future<void> loadPlaylist() async {
    emit(const PlaylistDetailLoading());

    try {
      final playlist = _isDefaultLibrary
          ? await _repository.getDefaultLibrary()
          : await _repository.getPlaylist(playlistId!);

      if (playlist == null) {
        emit(const PlaylistDetailError('Playlist not found.'));
        return;
      }

      // Convert VideoModel → Video entity for UI consumption
      final normalVideos = playlist.videos.map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

      if (normalVideos.isEmpty) {
        emit(PlaylistDetailEmpty(playlist));
        return;
      }

      // Hero = selected video, then the most recently played video in this
      // playlist, or the first video when this playlist has no history.
      Video heroVideo;
      if (_selectedHeroId != null) {
        heroVideo =
            normalVideos.where((v) => v.id == _selectedHeroId).firstOrNull ??
            normalVideos.first;
      } else {
        final sortedForHero = List<Video>.from(normalVideos)
          ..sort((a, b) {
            if (a.lastPlayedAt != null && b.lastPlayedAt != null) {
              return b.lastPlayedAt!.compareTo(a.lastPlayedAt!);
            }
            if (a.lastPlayedAt != null) return -1;
            if (b.lastPlayedAt != null) return 1;
            return b.addedAt.compareTo(a.addedAt);
          });

        heroVideo = sortedForHero.first;
      }
      _selectedHeroId = heroVideo.id;

      final videos = _pinnedFirst(normalVideos);
      final videosState = PlaylistVideosState(playlist: playlist, videos: videos);
      final heroVideoState = HeroVideoState(heroVideo: heroVideo);

      emit(
        PlaylistDetailLoaded(videosState: videosState, heroVideoState: heroVideoState),
      );
    } on Object catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'PlaylistDetailCubit: loadPlaylist error');
      emit(PlaylistDetailError(_exceptionMessage(e)));
    }
  }

  /// User tapped a video in the list — set as hero and auto-play.
  Future<void> selectVideo(Video video) async {
    final currentState = state;

    if (currentState is PlaylistDetailLoaded) {
      _selectedHeroId = video.id;
      await _repository.markVideoAsLastPlayed(video.id);
      unawaited(di.sl<AnalyticsService>().logEvent(name: 'video_played'));

      // Check if this is the same video as current hero
      final isSameVideo = currentState.heroVideoState.heroVideo?.id == video.id;

      // Update the in-memory video state with new lastPlayedAt
      final updatedVideos = currentState.videosState.videos.map((v) {
        if (v.id == video.id) {
          return v.copyWith(lastPlayedAt: DateTime.now());
        }
        return v;
      }).toList();

      // Also update the hero video with new lastPlayedAt
      final updatedHeroVideo = video.copyWith(lastPlayedAt: DateTime.now());

      emit(
        PlaylistDetailLoaded(
          videosState: PlaylistVideosState(
            playlist: currentState.videosState.playlist,
            videos: updatedVideos,
          ),
          heroVideoState: HeroVideoState(
            heroVideo: updatedHeroVideo,
            // Only set forcePlayTimestamp if tapping the same video
            forcePlayTimestamp: isSameVideo
                ? DateTime.now().millisecondsSinceEpoch
                : null,
          ),
        ),
      );
    }
  }

  /// Save watch progress (called by the player's heartbeat).
  /// The progress is saved to this playlist's own video row and UI is updated in real-time.
  Future<void> updateProgress(int playlistVideoId, int positionSeconds) async {
    try {
      final isCurrentHero = _selectedHeroId == playlistVideoId;
      await _repository.updateVideoProgress(
        playlistVideoId,
        positionSeconds,
        updateLastPlayed: isCurrentHero,
      );

      // Debouncing logic: Only update UI if:
      // 1. At least 2 seconds have passed since last emit, OR
      // 2. Progress changed by at least 30 seconds (significant jump)
      final now = DateTime.now();
      final timeSinceLastEmit = now.difference(_lastProgressEmit).inSeconds;
      final positionDiff = (positionSeconds - _lastEmittedPosition).abs();

      if (timeSinceLastEmit >= 2 || positionDiff >= 30) {
        _lastProgressEmit = now;
        _lastEmittedPosition = positionSeconds;

        // Update UI state without reloading playlist
        final currentState = state;
        if (currentState is PlaylistDetailLoaded) {
          // Find and update the specific video
          final updatedVideos = currentState.videosState.videos.map((video) {
            if (video.id == playlistVideoId) {
              return video.copyWith(
                lastWatchedPositionSeconds: positionSeconds,
                lastPlayedAt: isCurrentHero ? DateTime.now() : video.lastPlayedAt,
              );
            }
            return video;
          }).toList();

          // Emit new state with updated videos
          emit(
            PlaylistDetailLoaded(
              videosState: PlaylistVideosState(
                playlist: currentState.videosState.playlist,
                videos: updatedVideos,
              ),
              heroVideoState: currentState.heroVideoState,
            ),
          );
        }
      }
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'PlaylistDetailCubit: updateProgress error');
      // Progress save runs in the background, ignore errors to not interrupt UI
    }
  }

  /// Remove a video from this playlist (or from library if it's the default playlist).
  Future<void> removeVideo(int videoModelId) async {
    try {
      if (_isDefaultLibrary) {
        await _repository.removeVideoFromLibrary(videoModelId);
      } else {
        await _repository.removeVideoFromPlaylist(playlistId!, videoModelId);
      }
      unawaited(di.sl<AnalyticsService>().logEvent(name: 'video_removed'));
      await loadPlaylist();
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'PlaylistDetailCubit: removeVideo error');
      emit(PlaylistDetailError(_exceptionMessage(e)));
      await loadPlaylist(); // Recover UI
    }
  }

  Future<void> addVideoToPlaylist(int playlistId, String url) async {
    emit(const PlaylistDetailLoading());

    try {
      await _repository.addVideoToPlaylist(playlistId, url);
      unawaited(di.sl<AnalyticsService>().logEvent(name: 'video_added'));
      emit(const VideoAddPlaylistSuccessState()); // Triggers the success toast
      await loadPlaylist(); // <--- NEW: Recovers the Dashboard UI
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'PlaylistDetailCubit: addVideoToPlaylist error');
      emit(PlaylistDetailError(_exceptionMessage(e))); // Triggers the error toast
      await loadPlaylist(); // <--- NEW: Recovers the Dashboard UI
    }
  }

  /// Add a video to this playlist (or to library if it's the default playlist).
  Future<void> addVideo(String url) async {
    try {
      if (_isDefaultLibrary) {
        await _repository.addVideoToLibrary(url);
      } else {
        await _repository.addVideoToPlaylist(playlistId!, url);
      }
      unawaited(di.sl<AnalyticsService>().logEvent(name: 'video_added'));
      await loadPlaylist();
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'PlaylistDetailCubit: addVideo error');
      emit(PlaylistDetailError(_exceptionMessage(e)));
      await loadPlaylist(); // Recover UI
    }
  }

  /// Load playlist and optionally add-and-play a video immediately.
  /// Used when navigating from the clipboard toast to a non-default playlist.
  Future<void> loadAndPlay(String? videoUrl) async {
    if (videoUrl != null) {
      await addAndPlayVideo(videoUrl);
    } else {
      await loadPlaylist();
    }
  }

  /// Add a video and immediately play it
  Future<void> addAndPlayVideo(String url) async {
    try {
      if (_isDefaultLibrary) {
        await _repository.addVideoToLibrary(url);
      } else {
        await _repository.addVideoToPlaylist(playlistId!, url);
      }
      unawaited(di.sl<AnalyticsService>().logEvent(name: 'video_added'));
    } on VideoException catch (e, st) {
      di.sl<AppLogger>().handle(
        e,
        st,
        'PlaylistDetailCubit: addAndPlayVideo VideoException',
      );
      if (e.code != 'already_exists') {
        emit(PlaylistDetailError(_exceptionMessage(e)));
        await loadPlaylist(); // Recover UI
        return;
      }
      // If it already exists, we just catch it and continue to play it.
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'PlaylistDetailCubit: addAndPlayVideo Exception');
      emit(PlaylistDetailError(_exceptionMessage(e)));
      await loadPlaylist(); // Recover UI
      return;
    }

    await loadPlaylist();

    // After loading, select the newly added or existing video
    final currentState = state;
    if (currentState is PlaylistDetailLoaded &&
        currentState.videosState.videos.isNotEmpty) {
      final youtubeId = YoutubeUrlParser.extractVideoId(url);
      final videoToPlay = currentState.videosState.videos
          .where((v) => v.youtubeId == youtubeId)
          .firstOrNull;

      if (videoToPlay != null) {
        await selectVideo(videoToPlay);
      } else {
        await selectVideo(currentState.videosState.videos.first);
      }
    }
  }

  /// Automatically plays the next video if autoplay is enabled.
  Future<void> playNextVideo() async {
    try {
      final autoplay = _prefs.getBool(SettingsCubit.autoplayKey) ?? true;
      if (!autoplay) return;

      final currentState = state;
      if (currentState is PlaylistDetailLoaded) {
        final videos = currentState.videosState.videos;
        if (videos.isEmpty) return;

        final heroId = currentState.heroVideoState.heroVideo?.id ?? _selectedHeroId;
        if (heroId == null) return;

        final currentIndex = videos.indexWhere((v) => v.id == heroId);
        if (currentIndex != -1) {
          if (currentIndex + 1 < videos.length) {
            await selectVideo(videos[currentIndex + 1]);
          } else {
            // Loop back to start
            await selectVideo(videos.first);
          }
        }
      }
    } catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'PlaylistDetailCubit: playNextVideo error');
    }
  }

  // Set video as pinned or not.
  // ignore: avoid_positional_boolean_parameters
  Future<void> setVideoPinned(int videoId, bool isPinned) async {
    try {
      await _repository.setVideoPinned(videoId, isPinned);
      await loadPlaylist();
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'PlaylistDetailCubit: setVideoPinned error');
      emit(PlaylistDetailError(_exceptionMessage(e)));
      await loadPlaylist();
    }
  }

  /// When default playlist changes, clear selected hero and reload
  Future<void> onDefaultPlaylistChanged() async {
    _selectedHeroId = null;
    await loadPlaylist();
  }

  List<Video> _pinnedFirst(List<Video> videos) => [
    ...videos.where((video) => video.isPinned),
    ...videos.where((video) => !video.isPinned),
  ];

  String _exceptionMessage(Object exception) {
    if (exception is AppException && exception.message.isNotEmpty) {
      return exception.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
