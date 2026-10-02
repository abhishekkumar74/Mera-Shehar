import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roz/features/notifications/presentation/notification_prompt_bottom_sheet.dart';
import 'package:roz/features/notifications/domain/notification_permission_state_machine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationPromptBottomSheet Widget Tests', () {
    testWidgets('Renders bottom sheet title and buttons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationPromptBottomSheet(),
          ),
        ),
      );

      expect(find.text('Roz subah card ready milega'), findsOneWidget);
      expect(find.text('Allow karein?'), findsOneWidget);
      expect(find.text('Haan, batao'), findsOneWidget);
      expect(find.text('Abhi nahi'), findsOneWidget);
    });

    testWidgets('Tapping Abhi nahi closes bottom sheet without requesting system permissions', (WidgetTester tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    builder: (_) => const NotificationPromptBottomSheet(),
                  );
                  closed = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Abhi nahi'), findsOneWidget);

      await tester.tap(find.text('Abhi nahi'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(closed, true);
    });
  });

  group('NotificationPermissionStateMachine State Tests', () {
    test('State machine transitions properly', () {
      final now = DateTime.now();
      var machine = const NotificationPermissionStateMachine();

      expect(machine.state, NotificationPermState.neverAsked);

      machine = machine.snooze(now);
      expect(machine.state, NotificationPermState.snoozed);

      machine = machine.accept();
      expect(machine.state, NotificationPermState.accepted);

      machine = machine.deny();
      expect(machine.state, NotificationPermState.denied);
    });
  });
}
