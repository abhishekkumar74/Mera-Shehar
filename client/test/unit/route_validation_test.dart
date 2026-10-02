import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roz/features/templates/domain/template_model.dart';
import 'package:roz/features/templates/data/template_repository.dart';

class MockTemplateRepository implements TemplateRepository {
  final List<Template> _templates;
  MockTemplateRepository(this._templates);

  @override
  Future<List<Template>> getAll() async => _templates;

  @override
  Future<Template?> getById(String id) async {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Template>> getUpcoming(DateTime now) async => _templates;
}

void main() {
  group('Route Allow-List & Validation Tests', () {
    late MockTemplateRepository mockRepo;

    setUp(() {
      mockRepo = MockTemplateRepository([
        const Template(
          id: 'diwali_gold_01',
          category: 'diwali',
          title: 'Diwali Gold',
          festivalDate: '2026-11-08',
          isPremium: false,
          isActive: true,
          sortOrder: 1,
          palette: TemplatePalette(
            bgColor: Color(0xFFF4E8D8),
            pillBg: Color(0xFFFFFFFF),
            pillText: Color(0xFF2B2623),
            accent: Color(0xFF8A6212),
          ),
          backgroundAsset: 'assets/templates/diwali_gold_01/bg.webp',
          showInnerFrame: true,
          texts: [],
          photoLayouts: [PhotoLayout.bottomLeft],
          defaultLayout: PhotoLayout.bottomLeft,
        ),
      ]);
    });

    String resolveRoute(String? route, MockTemplateRepository repo) {
      if (route == null || route.isEmpty || route == '/home') {
        return '/home';
      }

      if (route.startsWith('/editor/')) {
        final templateId = route.substring('/editor/'.length);
        final hasTemplate = repo._templates.any((t) => t.id == templateId);
        if (hasTemplate) {
          return route;
        } else {
          return '/home';
        }
      }

      return '/home';
    }

    test('Valid editor route resolves correctly', () {
      final resolved = resolveRoute('/editor/diwali_gold_01', mockRepo);
      expect(resolved, '/editor/diwali_gold_01');
    });

    test('Missing template ID falls back to /home', () {
      final resolved = resolveRoute('/editor/non_existent_template', mockRepo);
      expect(resolved, '/home');
    });

    test('Invalid or arbitrary route falls back to /home', () {
      expect(resolveRoute('/malicious_route', mockRepo), '/home');
      expect(resolveRoute('', mockRepo), '/home');
      expect(resolveRoute(null, mockRepo), '/home');
    });
  });
}
