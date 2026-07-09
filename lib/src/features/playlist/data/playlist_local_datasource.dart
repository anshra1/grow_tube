import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/objectbox.g.dart';
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:talker_flutter/talker_flutter.dart';

abstract class PlaylistLocalDataSource {
  /// Returns all playlists, ordered by createdAt descending (newest first).
  Future<List<PlaylistModel>> getAllPlaylists();

  /// Returns a single playlist by its ObjectBox ID, with videos relation loaded.
  Future<PlaylistModel?> getPlaylist(int id);

  /// Saves a new playlist (id=0) or updates an existing one.
  /// Returns the ObjectBox ID.
  Future<int> savePlaylist(PlaylistModel playlist);

  /// Deletes a playlist by ID.
  /// IMPORTANT: This only removes the playlist and its relation links.
  /// It does NOT delete the VideoModel entities themselves (they remain in the library).
  Future<void> deletePlaylist(int id);

  /// Adds a PlaylistVideoModel to a playlist's ToMany relation.
  /// If the video is not yet in the database, it is inserted first.
  /// If the video is already in this playlist, this is a no-op.
  Future<void> addVideoToPlaylist(int playlistId, PlaylistVideoModel video);

  /// Removes a video from a playlist's ToMany relation.
  /// Does NOT delete the video from the library.
  Future<void> removeVideoFromPlaylist(int playlistId, int videoModelId);

  /// Checks if a YouTube playlist has already been imported (by youtubePlaylistId).
  Future<bool> isPlaylistImported(String youtubePlaylistId);

  /// Updates watch progress for a playlist video.
  Future<void> updateVideoProgress(String youtubeId, int positionSeconds);
}

