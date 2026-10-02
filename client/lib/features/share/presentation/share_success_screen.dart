import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/ad_service.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_text_button.dart';
import '../../../features/notifications/presentation/notification_prompt_bottom_sheet.dart';

class ShareSuccessScreen extends StatelessWidget {
  const ShareSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.screenPaddingHorizontal,
            vertical: AppTokens.space24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Check Icon inside soft circle
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppTokens.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: AppTokens.gold,
                ),
              ),
              const SizedBox(height: AppTokens.space24),

              Text(
                AppStrings.shareSuccessTitle,
                style: AppTokens.title28,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space8),

              Text(
                AppStrings.shareSuccessSub,
                style: AppTokens.body14.copyWith(color: AppTokens.muted),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // Primary: "Ek aur card banao"
              PrimaryButton(
                label: AppStrings.shareSuccessPrimary,
                onPressed: () {
                  adService.showInterstitialIfEligible(onComplete: () {
                    context.go('/tyohar');
                    NotificationPromptBottomSheet.showIfNeeded(context);
                  });
                },
              ),
              const SizedBox(height: AppTokens.space12),

              // Text Button: "Home par jao"
              SecondaryTextButton(
                label: AppStrings.shareSuccessSecondary,
                onPressed: () {
                  adService.showInterstitialIfEligible(onComplete: () {
                    context.go('/home');
                    NotificationPromptBottomSheet.showIfNeeded(context);
                  });
                },
              ),
              const SizedBox(height: AppTokens.space16),
            ],
          ),
        ),
      ),
    );
  }
}
