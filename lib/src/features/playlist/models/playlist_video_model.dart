import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class PlaylistVideoModel {
  PlaylistVideoModel({
    required this.youtubeId,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.addedAt,
    this.id = 0,
    this.lastWatchedPositionSeconds = 0,
    this.lastPlayedAt,
  });

  @Id()
  int id;

  /// Removed @Unique() here since a user might import the same video
  /// into multiple different playlists. The uniqueness in a playlist is
  /// handled by the repository/datasource check before insertion.
  String youtubeId;

  String title;
  String channelName;
  String thumbnailUrl;
  int durationSeconds;
  int lastWatchedPositionSeconds;

  @Property(type: PropertyType.dateNano)
  DateTime addedAt;

  @Property(type: PropertyType.dateNano)
  DateTime? lastPlayedAt;

  /// Maps Model -> Entity so the UI can consume it exactly like a normal video.
  Video toEntity() {
    return Video(
      id: id,
      youtubeId: youtubeId,
      title: title,
      channelName: channelName,
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds,
      lastWatchedPositionSeconds: lastWatchedPositionSeconds,
      addedAt: addedAt,
      lastPlayedAt: lastPlayedAt,
    );
  }
}
