import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';

class VideoSearchResult {
  const VideoSearchResult({
    required this.video,
    required this.playlistId,
    required this.playlistTitle,
  });

  final PlaylistVideoModel video;
  final int playlistId;
  final String playlistTitle;
}
