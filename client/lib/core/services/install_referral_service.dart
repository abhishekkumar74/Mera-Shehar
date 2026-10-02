import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';

class InstallReferralService {
  static const String _processedKey = 'install_referrer_processed';
  static const String _sourceKey = 'install_source';
  static const String _campaignKey = 'install_campaign';

  static String sanitize(String input, {int maxLength = 40}) {
    final sanitized = input.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
    return sanitized.length > maxLength ? sanitized.substring(0, maxLength) : sanitized;
  }

  static Future<void> checkAndProcessReferrer() async {
    final prefs = await SharedPreferences.getInstance();
    final isProcessed = prefs.getBool(_processedKey) ?? false;
    if (isProcessed) return;

    try {
      final details = await PlayInstallReferrer.installReferrer;
      final rawReferrer = details.installReferrer;
      if (rawReferrer != null && rawReferrer.isNotEmpty) {
        await processReferrerString(rawReferrer);
      }
    } catch (e) {
      debugPrint('[InstallReferralService] Referrer read error or unavailable: $e');
    } finally {
      await prefs.setBool(_processedKey, true);
    }
  }

  static Future<void> processReferrerString(String rawReferrer) async {
    final prefs = await SharedPreferences.getInstance();

    // Decode URL component if needed
    final decoded = Uri.decodeComponent(rawReferrer);
    final params = Uri.splitQueryString(decoded);

    final rawSource = params['utm_source'] ?? 'unknown';
    final rawCampaign = params['utm_campaign'] ?? 'none';

    final source = sanitize(rawSource);
    final campaign = sanitize(rawCampaign);

    await prefs.setString(_sourceKey, source);
    await prefs.setString(_campaignKey, campaign);
    await prefs.setBool(_processedKey, true);

    analyticsService.logEvent('install_referred', {
      'source': source,
      'campaign': campaign,
    });
    analyticsService.setUserProperty('install_source', source);
  }
}
