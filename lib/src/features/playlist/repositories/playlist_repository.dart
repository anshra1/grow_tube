import 'package:levelup_tube/objectbox.g.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/core/utils/youtube_url_parser.dart';
import 'package:levelup_tube/src/features/library/data/datasources/youtube_api_service.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';
import 'package:talker_flutter/talker_flutter.dart';

class PlaylistRepository {
  PlaylistRepository({
    required Store store,
    required this.apiService,
  }) : _store = store;

  final Store _store;
  final YoutubeApiService apiService;
  final Talker talker = TalkerFlutter.init();

  Box<PlaylistModel> get _playlistBox => _store.box<PlaylistModel>();
  Box<PlaylistVideoModel> get _videoBox => _store.box<PlaylistVideoModel>();

  Future<List<PlaylistModel>> getAllPlaylists() async {
    talker.log('PlaylistRepository: Fetching all playlists', logLevel: LogLevel.debug);
    try {
      final query = _playlistBox.query()
        ..order(PlaylistModel_.createdAt, flags: Order.descending);
      final playlists = query.build().find();
      talker.log('PlaylistRepository: Found ${playlists.length} playlists', logLevel: LogLevel.debug);
      return playlists;
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error fetching playlists');
      return [];
    }
  }

  Future<PlaylistModel?> getPlaylist(int id) async {
    talker.log('PlaylistRepository: Fetching playlist ID: $id', logLevel: LogLevel.debug);
    try {
      final playlist = _playlistBox.get(id);
      if (playlist != null) {
        // ignore: unused_local_variable
        final _ = playlist.videos.length; // force lazy loading
      }
      return playlist;
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error fetching playlist $id');
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
      return _playlistBox.put(playlist);
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error saving playlist');
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

    talker.log('PlaylistRepository: Fetching metadata for playlist $playlistId');
    final playlistMeta = await apiService.fetchPlaylistDetails(playlistId);

    talker.log('PlaylistRepository: Fetching video IDs for playlist $playlistId');
    final videoIds = await apiService.fetchPlaylistVideoIds(playlistId);

    if (videoIds.isEmpty) {
      throw const VideoException('This playlist has no videos.', code: 'emptyPlaylist');
    }

    talker.log('PlaylistRepository: Fetching details for ${videoIds.length} videos');
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
        talker.warning('PlaylistRepository: Skipping video $videoId — $e');
      }
    }

    if (videoModels.isEmpty) {
      throw const VideoException('No accessible videos found in this playlist.', code: 'emptyPlaylist');
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
    talker.log('PlaylistRepository: Imported playlist "${playlistMeta['title']}" with ${videoModels.length} videos (ID: $savedId)');
    return savedId;
  }

  Future<bool> isPlaylistImported(String youtubePlaylistId) async {
    try {
      final count = _playlistBox
          .query(PlaylistModel_.youtubePlaylistId.equals(youtubePlaylistId))
          .build()
          .count();
      return count > 0;
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error checking imported playlist');
      return false; 
    }
  }

  Future<void> deletePlaylist(int id) async {
    talker.log('PlaylistRepository: Deleting playlist ID: $id', logLevel: LogLevel.info);
    try {
      final playlist = _playlistBox.get(id);
      if (playlist == null) return;

      final videoIdsToRemove = playlist.videos.map((v) => v.id).toSet();
      _playlistBox.remove(id);

      final allOtherPlaylists = _playlistBox.getAll();
      final usedVideoIds = <int>{};
      for (final p in allOtherPlaylists) {
        usedVideoIds.addAll(p.videos.map((v) => v.id));
      }

      final orphanedVideoIds = videoIdsToRemove.difference(usedVideoIds).toList();
      if (orphanedVideoIds.isNotEmpty) {
        _videoBox.removeMany(orphanedVideoIds);
      }
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error deleting playlist');
    }
  }

  Future<void> _internalAddVideoToPlaylist(int playlistId, PlaylistVideoModel video) async {
    try {
      final playlist = _playlistBox.get(playlistId);
      if (playlist == null) {
        throw DatabaseException('Playlist $playlistId not found');
      }

      PlaylistVideoModel dbVideo;
      final existing = _videoBox
          .query(PlaylistVideoModel_.youtubeId.equals(video.youtubeId))
          .build()
          .findFirst();

      if (existing != null) {
        dbVideo = existing;
      } else {
        final newId = _videoBox.put(video);
        video.id = newId;
        dbVideo = video;
      }

      final alreadyLinked = playlist.videos.any((v) => v.youtubeId == dbVideo.youtubeId);
      if (alreadyLinked) {
        return;
      }

      playlist.videos.add(dbVideo);
      playlist.videoCount = playlist.videos.length;
      _playlistBox.put(playlist);
    } catch (e, st) {
      if (e is DatabaseException) rethrow;
      talker.handle(e, st, 'PlaylistRepository: Error adding video to playlist');
      throw DatabaseException(e.toString());
    }
  }

  Future<void> removeVideoFromPlaylist(int playlistId, int videoModelId) async {
    try {
      final playlist = _playlistBox.get(playlistId);
      if (playlist == null) return;

      playlist.videos.removeWhere((v) => v.id == videoModelId);
      playlist.videoCount = playlist.videos.length;

      if (playlist.videos.isNotEmpty) {
        playlist.thumbnailUrl = playlist.videos.first.thumbnailUrl;
      } else {
        playlist.thumbnailUrl = null;
      }

      _playlistBox.put(playlist);
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error removing video from playlist');
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
      final query = _videoBox.query(PlaylistVideoModel_.youtubeId.equals(youtubeId)).build();
      final video = query.findFirst();
      query.close();

      if (video != null) {
        video.lastWatchedPositionSeconds = positionSeconds;
        video.lastPlayedAt = DateTime.now();
        _videoBox.put(video);
      }
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error updating video progress');
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
      _store.runInTransaction(TxMode.write, () {
        final all = _playlistBox.getAll();
        for (final p in all) {
          p.isSystemDefault = false;
        }
        _playlistBox.putMany(all);

        final target = _playlistBox.get(playlistId);
        if (target == null) {
          throw DatabaseException('Playlist $playlistId not found');
        }
        target.isSystemDefault = true;
        _playlistBox.put(target);
      });
    } catch (e, st) {
      if (e is DatabaseException) rethrow;
      talker.handle(e, st, 'PlaylistRepository: Error setting default playlist');
      throw DatabaseException(e.toString());
    }
  }
}
