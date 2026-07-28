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
      // Wrap in a write transaction to ensure atomicity. If anything fails,
      // it rolls back and NO data is deleted.
      store.runInTransaction(TxMode.write, () {
        // 1. Find or create default playlist
        var defaultPlaylist = playlistBox.query(PlaylistModel_.isSystemDefault.equals(true)).build().findFirst();
        defaultPlaylist ??= PlaylistModel(
          title: 'My Library',
          createdAt: DateTime.now(),
          isSystemDefault: true,
          isPinned: true,
          description: 'Your saved videos',
        );
        
        // Put the playlist first if it's new so it becomes attached. 
        if (defaultPlaylist.id == 0) {
          playlistBox.put(defaultPlaylist);
        }

        // Fast O(1) lookup to prevent freezing the app on large lists
        final existingYoutubeIds = defaultPlaylist.videos.map((v) => v.youtubeId).toSet();

        // 2. Fetch all old videos and convert
        final allOldVideos = videoBox.getAll();
        final newVideosToSave = <PlaylistVideoModel>[];

        for (final old in allOldVideos) {
          if (!existingYoutubeIds.contains(old.youtubeId)) {
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
            newVideosToSave.add(newVideo);
          }
        }

        // Only save if we actually made changes
        if (newVideosToSave.isNotEmpty) {
          // EXPLICITLY save all new videos to their own box first
          final playlistVideoBox = store.box<PlaylistVideoModel>();
          playlistVideoBox.putMany(newVideosToSave);

          // Now add the saved entities to the relation
          defaultPlaylist.videos.addAll(newVideosToSave);

          // 3. Set video count and initial thumbnail explicitly
          defaultPlaylist.videoCount = defaultPlaylist.videos.length;
          if (defaultPlaylist.thumbnailUrl == null && defaultPlaylist.videos.isNotEmpty) {
            defaultPlaylist.thumbnailUrl = defaultPlaylist.videos.first.thumbnailUrl;
          }

          // 4. Save playlist properties
          playlistBox.put(defaultPlaylist);
          
          // CRITICAL FIX: explicitly save the ToMany relation to the database
          defaultPlaylist.videos.applyToDb();
        }

        // 5. Delete old box entries safely only inside the successful transaction
        videoBox.removeAll();
      });

      // 6. Commit flag
      await prefs.setBool(_migratedLibraryV1Key, true);
      appLogger.info('[TESTING_LOG] MigrationService: Migration completed successfully. Flag set. Old VideoModel box cleared.');

    } on Exception catch (e, st) {
      appLogger.handle(e, st, '[TESTING_LOG] MigrationService: Failed to complete Library V1 migration');
      // Do not set the flag, allowing it to retry on next launch
    }
  }
}
