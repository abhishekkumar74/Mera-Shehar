import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/app_links.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/photo_picker_service.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../notifications/domain/notification_permission_state_machine.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();

  File? _newPhotoFile;
  String? _nameError;
  String? _linkError;
  bool _isSaving = false;
  bool _savedSuccess = false;
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

  bool _hasChanges(UserProfile profile) {
    if (_newPhotoFile != null) return true;
    if (_nameController.text.trim() != profile.name) return true;
    if (_shopNameController.text.trim() != (profile.shopName ?? '')) return true;
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final photoPicker = ref.read(photoPickerServiceProvider);
    final file = await photoPicker.pickAndCropImage(source: source, context: context);

    if (file != null && mounted) {
      setState(() {
        _newPhotoFile = file;
        _savedSuccess = false;
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

  Future<void> _saveProfile() async {
    final rawName = _nameController.text;
    final normalizedName = UserProfile.normalizeName(rawName);

    if (!UserProfile.isValidName(normalizedName)) {
      setState(() => _nameError = AppStrings.onboardingErrName);
      return;
    }

    setState(() {
      _nameError = null;
      _isSaving = true;
    });

    try {
      await ref.read(profileProvider.notifier).updateProfileDetails(
            name: normalizedName,
            newPhotoFile: _newPhotoFile,
            shopName: _shopNameController.text,
          );

      if (mounted) {
        setState(() {
          _newPhotoFile = null;
          _savedSuccess = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _savedSuccess = false);
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _resetProfile() async {
    await ref.read(profileProvider.notifier).clearProfile();
    if (mounted) {
      context.go('/onboarding');
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
          final isChanged = profile != null && _hasChanges(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.screenPaddingHorizontal,
              vertical: AppTokens.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 112dp Avatar Picker
                GestureDetector(
                  onTap: _showImagePickerSheet,
                  child: Stack(
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTokens.surface,
                          border: Border.all(color: AppTokens.border, width: 1.5),
                        ),
                        child: ClipOval(
                          child: _newPhotoFile != null
                              ? Image.file(
                                  _newPhotoFile!,
                                  width: 112,
                                  height: 112,
                                  fit: BoxFit.cover,
                                )
                              : (existingPhotoPath != null &&
                                      existingPhotoPath.isNotEmpty &&
                                      File(existingPhotoPath).existsSync())
                                  ? Image.file(
                                      File(existingPhotoPath),
                                      width: 112,
                                      height: 112,
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
                        bottom: 4,
                        right: 4,
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
                        onChanged: (_) => setState(() => _savedSuccess = false),
                      ),
                    ),
                    if (_nameError != null) ...[
                      const SizedBox(height: AppTokens.space4),
                      Text(
                        _nameError!,
                        style: AppTokens.small12.copyWith(color: const Color(0xFFB3261E)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppTokens.space20),

                // Shop Name Input (Optional)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dukaan ka naam (optional)',
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
                        onChanged: (_) => setState(() => _savedSuccess = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space24),

                // Primary Save Button (Only visible when changes exist or recently saved)
                if (isChanged || _savedSuccess)
                  PrimaryButton(
                    label: _savedSuccess
                        ? 'Save ho gaya'
                        : (_isSaving ? 'Saving...' : 'Save karein'),
                    leadingIcon: _savedSuccess ? Icons.check : null,
                    onPressed: _isSaving ? null : _saveProfile,
                  ),
                const SizedBox(height: AppTokens.space24),

                const Divider(color: AppTokens.border),
                const SizedBox(height: AppTokens.space8),

                // Notification Reminder Row
                Consumer(
                  builder: (context, ref, child) {
                    final stateMachine = notificationService.stateMachine;
                    final isGranted = stateMachine.state == NotificationPermState.accepted;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.notifications_active_outlined, color: AppTokens.ink),
                          title: Text('Roz subah reminder', style: AppTokens.body14Medium),
                          trailing: Switch(
                            value: isGranted,
                            activeThumbColor: AppTokens.gold,
                            onChanged: (val) async {
                              final prefs = await SharedPreferences.getInstance();
                              if (stateMachine.state == NotificationPermState.denied) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Settings mein notification allow karein'),
                                    action: SnackBarAction(
                                      label: 'Settings',
                                      onPressed: () => _openUrl('app-settings:'),
                                    ),
                                  ),
                                );
                                return;
                              }
                              await notificationService.toggleReminderSwitch(val, prefs);
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Invite Friend Row
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: AppTokens.ink),
                  title: Text('Dost ko bhejo', style: AppTokens.body14Medium),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTokens.hint),
                  onTap: () async {
                    analyticsService.logEvent('invite_tap');
                    final inviteUrl = await AppLinks.buildPlayStoreUrl(source: 'invite');
                    final inviteText = 'Apne naam aur photo ke saath tyohar ke card banao, free: $inviteUrl';
                    await Share.share(inviteText);
                  },
                ),
                const Divider(color: AppTokens.border),
                const SizedBox(height: AppTokens.space8),

                // List Rows for Legal
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppTokens.ink),
                  title: Text(AppStrings.profilePrivacy, style: AppTokens.body14Medium),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTokens.hint),
                  onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppTokens.ink),
                  title: Text(AppStrings.profileTerms, style: AppTokens.body14Medium),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTokens.hint),
                  onTap: () => _openUrl(AppConstants.termsConditionsUrl),
                ),
                if (_linkError != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(AppTokens.space8),
                    child: Text(
                      _linkError!,
                      style: AppTokens.caption11.copyWith(color: const Color(0xFFB3261E)),
                    ),
                  ),
                ],
                const SizedBox(height: AppTokens.space24),

                // Debug Reset Option
                if (kDebugMode)
                  TextButton.icon(
                    onPressed: _resetProfile,
                    icon: const Icon(Icons.refresh, size: 16, color: Color(0xFFB3261E)),
                    label: Text(
                      'Reset profile (Debug only)',
                      style: AppTokens.small12.copyWith(color: const Color(0xFFB3261E)),
                    ),
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
