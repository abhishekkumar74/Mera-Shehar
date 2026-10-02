import 'dart:io';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'app_links.dart';

class ShareService {
  static const MethodChannel _channel = MethodChannel('mera_shehar/share');

  Future<void> shareToWhatsApp(File file) async {
    try {
      final String result = await _channel.invokeMethod('shareToWhatsApp', {
        'path': file.path,
      });

      if (result == 'not_installed') {
        await shareGeneric(file);
      }
    } catch (_) {
      await shareGeneric(file);
    }
  }

  Future<void> shareGeneric(File file, [String? caption]) async {
    try {
      final shareUrl = await AppLinks.buildPlayStoreUrl(source: 'share');
      final textCaption = caption ?? 'Mera Shehar se banaya. Aap bhi banao: $shareUrl';
      await Share.shareXFiles(
        [XFile(file.path)],
        text: textCaption,
      );
    } catch (_) {}
  }

  Future<String> saveToGallery(File file) async {
    try {
      final String result = await _channel.invokeMethod('saveToGallery', {
        'path': file.path,
      });

      if (result == 'unsupported') {
        await shareGeneric(file);
        return 'unsupported';
      }

      return result;
    } catch (_) {
      await shareGeneric(file);
      return 'fallback';
    }
  }
}

final shareService = ShareService();
