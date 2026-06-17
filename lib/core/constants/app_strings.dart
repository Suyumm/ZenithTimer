/// All user-visible string literals for ZenithTimer.
///
/// Centralising strings here prepares the codebase for future i18n (e.g.
/// via the `intl` package) without requiring changes across the widget tree.
abstract final class AppStrings {
  // App
  static const String appName = 'ZenithTimer';

  // Timer
  static const String startSession = 'Start';
  static const String pauseSession = 'Pause';
  static const String resumeSession = 'Resume';
  static const String resetSession = 'Reset';
  static const String sessionComplete = 'Session Complete';
  static const String tapToLog = 'Tap to log your session';

  // Session types
  static const String workSession = 'Focus';
  static const String shortBreak = 'Short Break';
  static const String longBreak = 'Long Break';

  // Post-session modal
  static const String addNote = 'How was your session?';
  static const String notePlaceholder = 'Jot down your thoughts… (max 250 chars)';
  static const String saveSession = 'Save Session';
  static const String skipNote = 'Skip';

  // Calendar / Journal
  static const String journalTitle = 'Focus Journal';
  static const String totalFocusTime = 'Total focus time';
  static const String noSessionsToday = 'No sessions recorded for this day.';
  static const String sessions = 'sessions';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String workDuration = 'Work Duration';
  static const String shortBreakDuration = 'Short Break';
  static const String longBreakDuration = 'Long Break';
  static const String windowMode = 'Window Mode';
  static const String dynamicWallpaper = 'Dynamic Wallpaper';
  static const String floatingWidget = 'Floating Widget';

  // Errors
  static const String errorSavingSession = 'Failed to save session. Please try again.';
}
