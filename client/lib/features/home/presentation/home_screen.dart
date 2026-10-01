import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../profile/data/profile_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.value;
    final firstName = profile?.firstName ?? 'User';

    return Scaffold(
      appBar: AppTopBar.home(
        onAvatarTap: () => context.go('/profile'),
      ),
      backgroundColor: AppTokens.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.screenPaddingHorizontal,
          vertical: AppTokens.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Block
            Text(
              AppStrings.homeGreetingPrefix,
              style: AppTokens.small12.copyWith(color: AppTokens.muted),
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              '$firstName ji',
              style: AppTokens.heading22,
            ),
            const SizedBox(height: AppTokens.space24),

            // Proof of data flow card with Photo + Name Pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTokens.space20),
              decoration: BoxDecoration(
                color: AppTokens.heroPeach,
                borderRadius: BorderRadius.circular(AppTokens.radiusHeroCard),
                border: Border.all(color: AppTokens.border, width: 1.0),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppTokens.space16),
                  Text(
                    'Shubh Deepawali',
                    style: AppTokens.title28.copyWith(color: AppTokens.gold),
                  ),
                  const SizedBox(height: AppTokens.space8),
                  Text(
                    'Aapko aur aapke parivaar ko dheron shubhkaamnayein',
                    style: AppTokens.body14.copyWith(color: AppTokens.ink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.space24),

                  // User Photo Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space12,
                      vertical: AppTokens.space8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.white,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UserAvatar(
                          photoPath: profile?.photoPath,
                          initial: firstName,
                          size: 32.0,
                        ),
                        const SizedBox(width: AppTokens.space8),
                        Text(
                          profile?.name ?? 'User Name',
                          style: AppTokens.body14Medium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
