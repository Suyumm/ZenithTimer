/// Default durations for the Pomodoro technique and UI animations.
///
/// The [SettingsProvider] exposes user-overridable versions of the Pomodoro
/// constants; these values serve as the factory defaults.
abstract final class AppDurations {
  // ---------------------------------------------------------------------------
  // Pomodoro defaults (user-configurable via settings)
  // ---------------------------------------------------------------------------

  /// Standard focus / work session length.
  static const Duration workSession = Duration(seconds: 5);

  /// Short break between work sessions.
  static const Duration shortBreak = Duration(seconds: 3);

  /// Long break after every [sessionsBeforeLongBreak] work sessions.
  static const Duration longBreak = Duration(seconds: 5);

  /// Number of consecutive work sessions before a long break is triggered.
  static const int sessionsBeforeLongBreak = 4;

  // ---------------------------------------------------------------------------
  // UI / Animation timings
  // ---------------------------------------------------------------------------

  /// Duration for the timer → "Session Complete" button morph animation.
  static const Duration sessionCompleteMorph = Duration(milliseconds: 600);

  /// Mode-switch window transition (A ↔ B).
  static const Duration windowModeTransition = Duration(milliseconds: 350);

  /// Fade in/out for modal overlays.
  static const Duration modalFade = Duration(milliseconds: 250);

  /// Micro-animation for button press feedback.
  static const Duration buttonPress = Duration(milliseconds: 120);

  /// Calendar day summary card slide-in.
  static const Duration calendarCardSlide = Duration(milliseconds: 300);
}
