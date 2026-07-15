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

  /// Updates the watch progress (in seconds) for a specific video across all playlists.
  Future<void> updateVideoProgress(String youtubeId, int positionSeconds);

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

  Future<List<PlaylistModel>> getAllPlaylists() async {
    appLogger.debug('PlaylistRepository: Fetching all playlists');
    try {
      final query = playlistBox.query()
        ..order(PlaylistModel_.createdAt, flags: Order.descending);
      final playlists = query.build().find();
      appLogger.debug('PlaylistRepository: Found ${playlists.length} playlists');
      return playlists;
    } catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error fetching playlists');
      return [];
    }
  }

  Future<PlaylistModel?> getPlaylist(int id) async {
    appLogger.debug('PlaylistRepository: Fetching playlist ID: $id');
    try {
      final playlist = playlistBox.get(id);
      if (playlist != null) {
        // ignore: unused_local_variable
        final _ = playlist.videos.length; // force lazy loading
      }
      return playlist;
    } catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error fetching playlist $id');
      return null;
    }
  }

  Future<int> createCustomPlaylist(String title) async {
    final playlist = PlaylistModel(
      title: title.trim(),
      createdAt: DateTime.now(),
      isSystemDefault: false,
    );
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
    final List<PlaylistVideoModel> videoModels = [];

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
      } catch (e) {
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
      isSystemDefault: false,
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

  Future<bool> isPlaylistImported(String youtubePlaylistId) async {
    try {
      final count = playlistBox
          .query(PlaylistModel_.youtubePlaylistId.equals(youtubePlaylistId))
          .build()
          .count();
      return count > 0;
    } catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error checking imported playlist');
      return false;
    }
  }

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
    } catch (e, st) {
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

      PlaylistVideoModel dbVideo;
      final existing = videoBox
          .query(PlaylistVideoModel_.youtubeId.equals(video.youtubeId))
          .build()
          .findFirst();

      if (existing != null) {
        dbVideo = existing;
      } else {
        final newId = videoBox.put(video);
        video.id = newId;
        dbVideo = video;
      }

      final alreadyLinked = playlist.videos.any((v) => v.youtubeId == dbVideo.youtubeId);
      if (alreadyLinked) {
        return;
      }

      playlist.videos.add(dbVideo);
      playlist.videoCount = playlist.videos.length;
      playlistBox.put(playlist);
    } catch (e, st) {
      if (e is DatabaseException) rethrow;
      appLogger.handle(e, st, 'PlaylistRepository: Error adding video to playlist');
      throw DatabaseException(e.toString());
    }
  }

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
    } catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error removing video from playlist');
    }
  }

  Future<void> addVideoToPlaylist(int playlistId, String videoUrl) async {
    final videoId = YoutubeUrlParser.extractVideoId(videoUrl);
    if (videoId == null) {
      throw const VideoException('Invalid YouTube URL', code: 'invalidUrl');
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

  Future<void> updateVideoProgress(String youtubeId, int positionSeconds) async {
    try {
      final query = videoBox
          .query(PlaylistVideoModel_.youtubeId.equals(youtubeId))
          .build();
      final video = query.findFirst();
      query.close();

      if (video != null) {
        video.lastWatchedPositionSeconds = positionSeconds;
        video.lastPlayedAt = DateTime.now();
        videoBox.put(video);
      }
    } catch (e, st) {
      appLogger.handle(e, st, 'PlaylistRepository: Error updating video progress');
    }
  }

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

  Future<void> addVideoToLibrary(String videoUrl) async {
    final defaultLib = await getOrCreateDefaultLibrary();
    await addVideoToPlaylist(defaultLib.id, videoUrl);
  }

  Future<void> removeVideoFromLibrary(int videoModelId) async {
    final defaultLib = await getOrCreateDefaultLibrary();
    await removeVideoFromPlaylist(defaultLib.id, videoModelId);
  }

  Future<PlaylistModel> getDefaultLibrary() async {
    return getOrCreateDefaultLibrary();
  }

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
}
