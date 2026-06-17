/// Utility functions for formatting timer-related durations and timestamps.
abstract final class TimeFormatter {
  /// Formats [seconds] as a MM:SS string (e.g. `25:00`, `04:37`).
  static String mmss(int seconds) {
    assert(seconds >= 0, 'seconds must be non-negative');
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Returns a human-readable focus-time summary (e.g. "1h 23m", "45m").
  static String focusSummary(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  /// Returns a progress fraction in [0.0, 1.0] representing how much of
  /// [totalSeconds] has elapsed ([elapsedSeconds]).
  static double progress({
    required int elapsedSeconds,
    required int totalSeconds,
  }) {
    if (totalSeconds <= 0) return 0.0;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// Returns the remaining fraction in [0.0, 1.0] — the inverse of
  /// [progress]. This is what drives the Rive state machine input
  /// (0.0 = session just started, 1.0 = session complete).
  static double remainingFraction({
    required int remainingSeconds,
    required int totalSeconds,
  }) {
    if (totalSeconds <= 0) return 1.0;
    return (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }
}
