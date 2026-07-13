import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/core/utils/youtube_url_parser.dart';
import 'package:levelup_tube/src/features/library/data/datasources/youtube_api_service.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';
import 'package:levelup_tube/src/features/playlist/data/repositories/playlist_local_datasource.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl({
    required this.localDataSource,
    required this.apiService,
  });

  final PlaylistLocalDataSource localDataSource;
  final YoutubeApiService apiService;

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    try {
      final playlists = await localDataSource.getAllPlaylists();
      return playlists;
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error fetching playlists');
      return [];
    }
  }

  @override
  Future<PlaylistModel?> getPlaylist(int id) async {
    try {
      return await localDataSource.getPlaylist(id);
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error fetching playlist $id');
      return null;
    }
  }

  @override
  Future<int> createCustomPlaylist(String title) async {
    final playlist = PlaylistModel(
      title: title.trim(),
      createdAt: DateTime.now(),
      isSystemDefault: false,
    );
    return localDataSource.savePlaylist(playlist);
  }

  @override
  Future<int> importYoutubePlaylist(String playlistUrl) async {
    final playlistId = YoutubeUrlParser.extractPlaylistId(playlistUrl);
    if (playlistId == null) {
      throw const VideoException('Invalid YouTube playlist URL.', code: 'invalidUrl');
    }

    final alreadyImported = await localDataSource.isPlaylistImported(playlistId);
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

    final savedId = await localDataSource.savePlaylist(playlist);
    for (final video in videoModels) {
      await localDataSource.addVideoToPlaylist(savedId, video);
    }
    talker.log('PlaylistRepository: Imported playlist "${playlistMeta['title']}" with ${videoModels.length} videos (ID: $savedId)');
    return savedId;
  }

  @override
  Future<bool> isPlaylistImported(String youtubePlaylistId) async {
    return localDataSource.isPlaylistImported(youtubePlaylistId);
  }

  @override
  Future<void> deletePlaylist(int id) async {
    await localDataSource.deletePlaylist(id);
  }

  @override
  Future<void> removeVideoFromPlaylist(int playlistId, int videoModelId) async {
    await localDataSource.removeVideoFromPlaylist(playlistId, videoModelId);
  }

  @override
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

    await localDataSource.addVideoToPlaylist(playlistId, model);
  }

  @override
  Future<void> updateVideoProgress(String youtubeId, int positionSeconds) async {
    // We need to update progress across all playlists where this video exists,
    // since PlaylistVideoModel doesn't enforce uniqueness on youtubeId.
    // However, the original code had this method on PlaylistLocalDataSource but wait, did it?
    // Let's implement it by querying PlaylistVideoModel by youtubeId and updating all.
    // The VideoLocalDataSource had this. Let's assume PlaylistLocalDataSource doesn't have it yet, we will add it.
    await localDataSource.updateVideoProgress(youtubeId, positionSeconds);
  }

  @override
  Future<PlaylistModel> getOrCreateDefaultLibrary() async {
    final playlists = await localDataSource.getAllPlaylists();
    var defaultLib = playlists.where((p) => p.isSystemDefault).firstOrNull;
    if (defaultLib == null) {
       talker.log('PlaylistRepository: Creating new Default Library playlist.', logLevel: LogLevel.info);
       defaultLib = PlaylistModel(
         title: 'My Library',
         createdAt: DateTime.now(),
         isSystemDefault: true,
       );
       final id = await localDataSource.savePlaylist(defaultLib);
       defaultLib.id = id;
    } else {
       talker.log('PlaylistRepository: Found existing Default Library playlist (ID: ${defaultLib.id}).', logLevel: LogLevel.debug);
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
    await localDataSource.setDefaultPlaylist(playlistId);
  }
}
