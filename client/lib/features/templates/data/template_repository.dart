import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/template_model.dart';

abstract class TemplateRepository {
  Future<List<Template>> getAll();
  Future<Template?> getById(String id);
  Future<List<Template>> getUpcoming(DateTime now);
}

class BundledTemplateSource implements TemplateRepository {
  List<Template>? _cachedTemplates;

  @override
  Future<List<Template>> getAll() async {
    if (_cachedTemplates != null) return _cachedTemplates!;

    try {
      final jsonString = await rootBundle.loadString('assets/templates/index.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      _cachedTemplates = jsonList.map((e) => Template.fromJson(e as Map<String, dynamic>)).toList();
      _cachedTemplates!.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return _cachedTemplates!;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Template?> getById(String id) async {
    final templates = await getAll();
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Template>> getUpcoming(DateTime now) async {
    final templates = await getAll();
    final upcoming = templates.where((t) {
      try {
        final date = DateTime.parse(t.festivalDate);
        return date.isAfter(now.subtract(const Duration(days: 1)));
      } catch (_) {
        return true;
      }
    }).toList();

    upcoming.sort((a, b) {
      final da = DateTime.tryParse(a.festivalDate) ?? now;
      final db = DateTime.tryParse(b.festivalDate) ?? now;
      return da.compareTo(db);
    });

    return upcoming;
  }
}

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return BundledTemplateSource();
});

final templatesProvider = FutureProvider<List<Template>>((ref) async {
  final repo = ref.watch(templateRepositoryProvider);
  return repo.getAll();
});

final upcomingTemplatesProvider = FutureProvider<List<Template>>((ref) async {
  final repo = ref.watch(templateRepositoryProvider);
  return repo.getUpcoming(DateTime.now());
});

final templateByIdProvider = FutureProvider.family<Template?, String>((ref, id) async {
  final repo = ref.watch(templateRepositoryProvider);
  return repo.getById(id);
});
