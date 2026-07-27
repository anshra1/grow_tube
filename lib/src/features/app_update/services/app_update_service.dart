import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/features/app_update/utils/version_comparator.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateStatus { upToDate, softUpdate, hardUpdate }

class AppUpdateService {
  AppUpdateService(this._remoteConfig, this._logger);

  final FirebaseRemoteConfig _remoteConfig;
  final AppLogger _logger;

// Todo: need to update this later
  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await _remoteConfig.setDefaults(const {
        'min_app_version': '1.0.0',
        'latest_app_version': '1.0.0',
        'android_store_url': '',
        'ios_store_url': '',
      });
    } on Object catch (e, stack) {
      _logger.error(
        'Failed to init Remote Config for app update',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<UpdateStatus> checkUpdate() async {
    try {
      _logger.debug('AppUpdate: starting fetchAndActivate');
      final fetched = await _remoteConfig.fetchAndActivate();
      _logger.debug('AppUpdate: fetchAndActivate completed, fetched=$fetched');

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final minVersion = _remoteConfig.getString('min_app_version');
      final latestVersion = _remoteConfig.getString('latest_app_version');

      _logger.debug('AppUpdate: current=$currentVersion, min=$minVersion, latest=$latestVersion');

      if (VersionComparator.isVersionLower(currentVersion, minVersion)) {
        _logger.debug('AppUpdate: Requires Hard Update');
        return UpdateStatus.hardUpdate;
      } else if (VersionComparator.isVersionLower(currentVersion, latestVersion)) {
        _logger.debug('AppUpdate: Requires Soft Update');
        return UpdateStatus.softUpdate;
      }
      _logger.debug('AppUpdate: Up to date');
      return UpdateStatus.upToDate;
    } on Exception catch (e, stack) {
      _logger.error('Failed to check app update status', error: e, stackTrace: stack);
      return UpdateStatus.upToDate;
    }
  }

  String get storeUrl {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _remoteConfig.getString('ios_store_url')
        : _remoteConfig.getString('android_store_url');
  }
}
