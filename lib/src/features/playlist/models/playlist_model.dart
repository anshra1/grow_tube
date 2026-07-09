import 'package:objectbox/objectbox.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';

@Entity()
class PlaylistModel {
  PlaylistModel({
    required this.title,
    required this.createdAt,
    this.id = 0,
    this.youtubePlaylistId,
    this.thumbnailUrl,
    this.description,
    this.videoCount = 0,
  });

  @Id()
  int id;

  /// User-given title (for custom playlists) or YouTube playlist title (for imported).
  String title;

  /// Optional: the YouTube playlist ID (e.g. "PLxxxxxx").
  /// Null for user-created custom playlists.
  /// Used to prevent duplicate imports & for potential future refresh.
  String? youtubePlaylistId;

  /// Cached thumbnail URL — first video's thumbnail or YouTube playlist thumbnail.
  String? thumbnailUrl;

  /// Optional description from YouTube or user.
  String? description;

  /// Cached count of videos (denormalized for list display performance).
  /// Updated whenever videos are added/removed.
  int videoCount;

  @Property(type: PropertyType.dateNano)
  DateTime createdAt;

  /// The ObjectBox ToMany relation to VideoModel.
  /// This is the CORE relationship — a playlist contains many videos.
  ///
  /// IMPORTANT: ObjectBox ToMany is lazy-loaded. Call `.length` or iterate
  /// to trigger the load. The relation is stored in a separate join table
  /// managed by ObjectBox automatically.
  final videos = ToMany<PlaylistVideoModel>();
}
