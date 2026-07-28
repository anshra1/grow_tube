import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsService {
  Future<void> logEvent({required String name, Map<String, Object>? parameters});
  Future<void> setUserProperty({required String name, required String value});
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({required FirebaseAnalytics analytics}) : _analytics = analytics;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent({required String name, Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> setUserProperty({required String name, required String value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
