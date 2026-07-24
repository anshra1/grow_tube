//
// ignore_for_file: avoid_positional_boolean_parameters

import 'package:levelup_tube/objectbox.g.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/core/services/youtube_api_service.dart';
import 'package:levelup_tube/src/core/utils/youtube_url_parser.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';

abstract class PlaylistRepository {
  /// Fetches all playlists currently stored in the local database, ordered by newest first.
  Future<List<PlaylistModel>> getAllPlaylists();

  /// Retrieves a specific playlist by its local database ID.
  Future<PlaylistModel?> getPlaylist(int id);

  /// Creates a new custom playlist with the given [title] and saves it locally.
  Future<int> createCustomPlaylist(String title);

  /// Imports a YouTube playlist by its URL, fetching its metadata and all its videos.
  /// Returns the local database ID of the newly imported playlist.
  Future<int> importYoutubePlaylist(String playlistUrl);

  /// Checks if a YouTube playlist with the given [youtubePlaylistId] has already been imported.
  Future<bool> isPlaylistImported(String youtubePlaylistId);

  /// Deletes a playlist by its local database ID.
  /// Also cleans up any orphaned videos that are no longer part of any other playlist.
  Future<void> deletePlaylist(int id);

  /// Removes a specific video from a playlist without deleting the video from the library.
  Future<void> removeVideoFromPlaylist(int playlistId, int videoModelId);

  /// Adds a video to a specific playlist by fetching its metadata via its YouTube URL.
  Future<void> addVideoToPlaylist(int playlistId, String videoUrl);

  /// Updates the watch progress for one playlist-owned video row.
  Future<void> updateVideoProgress(
    int playlistVideoId,
    int positionSeconds, {
    bool updateLastPlayed = true,
  });

  /// Retrieves the default "My Library" playlist, creating it if it doesn't exist yet.
  Future<PlaylistModel> getOrCreateDefaultLibrary();

  /// Adds a video (by URL) directly to the system's default library.
  Future<void> addVideoToLibrary(String videoUrl);

  /// Removes a video from the system's default library.
  Future<void> removeVideoFromLibrary(int videoModelId);

  /// Fetches the default library playlist, creating it if necessary.
  Future<PlaylistModel> getDefaultLibrary();

  /// Sets a specific playlist as the system-wide default, unsetting the flag on all others.
  Future<void> setDefaultPlaylist(int playlistId);

  /// Pins or unpins one playlist without changing any other playlist fields.
  Future<void> setPlaylistPinned(int playlistId, bool isPinned);

  /// Pins or unpins one playlist-owned video row.
  Future<void> setVideoPinned(int playlistVideoId, bool isPinned);

  /// Marks a specific playlist-owned video as the last played one by updating its lastPlayedAt timestamp.
  Future<void> markVideoAsLastPlayed(int playlistVideoId);

  /// Updates the title and/or local thumbnail path of a playlist.
  Future<void> updatePlaylistDetails(int id, {String? title, String? localThumbnailPath});
}

