abstract class AppConfig {
  static const youtubeApiKey = 'AIzaSyDuMfvPDlZRIDMRYPrtzfB--Mxd3Y7gQTg';

  static bool get hasYoutubeKey => youtubeApiKey.isNotEmpty;

  static String requireYoutubeApiKey() {
    if (hasYoutubeKey) {
      return youtubeApiKey;
    }

    throw const AppConfigurationException(
      userMessage:
          'This app build is missing required YouTube configuration. Please reinstall or contact support.',
      debugMessage:
          'Missing YOUTUBE_API_KEY. Build with --dart-define=YOUTUBE_API_KEY=YOUR_KEY.',
    );
  }
}

class AppConfigurationException implements Exception {
  const AppConfigurationException({
    required this.userMessage,
    required this.debugMessage,
  });

  final String userMessage;
  final String debugMessage;
}