class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  PlaylistLocalDataSourceImpl(this._store);
  final Store _store;

  Box<PlaylistModel> get _playlistBox => _store.box<PlaylistModel>();
  Box<PlaylistVideoModel> get _videoBox => _store.box<PlaylistVideoModel>();

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    talker.log('PlaylistLocalDS: Fetching all playlists', logLevel: LogLevel.debug);
    try {
      final query = _playlistBox.query()
        ..order(PlaylistModel_.createdAt, flags: Order.descending);
      final playlists = query.build().find();
      talker.log('PlaylistLocalDS: Found ${playlists.length} playlists', logLevel: LogLevel.debug);
      return playlists;
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistLocalDS: Error fetching all playlists');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<PlaylistModel?> getPlaylist(int id) async {
    talker.log('PlaylistLocalDS: Fetching playlist ID: $id', logLevel: LogLevel.debug);
    try {
      final playlist = _playlistBox.get(id);
      if (playlist != null) {
        // ToMany is lazy — accessing .length forces the relation to load from DB
        // ignore: unused_local_variable
        final _ = playlist.videos.length;
        talker.log(
          'PlaylistLocalDS: Playlist "${playlist.title}" has ${playlist.videos.length} videos',
          logLevel: LogLevel.debug,
        );
      }
      return playlist;
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistLocalDS: Error fetching playlist $id');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<int> savePlaylist(PlaylistModel playlist) async {
    talker.log('PlaylistLocalDS: Saving playlist "${playlist.title}"', logLevel: LogLevel.info);
    try {
      final id = _playlistBox.put(playlist);
      talker.log('PlaylistLocalDS: Playlist saved with ID: $id', logLevel: LogLevel.info);
      return id;
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistLocalDS: Error saving playlist');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deletePlaylist(int id) async {
    talker.log('PlaylistLocalDS: Deleting playlist ID: $id', logLevel: LogLevel.info);
    try {
      final playlist = _playlistBox.get(id);
      if (playlist == null) return;

      // Collect IDs of videos in this playlist
      final videoIdsToRemove = playlist.videos.map((v) => v.id).toSet();

      // Remove the playlist
      _playlistBox.remove(id);

      // Find all video IDs used in other playlists
      final allOtherPlaylists = _playlistBox.getAll();
      final usedVideoIds = <int>{};
      for (final p in allOtherPlaylists) {
        usedVideoIds.addAll(p.videos.map((v) => v.id));
      }

      // Only delete videos that are NOT used in any other playlist
      final orphanedVideoIds = videoIdsToRemove.difference(usedVideoIds).toList();

      if (orphanedVideoIds.isNotEmpty) {
        _videoBox.removeMany(orphanedVideoIds);
        talker.log('PlaylistLocalDS: Deleted ${orphanedVideoIds.length} orphaned videos', logLevel: LogLevel.info);
      }

      talker.log('PlaylistLocalDS: Playlist deleted successfully', logLevel: LogLevel.info);
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistLocalDS: Error deleting playlist');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> addVideoToPlaylist(int playlistId, PlaylistVideoModel video) async {
    talker.log(
      'PlaylistLocalDS: Adding video "${video.title}" to playlist $playlistId',
      logLevel: LogLevel.info,
    );
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
        talker.log(
          'PlaylistLocalDS: Video "${video.youtubeId}" already in DB (ID: ${existing.id})',
          logLevel: LogLevel.debug,
        );
      } else {
        final newId = _videoBox.put(video);
        video.id = newId;
        dbVideo = video;
        talker.log(
          'PlaylistLocalDS: Inserted new video "${video.youtubeId}" (ID: $newId)',
          logLevel: LogLevel.info,
        );
      }

      final alreadyLinked = playlist.videos.any((v) => v.youtubeId == dbVideo.youtubeId);
      if (alreadyLinked) {
        talker.log(
          'PlaylistLocalDS: Video "${dbVideo.youtubeId}" already in playlist, skipping',
          logLevel: LogLevel.debug,
        );
        return;
      }

      playlist.videos.add(dbVideo);
      playlist.videoCount = playlist.videos.length;
      _playlistBox.put(playlist);

      talker.log(
        'PlaylistLocalDS: Video added to playlist. Count: ${playlist.videoCount}',
        logLevel: LogLevel.info,
      );
    } catch (e, st) {
      if (e is DatabaseException) rethrow;
      talker.handle(e, st, 'PlaylistLocalDS: Error adding video to playlist');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> removeVideoFromPlaylist(int playlistId, int videoModelId) async {
    talker.log(
      'PlaylistLocalDS: Removing video $videoModelId from playlist $playlistId',
      logLevel: LogLevel.info,
    );
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
      talker.log('PlaylistLocalDS: Video removed from playlist', logLevel: LogLevel.info);
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistLocalDS: Error removing video from playlist');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<bool> isPlaylistImported(String youtubePlaylistId) async {
    try {
      final count = _playlistBox
          .query(PlaylistModel_.youtubePlaylistId.equals(youtubePlaylistId))
          .build()
          .count();
      return count > 0;
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistLocalDS: Error checking imported playlist');
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> updateVideoProgress(String youtubeId, int positionSeconds) async {
    talker.log(
      'PlaylistLocalDS: Updating progress for $youtubeId to $positionSeconds s',
      logLevel: LogLevel.debug,
    );
    try {
      final query = _videoBox.query(PlaylistVideoModel_.youtubeId.equals(youtubeId)).build();
      final video = query.findFirst();
      query.close();

      if (video != null) {
        if (positionSeconds == 0 && video.lastWatchedPositionSeconds > 0) {
          talker.log('PlaylistLocalDS: Received 0 position for $youtubeId. Existing was ${video.lastWatchedPositionSeconds}. Writing 0.', logLevel: LogLevel.warning);
        }
        
        video.lastWatchedPositionSeconds = positionSeconds;
        video.lastPlayedAt = DateTime.now();
        _videoBox.put(video);
        talker.log('PlaylistLocalDS: Progress updated successfully to $positionSeconds', logLevel: LogLevel.debug);
      }
    } catch (e, st) {
      talker.handle(e, st, 'PlaylistLocalDS: Error updating video progress');
      throw DatabaseException(e.toString());
    }
  }
}
