import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/ad_service.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../profile/data/profile_repository.dart';
import '../../templates/data/template_repository.dart';
import '../../templates/domain/template_model.dart';
import '../../templates/presentation/card_renderer.dart';
import 'tyohar_ad_slot.dart';

class TyoharScreen extends ConsumerWidget {
  const TyoharScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    final profileState = ref.watch(profileProvider);
    final profile = profileState.value;

    return Scaffold(
      appBar: AppTopBar.title(AppStrings.tabTyohar),
      backgroundColor: AppTokens.bg,
      body: templatesAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(AppTokens.screenPaddingHorizontal),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 360 / 450,
              crossAxisSpacing: AppTokens.space12,
              mainAxisSpacing: AppTokens.space12,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => const SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: AppTokens.radiusTile,
            ),
          ),
        ),
        error: (err, st) => Center(child: Text(AppStrings.errGeneric, style: AppTokens.body14)),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(child: Text(AppStrings.phase0Placeholder, style: AppTokens.body14));
          }

          final chunkSize = adService.nativeAdEveryN;
          final List<List<Template>> chunks = [];
          for (var i = 0; i < templates.length; i += chunkSize) {
            final end = (i + chunkSize < templates.length) ? i + chunkSize : templates.length;
            chunks.add(templates.sublist(i, end));
          }

          return CustomScrollView(
            slivers: [
              for (var i = 0; i < chunks.length; i++) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.screenPaddingHorizontal,
                    vertical: AppTokens.space8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 360 / 450,
                      crossAxisSpacing: AppTokens.space12,
                      mainAxisSpacing: AppTokens.space12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final template = chunks[i][index];
                        final boundaryKey = GlobalKey();

                        return GestureDetector(
                          onTap: () => context.push('/editor/${template.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppTokens.radiusTile),
                                  child: CardView(
                                    boundaryKey: boundaryKey,
                                    template: template,
                                    profile: profile,
                                    layout: template.defaultLayout,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTokens.space4),
                              Text(
                                template.title,
                                style: AppTokens.small12.copyWith(color: AppTokens.ink),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: chunks[i].length,
                    ),
                  ),
                ),
                if (i < chunks.length - 1 && adService.adsEnabled)
                  const SliverToBoxAdapter(child: TyoharAdSlot()),
              ],
            ],
          );
        },
      ),
    );
  }
}
