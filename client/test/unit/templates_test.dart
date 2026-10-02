import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roz/features/templates/domain/template_model.dart';
import 'package:roz/features/templates/presentation/auto_fit_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Template JSON Parsing Tests', () {
    const jsonSample = '''
    {
      "id": "diwali_gold_01",
      "category": "diwali",
      "title": "Shubh Deepawali Gold",
      "festivalDate": "2026-11-08",
      "isPremium": false,
      "isActive": true,
      "sortOrder": 1,
      "palette": {
        "bgColor": "#F4E8D8",
        "pillBg": "#FFFFFF",
        "pillText": "#2B2623",
        "accent": "#8A6212"
      },
      "backgroundAsset": "assets/templates/diwali_gold_01/bg.webp",
      "showInnerFrame": true,
      "texts": [
        {
          "text": "Shubh Deepawali",
          "style": "display",
          "x": 0.5,
          "y": 0.32,
          "color": "#8A6212",
          "fontSize": 32,
          "maxWidth": 0.85
        }
      ],
      "photoLayouts": ["bottomLeft", "bottomCenter", "bottomRight", "none"],
      "defaultLayout": "bottomLeft"
    }
    ''';

    test('Parses template JSON successfully', () {
      final map = jsonDecode(jsonSample) as Map<String, dynamic>;
      final template = Template.fromJson(map);

      expect(template.id, 'diwali_gold_01');
      expect(template.category, 'diwali');
      expect(template.festivalDate, '2026-11-08');
      expect(template.showInnerFrame, true);
      expect(template.photoLayouts.length, 4);
      expect(template.defaultLayout, PhotoLayout.bottomLeft);
      expect(template.texts.first.text, 'Shubh Deepawali');
    });

    testWidgets('AutoFitText widget renders without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AutoFitText(
                text: 'आपको और आपके परिवार को दीपावली की हार्दिक शुभकामनाएं',
                style: TextStyle(fontSize: 28, height: 1.35),
                maxWidth: 300,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('दीपावली'), findsOneWidget);
    });
  });
}
