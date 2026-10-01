import 'package:flutter/material.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';

class ShareSuccessScreen extends StatelessWidget {
  const ShareSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPaddingHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.shareSuccessTitle,
                style: AppTokens.title28,
              ),
              const SizedBox(height: AppTokens.space8),
              Text(
                AppStrings.phase0Placeholder,
                style: AppTokens.body14.copyWith(color: AppTokens.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
