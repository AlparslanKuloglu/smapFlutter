import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:smap/core/services/device_preferences.dart';

/// The four kinds of notification "Bildirimler" lets the student switch (pano
/// 9.6 kare 1 "Kategoriler"), in the order of the board.
enum NotificationCategory {
  /// "Deneme sonucun hazır": when the analysis of a read exam is done.
  examReady('examReady'),

  /// "Koçun deneme ya da ödev atadı": spec §6.3 #35 keeps the category
  /// although a coach cannot assign in v1.
  coachAssigned('coachAssigned'),

  /// "Görüşme planlandı": when the coach plans a meeting.
  meetingPlanned('meetingPlanned'),

  /// "Çalışma hatırlatıcısı": at the hour of a study slot of the program.
  studyReminder('studyReminder');

  const NotificationCategory(this.key);

  /// The name the choice is stored under.
  final String key;
}

/// Which end of the quiet hours a time picker edits (pano 9.6 kare 3).
enum QuietBound { start, end }

/// The notification choices of the device (pano 9.6; D-24, 8.5).
///
/// Defaults: every category on; quiet hours on, 22:00 to 08:00. Times are
/// minutes after midnight. Immutable, with value equality, so a selector
/// rebuilds only when something the screen shows changed.
@immutable
class NotificationPreferences {
  const NotificationPreferences({
    this.enabledCategories = _allCategories,
    this.quietEnabled = true,
    this.quietStart = defaultQuietStart,
    this.quietEnd = defaultQuietEnd,
  });

  static const Set<NotificationCategory> _allCategories = {
    NotificationCategory.examReady,
    NotificationCategory.coachAssigned,
    NotificationCategory.meetingPlanned,
    NotificationCategory.studyReminder,
  };

  /// 22:00 (D-24).
  static const int defaultQuietStart = 22 * 60;

  /// 08:00 (D-24).
  static const int defaultQuietEnd = 8 * 60;

  /// The categories that are switched on.
  final Set<NotificationCategory> enabledCategories;

  /// "Sessiz saatler" is on.
  final bool quietEnabled;

  /// Start of the quiet hours, minutes after midnight.
  final int quietStart;

  /// End of the quiet hours, minutes after midnight.
  final int quietEnd;

  bool isOn(NotificationCategory category) =>
      enabledCategories.contains(category);

  /// The quiet time at [bound].
  int quietAt(QuietBound bound) =>
      bound == QuietBound.start ? quietStart : quietEnd;

  NotificationPreferences withCategory(
    NotificationCategory category, {
    required bool on,
  }) {
    final next = {...enabledCategories};
    on ? next.add(category) : next.remove(category);
    return copyWith(enabledCategories: next);
  }

  NotificationPreferences withQuietAt(QuietBound bound, int minutes) =>
      bound == QuietBound.start
      ? copyWith(quietStart: minutes)
      : copyWith(quietEnd: minutes);

  NotificationPreferences copyWith({
    Set<NotificationCategory>? enabledCategories,
    bool? quietEnabled,
    int? quietStart,
    int? quietEnd,
  }) => NotificationPreferences(
    enabledCategories: enabledCategories ?? this.enabledCategories,
    quietEnabled: quietEnabled ?? this.quietEnabled,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
  );

  /// The stored form.
  Map<String, Object> toJson() => {
    'categories': {
      for (final category in NotificationCategory.values)
        category.key: isOn(category),
    },
    'quiet': {'enabled': quietEnabled, 'start': quietStart, 'end': quietEnd},
  };

  /// Reads the stored form. Anything missing or odd keeps its default, so an
  /// older or damaged value never breaks the screen.
  factory NotificationPreferences.fromJson(Object? json) {
    if (json is! Map) return const NotificationPreferences();
    final categories = json['categories'];
    final quiet = json['quiet'];
    final enabled = <NotificationCategory>{};
    for (final category in NotificationCategory.values) {
      final stored = categories is Map ? categories[category.key] : null;
      if (stored is bool ? stored : true) enabled.add(category);
    }
    int minutes(Object? value, int fallback) =>
        value is int && value >= 0 && value < _minutesPerDay ? value : fallback;
    final quietMap = quiet is Map ? quiet : const <Object?, Object?>{};
    return NotificationPreferences(
      enabledCategories: enabled,
      quietEnabled: quietMap['enabled'] is bool
          ? quietMap['enabled'] as bool
          : true,
      quietStart: minutes(quietMap['start'], defaultQuietStart),
      quietEnd: minutes(quietMap['end'], defaultQuietEnd),
    );
  }

  static const int _minutesPerDay = 24 * 60;

  @override
  bool operator ==(Object other) =>
      other is NotificationPreferences &&
      setEquals(other.enabledCategories, enabledCategories) &&
      other.quietEnabled == quietEnabled &&
      other.quietStart == quietStart &&
      other.quietEnd == quietEnd;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(enabledCategories),
    quietEnabled,
    quietStart,
    quietEnd,
  );
}

/// Keeps [NotificationPreferences] on the device until the backend has a
/// preferences endpoint (spec 8.4; `FeatureFlags.notificationsEnabled`).
class NotificationPreferencesStore {
  const NotificationPreferencesStore(this._preferences);

  final DevicePreferences _preferences;

  /// The saved choices; the defaults when nothing (or nothing readable) is
  /// saved.
  NotificationPreferences load() {
    final raw = _preferences.getString(
      DevicePreferences.notificationPreferencesKey,
    );
    if (raw == null) return const NotificationPreferences();
    try {
      return NotificationPreferences.fromJson(jsonDecode(raw));
    } on FormatException {
      return const NotificationPreferences();
    }
  }

  /// Saves [value]; never throws (`DevicePreferences` keeps failures to
  /// itself).
  Future<void> save(NotificationPreferences value) => _preferences.setString(
    DevicePreferences.notificationPreferencesKey,
    jsonEncode(value.toJson()),
  );
}
