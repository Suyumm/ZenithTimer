import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/session_entry.dart';
import '../../timer/providers/timer_provider.dart';

// ---------------------------------------------------------------------------
// Selected day (drives calendar → summary card)
// ---------------------------------------------------------------------------

final selectedDayProvider =
    NotifierProvider<SelectedDayNotifier, DateTime>(SelectedDayNotifier.new);

class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime day) => state = day;
}

// ---------------------------------------------------------------------------
// Focused month (drives calendar header navigation)
// ---------------------------------------------------------------------------

final currentMonthProvider =
    NotifierProvider<CurrentMonthNotifier, DateTime>(CurrentMonthNotifier.new);

class CurrentMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setMonth(DateTime month) => state = month;
}

// ---------------------------------------------------------------------------
// Sessions for a specific day
// ---------------------------------------------------------------------------

final sessionsForDayProvider =
    FutureProvider.family<List<SessionEntry>, DateTime>((ref, day) async {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessionsForDay(day);
});

final totalFocusSecondsForDayProvider =
    FutureProvider.family<int, DateTime>((ref, day) async {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getTotalFocusSecondsForDay(day);
});

// ---------------------------------------------------------------------------
// Sessions for the current month (calendar heat-map data)
// ---------------------------------------------------------------------------

final sessionsForMonthProvider =
    FutureProvider.family<List<SessionEntry>, ({int year, int month})>(
        (ref, args) async {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessionsForMonth(args.year, args.month);
});
