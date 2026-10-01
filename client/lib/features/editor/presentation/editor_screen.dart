import 'package:flutter/material.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';

class EditorScreen extends StatelessWidget {
  final String templateId;

  const EditorScreen({super.key, required this.templateId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.title('Editor: $templateId'),
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
