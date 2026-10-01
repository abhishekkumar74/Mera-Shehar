import 'package:flutter/material.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.home(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.screenPaddingHorizontal,
          vertical: AppTokens.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.homeGreetingPrefix}, User ji',
              style: AppTokens.heading22,
            ),
            const SizedBox(height: AppTokens.space12),
            Text(
              AppStrings.phase0Placeholder,
              style: AppTokens.body14.copyWith(color: AppTokens.muted),
            ),
          ],
        ),
      ),
    );
  }
}
