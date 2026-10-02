import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AppLinks {
  static const String _playStoreBaseUrl = 'https://play.google.com/store/apps/details?id=com.merashehar.app';
  static const String _prefsReferralKey = 'local_referral_code';

  /// Generates a random 6-character code from A-Z, 2-9 (excluding look-alikes I, O, 1, 0)
  static String generateReferralCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static Future<String> getReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    var code = prefs.getString(_prefsReferralKey);
    if (code == null || code.length != 6) {
      code = generateReferralCode();
      await prefs.setString(_prefsReferralKey, code);
    }
    return code;
  }

  static Future<String> buildPlayStoreUrl({required String source}) async {
    final code = await getReferralCode();
    final utmString = 'utm_source=$source&utm_campaign=$code';
    final encodedUtm = Uri.encodeComponent(utmString);
    return '$_playStoreBaseUrl&referrer=$encodedUtm';
  }

  static String buildUrlWithCode({required String source, required String code}) {
    final utmString = 'utm_source=$source&utm_campaign=$code';
    final encodedUtm = Uri.encodeComponent(utmString);
    return '$_playStoreBaseUrl&referrer=$encodedUtm';
  }
}
