import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/session_entry.dart';

/// Low-level data-access service that manages the single [Isar] instance
/// for the lifetime of the ZenithTimer application.
///
/// ## Lifecycle
/// ```
/// main() {
///   await IsarService.instance.open();   // 1 – before runApp
///   runApp(...);
///
///   // app teardown (optional):
///   await IsarService.instance.close();
/// }
/// ```
///
/// ## Usage in Riverpod providers
/// Higher-level repository classes ([SessionRepository]) depend on this
/// service through its singleton accessor and call the public query/write
/// helpers. Riverpod providers should **not** reference [Isar] directly.
///
/// ## Thread safety
/// [Isar] is thread-safe. All write operations use [Isar.writeTxn] and all
/// reads use synchronous [IsarCollection] query builders (no locking needed).
class IsarService {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  IsarService._();
  static final IsarService _instance = IsarService._();

  /// The global singleton accessor.
  ///
  /// Call [open] before first use. The singleton is initialized lazily so
  /// unit tests can create a separate [IsarService] instance if needed.
  static IsarService get instance => _instance;

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  Isar? _isar;

  /// The open [Isar] database handle.
  ///
  /// Throws a [StateError] if accessed before [open] has completed.
  /// This fail-fast contract makes initialization order mistakes obvious
  /// instead of silently returning null.
  Isar get db {
    final isar = _isar;
    if (isar == null || !isar.isOpen) {
      throw StateError(
        'IsarService.db accessed before open() completed.\n'
        'Ensure `await IsarService.instance.open()` is called in main() '
        'before runApp().',
      );
    }
    return isar;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Opens the Isar database.
  ///
  /// - Idempotent: subsequent calls are no-ops if the database is already open.
  /// - Database file is stored in [getApplicationDocumentsDirectory], which
  ///   resolves to the correct per-user, per-app location on both Windows and
  ///   macOS without requiring extra permissions.
  /// - [inspector] is enabled only in debug builds so the Isar Inspector
  ///   (web-based DevTools) connects automatically during development.
  Future<void> open() async {
    if (_isar != null && _isar!.isOpen) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [SessionEntrySchema],
      directory: dir.path,
      name: 'zenith_core_db',
      // Isar Inspector is available at http://localhost:8080 in debug mode.
      inspector: kDebugMode,
    );

    debugPrint('[IsarService] Database opened at ${dir.path}');
  }

  /// Closes the database connection.
  ///
  /// Call this during app teardown or in integration tests between test cases.
  /// After closing, [open] can be called again safely.
  Future<void> close() async {
    if (_isar == null || !_isar!.isOpen) return;
    await _isar!.close();
    _isar = null;
    debugPrint('[IsarService] Database closed.');
  }

  // ---------------------------------------------------------------------------
  // Write operations
  // ---------------------------------------------------------------------------

  /// Persists [entry] to the database inside a write transaction.
  ///
  /// If [entry.id] is [Isar.autoIncrement] (the default), Isar assigns the
  /// next available integer ID and updates [entry.id] in place.
  ///
  /// Returns the assigned (or existing) [Id].
  ///
  /// Example:
  /// ```dart
  /// final entry = SessionEntry()
  ///   ..date = DateTime.now()
  ///   ..durationSeconds = 1500
  ///   ..note = 'Deep work block — finished the auth module.';
  ///
  /// final id = await IsarService.instance.saveSession(entry);
  /// ```
  Future<Id> saveSession(SessionEntry entry) async {
    assert(entry.durationSeconds >= 0,
        'durationSeconds must be non-negative; got ${entry.durationSeconds}');
    assert(
      entry.note == null || entry.note!.length <= 250,
      'note exceeds 250 characters (${entry.note!.length} chars). '
      'Truncation should happen in the UI before calling saveSession.',
    );

    return db.writeTxn(() => db.sessionEntrys.put(entry));
  }

  /// Deletes the session identified by [id].
  ///
  /// Returns `true` if the record existed and was deleted, `false` if not
  /// found (e.g. already deleted).
  Future<bool> deleteSession(Id id) {
    return db.writeTxn(() => db.sessionEntrys.delete(id));
  }

  // ---------------------------------------------------------------------------
  // Read operations
  // ---------------------------------------------------------------------------

  /// Returns all [SessionEntry] records whose [SessionEntry.date] falls within
  /// the calendar day represented by [day] (midnight-to-midnight, UTC).
  ///
  /// Uses the `@Index()` on [SessionEntry.date] for an O(log n) range scan
  /// instead of a full-collection scan.
  ///
  /// This is the primary query used by [TableCalendar] tap callbacks.
  ///
  /// Example:
  /// ```dart
  /// final sessions = await IsarService.instance.getSessionsForDay(
  ///   DateTime(2025, 6, 15),
  /// );
  /// ```
  Future<List<SessionEntry>> getSessionsForDay(DateTime day) {
    // Normalise to midnight UTC so the index scan is consistent regardless of
    // the local timezone offset the caller used to construct [day].
    final start = DateTime.utc(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return db.sessionEntrys
        .where()
        .dateBetween(start, end)
        .sortByDate()
        .findAll();
  }

  /// Returns all sessions in the given calendar [month].
  ///
  /// Used to build the calendar heat-map: months with sessions show markers.
  Future<List<SessionEntry>> getSessionsForMonth(
    int year,
    int month,
  ) {
    final start = DateTime.utc(year, month);
    final end = DateTime.utc(year, month + 1);

    return db.sessionEntrys
        .where()
        .dateBetween(start, end)
        .sortByDate()
        .findAll();
  }

  /// Returns the sum of [SessionEntry.durationSeconds] for all sessions on
  /// [day]. Returns `0` if no sessions exist for that day.
  Future<int> getTotalFocusSecondsForDay(DateTime day) async {
    final sessions = await getSessionsForDay(day);
    return sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Returns all sessions ordered by [SessionEntry.date] descending
  /// (newest first). Used by a hypothetical "all sessions" list view.
  Future<List<SessionEntry>> getAllSessions() {
    return db.sessionEntrys.where().sortByDateDesc().findAll();
  }

  /// Returns a lazy stream that emits a void event every time *any*
  /// [SessionEntry] is added, updated, or deleted.
  ///
  /// Consumers (e.g. the calendar provider) can listen to this stream and
  /// call [getSessionsForDay] / [getSessionsForMonth] to refresh their data
  /// without polling.
  ///
  /// ```dart
  /// IsarService.instance.watchSessions().listen((_) {
  ///   // refresh calendar markers
  /// });
  /// ```
  Stream<void> watchSessions() => db.sessionEntrys.watchLazy();
}
