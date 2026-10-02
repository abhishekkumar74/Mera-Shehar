import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/card_export_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/data/profile_repository.dart';
import '../../templates/data/template_repository.dart';
import '../../templates/domain/template_model.dart';
import '../../templates/presentation/card_renderer.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String templateId;

  const EditorScreen({super.key, required this.templateId});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> with WidgetsBindingObserver {
  final GlobalKey _boundaryKey = GlobalKey();

  PhotoLayout _selectedLayout = PhotoLayout.bottomLeft;
  String? _cardSpecificName;
  bool _isExporting = false;
  bool _isSavedToGallery = false;
  String? _exportError;
  bool _awaitingReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastLayout();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingReturn) {
      _awaitingReturn = false;
      if (mounted) {
        context.push('/share-success');
      }
    }
  }

  Future<void> _loadLastLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('editor_last_layout');

    final template = await ref.read(templateByIdProvider(widget.templateId).future);
    if (template != null) {
      analyticsService.log('editor_open', {
        'template_id': template.id,
        'layout': template.defaultLayout.name,
      });

      if (saved != null) {
        final match = PhotoLayout.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => template.defaultLayout,
        );
        if (template.photoLayouts.contains(match)) {
          setState(() => _selectedLayout = match);
          return;
        }
      }

      setState(() => _selectedLayout = template.defaultLayout);
    }
  }

  Future<void> _changeLayout(PhotoLayout layout) async {
    setState(() => _selectedLayout = layout);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('editor_last_layout', layout.name);

    analyticsService.log('layout_change', {
      'template_id': widget.templateId,
      'layout': layout.name,
    });
  }

  void _editCardName(UserProfile? currentProfile) {
    final controller = TextEditingController(text: _cardSpecificName ?? currentProfile?.name ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokens.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusBottomSheet)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppTokens.screenPaddingHorizontal,
            right: AppTokens.screenPaddingHorizontal,
            top: AppTokens.space24,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppTokens.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Card par naam badlein', style: AppTokens.heading22),
              const SizedBox(height: AppTokens.space16),
              TextField(
                controller: controller,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                style: AppTokens.body14Medium,
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'Aapka naam',
                ),
              ),
              const SizedBox(height: AppTokens.space20),
              PrimaryButton(
                label: 'Save karein',
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    setState(() => _cardSpecificName = text);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _exportCard() async {
    if (_isExporting) return null;
    setState(() {
      _isExporting = true;
      _exportError = null;
    });

    try {
      final file = await cardExportService.exportPng(
        boundaryKey: _boundaryKey,
        templateId: widget.templateId,
        layout: _selectedLayout,
      );

      if (file == null && mounted) {
        setState(() => _exportError = AppStrings.errGeneric);
      }
      return file;
    } catch (_) {
      if (mounted) {
        setState(() => _exportError = AppStrings.errGeneric);
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _shareToStatus() async {
    analyticsService.log('share_status_tap', {
      'template_id': widget.templateId,
      'layout': _selectedLayout.name,
    });

    final file = await _exportCard();
    if (file == null) return;

    _awaitingReturn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shares_total', (prefs.getInt('shares_total') ?? 0) + 1);

    await shareService.shareToWhatsApp(file);
  }

  Future<void> _shareGeneric() async {
    analyticsService.log('share_generic_tap', {
      'template_id': widget.templateId,
      'layout': _selectedLayout.name,
    });

    final file = await _exportCard();
    if (file == null) return;

    _awaitingReturn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shares_total', (prefs.getInt('shares_total') ?? 0) + 1);

    await shareService.shareGeneric(file);
  }

  Future<void> _downloadToGallery() async {
    final file = await _exportCard();
    if (file == null) return;

    final result = await shareService.saveToGallery(file);
    if (result == 'ok' && mounted) {
      setState(() => _isSavedToGallery = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isSavedToGallery = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(templateByIdProvider(widget.templateId));
    final profileState = ref.watch(profileProvider);
    final profile = profileState.value;

    final displayProfile = _cardSpecificName != null
        ? profile?.copyWith(name: _cardSpecificName)
        : profile;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (AppTokens.screenPaddingHorizontal * 2);

    return templateAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppTokens.bg,
        body: Center(child: CircularProgressIndicator(color: AppTokens.ink)),
      ),
      error: (err, st) => Scaffold(
        backgroundColor: AppTokens.bg,
        body: Center(child: Text(AppStrings.errGeneric, style: AppTokens.body14)),
      ),
      data: (template) {
        if (template == null) {
          return Scaffold(
            backgroundColor: AppTokens.bg,
            body: Center(child: Text(AppStrings.errGeneric, style: AppTokens.body14)),
          );
        }

        return Scaffold(
          backgroundColor: AppTokens.bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTokens.ink),
              onPressed: () => context.pop(),
            ),
            centerTitle: true,
            title: Text(template.title, style: AppTokens.heading22),
            actions: [
              IconButton(
                icon: Icon(
                  _isSavedToGallery ? Icons.check_circle : Icons.download_outlined,
                  color: _isSavedToGallery ? AppTokens.success : AppTokens.ink,
                ),
                onPressed: _downloadToGallery,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.screenPaddingHorizontal,
              vertical: AppTokens.space12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Card Preview Wrapper
                Center(
                  child: GestureDetector(
                    onTap: () => _editCardName(profile),
                    child: CardView(
                      boundaryKey: _boundaryKey,
                      template: template,
                      profile: displayProfile,
                      layout: _selectedLayout,
                      width: cardWidth,
                      height: cardWidth * (450 / 360),
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.space20),

                // Layout Picker Section
                Text(
                  AppStrings.editorPhotoLayoutHeader,
                  style: AppTokens.small12.copyWith(color: AppTokens.muted),
                ),
                const SizedBox(height: AppTokens.space12),

                // Layout Options Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: template.photoLayouts.map((layout) {
                    final isSelected = _selectedLayout == layout;
                    return _LayoutTile(
                      layout: layout,
                      isSelected: isSelected,
                      onTap: () => _changeLayout(layout),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppTokens.space24),

                if (_exportError != null) ...[
                  Center(
                    child: Text(
                      _exportError!,
                      style: AppTokens.small12.copyWith(color: const Color(0xFFB3261E)),
                    ),
                  ),
                  const SizedBox(height: AppTokens.space12),
                ],

                // Action Buttons Row (Primary: Status, Secondary: Share)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: _isExporting ? 'Preparing...' : AppStrings.editorButtonStatus,
                        leadingIcon: _isExporting ? null : Icons.chat_bubble_outline,
                        onPressed: _isExporting ? null : _shareToStatus,
                      ),
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: AppTokens.buttonHeight,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTokens.ink, width: 1.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radiusButton),
                            ),
                            foregroundColor: AppTokens.ink,
                          ),
                          onPressed: _isExporting ? null : _shareGeneric,
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: Text(AppStrings.editorButtonShare, style: AppTokens.body14Medium),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LayoutTile extends StatelessWidget {
  final PhotoLayout layout;
  final bool isSelected;
  final VoidCallback onTap;

  const _LayoutTile({
    required this.layout,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppTokens.surface : AppTokens.chip,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTokens.ink : AppTokens.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Mini Diagram of Pill Position
            _buildMiniPillDiagram(),

            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTokens.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 10, color: AppTokens.bg),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPillDiagram() {
    Alignment alignment;
    switch (layout) {
      case PhotoLayout.bottomLeft:
        alignment = Alignment.bottomLeft;
        break;
      case PhotoLayout.bottomRight:
        alignment = Alignment.bottomRight;
        break;
      case PhotoLayout.bottomCenter:
      case PhotoLayout.none:
      default:
        alignment = Alignment.bottomCenter;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: alignment,
        child: Container(
          width: layout == PhotoLayout.none ? 24 : 32,
          height: 12,
          decoration: BoxDecoration(
            color: AppTokens.ink.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
