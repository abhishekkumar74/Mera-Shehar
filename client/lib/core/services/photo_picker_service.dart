import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../tokens/app_tokens.dart';

abstract class PhotoPickerService {
  Future<File?> pickAndCropImage({
    required ImageSource source,
    required BuildContext context,
  });

  Future<File?> retrieveLostData();
}

class DefaultPhotoPickerService implements PhotoPickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickAndCropImage({
    required ImageSource source,
    required BuildContext context,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 800,
        maxHeight: 800,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Photo ko theek karein',
            toolbarColor: AppTokens.ink,
            toolbarWidgetColor: AppTokens.bg,
            activeControlsWidgetColor: AppTokens.gold,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Photo ko theek karein',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      // Return null silently on cancel or error
    }
    return null;
  }

  @override
  Future<File?> retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty || response.file == null) return null;
      return File(response.file!.path);
    } catch (e) {
      return null;
    }
  }
}

final photoPickerServiceProvider = Provider<PhotoPickerService>((ref) {
  return DefaultPhotoPickerService();
});
