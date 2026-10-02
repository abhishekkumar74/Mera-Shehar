import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/templates/domain/template_model.dart';
import 'analytics_service.dart';

class CardExportService {
  Future<File?> exportPng({
    required GlobalKey boundaryKey,
    required String templateId,
    required PhotoLayout layout,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Clean up old exported files older than 24 hours
      await _cleanupOldExports();

      // Wait for rendering & painting frames to be ready
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      // 360x450 canvas at pixelRatio 3.0 produces exactly 1080x1350 PNG
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();

      final cacheDir = await getTemporaryDirectory();
      final cardsDir = Directory('${cacheDir.path}/cards');
      if (!cardsDir.existsSync()) {
        await cardsDir.create(recursive: true);
      }

      final fileName = '${templateId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${cardsDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      stopwatch.stop();

      await analyticsService.log('export_done', {
        'template_id': templateId,
        'layout': layout.name,
        'ms': stopwatch.elapsedMilliseconds,
      });

      return file;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cleanupOldExports() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cardsDir = Directory('${cacheDir.path}/cards');
      if (!cardsDir.existsSync()) return;

      final now = DateTime.now();
      final files = cardsDir.listSync();

      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.png')) {
          final stat = entity.statSync();
          if (now.difference(stat.modified).inHours >= 24) {
            try {
              entity.deleteSync();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }
}

final cardExportService = CardExportService();
