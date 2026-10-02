enum NotificationPermState {
  neverAsked,
  snoozed,
  accepted,
  denied,
}

class NotificationPermissionStateMachine {
  final NotificationPermState state;
  final DateTime? snoozedAt;
  final int askedCount;

  const NotificationPermissionStateMachine({
    this.state = NotificationPermState.neverAsked,
    this.snoozedAt,
    this.askedCount = 0,
  });

  bool shouldShowPrompt({
    required DateTime now,
    required int totalShares,
  }) {
    switch (state) {
      case NotificationPermState.accepted:
      case NotificationPermState.denied:
        return false;
      case NotificationPermState.neverAsked:
        return totalShares >= 1;
      case NotificationPermState.snoozed:
        if (askedCount >= 2) return false;
        if (snoozedAt == null) return false;
        final daysPassed = now.difference(snoozedAt!).inDays;
        return daysPassed >= 7 && totalShares >= 3;
    }
  }

  NotificationPermissionStateMachine markPromptShown() {
    return NotificationPermissionStateMachine(
      state: state,
      snoozedAt: snoozedAt,
      askedCount: askedCount + 1,
    );
  }

  NotificationPermissionStateMachine snooze(DateTime now) {
    return NotificationPermissionStateMachine(
      state: NotificationPermState.snoozed,
      snoozedAt: now,
      askedCount: askedCount,
    );
  }

  NotificationPermissionStateMachine accept() {
    return NotificationPermissionStateMachine(
      state: NotificationPermState.accepted,
      snoozedAt: null,
      askedCount: askedCount,
    );
  }

  NotificationPermissionStateMachine deny() {
    return NotificationPermissionStateMachine(
      state: NotificationPermState.denied,
      snoozedAt: null,
      askedCount: askedCount,
    );
  }

  factory NotificationPermissionStateMachine.fromMap(Map<String, dynamic> map) {
    final stateStr = map['state'] as String? ?? 'neverAsked';
    final state = NotificationPermState.values.firstWhere(
      (e) => e.name == stateStr,
      orElse: () => NotificationPermState.neverAsked,
    );
    final snoozedMs = map['snoozedAt'] as int?;
    final askedCount = map['askedCount'] as int? ?? 0;

    return NotificationPermissionStateMachine(
      state: state,
      snoozedAt: snoozedMs != null ? DateTime.fromMillisecondsSinceEpoch(snoozedMs) : null,
      askedCount: askedCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state.name,
      'snoozedAt': snoozedAt?.millisecondsSinceEpoch,
      'askedCount': askedCount,
    };
  }
}
