import 'package:levelup_tube/objectbox.g.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/features/library/data/models/video_model.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MigrationService {
  static const String _migratedLibraryV1Key = 'has_migrated_library_v1';

  static Future<void> run(Store store, SharedPreferences prefs, AppLogger appLogger) async {
    final hasMigrated = prefs.getBool(_migratedLibraryV1Key) ?? false;
    if (hasMigrated) {
      appLogger.info('[TESTING_LOG] MigrationService: Library V1 migration already completed.');
      return;
    }

    final videoBox = store.box<VideoModel>();
    final playlistBox = store.box<PlaylistModel>();
    
    final oldVideosCount = videoBox.count();
    if (oldVideosCount == 0) {
      // Nothing to migrate. Set flag to prevent future checks.
      await prefs.setBool(_migratedLibraryV1Key, true);
      appLogger.info('[TESTING_LOG] MigrationService: No V1 videos to migrate.');
      return;
    }

    appLogger.info('[TESTING_LOG] MigrationService: Starting Library V1 migration of $oldVideosCount videos.');

    try {
      // 1. Find or create default playlist
      var defaultPlaylist = playlistBox.query(PlaylistModel_.isSystemDefault.equals(true)).build().findFirst();
      defaultPlaylist ??= PlaylistModel(
          title: 'My Library',
          createdAt: DateTime.now(),
          isSystemDefault: true,
        );

      // 2. Fetch all old videos and convert
      final allOldVideos = videoBox.getAll();
      for (final old in allOldVideos) {
        // Only add if not already present
        final exists = defaultPlaylist.videos.any((v) => v.youtubeId == old.youtubeId);
        if (!exists) {
          final newVideo = PlaylistVideoModel(
            youtubeId: old.youtubeId,
            title: old.title,
            channelName: old.channelName,
            thumbnailUrl: old.thumbnailUrl,
            durationSeconds: old.durationSeconds,
            addedAt: old.addedAt,
            lastWatchedPositionSeconds: old.lastWatchedPositionSeconds,
            lastPlayedAt: old.lastPlayedAt,
          );
          defaultPlaylist.videos.add(newVideo);
        }
      }

      // 3. Set video count explicitly
      defaultPlaylist.videoCount = defaultPlaylist.videos.length;

      // 4. Save playlist
      playlistBox.put(defaultPlaylist);
      
      // 5. Commit flag
      await prefs.setBool(_migratedLibraryV1Key, true);
      appLogger.info('[TESTING_LOG] MigrationService: Migration completed successfully. Flag set.');
      
      // 6. Delete old box entries safely
      videoBox.removeAll();
      appLogger.info('[TESTING_LOG] MigrationService: Old VideoModel box cleared.');

    } on Exception catch (e, st) {
      appLogger.handle(e, st, '[TESTING_LOG] MigrationService: Failed to complete Library V1 migration');
      // Do not set the flag, allowing it to retry on next launch
    }
  }
}
