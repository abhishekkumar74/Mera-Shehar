import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/notifications/domain/notification_permission_state_machine.dart';
import '../../features/templates/data/template_repository.dart';
import 'analytics_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  FirebaseMessaging? _fcmInstance;
  FirebaseMessaging get _fcm {
    try {
      _fcmInstance ??= FirebaseMessaging.instance;
    } catch (_) {}
    return _fcmInstance ?? FirebaseMessaging.instance;
  }
  NotificationPermissionStateMachine _stateMachine = const NotificationPermissionStateMachine();

  static const String _prefsKey = 'notif_perm_state_machine';
  static const String _topicDaily = 'daily';

  NotificationPermissionStateMachine get stateMachine => _stateMachine;

  Future<void> init(SharedPreferences prefs) async {
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _stateMachine = NotificationPermissionStateMachine.fromMap(map);
      } catch (_) {}
    }

    // Print token in debug mode only
    if (kDebugMode) {
      try {
        final token = await _fcm.getToken();
        debugPrint('[NotificationService] FCM Token: $token');
      } catch (e) {
        debugPrint('[NotificationService] FCM Token error: $e');
      }
    }

    // Foreground listener: log only
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Foreground message received: ${message.messageId}');
    });
  }

  Future<void> setupTapHandling(GoRouter router, TemplateRepository catalogRepo) async {
    // Handle tap from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageTap(message, router, catalogRepo);
    });

    // Handle tap from terminated state (cold start)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage, router, catalogRepo);
    }
  }

  Future<void> _handleMessageTap(RemoteMessage message, GoRouter router, TemplateRepository catalogRepo) async {
    final route = message.data['route'] as String?;
    if (route == null || route.isEmpty) {
      analyticsService.logEvent('notif_open', {'route_type': 'home'});
      router.go('/home');
      return;
    }

    if (route == '/home') {
      analyticsService.logEvent('notif_open', {'route_type': 'home'});
      router.go('/home');
      return;
    }

    if (route.startsWith('/editor/')) {
      final templateId = route.substring('/editor/'.length);
      final template = await catalogRepo.getById(templateId);
      final templateExists = template != null;
      if (templateExists) {
        analyticsService.logEvent('notif_open', {'route_type': 'editor'});
        router.go(route);
      } else {
        analyticsService.logEvent('notif_open', {'route_type': 'home'});
        router.go('/home');
      }
      return;
    }

    // Ignore any other arbitrary route
    debugPrint('[NotificationService] Ignored invalid route: $route');
  }

  Future<void> _saveStateMachine(SharedPreferences prefs) async {
    await prefs.setString(_prefsKey, jsonEncode(_stateMachine.toMap()));
  }

  Future<bool> requestSystemPermission(SharedPreferences prefs) async {
    analyticsService.logEvent('notif_prompt_yes');

    _stateMachine = _stateMachine.markPromptShown();
    bool isGranted = false;

    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      isGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('[NotificationService] requestPermission error: $e');
    }

    if (isGranted) {
      _stateMachine = _stateMachine.accept();
      await subscribeToDailyTopic();
      analyticsService.logEvent('notif_permission_result', {'status': 'granted'});
    } else {
      _stateMachine = _stateMachine.deny();
      analyticsService.logEvent('notif_permission_result', {'status': 'denied'});
    }

    await _saveStateMachine(prefs);
    return isGranted;
  }

  Future<void> userSnoozed(SharedPreferences prefs) async {
    analyticsService.logEvent('notif_prompt_no');
    _stateMachine = _stateMachine.markPromptShown().snooze(DateTime.now());
    await _saveStateMachine(prefs);
  }

  Future<void> subscribeToDailyTopic() async {
    try {
      await _fcm.subscribeToTopic(_topicDaily);
      debugPrint('[NotificationService] Subscribed to topic: $_topicDaily');
    } catch (e) {
      debugPrint('[NotificationService] Subscribe failed: $e');
    }
  }

  Future<void> unsubscribeFromDailyTopic() async {
    try {
      await _fcm.unsubscribeFromTopic(_topicDaily);
      debugPrint('[NotificationService] Unsubscribed from topic: $_topicDaily');
    } catch (e) {
      debugPrint('[NotificationService] Unsubscribe failed: $e');
    }
  }

  Future<void> toggleReminderSwitch(bool enabled, SharedPreferences prefs) async {
    if (enabled) {
      _stateMachine = _stateMachine.accept();
      await subscribeToDailyTopic();
    } else {
      await unsubscribeFromDailyTopic();
    }
    await _saveStateMachine(prefs);
  }
}

final notificationService = NotificationService.instance;
