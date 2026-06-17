import 'package:isar/isar.dart';

// This directive tells the Dart build system to look for a generated file.
// Run: dart run build_runner build --delete-conflicting-outputs
// to produce session_entry.g.dart from this schema definition.
part 'session_entry.g.dart';

/// Isar database collection representing one completed Pomodoro session.
///
/// Schema:
/// | Field           | Type      | Constraints                       |
/// |-----------------|-----------|-----------------------------------|
/// | id              | Id        | auto-increment, primary key        |
/// | date            | DateTime  | indexed for calendar queries       |
/// | durationSeconds | int       | actual elapsed time in seconds     |
/// | note            | String?   | optional journal entry, max 250 ch |
///
/// Example usage:
/// ```dart
/// final entry = SessionEntry()
///   ..date = DateTime.now()
///   ..durationSeconds = 1500
///   ..note = 'Great focus session!';
/// await isar.writeTxn(() => isar.sessionEntrys.put(entry));
/// ```
@Collection()
class SessionEntry {
  /// Isar auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// The calendar date on which this session occurred.
  ///
  /// Stored as UTC; the UI layer is responsible for local-time conversion
  /// before display. Indexed so calendar queries (date range scans) are O(log n).
  @Index()
  late DateTime date;

  /// Actual focus time recorded for this session, in seconds.
  ///
  /// This may differ from the configured Pomodoro duration if the user
  /// stopped the timer early.
  late int durationSeconds;

  /// Session title, usually something brief like "UI Overhaul" or "Study Math".
  late String title;

  /// Optional free-form note captured in the Post-Session modal.
  ///
  /// The UI enforces a 250-character limit via [MaxLengthEnforcement.enforced].
  /// There is no Isar-level string-length annotation in Isar 3.x — validation
  /// lives in the widget layer only.
  String? note;
}
