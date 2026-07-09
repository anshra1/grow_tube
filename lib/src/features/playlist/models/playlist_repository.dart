import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/features/library/data/datasources/video_remote_datasource.dart';
import 'package:levelup_tube/src/features/library/data/datasources/youtube_api_service.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';
import 'package:levelup_tube/src/features/playlist/data/playlist_local_datasource.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

class PlaylistRepository {
  PlaylistRepository({
    required this.localDataSource,
    required this.apiService,
  });

  final PlaylistLocalDataSource localDataSource;
  final YoutubeApiService apiService;

  /// Returns all playlists, ordered newest first.
  /// Catches DatabaseException → returns empty list and logs error.
  Future<List<PlaylistModel>> getAllPlaylists() async {
    try {
      return await localDataSource.getAllPlaylists();
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error fetching playlists');
      return [];
    }
  }

  /// Returns a single playlist with videos loaded.
  Future<PlaylistModel?> getPlaylist(int id) async {
    try {
      return await localDataSource.getPlaylist(id);
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistRepository: Error fetching playlist $id');
      return null;
    }
  }

  /// Creates a new empty custom playlist.
  /// Returns the created playlist's ObjectBox ID.
  Future<int> createCustomPlaylist(String title) async {
    final playlist = PlaylistModel(
      title: title.trim(),
      createdAt: DateTime.now(),
    );
    return localDataSource.savePlaylist(playlist);
  }

  /// Imports a YouTube playlist:
  /// 1. Extract playlist ID from URL
  /// 2. Check if already imported (duplicate guard)
  /// 3. Fetch playlist metadata (title, thumbnail)
  /// 4. Fetch all video IDs in the playlist
  /// 5. For each video ID, fetch video details via YoutubeApiService
  /// 6. Create PlaylistModel, add all VideoModels to its ToMany
  /// 7. Save to ObjectBox
  ///
  /// Returns the created playlist's ObjectBox ID.
  ///
  /// Throws:
  /// - [VideoException] for API errors (invalid URL, quota, etc.)
  /// - [DatabaseException] for local DB errors
  /// - [Exception] with 'duplicate' message if already imported
  Future<int> importYoutubePlaylist(String playlistUrl) async {
    // 1. Extract playlist ID
    final playlistId = VideoRemoteDataSourceImpl.extractPlaylistId(playlistUrl);
    if (playlistId == null) {
      throw const VideoException(
        'Invalid YouTube playlist URL.',
        code: 'invalidUrl',
      );
    }

    // 2. Check duplicate
    final alreadyImported = await localDataSource.isPlaylistImported(playlistId);
    if (alreadyImported) {
      throw Exception('This playlist has already been imported.');
    }

    // 3. Fetch playlist metadata
    talker.log('PlaylistRepository: Fetching metadata for playlist $playlistId');
    final playlistMeta = await apiService.fetchPlaylistDetails(playlistId);

    // 4. Fetch video IDs
    talker.log('PlaylistRepository: Fetching video IDs for playlist $playlistId');
    final videoIds = await apiService.fetchPlaylistVideoIds(playlistId);

    if (videoIds.isEmpty) {
      throw const VideoException(
        'This playlist has no videos.',
        code: 'emptyPlaylist',
      );
    }

    // 5. Fetch video details for each ID
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
        // Skip unavailable videos (private, deleted, etc.)
        // Log but don't fail the entire import.
        talker.warning(
          'PlaylistRepository: Skipping video $videoId — $e',
        );
      }
    }

    if (videoModels.isEmpty) {
      throw const VideoException(
        'No accessible videos found in this playlist.',
        code: 'emptyPlaylist',
      );
    }

    // 6. Create PlaylistModel
    final playlist = PlaylistModel(
      title: playlistMeta['title'] as String,
      createdAt: DateTime.now(),
      youtubePlaylistId: playlistId,
      thumbnailUrl: playlistMeta['thumbnailUrl'] as String?,
      description: playlistMeta['description'] as String?,
      videoCount: videoModels.length,
    );

    // 7. Save playlist first to get an ID
    final savedId = await localDataSource.savePlaylist(playlist);

    // 8. Add each video to the playlist
    for (final video in videoModels) {
      await localDataSource.addVideoToPlaylist(savedId, video);
    }

    talker.log(
      'PlaylistRepository: Imported playlist "${playlistMeta['title']}" '
      'with ${videoModels.length} videos (ID: $savedId)',
    );

    return savedId;
  }

  Future<void> deletePlaylist(int id) async {
    await localDataSource.deletePlaylist(id);
  }

  Future<void> removeVideoFromPlaylist(int playlistId, int videoModelId) async {
    await localDataSource.removeVideoFromPlaylist(playlistId, videoModelId);
  }

  /// Adds a single video to a playlist by URL.
  Future<void> addVideoToPlaylist(int playlistId, String videoUrl) async {
    final videoId = VideoRemoteDataSourceImpl.extractVideoId(videoUrl);
    if (videoId == null) {
      throw const VideoException('Invalid YouTube URL', code: 'invalidUrl');
    }

    // Fetch details
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

  Future<void> updateVideoProgress(String youtubeId, int positionSeconds) async {
    await localDataSource.updateVideoProgress(youtubeId, positionSeconds);
  }
}
