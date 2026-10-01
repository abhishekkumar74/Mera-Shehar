import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const LogoMark(size: 56.0),
              const SizedBox(height: AppTokens.space24),
              Text(
                AppStrings.onboardingHeading,
                style: AppTokens.title28,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                AppStrings.onboardingSub,
                style: AppTokens.body14.copyWith(color: AppTokens.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space16),
              Text(
                AppStrings.phase0Placeholder,
                style: AppTokens.small12.copyWith(color: AppTokens.hint),
              ),
              const Spacer(),
              PrimaryButton(
                label: AppStrings.onboardingButton,
                trailingIcon: Icons.arrow_forward,
                onPressed: () async {
                  await ref.read(hasProfileProvider.notifier).completeOnboarding();
                  if (context.mounted) {
                    context.go('/home');
                  }
                },
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                AppStrings.onboardingTimeNotice,
                style: AppTokens.small12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
