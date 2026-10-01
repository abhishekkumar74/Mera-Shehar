import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_text_button.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/user_avatar.dart';

/// Debug-only design preview screen (/dev/design).
/// Proves that theme, typography, colours, and widgets strictly comply with master.md Section 3.
class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key});

  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen> {
  int _selectedNavIndex = 0;
  bool _chipSelected = true;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Design preview is only available in debug mode.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppTopBar.title('Design System Preview'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.screenPaddingHorizontal,
          vertical: AppTokens.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: '1. Colour Tokens (Section 3.1)'),
            const SizedBox(height: AppTokens.space12),
            const Wrap(
              spacing: AppTokens.space8,
              runSpacing: AppTokens.space8,
              children: [
                _Swatch(name: 'bg', color: AppTokens.bg, hex: '#FDF8F4'),
                _Swatch(name: 'surface', color: AppTokens.surface, hex: '#F6ECE2'),
                _Swatch(name: 'heroPeach', color: AppTokens.heroPeach, hex: '#F4E8D8'),
                _Swatch(name: 'chip', color: AppTokens.chip, hex: '#EDE6E1'),
                _Swatch(name: 'border', color: AppTokens.border, hex: '#EBE1D0'),
                _Swatch(name: 'ink', color: AppTokens.ink, hex: '#2B2623'),
                _Swatch(name: 'muted', color: AppTokens.muted, hex: '#7A6F63'),
                _Swatch(name: 'hint', color: AppTokens.hint, hex: '#B9AE9F'),
                _Swatch(name: 'gold', color: AppTokens.gold, hex: '#8A6212'),
                _Swatch(name: 'goldLine', color: AppTokens.goldLine, hex: '#C9A04A'),
                _Swatch(name: 'white', color: AppTokens.white, hex: '#FFFFFF'),
                _Swatch(name: 'success', color: AppTokens.success, hex: '#22C55E'),
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            const _SectionHeader(title: '2. Typography & Devanagari Fallback (Section 3.2)'),
            const SizedBox(height: AppTokens.space12),
            _TypographySample(
              label: 'Title 28 (Playfair / Tiro)',
              style: AppTokens.title28,
              sampleEn: 'Shubh Deepawali',
              sampleHi: 'शुभ दीपावली',
            ),
            _TypographySample(
              label: 'Heading 22 (Playfair / Tiro)',
              style: AppTokens.heading22,
              sampleEn: 'Aane wale tyohar',
              sampleHi: 'आने वाले त्यौहार',
            ),
            _TypographySample(
              label: 'Body 14 (Plus Jakarta / Hind)',
              style: AppTokens.body14,
              sampleEn: 'Ek baar photo aur naam daalo.',
              sampleHi: 'एक बार फोटो और नाम डालो।',
            ),
            _TypographySample(
              label: 'Small 12 (Plus Jakarta / Hind)',
              style: AppTokens.small12,
              sampleEn: 'Passport ya profile photo',
              sampleHi: 'पासपोर्ट या प्रोफाइल फोटो',
            ),
            _TypographySample(
              label: 'Caption 11 (Plus Jakarta / Hind)',
              style: AppTokens.caption11,
              sampleEn: 'Aapka photo sirf aapke phone mein rehta hai.',
              sampleHi: 'आपका फोटो सिर्फ आपके फोन में रहता है।',
            ),
            const SizedBox(height: AppTokens.space24),

            const _SectionHeader(title: '3. Shared UI Components'),
            const SizedBox(height: AppTokens.space12),
            PrimaryButton(
              label: 'Primary Button (${AppStrings.onboardingButton})',
              trailingIcon: Icons.arrow_forward,
              onPressed: () {},
            ),
            const SizedBox(height: AppTokens.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SecondaryTextButton(
                  label: 'Secondary Text Button (${AppStrings.homeButtonEdit})',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space16),

            Row(
              children: [
                const LogoMark(size: 36.0),
                const SizedBox(width: AppTokens.space16),
                const UserAvatar(size: 36.0, initial: 'M'),
                const SizedBox(width: AppTokens.space16),
                AppChip(
                  label: 'Selected',
                  isSelected: _chipSelected,
                  onTap: () => setState(() => _chipSelected = !_chipSelected),
                ),
                const SizedBox(width: AppTokens.space8),
                AppChip(
                  label: 'Unselected',
                  isSelected: !_chipSelected,
                  onTap: () => setState(() => _chipSelected = !_chipSelected),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            const _SectionHeader(title: '4. Skeleton Loader Shimmer'),
            const SizedBox(height: AppTokens.space12),
            const Row(
              children: [
                SkeletonBox(width: 112, height: 128, borderRadius: AppTokens.radiusTile),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: SkeletonBox(width: double.infinity, height: 128, borderRadius: AppTokens.radiusTile),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            const _SectionHeader(title: '5. Sample Hero Card (Radius 24, 1px Border)'),
            const SizedBox(height: AppTokens.space12),
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
                  Container(
                    padding: const EdgeInsets.all(AppTokens.space16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTokens.goldLine, width: 1.0),
                    ),
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space32),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTokens.heading22.copyWith(fontSize: 16.0, color: AppTokens.gold),
    );
  }
}

class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  final String hex;

  const _Swatch({required this.name, required this.color, required this.hex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(AppTokens.space8),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusTile),
        border: Border.all(color: AppTokens.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTokens.border, width: 0.5),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(name, style: AppTokens.caption11.copyWith(fontWeight: FontWeight.w500, color: AppTokens.ink)),
          Text(hex, style: AppTokens.caption11.copyWith(color: AppTokens.muted)),
        ],
      ),
    );
  }
}

class _TypographySample extends StatelessWidget {
  final String label;
  final TextStyle style;
  final String sampleEn;
  final String sampleHi;

  const _TypographySample({
    required this.label,
    required this.style,
    required this.sampleEn,
    required this.sampleHi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTokens.caption11.copyWith(color: AppTokens.gold)),
          const SizedBox(height: AppTokens.space4),
          Text(sampleEn, style: style),
          Text(sampleHi, style: style),
        ],
      ),
    );
  }
}