class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl({
    required this.playlistBox,
    required this.videoBox,
    required this.store,
    required this.apiService,
    required this.appLogger,
  });

  final Box<PlaylistModel> playlistBox;
  final Box<PlaylistVideoModel> videoBox;
  final Store store;
  final YoutubeApiService apiService;
  final AppLogger appLogger;

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    appLogger.debug('PlaylistRepository: Fetching all playlists');
    try {
      final query = playlistBox.query()
        ..order(PlaylistModel_.createdAt, flags: Order.descending);
      final playlists = query.build().find();
      appLogger.debug('PlaylistRepository: Found ${playlists.length} playlists');
      return playlists;
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error fetching playlists');
      return [];
    }
  }

  @override
  Future<PlaylistModel?> getPlaylist(int id) async {
    appLogger.debug('PlaylistRepository: Fetching playlist ID: $id');
    try {
      final playlist = playlistBox.get(id);
      if (playlist != null) {
        // Force lazy loading of videos to avoid N+1 query problem
        // ignore: unused_local_variable
        final _ = playlist.videos.length; // force lazy loading
      }
      return playlist;
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error fetching playlist $id');
      return null;
    }
  }

  @override
  Future<int> createCustomPlaylist(String title) async {
    final playlist = PlaylistModel(title: title.trim(), createdAt: DateTime.now());
    return _savePlaylist(playlist);
  }

  Future<int> _savePlaylist(PlaylistModel playlist) async {
    try {
      return playlistBox.put(playlist);
    } catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error saving playlist');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<int> importYoutubePlaylist(String playlistUrl) async {
    final playlistId = YoutubeUrlParser.extractPlaylistId(playlistUrl);
    if (playlistId == null) {
      throw const VideoException('Invalid YouTube playlist URL.', code: 'invalidUrl');
    }

    final alreadyImported = await isPlaylistImported(playlistId);
    if (alreadyImported) {
      throw Exception('This playlist has already been imported.');
    }

    appLogger.info('PlaylistRepository: Fetching metadata for playlist $playlistId');
    final playlistMeta = await apiService.fetchPlaylistDetails(playlistId);

    appLogger.info('PlaylistRepository: Fetching video IDs for playlist $playlistId');
    final videoIds = await apiService.fetchPlaylistVideoIds(playlistId);

    if (videoIds.isEmpty) {
      throw const VideoException('This playlist has no videos.', code: 'emptyPlaylist');
    }

    appLogger.info('PlaylistRepository: Fetching details for ${videoIds.length} videos');
    final videoModels = <PlaylistVideoModel>[];

    for (final videoId in videoIds) {
      try {
        final data = await apiService.fetchVideoDetails(videoId);
        final model = PlaylistVideoModel(
          youtubeId: data['id'] as String,
          title: data['title'] as String,
          channelName: data['channelTitle'] as String,
          thumbnailUrl: data['thumbnailUrl'] as String,
          durationSeconds: data['durationSeconds'] as int,
          addedAt: DateTime.now(),
        );
        videoModels.add(model);
      } on Exception catch (e) {
        appLogger.warning('PlaylistRepository: Skipping video $videoId — $e');
      }
    }

    if (videoModels.isEmpty) {
      throw const VideoException(
        'No accessible videos found in this playlist.',
        code: 'emptyPlaylist',
      );
    }

    final playlist = PlaylistModel(
      title: playlistMeta['title'] as String,
      createdAt: DateTime.now(),
      youtubePlaylistId: playlistId,
      thumbnailUrl: playlistMeta['thumbnailUrl'] as String?,
      description: playlistMeta['description'] as String?,
      videoCount: videoModels.length,
    );

    final savedId = await _savePlaylist(playlist);
    for (final video in videoModels) {
      await _internalAddVideoToPlaylist(savedId, video);
    }
    appLogger.info(
      'PlaylistRepository: Imported playlist "${playlistMeta['title']}" with ${videoModels.length} videos (ID: $savedId)',
    );
    return savedId;
  }

  @override
  Future<bool> isPlaylistImported(String youtubePlaylistId) async {
    try {
      final count = playlistBox
          .query(PlaylistModel_.youtubePlaylistId.equals(youtubePlaylistId))
          .build()
          .count();
      return count > 0;
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error checking imported playlist');
      return false;
    }
  }

  @override
  Future<void> deletePlaylist(int id) async {
    appLogger.info('PlaylistRepository: Deleting playlist ID: $id');
    try {
      final playlist = playlistBox.get(id);
      if (playlist == null) return;

      final videoIdsToRemove = playlist.videos.map((v) => v.id).toSet();
      playlistBox.remove(id);

      final allOtherPlaylists = playlistBox.getAll();
      final usedVideoIds = <int>{};
      for (final p in allOtherPlaylists) {
        usedVideoIds.addAll(p.videos.map((v) => v.id));
      }

      final orphanedVideoIds = videoIdsToRemove.difference(usedVideoIds).toList();
      if (orphanedVideoIds.isNotEmpty) {
        videoBox.removeMany(orphanedVideoIds);
      }
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error deleting playlist');
    }
  }

  Future<void> _internalAddVideoToPlaylist(
    int playlistId,
    PlaylistVideoModel video,
  ) async {
    try {
      final playlist = playlistBox.get(playlistId);
      if (playlist == null) {
        throw DatabaseException('Playlist $playlistId not found');
      }

      final alreadyLinked = playlist.videos.any((v) => v.youtubeId == video.youtubeId);
      if (alreadyLinked) {
        throw const VideoException('Video already in playlist', code: 'already_exists');
      }

      // A playlist owns its own video row. The same YouTube video may exist
      // in another playlist, but its progress and last-played state are local.
      final newId = videoBox.put(video);
      video.id = newId;
      playlist.videos.add(video);
      playlist.videoCount = playlist.videos.length;
      playlistBox.put(playlist);
    } catch (e, st) {
      if (e is DatabaseException || e is VideoException) rethrow;
      appLogger.handle(e, st, 'PlaylistRepository: Error adding video to playlist');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> removeVideoFromPlaylist(int playlistId, int videoModelId) async {
    try {
      final playlist = playlistBox.get(playlistId);
      if (playlist == null) return;

      playlist.videos.removeWhere((v) => v.id == videoModelId);
      playlist.videoCount = playlist.videos.length;

      if (playlist.videos.isNotEmpty) {
        playlist.thumbnailUrl = playlist.videos.first.thumbnailUrl;
      } else {
        playlist.thumbnailUrl = null;
      }

      playlistBox.put(playlist);
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error removing video from playlist');
    }
  }

  @override
  Future<void> addVideoToPlaylist(int playlistId, String videoUrl) async {
    final videoId = YoutubeUrlParser.extractVideoId(videoUrl);
    if (videoId == null) {
      throw const VideoException('Invalid YouTube URL', code: 'invalidUrl');
    }

    // Check if video is already in playlist before making API call
    final playlist = playlistBox.get(playlistId);
    if (playlist == null) {
      throw DatabaseException('Playlist $playlistId not found');
    }

    final alreadyLinked = playlist.videos.any((v) => v.youtubeId == videoId);
    if (alreadyLinked) {
      throw const VideoException('Video already in playlist', code: 'already_exists');
    }

    final data = await apiService.fetchVideoDetails(videoId);

    final model = PlaylistVideoModel(
      youtubeId: data['id'] as String,
      title: data['title'] as String,
      channelName: data['channelTitle'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String,
      durationSeconds: data['durationSeconds'] as int,
      addedAt: DateTime.now(),
    );

    await _internalAddVideoToPlaylist(playlistId, model);
  }

  @override
  Future<void> updateVideoProgress(
    int playlistVideoId,
    int positionSeconds, {
    bool updateLastPlayed = true,
  }) async {
    try {
      appLogger.debug(
        'PlaylistRepository: Updating progress for video $playlistVideoId to $positionSeconds seconds',
      );

      final video = videoBox.get(playlistVideoId);

      if (video != null) {
        appLogger.debug(
          'PlaylistRepository: Found video - youtubeId: ${video.youtubeId}, old position: ${video.lastWatchedPositionSeconds}',
        );

        video.lastWatchedPositionSeconds = positionSeconds;
        if (updateLastPlayed) {
          video.lastPlayedAt = DateTime.now();
        }
        videoBox.put(video);

        appLogger.debug(
          'PlaylistRepository: Progress saved successfully for video $playlistVideoId',
        );
      } else {
        appLogger.debug('PlaylistRepository: Video $playlistVideoId not found');
      }
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error updating video progress');
    }
  }

  @override
  Future<void> markVideoAsLastPlayed(int playlistVideoId) async {
    try {
      final video = videoBox.get(playlistVideoId);
      if (video != null) {
        video.lastPlayedAt = DateTime.now();
        videoBox.put(video);
      }
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error marking video as last played');
    }
  }

  @override
  Future<PlaylistModel> getOrCreateDefaultLibrary() async {
    final playlists = await getAllPlaylists();
    var defaultLib = playlists.where((p) => p.isSystemDefault).firstOrNull;
    if (defaultLib == null) {
      defaultLib = PlaylistModel(
        title: 'My Library',
        createdAt: DateTime.now(),
        isSystemDefault: true,
      );
      final id = await _savePlaylist(defaultLib);
      defaultLib.id = id;
    }
    return defaultLib;
  }

  @override
  Future<void> addVideoToLibrary(String videoUrl) async {
    final defaultLib = await getOrCreateDefaultLibrary();
    await addVideoToPlaylist(defaultLib.id, videoUrl);
  }

  @override
  Future<void> removeVideoFromLibrary(int videoModelId) async {
    final defaultLib = await getOrCreateDefaultLibrary();
    await removeVideoFromPlaylist(defaultLib.id, videoModelId);
  }

  @override
  Future<PlaylistModel> getDefaultLibrary() async {
    return getOrCreateDefaultLibrary();
  }

  @override
  Future<void> setDefaultPlaylist(int playlistId) async {
    try {
      store.runInTransaction(TxMode.write, () {
        final all = playlistBox.getAll();
        for (final p in all) {
          p.isSystemDefault = false;
        }
        playlistBox.putMany(all);

        final target = playlistBox.get(playlistId);
        if (target == null) {
          throw DatabaseException('Playlist $playlistId not found');
        }
        target.isSystemDefault = true;
        playlistBox.put(target);
      });
    } catch (e, st) {
      if (e is DatabaseException) rethrow;
      appLogger.handle(e, st, 'PlaylistRepository: Error setting default playlist');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> setPlaylistPinned(int playlistId, bool isPinned) async {
    try {
      final playlist = playlistBox.get(playlistId);
      if (playlist == null) return;
      playlist.isPinned = isPinned;
      playlistBox.put(playlist);
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error pinning playlist');
    }
  }

  @override
  Future<void> setVideoPinned(int playlistVideoId, bool isPinned) async {
    try {
      final video = videoBox.get(playlistVideoId);
      if (video == null) return;
      video.isPinned = isPinned;
      videoBox.put(video);
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error pinning video');
    }
  }

  @override
  Future<void> updatePlaylistDetails(
    int id, {
    String? title,
    String? localThumbnailPath,
  }) async {
    try {
      final playlist = playlistBox.get(id);
      if (playlist == null) return;

      var hasChanges = false;

      if (title != null && title.trim().isNotEmpty && playlist.title != title.trim()) {
        playlist.title = title.trim();
        hasChanges = true;
      }

      if (localThumbnailPath != null &&
          playlist.localThumbnailPath != localThumbnailPath) {
        playlist.localThumbnailPath = localThumbnailPath;
        hasChanges = true;
      }

      if (hasChanges) {
        playlistBox.put(playlist);
      }
    } on Exception catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error updating playlist details');
    }
  }
}
