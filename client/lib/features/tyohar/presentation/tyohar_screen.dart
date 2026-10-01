import 'package:flutter/material.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';

class TyoharScreen extends StatelessWidget {
  const TyoharScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.title(AppStrings.tabTyohar),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.screenPaddingHorizontal,
          vertical: AppTokens.space16,
        ),
        child: Text(
          AppStrings.phase0Placeholder,
          style: AppTokens.body14.copyWith(color: AppTokens.muted),
        ),
      ),
    );
  }
}
