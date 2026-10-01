import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/router/app_router.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/dashed_circle.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/data/profile_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedPhoto;
  String? _nameError;
  String? _photoError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: AppTokens.ink,
            toolbarWidgetColor: AppTokens.bg,
            activeControlsWidgetColor: AppTokens.gold,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedPhoto = File(croppedFile.path);
          _photoError = null;
        });
      }
    } catch (e) {
      // Ignore photo pick errors silently
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokens.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusBottomSheet),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.screenPaddingHorizontal,
              vertical: AppTokens.space24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.onboardingPhotoLabel,
                  style: AppTokens.heading22,
                ),
                const SizedBox(height: AppTokens.space20),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppTokens.ink),
                  title: Text('Gallery se chunein', style: AppTokens.body14Medium),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppTokens.ink),
                  title: Text('Camera se lo', style: AppTokens.body14Medium),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    bool hasError = false;

    setState(() {
      if (_selectedPhoto == null) {
        _photoError = AppStrings.onboardingErrPhoto;
        hasError = true;
      } else {
        _photoError = null;
      }

      if (name.isEmpty) {
        _nameError = AppStrings.onboardingErrName;
        hasError = true;
      } else {
        _nameError = null;
      }
    });

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(profileProvider.notifier).updateProfile(
            name: name,
            newPhotoFile: _selectedPhoto,
          );

      await ref.read(hasProfileProvider.notifier).completeOnboarding();

      if (mounted) {
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.screenPaddingHorizontal,
            vertical: AppTokens.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppTokens.space12),
              const Center(child: LogoMark(size: 56.0)),
              const SizedBox(height: AppTokens.space24),
              Text(
                AppStrings.onboardingHeading,
                style: AppTokens.title28,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space8),
              Text(
                AppStrings.onboardingSub,
                style: AppTokens.body14.copyWith(color: AppTokens.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space32),

              // Photo Picker (112dp Circle)
              GestureDetector(
                onTap: _showImagePickerSheet,
                child: Column(
                  children: [
                    CustomPaint(
                      painter: DashedCirclePainter(color: AppTokens.goldLine),
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: const BoxDecoration(
                          color: AppTokens.surface,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: _selectedPhoto != null
                              ? Stack(
                                  children: [
                                    Image.file(
                                      _selectedPhoto!,
                                      width: 112,
                                      height: 112,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTokens.ink,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 14,
                                          color: AppTokens.bg,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppTokens.gold,
                                      size: 28,
                                    ),
                                    const SizedBox(height: AppTokens.space4),
                                    Text(
                                      AppStrings.onboardingPhotoLabel,
                                      style: AppTokens.small12.copyWith(
                                        color: AppTokens.gold,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    if (_photoError != null) ...[
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        _photoError!,
                        style: AppTokens.small12.copyWith(
                          color: const Color(0xFFB3261E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        AppStrings.onboardingPhotoCaption,
                        style: AppTokens.small12,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space32),

              // Name Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.onboardingNameLabel,
                    style: AppTokens.small12.copyWith(
                      color: AppTokens.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space8),
                  SizedBox(
                    height: 52,
                    child: TextField(
                      controller: _nameController,
                      maxLength: 30,
                      textCapitalization: TextCapitalization.words,
                      style: AppTokens.body14Medium,
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: 'Ram Sharma',
                      ),
                      onChanged: (val) {
                        if (_nameError != null && val.trim().isNotEmpty) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                  ),
                  if (_nameError != null) ...[
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      _nameError!,
                      style: AppTokens.small12.copyWith(
                        color: const Color(0xFFB3261E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppTokens.space32),

              // Primary Button
              PrimaryButton(
                label: _isLoading ? 'Loading...' : AppStrings.onboardingButton,
                trailingIcon: _isLoading ? null : Icons.arrow_forward,
                onPressed: _isLoading ? null : _submit,
              ),
              const SizedBox(height: AppTokens.space12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppTokens.muted),
                  const SizedBox(width: AppTokens.space4),
                  Text(
                    AppStrings.onboardingTimeNotice,
                    style: AppTokens.small12,
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space32),

              // Legal / Privacy Notices
              Text(
                AppStrings.onboardingPrivacyNotice,
                style: AppTokens.caption11,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                AppStrings.onboardingTermsConsent,
                style: AppTokens.caption11,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space16),
            ],
          ),
        ),
      ),
    );
  }
}
