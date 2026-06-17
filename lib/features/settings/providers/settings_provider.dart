import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';

/// User-configurable settings for ZenithTimer.
class SettingsState {
  const SettingsState({
    this.workDuration = AppDurations.workSession,
    this.shortBreakDuration = AppDurations.shortBreak,
    this.longBreakDuration = AppDurations.longBreak,
    this.sessionsBeforeLongBreak = AppDurations.sessionsBeforeLongBreak,
    this.alarmEnabled = true,
  });

  final Duration workDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
  final int sessionsBeforeLongBreak;
  final bool alarmEnabled;

  SettingsState copyWith({
    Duration? workDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
    int? sessionsBeforeLongBreak,
    bool? alarmEnabled,
  }) {
    return SettingsState(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
    );
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  // TODO: Persist settings using shared_preferences in Phase 3.

  void setWorkDuration(Duration d) =>
      state = state.copyWith(workDuration: d);

  void setShortBreakDuration(Duration d) =>
      state = state.copyWith(shortBreakDuration: d);

  void setLongBreakDuration(Duration d) =>
      state = state.copyWith(longBreakDuration: d);

  void setSessionsBeforeLongBreak(int n) =>
      state = state.copyWith(sessionsBeforeLongBreak: n);

  void toggleAlarm() =>
      state = state.copyWith(alarmEnabled: !state.alarmEnabled);
}
