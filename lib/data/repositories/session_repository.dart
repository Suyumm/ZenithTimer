import 'package:isar/isar.dart';

import '../models/session_entry.dart';
import '../services/isar_service.dart';

/// Repository that abstracts all [SessionEntry] CRUD operations over Isar.
///
/// Consumers (Riverpod providers) depend on this class — never on [Isar]
/// directly — keeping the data layer swappable and unit-testable.
class SessionRepository {
  SessionRepository({IsarService? isarService})
      : _service = isarService ?? IsarService.instance;

  final IsarService _service;

  Isar get _db => _service.db;

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Persists a new [SessionEntry] and returns its assigned [Id].
  Future<Id> save(SessionEntry entry) async {
    return _db.writeTxn(() => _db.sessionEntrys.put(entry));
  }

  /// Deletes the session with the given [id]. Returns true if deleted.
  Future<bool> delete(Id id) async {
    return _db.writeTxn(() => _db.sessionEntrys.delete(id));
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns all sessions sorted by date descending (newest first).
  Future<List<SessionEntry>> getAllSessions() {
    return _db.sessionEntrys
        .where()
        .sortByDateDesc()
        .findAll();
  }

  /// Returns all sessions whose [SessionEntry.date] falls within [day]
  /// (midnight-to-midnight, local time).
  Future<List<SessionEntry>> getSessionsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _db.sessionEntrys
        .where()
        .dateBetween(start, end)
        .findAll();
  }

  /// Returns the sum of [SessionEntry.durationSeconds] for all sessions on
  /// [day]. Returns 0 if no sessions exist for that day.
  Future<int> getTotalFocusSecondsForDay(DateTime day) async {
    final sessions = await getSessionsForDay(day);
    return sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Returns all sessions for a given month (used to populate the calendar).
  Future<List<SessionEntry>> getSessionsForMonth(
    int year,
    int month,
  ) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);

    return _db.sessionEntrys
        .where()
        .dateBetween(start, end)
        .findAll();
  }

  /// Watches all session changes as a stream — useful for real-time calendar
  /// updates without manual refresh calls.
  Stream<void> watchAllSessions() {
    return _db.sessionEntrys.watchLazy();
  }
}
