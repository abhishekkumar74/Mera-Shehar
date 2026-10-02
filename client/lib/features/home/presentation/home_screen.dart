import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/ad_service.dart';
import '../../../core/services/card_export_service.dart';
import '../../../core/services/share_service.dart';
import 'home_ad_slot.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_text_button.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../profile/data/profile_repository.dart';
import '../../templates/data/template_repository.dart';
import '../../templates/domain/template_model.dart';
import '../../templates/presentation/card_renderer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _heroBoundaryKey = GlobalKey();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adService.initializeAfterFirstFrame();
    });
  }

  Future<void> _shareHeroStatus(Template template, PhotoLayout layout) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final file = await cardExportService.exportPng(
        boundaryKey: _heroBoundaryKey,
        templateId: template.id,
        layout: layout,
      );

      if (file != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('shares_total', (prefs.getInt('shares_total') ?? 0) + 1);
        await shareService.shareToWhatsApp(file);
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.value;
    final firstName = profile?.firstName ?? 'User';

    final upcomingAsync = ref.watch(upcomingTemplatesProvider);

    return Scaffold(
      appBar: AppTopBar.home(
        onAvatarTap: () => context.go('/profile'),
      ),
      backgroundColor: AppTokens.bg,
      body: upcomingAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(AppTokens.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 140, height: 24),
              SizedBox(height: 16),
              SkeletonBox(width: double.infinity, height: 360),
            ],
          ),
        ),
        error: (err, st) => Center(child: Text(AppStrings.errGeneric, style: AppTokens.body14)),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(child: Text(AppStrings.phase0Placeholder, style: AppTokens.body14));
          }

          final heroTemplate = templates.first;
          final layout = heroTemplate.defaultLayout;

          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final cardWidth = (screenWidth - (AppTokens.screenPaddingHorizontal * 2)).clamp(280.0, 320.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.screenPaddingHorizontal,
                  vertical: AppTokens.space12,
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
                    const SizedBox(height: AppTokens.space16),

                    // Capped Hero Card View
                    Center(
                      child: CardView(
                        boundaryKey: _heroBoundaryKey,
                        template: heroTemplate,
                        profile: profile,
                        layout: layout,
                        width: cardWidth,
                        height: cardWidth * (450 / 360),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),

                    // Primary Button: "Status lagao"
                    PrimaryButton(
                      label: _isExporting ? 'Preparing...' : AppStrings.homeButtonStatus,
                      leadingIcon: _isExporting ? null : Icons.chat_bubble_outline,
                      onPressed: _isExporting ? null : () => _shareHeroStatus(heroTemplate, layout),
                    ),
                    const SizedBox(height: AppTokens.space8),

                    // Text Button: "Badlo"
                    Center(
                      child: SecondaryTextButton(
                        label: AppStrings.homeButtonEdit,
                        onPressed: () => context.push('/editor/${heroTemplate.id}'),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),

                    // Upcoming Section Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.homeUpcomingSectionTitle,
                          style: AppTokens.small12.copyWith(color: AppTokens.muted),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/tyohar'),
                          child: Text(
                            AppStrings.homeSeeAll,
                            style: AppTokens.small12.copyWith(color: AppTokens.gold, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space12),

                    // Horizontal Row of Upcoming Tiles
                    SizedBox(
                      height: 128,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: templates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppTokens.space12),
                        itemBuilder: (context, index) {
                          final item = templates[index];
                          return GestureDetector(
                            onTap: () => context.push('/editor/${item.id}'),
                            child: Container(
                              width: 112,
                              padding: const EdgeInsets.all(AppTokens.space8),
                              decoration: BoxDecoration(
                                color: item.palette.bgColor,
                                borderRadius: BorderRadius.circular(AppTokens.radiusTile),
                                border: Border.all(color: AppTokens.border, width: 0.5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    item.festivalDate,
                                    style: AppTokens.caption11.copyWith(color: item.palette.accent),
                                  ),
                                  Icon(Icons.auto_awesome, color: item.palette.accent, size: 24),
                                  Text(
                                    item.title,
                                    style: AppTokens.small12.copyWith(
                                      fontFamily: AppTokens.fontDisplay,
                                      color: AppTokens.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const HomeAdSlot(),
                    const SizedBox(height: AppTokens.space24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
