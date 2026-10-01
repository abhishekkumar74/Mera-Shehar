import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roz/main.dart';
import 'package:roz/core/strings/app_strings.dart';

void main() {
  testWidgets('App boots, redirects to onboarding, validates fields on submit', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MeraSheharApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Onboarding screen is shown
    expect(find.text(AppStrings.onboardingHeading), findsOneWidget);
    expect(find.text(AppStrings.onboardingButton), findsOneWidget);

    // Tap "Shuru karein" button without photo or name
    await tester.tap(find.text(AppStrings.onboardingButton));
    await tester.pumpAndSettle();

    // Inline validation error messages should be shown (photo error + name error)
    expect(find.text(AppStrings.onboardingErrPhoto), findsNWidgets(2));
    expect(find.text(AppStrings.onboardingErrName), findsOneWidget);
  });

  testWidgets('App boots directly to Home with 4 tabs when profile exists', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'has_user_profile': true,
      'user_name': 'Ram Sharma',
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MeraSheharApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Home screen and bottom navigation tabs are displayed
    expect(find.text(AppStrings.tabHome), findsOneWidget);
    expect(find.text(AppStrings.tabTyohar), findsOneWidget);
    expect(find.text(AppStrings.tabSaved), findsOneWidget);
    expect(find.text(AppStrings.tabProfile), findsOneWidget);
  });
}
