import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/services/install_referral_service.dart';
import 'core/services/notification_service.dart';
import 'core/strings/app_strings.dart';
import 'core/tokens/app_tokens.dart';
import 'features/profile/data/profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Task 1: Portrait orientation only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Task 1: Edge-to-edge styling with light status bar (dark icons) over `bg`
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppTokens.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final sharedPrefs = await SharedPreferences.getInstance();
  final profileRepository = ProfileRepository(sharedPrefs);

  // Phase 4 Services Init
  await notificationService.init(sharedPrefs);
  await InstallReferralService.checkAndProcessReferrer();

  runApp(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ],
      child: const MeraSheharApp(),
    ),
  );
}

class MeraSheharApp extends ConsumerWidget {
  const MeraSheharApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
