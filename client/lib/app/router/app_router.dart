import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_tokens.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../features/dev/presentation/design_preview_screen.dart';
import '../../features/editor/presentation/editor_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/saved/presentation/saved_screen.dart';
import '../../features/share/presentation/share_success_screen.dart';
import '../../features/tyohar/presentation/tyohar_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final profileAsync = ref.watch(profileProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      if (profileAsync.isLoading) {
        return null; // Plain bg screen while loading
      }

      final hasProfile = profileAsync.value != null;
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      final isGoingToDev = state.matchedLocation == '/dev/design';

      if (isGoingToDev) return null;

      if (!hasProfile && !isGoingToOnboarding) {
        return '/onboarding';
      }

      if (hasProfile && isGoingToOnboarding) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          if (profileAsync.isLoading) {
            return const Scaffold(backgroundColor: AppTokens.bg);
          }
          return const OnboardingScreen();
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          if (profileAsync.isLoading) {
            return const Scaffold(backgroundColor: AppTokens.bg);
          }

          int currentIndex = 0;
          final location = state.matchedLocation;
          if (location.startsWith('/tyohar')) {
            currentIndex = 1;
          } else if (location.startsWith('/saved')) {
            currentIndex = 2;
          } else if (location.startsWith('/profile')) {
            currentIndex = 3;
          }

          return Scaffold(
            body: child,
            bottomNavigationBar: AppBottomNav(
              currentIndex: currentIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/tyohar');
                    break;
                  case 2:
                    context.go('/saved');
                    break;
                  case 3:
                    context.go('/profile');
                    break;
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/tyohar',
            builder: (context, state) => const TyoharScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/editor/:templateId',
        builder: (context, state) {
          final templateId = state.pathParameters['templateId'] ?? 'default';
          return EditorScreen(templateId: templateId);
        },
      ),
      GoRoute(
        path: '/share-success',
        builder: (context, state) => const ShareSuccessScreen(),
      ),
      GoRoute(
        path: '/dev/design',
        builder: (context, state) => const DesignPreviewScreen(),
      ),
    ],
  );
});
