import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roz/features/profile/data/profile_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfile Model & Validation Tests', () {
    test('normalizeName collapses spaces and trims', () {
      expect(UserProfile.normalizeName('  Ram   Sharma  '), 'Ram Sharma');
      expect(UserProfile.normalizeName('राहुल    शर्मा'), 'राहुल शर्मा');
    });

    test('isValidName validates names correctly', () {
      // Valid names
      expect(UserProfile.isValidName('Ram Sharma'), true);
      expect(UserProfile.isValidName('राहुल शर्मा'), true);
      expect(UserProfile.isValidName('A. P. J. Abdul Kalam'), true);
      expect(UserProfile.isValidName('Mary-Jane'), true);

      // Invalid names
      expect(UserProfile.isValidName('A'), false); // Too short
      expect(UserProfile.isValidName('   '), false); // Only spaces
      expect(UserProfile.isValidName('Ram@123'), false); // Special characters/numbers
      expect(UserProfile.isValidName('A' * 31), false); // Too long (>30)
    });

    test('firstName extracts first word correctly', () {
      final profile = UserProfile(
        name: '  Rahul  Kumar  Sharma ',
        photoPath: '/path/to/photo.jpg',
        updatedAt: DateTime.parse('2026-10-01'),
      );
      expect(profile.firstName, 'Rahul');
    });
  });

  group('ProfileRepository Unit Tests', () {
    late ProfileRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ProfileRepository(prefs);
    });

    test('load returns null when no profile saved', () {
      expect(repository.load(), isNull);
    });

    test('save and load profile successfully', () async {
      final profile = UserProfile(
        name: 'Rahul Sharma',
        shopName: 'Sharma General Store',
        photoPath: '/tmp/profile_123.jpg',
        updatedAt: DateTime.now(),
      );

      await repository.save(profile);
      final loaded = repository.load();

      expect(loaded, isNotNull);
      expect(loaded!.name, 'Rahul Sharma');
      expect(loaded.shopName, 'Sharma General Store');
      expect(loaded.photoPath, '/tmp/profile_123.jpg');
      expect(loaded.firstName, 'Rahul');
    });

    test('clear removes all profile data', () async {
      final profile = UserProfile(
        name: 'Rahul Sharma',
        photoPath: '/tmp/profile_123.jpg',
        updatedAt: DateTime.now(),
      );

      await repository.save(profile);
      expect(repository.load(), isNotNull);

      await repository.clear();
      expect(repository.load(), isNull);
    });
  });
}
