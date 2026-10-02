import 'package:flutter_test/flutter_test.dart';
import 'package:roz/core/services/app_links.dart';
import 'package:roz/core/services/install_referral_service.dart';
import 'package:roz/features/notifications/domain/notification_permission_state_machine.dart';

void main() {
  group('NotificationPermissionStateMachine Tests', () {
    test('Initial state neverAsked shows prompt on first share', () {
      const machine = NotificationPermissionStateMachine();
      final now = DateTime.now();

      expect(machine.shouldShowPrompt(now: now, totalShares: 0), false);
      expect(machine.shouldShowPrompt(now: now, totalShares: 1), true);
    });

    test('Snoozed state respects 7-day and 3-share rules', () {
      final now = DateTime(2026, 10, 10);
      final snoozed6DaysAgo = DateTime(2026, 10, 4);
      final snoozed8DaysAgo = DateTime(2026, 10, 2);

      final machine6Days = NotificationPermissionStateMachine(
        state: NotificationPermState.snoozed,
        snoozedAt: snoozed6DaysAgo,
        askedCount: 1,
      );

      // Only 6 days passed -> false even with 3 shares
      expect(machine6Days.shouldShowPrompt(now: now, totalShares: 3), false);

      final machine8Days2Shares = NotificationPermissionStateMachine(
        state: NotificationPermState.snoozed,
        snoozedAt: snoozed8DaysAgo,
        askedCount: 1,
      );

      // 8 days passed but only 2 shares -> false
      expect(machine8Days2Shares.shouldShowPrompt(now: now, totalShares: 2), false);

      final machine8Days3Shares = NotificationPermissionStateMachine(
        state: NotificationPermState.snoozed,
        snoozedAt: snoozed8DaysAgo,
        askedCount: 1,
      );

      // 8 days passed AND 3 shares -> true
      expect(machine8Days3Shares.shouldShowPrompt(now: now, totalShares: 3), true);
    });

    test('Accepted or denied states never show prompt', () {
      const accepted = NotificationPermissionStateMachine(state: NotificationPermState.accepted);
      const denied = NotificationPermissionStateMachine(state: NotificationPermState.denied);
      final now = DateTime.now();

      expect(accepted.shouldShowPrompt(now: now, totalShares: 10), false);
      expect(denied.shouldShowPrompt(now: now, totalShares: 10), false);
    });

    test('Max 2 asked counts stops prompting', () {
      final now = DateTime.now();
      final machineMaxAsked = NotificationPermissionStateMachine(
        state: NotificationPermState.snoozed,
        snoozedAt: now.subtract(const Duration(days: 10)),
        askedCount: 2,
      );

      expect(machineMaxAsked.shouldShowPrompt(now: now, totalShares: 10), false);
    });
  });

  group('Referral Code and AppLinks Tests', () {
    test('generateReferralCode generates valid 6-char code without ambiguous chars', () {
      final code = AppLinks.generateReferralCode();
      expect(code.length, 6);
      expect(code.contains('I'), false);
      expect(code.contains('O'), false);
      expect(code.contains('1'), false);
      expect(code.contains('0'), false);
    });

    test('buildUrlWithCode creates correctly encoded Play Store URL', () {
      final url = AppLinks.buildUrlWithCode(source: 'invite', code: 'ABC234');
      expect(url, contains('play.google.com/store/apps/details?id=com.merashehar.app'));
      expect(url, contains('referrer=utm_source%3Dinvite%26utm_campaign%3DABC234'));
    });
  });

  group('InstallReferralService Sanitization Tests', () {
    test('sanitize strips invalid chars and caps length at 40', () {
      const raw = 'source_123!@#\$%^&*()_+<script>';
      final sanitized = InstallReferralService.sanitize(raw);
      expect(sanitized, 'source_123_script');
    });

    test('sanitize truncates string longer than 40 chars', () {
      final longStr = 'A' * 50;
      final sanitized = InstallReferralService.sanitize(longStr);
      expect(sanitized.length, 40);
    });
  });
}
