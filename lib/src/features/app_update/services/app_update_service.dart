import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/features/app_update/utils/version_comparator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UpdateStatus { upToDate, softUpdate, hardUpdate }

class AppUpdateService {
  AppUpdateService(this._remoteConfig, this._logger, this._prefs);

  final FirebaseRemoteConfig _remoteConfig;
  final AppLogger _logger;
  final SharedPreferences _prefs;

  static const _skippedVersionKey = 'skipped_update_version';

  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults(const {
        'min_app_version': '1.0.0',
        'latest_app_version': '1.0.0',
        'android_store_url': '',
        'ios_store_url': '',
      });

      // Fetch the newest values from Firebase and activate them
      await _remoteConfig.fetchAndActivate();
    } on Exception catch (e, stack) {
      _logger.error(
        'Failed to init Remote Config for app update',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<UpdateStatus> checkUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final minVersion = _remoteConfig.getString('min_app_version');
      final latestVersion = _remoteConfig.getString('latest_app_version');

      if (VersionComparator.isVersionLower(currentVersion, minVersion)) {
        return UpdateStatus.hardUpdate;
      } else if (VersionComparator.isVersionLower(currentVersion, latestVersion)) {
        final skippedVersion = _prefs.getString(_skippedVersionKey);
        if (skippedVersion == latestVersion) {
          return UpdateStatus.upToDate;
        }
        return UpdateStatus.softUpdate;
      }
      return UpdateStatus.upToDate;
    } on Exception catch (e, stack) {
      _logger.error('Failed to check app update status', error: e, stackTrace: stack);
      return UpdateStatus.upToDate;
    }
  }

  Future<void> skipUpdate(String version) async {
    await _prefs.setString(_skippedVersionKey, version);
  }

  String get latestAppVersion => _remoteConfig.getString('latest_app_version');

  String get storeUrl {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _remoteConfig.getString('ios_store_url')
        : _remoteConfig.getString('android_store_url');
  }
}
