import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable UserProfile model (Task B2).
class UserProfile {
  final String name;
  final String? shopName;
  final String photoPath;
  final DateTime updatedAt;

  const UserProfile({
    required this.name,
    this.shopName,
    required this.photoPath,
    required this.updatedAt,
  });

  /// Helper getter: first word of name
  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.first;
  }

  UserProfile copyWith({
    String? name,
    String? shopName,
    String? photoPath,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      photoPath: photoPath ?? this.photoPath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Name normalization helper (Task B6)
  static String normalizeName(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Name validation helper (Task B6): 2-30 chars, Latin & Devanagari letters, spaces, dots, hyphens.
  static bool isValidName(String raw) {
    final normalized = normalizeName(raw);
    if (normalized.length < 2 || normalized.length > 30) return false;
    final validCharRegex = RegExp(r'^[a-zA-Z\u0900-\u097F\s.\-]+$');
    return validCharRegex.hasMatch(normalized);
  }
}

class ProfileRepository {
  static const String _keyName = 'user_name';
  static const String _keyShopName = 'user_shop_name';
  static const String _keyPhotoPath = 'user_photo_path';
  static const String _keyUpdatedAt = 'user_updated_at';

  final SharedPreferences _prefs;

  ProfileRepository(this._prefs);

  static Future<ProfileRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfileRepository(prefs);
  }

  UserProfile? load() {
    final name = _prefs.getString(_keyName);
    final photoPath = _prefs.getString(_keyPhotoPath);

    if (name == null || name.isEmpty || photoPath == null || photoPath.isEmpty) {
      return null;
    }

    final shopName = _prefs.getString(_keyShopName);
    final updatedAtMs = _prefs.getInt(_keyUpdatedAt) ?? DateTime.now().millisecondsSinceEpoch;

    return UserProfile(
      name: name,
      shopName: shopName,
      photoPath: photoPath,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }

  Future<void> save(UserProfile profile) async {
    final normalizedName = UserProfile.normalizeName(profile.name);
    await _prefs.setString(_keyName, normalizedName);

    if (profile.shopName != null && profile.shopName!.trim().isNotEmpty) {
      await _prefs.setString(_keyShopName, profile.shopName!.trim());
    } else {
      await _prefs.remove(_keyShopName);
    }

    await _prefs.setString(_keyPhotoPath, profile.photoPath);
    await _prefs.setInt(_keyUpdatedAt, profile.updatedAt.millisecondsSinceEpoch);
  }

  /// Saves new photo JPEG file to app directory with timestamp naming, evicting old image & deleting old file.
  Future<String> savePhotoFile(File newPhotoFile) async {
    final oldPath = _prefs.getString(_keyPhotoPath);

    // Evict old photo from Flutter image cache if it exists
    if (oldPath != null && oldPath.isNotEmpty) {
      final oldFile = File(oldPath);
      PaintingBinding.instance.imageCache.evict(FileImage(oldFile));
      if (oldFile.existsSync()) {
        try {
          await oldFile.delete();
        } catch (_) {}
      }
    }

    final appDir = await getApplicationDocumentsDirectory();
    final newFileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${appDir.path}/$newFileName';
    final savedFile = await newPhotoFile.copy(newPath);

    await _prefs.setString(_keyPhotoPath, savedFile.path);
    return savedFile.path;
  }

  Future<void> clear() async {
    final oldPath = _prefs.getString(_keyPhotoPath);
    if (oldPath != null && oldPath.isNotEmpty) {
      final oldFile = File(oldPath);
      PaintingBinding.instance.imageCache.evict(FileImage(oldFile));
      if (oldFile.existsSync()) {
        try {
          await oldFile.delete();
        } catch (_) {}
      }
    }

    await _prefs.remove(_keyName);
    await _prefs.remove(_keyShopName);
    await _prefs.remove(_keyPhotoPath);
    await _prefs.remove(_keyUpdatedAt);
    await _prefs.remove('has_user_profile');
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('profileRepositoryProvider must be initialized in ProviderScope overrides');
});

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final repository = ref.watch(profileRepositoryProvider);
    return repository.load();
  }

  Future<void> saveProfile({
    required String name,
    required File photoFile,
    String? shopName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      final photoPath = await repository.savePhotoFile(photoFile);

      final profile = UserProfile(
        name: name,
        shopName: shopName,
        photoPath: photoPath,
        updatedAt: DateTime.now(),
      );

      await repository.save(profile);
      return profile;
    });
  }

  Future<void> updateProfileDetails({
    required String name,
    File? newPhotoFile,
    String? shopName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      final current = state.value;

      String photoPath = current?.photoPath ?? '';
      if (newPhotoFile != null) {
        photoPath = await repository.savePhotoFile(newPhotoFile);
      }

      final updated = UserProfile(
        name: name,
        shopName: shopName,
        photoPath: photoPath,
        updatedAt: DateTime.now(),
      );

      await repository.save(updated);
      return updated;
    });
  }

  Future<void> clearProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      await repository.clear();
      return null;
    });
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(() {
  return ProfileNotifier();
});

final hasProfileProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(profileProvider);
  return profileAsync.value != null;
});
