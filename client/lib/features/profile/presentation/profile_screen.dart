import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/primary_button.dart';

import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _newPhotoFile;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  void _initFields(UserProfile profile) {
    if (_initialized) return;
    _nameController.text = profile.name;
    _shopNameController.text = profile.shopName ?? '';
    _initialized = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
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
          _newPhotoFile = File(croppedFile.path);
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

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(profileProvider.notifier).updateProfile(
            name: name,
            newPhotoFile: _newPhotoFile,
            shopName: _shopNameController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile update ho gayi', style: AppTokens.body14),
            backgroundColor: AppTokens.ink,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppTopBar.title(AppStrings.profileTitle),
      backgroundColor: AppTokens.bg,
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTokens.ink)),
        error: (err, st) => Center(child: Text(AppStrings.errGeneric, style: AppTokens.body14)),
        data: (profile) {
          if (profile != null) {
            _initFields(profile);
          }

          final existingPhotoPath = profile?.photoPath;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.screenPaddingHorizontal,
              vertical: AppTokens.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Picker
                GestureDetector(
                  onTap: _showImagePickerSheet,
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTokens.surface,
                          border: Border.all(color: AppTokens.border, width: 1.5),
                        ),
                        child: ClipOval(
                          child: _newPhotoFile != null
                              ? Image.file(
                                  _newPhotoFile!,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                )
                              : (existingPhotoPath != null && File(existingPhotoPath).existsSync())
                                  ? Image.file(
                                      File(existingPhotoPath),
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        (profile?.name.isNotEmpty ?? false)
                                            ? profile!.name[0].toUpperCase()
                                            : 'M',
                                        style: AppTokens.title28.copyWith(color: AppTokens.gold),
                                      ),
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
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
                  ),
                ),
                const SizedBox(height: AppTokens.space24),

                // Name Input
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
                          hintText: 'Aapka naam',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space20),

                // Shop Name Input (Optional)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dukaan ya vyapaar ka naam (Optional)',
                      style: AppTokens.small12.copyWith(
                        color: AppTokens.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    SizedBox(
                      height: 52,
                      child: TextField(
                        controller: _shopNameController,
                        maxLength: 40,
                        textCapitalization: TextCapitalization.words,
                        style: AppTokens.body14Medium,
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: 'Ex: Sharma Traders',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space24),

                // Save Button
                PrimaryButton(
                  label: _isSaving ? 'Saving...' : 'Save',
                  onPressed: _isSaving ? null : _saveProfile,
                ),
                const SizedBox(height: AppTokens.space32),

                const Divider(color: AppTokens.border),
                const SizedBox(height: AppTokens.space16),

                // Secondary Links
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: AppTokens.ink),
                  title: Text(AppStrings.profileShareApp, style: AppTokens.body14Medium),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTokens.hint),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppTokens.ink),
                  title: Text(AppStrings.profilePrivacy, style: AppTokens.body14Medium),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTokens.hint),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppTokens.ink),
                  title: Text(AppStrings.profileTerms, style: AppTokens.body14Medium),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTokens.hint),
                  onTap: () {},
                ),
                const SizedBox(height: AppTokens.space24),

                Text(
                  'Mera Shehar v1.0.0',
                  style: AppTokens.caption11.copyWith(color: AppTokens.hint),
                ),
                const SizedBox(height: AppTokens.space24),
              ],
            ),
          );
        },
      ),
    );
  }
}
