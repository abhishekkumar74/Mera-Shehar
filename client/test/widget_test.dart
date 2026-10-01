import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roz/main.dart';
import 'package:roz/core/strings/app_strings.dart';

void main() {
  testWidgets('App boots, redirects to onboarding, tapping button reaches Home with 4 tabs', (WidgetTester tester) async {
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

    // Tap "Shuru karein" button
    await tester.tap(find.text(AppStrings.onboardingButton));
    await tester.pumpAndSettle();

    // Verify Home screen and bottom navigation tabs are displayed
    expect(find.text(AppStrings.tabHome), findsOneWidget);
    expect(find.text(AppStrings.tabTyohar), findsOneWidget);
    expect(find.text(AppStrings.tabSaved), findsOneWidget);
    expect(find.text(AppStrings.tabProfile), findsOneWidget);
  });
}
