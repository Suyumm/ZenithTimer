import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../data/models/session_entry.dart';
import '../../../data/repositories/session_repository.dart';

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

/// Which phase the Pomodoro cycle is currently in.
enum SessionType { work, shortBreak, longBreak }

/// Snapshot of the timer's complete runtime state.
class TimerState {
  const TimerState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.isComplete,
    required this.sessionType,
    required this.completedWorkSessions,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;

  /// True when the countdown has hit 00:00 — triggers the morph animation.
  final bool isComplete;

  final SessionType sessionType;

  /// Counter used to determine when to insert a long break.
  final int completedWorkSessions;

  /// Value fed into the Rive state machine: 1.0 → session just started,
  /// 0.0 → session complete.
  double get remainingFraction =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;

  TimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    bool? isComplete,
    SessionType? sessionType,
    int? completedWorkSessions,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isComplete: isComplete ?? this.isComplete,
      sessionType: sessionType ?? this.sessionType,
      completedWorkSessions:
          completedWorkSessions ?? this.completedWorkSessions,
    );
  }
}

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final sessionRepositoryProvider = Provider<SessionRepository>(
  (_) => SessionRepository(),
);

// ---------------------------------------------------------------------------
// Timer provider
// ---------------------------------------------------------------------------

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
  TimerNotifier.new,
);

class TimerNotifier extends Notifier<TimerState> {
  Timer? _ticker;

  @override
  TimerState build() {
    // Cancel any running ticker when the provider is disposed.
    ref.onDispose(() => _ticker?.cancel());

    return _initialState(SessionType.work);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  void start() {
    if (state.isRunning || state.isComplete) return;
    state = state.copyWith(isRunning: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _ticker?.cancel();
    state = _initialState(state.sessionType);
  }

  /// Called when the user taps the "Session Complete" button.
  /// Saves the session to Isar and advances to the next phase.
  ///
  /// Returns the [SessionEntry] that was saved (so the UI can pre-fill
  /// the Post-Session Note modal).
  Future<SessionEntry> confirmSessionComplete({
    required String title,
    String? note,
  }) async {
    _ticker?.cancel();

    final entry = SessionEntry()
      ..title = title
      ..date = DateTime.now()
      ..durationSeconds = state.totalSeconds - state.remainingSeconds
      ..note = note?.isEmpty ?? true ? null : note;

    await ref.read(sessionRepositoryProvider).save(entry);

    // Advance to the next session phase.
    final newCompletedCount = state.sessionType == SessionType.work
        ? state.completedWorkSessions + 1
        : state.completedWorkSessions;

    final nextType = _nextSessionType(
      currentType: state.sessionType,
      completedWorkSessions: newCompletedCount,
    );

    state = _initialState(nextType).copyWith(
      completedWorkSessions: newCompletedCount,
    );

    return entry;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _tick() {
    if (state.remainingSeconds <= 0) {
      _ticker?.cancel();
      state = state.copyWith(isRunning: false, isComplete: true);
      return;
    }
    state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
  }

  static TimerState _initialState(SessionType type) {
    final total = _durationForType(type).inSeconds;
    return TimerState(
      remainingSeconds: total,
      totalSeconds: total,
      isRunning: false,
      isComplete: false,
      sessionType: type,
      completedWorkSessions: 0,
    );
  }

  static Duration _durationForType(SessionType type) => switch (type) {
        SessionType.work => AppDurations.workSession,
        SessionType.shortBreak => AppDurations.shortBreak,
        SessionType.longBreak => AppDurations.longBreak,
      };

  static SessionType _nextSessionType({
    required SessionType currentType,
    required int completedWorkSessions,
  }) {
    if (currentType != SessionType.work) return SessionType.work;
    if (completedWorkSessions % AppDurations.sessionsBeforeLongBreak == 0) {
      return SessionType.longBreak;
    }
    return SessionType.shortBreak;
  }
}
