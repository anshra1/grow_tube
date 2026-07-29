import 'package:in_app_review/in_app_review.dart';
import 'package:levelup_tube/src/core/constants/app_links.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:url_launcher/url_launcher.dart';

class AppReviewService {
  AppReviewService(this._logger);

  final AppLogger _logger;
  final InAppReview _inAppReview = InAppReview.instance;

  /// Requests the native in-app review pop-up.
  /// If it is not available, it falls back to opening the store listing.
  Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        _logger.debug('In-App Review is available. Requesting review...');
        await _inAppReview.requestReview();
      } else {
        _logger.debug('In-App Review not available. Opening store listing...');
        await _inAppReview.openStoreListing();
      }
    } on Object catch (e, stack) {
      _logger.error('Failed to request in-app review', error: e, stackTrace: stack);
      // Fallback in case of absolute failure
      try {
        await _inAppReview.openStoreListing();
      } on Object catch (fallbackError, fallbackStack) {
        _logger.error(
          'Failed to open store listing fallback',
          error: fallbackError,
          stackTrace: fallbackStack,
        );
        // Ultimate fallback if the plugin channel completely fails
        try {
          await launchUrl(
            Uri.parse(AppLinks.playStore),
            mode: LaunchMode.externalApplication,
          );
        } catch (_) {}
      }
    }
  }
}
