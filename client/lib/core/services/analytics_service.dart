import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin AnalyticsService wrapper over FirebaseAnalytics.
/// Swallows errors gracefully and does nothing if Firebase is not initialized.
class AnalyticsService {
  FirebaseAnalytics? _analytics;

  AnalyticsService() {
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (e) {
      if (kDebugMode) {
        print('[AnalyticsService] Firebase not initialized yet, analytics disabled.');
      }
    }
  }

  Future<void> log(String name, [Map<String, Object>? params]) async {
    try {
      if (_analytics != null) {
        await _analytics!.logEvent(name: name, parameters: params);
      } else if (kDebugMode) {
        print('[AnalyticsService Event] $name params: $params');
      }
    } catch (e) {
      // Swallows analytics errors safely
    }
  }
}

final analyticsService = AnalyticsService();
