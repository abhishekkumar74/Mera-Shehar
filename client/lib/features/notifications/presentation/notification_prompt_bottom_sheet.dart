import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_text_button.dart';

class NotificationPromptBottomSheet extends StatelessWidget {
  const NotificationPromptBottomSheet({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final totalShares = prefs.getInt('shares_total') ?? 0;
    final stateMachine = notificationService.stateMachine;

    if (!stateMachine.shouldShowPrompt(now: DateTime.now(), totalShares: totalShares)) {
      return;
    }

    // Wait 600 ms after S5 sheet dismissal
    await Future.delayed(const Duration(milliseconds: 600));
    if (!context.mounted) return;

    analyticsService.logEvent('notif_prompt_shown');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: AppTokens.surface,
      builder: (context) => const NotificationPromptBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTokens.gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppTokens.gold,
                size: 26,
              ),
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              'Roz subah card ready milega',
              style: AppTokens.heading22.copyWith(
                fontFamily: AppTokens.fontDisplay,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.space8),
            Text(
              'Allow karein?',
              style: AppTokens.body14.copyWith(color: AppTokens.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.space24),
            PrimaryButton(
              label: 'Haan, batao',
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                await notificationService.requestSystemPermission(prefs);
              },
            ),
            const SizedBox(height: AppTokens.space8),
            SecondaryTextButton(
              label: 'Abhi nahi',
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await notificationService.userSnoozed(prefs);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: AppTokens.space12),
          ],
        ),
      ),
    );
  }
}
