import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/photo_picker_service.dart';
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

  File? _selectedPhoto;
  String? _nameError;
  String? _photoError;
  String? _linkError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLostData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkLostData() async {
    final photoPicker = ref.read(photoPickerServiceProvider);
    final lostFile = await photoPicker.retrieveLostData();
    if (lostFile != null && mounted) {
      setState(() {
        _selectedPhoto = lostFile;
        _photoError = null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    final photoPicker = ref.read(photoPickerServiceProvider);
    final file = await photoPicker.pickAndCropImage(source: source, context: context);

    if (file != null && mounted) {
      setState(() {
        _selectedPhoto = file;
        _photoError = null;
      });
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

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        setState(() => _linkError = 'Link nahi khul paaya.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _linkError = 'Link nahi khul paaya.');
      }
    }
  }

  Future<void> _submit() async {
    final rawName = _nameController.text;
    final normalizedName = UserProfile.normalizeName(rawName);
    bool hasError = false;

    setState(() {
      if (_selectedPhoto == null) {
        _photoError = AppStrings.onboardingErrPhoto;
        hasError = true;
      } else {
        _photoError = null;
      }

      if (!UserProfile.isValidName(normalizedName)) {
        _nameError = AppStrings.onboardingErrName;
        hasError = true;
      } else {
        _nameError = null;
      }
    });

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(profileProvider.notifier).saveProfile(
            name: normalizedName,
            photoFile: _selectedPhoto!,
          );

      await analyticsService.log('onboarding_done');

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
                      textInputAction: TextInputAction.done,
                      style: AppTokens.body14Medium,
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: 'Ram Sharma',
                      ),
                      onChanged: (val) {
                        if (_nameError != null && UserProfile.isValidName(val)) {
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

              // Legal / Privacy Notices with Tappable Links
              Text(
                AppStrings.onboardingPrivacyNotice,
                style: AppTokens.caption11,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space4),

              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text('Aage badhkar aap ', style: AppTokens.caption11),
                  GestureDetector(
                    onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
                    child: Text(
                      'Privacy Policy',
                      style: AppTokens.caption11.copyWith(
                        color: AppTokens.gold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(' aur ', style: AppTokens.caption11),
                  GestureDetector(
                    onTap: () => _openUrl(AppConstants.termsConditionsUrl),
                    child: Text(
                      'Terms',
                      style: AppTokens.caption11.copyWith(
                        color: AppTokens.gold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(' se sahmat hote hain.', style: AppTokens.caption11),
                ],
              ),
              if (_linkError != null) ...[
                const SizedBox(height: AppTokens.space4),
                Text(
                  _linkError!,
                  style: AppTokens.caption11.copyWith(color: const Color(0xFFB3261E)),
                ),
              ],
              const SizedBox(height: AppTokens.space16),
            ],
          ),
        ),
      ),
    );
  }
}
