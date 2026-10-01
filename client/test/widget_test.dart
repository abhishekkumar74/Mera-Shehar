import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roz/main.dart';
import 'package:roz/core/strings/app_strings.dart';
import 'package:roz/core/services/photo_picker_service.dart';
import 'package:roz/features/profile/data/profile_repository.dart';

class MockPhotoPickerService implements PhotoPickerService {
  final File? mockFile;

  MockPhotoPickerService({this.mockFile});

  @override
  Future<File?> pickAndCropImage({
    required ImageSource source,
    required BuildContext context,
  }) async {
    return mockFile;
  }

  @override
  Future<File?> retrieveLostData() async {
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots, redirects to onboarding, validates fields on submit', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = ProfileRepository(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repo),
          photoPickerServiceProvider.overrideWithValue(MockPhotoPickerService()),
        ],
        child: const MeraSheharApp(),
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
      'user_name': 'Ram Sharma',
      'user_photo_path': '/tmp/mock_photo.jpg',
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = ProfileRepository(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repo),
          photoPickerServiceProvider.overrideWithValue(MockPhotoPickerService()),
        ],
        child: const MeraSheharApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Home screen and bottom navigation tabs are displayed with user greeting
    expect(find.text(AppStrings.tabHome), findsOneWidget);
    expect(find.text(AppStrings.tabTyohar), findsOneWidget);
    expect(find.text(AppStrings.tabSaved), findsOneWidget);
    expect(find.text(AppStrings.tabProfile), findsOneWidget);
    expect(find.text('Ram ji'), findsOneWidget);
  });
}
