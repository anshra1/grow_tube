## Goal Description
Implement an app update notification system using Firebase Remote Config. The system will compare the installed app version against remote configuration values (`min_app_version` and `latest_app_version`) to determine if a "hard" (forced) update or a "soft" (optional) update is required. If an update is required, it will prompt the user and direct them to the app store using `url_launcher`.

## User Review Required
> [!IMPORTANT]
> You will need to manually add the following keys to your Firebase Remote Config dashboard in the Firebase Console:
> 1. `min_app_version` (String, e.g., "1.0.0")
> 2. `latest_app_version` (String, e.g., "1.0.0")
> 3. `store_url` (String, the URL to your app on the App Store/Play Store)

## Open Questions
> [!WARNING]
> Since this app might be deployed to both Android and iOS, do you want to use a single `store_url` key, or separate keys (e.g., `android_store_url` and `ios_store_url`)? We will assume separate keys for the plan.

## Proposed Changes

---

### Dependencies
We need to add the necessary Flutter packages to interact with Firebase Remote Config and get the device's app version.

#### [MODIFY] pubspec.yaml
Add the following dependencies:
```yaml
dependencies:
  # ... existing dependencies
  firebase_remote_config: ^5.0.2
  package_info_plus: ^8.0.0
```

---

### App Update Feature Layer
We will create a new feature folder `lib/src/features/app_update/` to house the logic and UI for the update checking.

#### [NEW] lib/src/features/app_update/utils/version_comparator.dart
A utility to compare semantic version strings (e.g., "1.0.5" vs "1.1.0").
```dart
class VersionComparator {
  /// Returns true if [v1] is strictly less than [v2].
  static bool isVersionLower(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final p1 = i < v1Parts.length ? v1Parts[i] : 0;
      final p2 = i < v2Parts.length ? v2Parts[i] : 0;
      if (p1 < p2) return true;
      if (p1 > p2) return false;
    }
    return false;
  }
}
```

#### [NEW] lib/src/features/app_update/services/app_update_service.dart
A service class that wraps `FirebaseRemoteConfig` and `PackageInfo`.
```dart
import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:levelup_tube/src/features/app_update/utils/version_comparator.dart';

enum UpdateStatus { upToDate, softUpdate, hardUpdate }

class AppUpdateService {
  final FirebaseRemoteConfig _remoteConfig;

  AppUpdateService(this._remoteConfig);

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.setDefaults(const {
      'min_app_version': '1.0.0',
      'latest_app_version': '1.0.0',
      'android_store_url': '',
      'ios_store_url': '',
    });
    await _remoteConfig.fetchAndActivate();
  }

  Future<UpdateStatus> checkUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final minVersion = _remoteConfig.getString('min_app_version');
    final latestVersion = _remoteConfig.getString('latest_app_version');

    if (VersionComparator.isVersionLower(currentVersion, minVersion)) {
      return UpdateStatus.hardUpdate;
    } else if (VersionComparator.isVersionLower(currentVersion, latestVersion)) {
      return UpdateStatus.softUpdate;
    }
    return UpdateStatus.upToDate;
  }

  String get storeUrl {
    return Platform.isIOS 
        ? _remoteConfig.getString('ios_store_url') 
        : _remoteConfig.getString('android_store_url');
  }
}
```

#### [NEW] lib/src/features/app_update/widgets/update_dialog.dart
A generic dialog widget to show either the hard or soft update UI. It will use `url_launcher` to open the `storeUrl`.

---

### Dependency Injection
We need to register the new service in our DI container.

#### [MODIFY] lib/src/core/di/injection_container.dart
```dart
// ... existing imports
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:levelup_tube/src/features/app_update/services/app_update_service.dart';

Future<void> init() async {
  // ... existing firebase init
  
  // Register Remote Config and Update Service
  sl.registerLazySingleton(() => FirebaseRemoteConfig.instance);
  sl.registerLazySingleton(() => AppUpdateService(sl()));
  
  // ... existing code
}
```

---

### UI Integration
We need to trigger the update check when the app launches and show the dialog if necessary.

#### [MODIFY] lib/main.dart
Wrap the root router with a widget that calls `AppUpdateService` on init.
```diff
  class LevelUpTube extends StatelessWidget {
    const LevelUpTube({super.key});
  
    @override
    Widget build(BuildContext context) {
      return ToastificationWrapper(
        // ...
        child: MultiBlocProvider(
          // ...
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                // ...
                builder: (context, child) {
                  return _DismissKeyboardOnTap(
                    child: ConnectivityToastListener(
-                     child: child ?? const SizedBox.shrink(),
+                     child: AppUpdateListener(
+                       child: child ?? const SizedBox.shrink(),
+                     ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }
  }
```

#### [NEW] lib/src/features/app_update/widgets/app_update_listener.dart
A StatefulWidget that calls `sl<AppUpdateService>().checkUpdate()` in `initState` and shows the `UpdateDialog` if necessary.

## Verification Plan

### Automated Tests
* We can write a unit test for `VersionComparator` to ensure semantic versions are compared correctly.

### Manual Verification
1. **Firebase Setup**: Add the keys `min_app_version`, `latest_app_version`, `android_store_url`, and `ios_store_url` to the Firebase Console.
2. **Soft Update Test**: Set `latest_app_version` to "99.9.9" and `min_app_version` to "1.0.0". Launch the app and verify the dismissible Soft Update dialog appears.
3. **Hard Update Test**: Set `min_app_version` to "99.9.9". Launch the app and verify the non-dismissible Hard Update screen appears.
4. **URL Test**: Tap the "Update" button and verify it opens the URL configured in Firebase.
