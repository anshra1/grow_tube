## Goal Description
The goal is to implement the "Rate App" logic in a production-ready way by using the official `in_app_review` package for Flutter. This will allow Android (and iOS) users to review the app natively via a pop-up dialog directly inside the app, without being redirected to the Play Store. 

As requested, we will place this logic in a dedicated feature folder (`lib/src/features/app_review`), keeping the architecture modular. We will attach this directly to the "Rate App" button in the Settings page so that the user can manually trigger it "without you telling them to do it" (i.e. without unsolicited pop-ups interrupting their experience).

## User Review Required
> [!IMPORTANT]
> The `in_app_review` package uses Google Play's In-App Review API. Google Play enforces quotas on how often the native pop-up can be shown. If a user has already reviewed the app, or if the pop-up has been shown recently, Google Play will **silently ignore** the request and not show the pop-up.
> Because of this, our service will include a fallback: if the native pop-up is unavailable or fails, it will gracefully redirect the user to the Play Store listing.

## Open Questions
> [!NOTE]
> 1. Do you want to keep the Play Store URL fallback using the `url_launcher` we added earlier, or should we use the built-in `openStoreListing()` method provided by the `in_app_review` package? (My plan uses the built-in method as it is cleaner).
> 2. Do you only want this triggered manually from Settings, or do you eventually want to add the "Smart Prompt" (auto-asking after a milestone) as well? (The current plan only sets up the manual trigger as requested).

---

## Proposed Changes

### 1. Dependencies
Add the `in_app_review` package to `pubspec.yaml`.

#### [MODIFY] pubspec.yaml
```diff
 dependencies:
   toastification: ^3.0.3
   url_launcher: ^6.3.2
+  in_app_review: ^2.0.9
```

---

### 2. Feature Module: App Review
Create a new feature folder for the app review logic. This ensures separation of concerns. The service will encapsulate the native API call and handle any potential errors or fallbacks.

#### [NEW] lib/src/features/app_review/services/app_review_service.dart
```dart
import 'package:in_app_review/in_app_review.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';

class AppReviewService {
  final AppLogger _logger;
  final InAppReview _inAppReview = InAppReview.instance;

  AppReviewService(this._logger);

  /// Requests the native in-app review pop-up.
  /// If it is not available, it falls back to opening the store listing.
  Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        _logger.debug('In-App Review is available. Requesting review...');
        await _inAppReview.requestReview();
      } else {
        _logger.debug('In-App Review not available. Opening store listing...');
        await _inAppReview.openStoreListing(appStoreId: 'com.ansh.levelup_tube');
      }
    } catch (e, stack) {
      _logger.error('Failed to request in-app review', e, stack);
      // Fallback in case of absolute failure
      await _inAppReview.openStoreListing(appStoreId: 'com.ansh.levelup_tube');
    }
  }
}
```

---

### 3. Dependency Injection
Register the `AppReviewService` in `injection_container.dart` so it can be accessed globally.

#### [MODIFY] lib/src/core/di/injection_container.dart
```diff
 import 'package:levelup_tube/src/features/app_update/services/app_update_service.dart';
+import 'package:levelup_tube/src/features/app_review/services/app_review_service.dart';
...
     ..registerLazySingleton<AnalyticsService>(
       () => FirebaseAnalyticsService(analytics: FirebaseAnalytics.instance),
     )
+    ..registerLazySingleton(() => AppReviewService(sl()))
     ..registerLazySingleton(() => FirebaseRemoteConfig.instance)
```

---

### 4. Settings Page Integration
Update `settings_page.dart` to use our new `AppReviewService` instead of `url_launcher`.

#### [MODIFY] lib/src/features/settings/pages/settings_page.dart
```diff
-  static final Uri _playStoreUri = Uri.parse(AppLinks.playStore);
...
   Future<void> _handleRateAppTap() async {
-    final launched = await launchUrl(
-      _playStoreUri,
-      mode: LaunchMode.externalApplication,
-    );
-
-    if (!launched && mounted) {
-      toastification.show(
-        context: context,
-        type: ToastificationType.error,
-        style: ToastificationStyle.fillColored,
-        title: const Text('Could not open Play Store'),
-        autoCloseDuration: const Duration(seconds: 4),
-        alignment: Alignment.bottomCenter,
-      );
-    }
+    await sl<AppReviewService>().requestReview();
   }
```

---

## Verification Plan

### Automated Tests
* N/A - we don't have unit tests for this UI feature setup, but we will ensure the project compiles successfully using `flutter analyze` and `flutter build`.

### Manual Verification
1. Run the app on an Android device or emulator (must have Google Play Store installed for the native pop-up to work).
2. Navigate to **Settings**.
3. Tap **Rate App**.
4. Verify that the native Google Play bottom sheet appears allowing star rating. (Note: on debug builds or emulators without accounts, it might fallback to opening the Play Store app instead—this confirms the logic works).
