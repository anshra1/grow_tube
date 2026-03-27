abstract class AppConfig {
  static const youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  static bool get hasYoutubeKey => youtubeApiKey.isNotEmpty;
}
