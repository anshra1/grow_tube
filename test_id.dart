import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  final url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
  final videoId = VideoId(url);
  print('Extracted ID: ${videoId.value}');
}
