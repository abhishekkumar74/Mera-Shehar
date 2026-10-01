import 'package:flutter/material.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.title(AppStrings.tabSaved),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.screenPaddingHorizontal,
          vertical: AppTokens.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.savedEmptyTitle,
              style: AppTokens.body14Medium,
            ),
            const SizedBox(height: AppTokens.space8),
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
