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
      } else {
        await _inAppReview.openStoreListing();
      }
    } on Object catch (e, stack) {
      _logger.error('Failed to request in-app review', error: e, stackTrace: stack);
      // Fallback in case of absolute failure
      try {
        await _inAppReview.openStoreListing();
      } on Exception catch (fallbackError, fallbackStack) {
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
        } on Exception catch (_) {}
      }
    }
  }

  /// Opens the store listing directly.
  /// Use this for manual "Rate App" buttons in settings menus
  /// to ensure the action never fails silently.
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
    } on Exception catch (e, stack) {
      _logger.error('Failed to open store listing directly', error: e, stackTrace: stack);
      // Ultimate fallback if the plugin channel completely fails
      try {
        await launchUrl(
          Uri.parse(AppLinks.playStore),
          mode: LaunchMode.externalApplication,
        );
      } on Exception catch (e, stack) {
        _logger.error(
          'Failed to launch the url',
          error: e,
          stackTrace: stack,
        );
      }
    }
  }
}
