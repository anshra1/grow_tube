import 'package:objectbox/objectbox.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

@Entity()
class VideoModel {
  VideoModel({
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

  @Unique()
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

  /// Maps Model -> Entity
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

  /// Maps Entity -> Model
  static VideoModel fromEntity(Video entity) {
    return VideoModel(
      id: entity.id,
      youtubeId: entity.youtubeId,
      title: entity.title,
      channelName: entity.channelName,
      thumbnailUrl: entity.thumbnailUrl,
      durationSeconds: entity.durationSeconds,
      lastWatchedPositionSeconds: entity.lastWatchedPositionSeconds,
      addedAt: entity.addedAt,
      lastPlayedAt: entity.lastPlayedAt,
    );
  }
}
