import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String? photoPath;
  final String? shopName;

  const UserProfile({
    required this.name,
    this.photoPath,
    this.shopName,
  });

  UserProfile copyWith({
    String? name,
    String? photoPath,
    String? shopName,
  }) {
    return UserProfile(
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      shopName: shopName ?? this.shopName,
    );
  }
}

class ProfileRepository {
  static const String _keyName = 'user_name';
  static const String _keyPhotoPath = 'user_photo_path';
  static const String _keyShopName = 'user_shop_name';

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName);
    if (name == null || name.isEmpty) return null;

    final photoPath = prefs.getString(_keyPhotoPath);
    final shopName = prefs.getString(_keyShopName);

    return UserProfile(
      name: name,
      photoPath: photoPath,
      shopName: shopName,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, profile.name.trim());

    if (profile.shopName != null) {
      await prefs.setString(_keyShopName, profile.shopName!.trim());
    } else {
      await prefs.remove(_keyShopName);
    }

    if (profile.photoPath != null) {
      await prefs.setString(_keyPhotoPath, profile.photoPath!);
    }
  }

  Future<String> savePhotoToAppDir(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await file.copy('${appDir.path}/$fileName');
    return savedImage.path;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.loadProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    required String name,
    File? newPhotoFile,
    String? shopName,
  }) async {
    String? photoPath = state.value?.photoPath;

    if (newPhotoFile != null) {
      photoPath = await _repository.savePhotoToAppDir(newPhotoFile);
    }

    final updated = UserProfile(
      name: name.trim(),
      photoPath: photoPath,
      shopName: shopName?.trim(),
    );

    await _repository.saveProfile(updated);
    state = AsyncValue.data(updated);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repo);
});
