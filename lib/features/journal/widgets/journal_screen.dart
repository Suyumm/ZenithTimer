import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/window/window_mode.dart';
import '../../../data/models/session_entry.dart';
import '../../timer/providers/timer_provider.dart';
import '../../timer/providers/window_mode_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import 'post_session_modal.dart';

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime newDate) => state = newDate;
}

final _dbWatcherProvider = StreamProvider<void>((ref) {
  final repo = ref.read(sessionRepositoryProvider);
  return repo.watchAllSessions();
});

final sessionsProvider = NotifierProvider<SessionsNotifier, AsyncValue<List<SessionEntry>>>(SessionsNotifier.new);

class SessionsNotifier extends Notifier<AsyncValue<List<SessionEntry>>> {
  @override
  AsyncValue<List<SessionEntry>> build() {
    final date = ref.watch(selectedDateProvider);
    
    // We fetch asynchronously
    Future(() async {
      final repo = ref.read(sessionRepositoryProvider);
      final data = await repo.getSessionsForDay(date);
      state = AsyncValue.data(data);
    });

    return const AsyncValue.loading();
  }

  void deleteSession(int id) {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.where((s) => s.id != id).toList());
    }
    ref.read(sessionRepositoryProvider).delete(id);
  }

  void editSession(SessionEntry session) {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.map((s) => s.id == session.id ? session : s).toList());
    }
    ref.read(sessionRepositoryProvider).save(session);
  }
}

// -----------------------------------------------------------------------------
// Screen
// -----------------------------------------------------------------------------

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDateProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final mode = ref.watch(windowModeProvider);
    final isWallpaper = mode == WindowMode.dynamicWallpaper;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF1A0D2E),
              Color(0xFF0D1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedScale(
              scale: isWallpaper ? 1.6 : 1.0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: SizedBox(
                width: 350,
                height: 550,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'Back to Timer',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'JOURNAL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                ).createShader(const Rect.fromLTWH(0, 0, 80, 20)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Calendar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassCard(
                        borderRadius: 20,
                        blur: 15,
                        fillOpacity: 0.05,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          rowHeight: 38,
                          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                          onDaySelected: (newSelectedDay, newFocusedDay) {
                            ref.read(selectedDateProvider.notifier).updateDate(newSelectedDay);
                            setState(() => _focusedDay = newFocusedDay);
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            headerPadding: const EdgeInsets.symmetric(vertical: 4),
                            titleTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 22),
                            rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 22),
                            leftChevronPadding: EdgeInsets.zero,
                            rightChevronPadding: EdgeInsets.zero,
                            leftChevronMargin: EdgeInsets.zero,
                            rightChevronMargin: EdgeInsets.zero,
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                            weekendStyle: const TextStyle(color: AppColors.accent, fontSize: 11),
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
                            weekendTextStyle: const TextStyle(color: AppColors.accent, fontSize: 12),
                            outsideTextStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                            cellMargin: const EdgeInsets.all(4),
                            todayDecoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    
                    // Date Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('MMMM d, yyyy').format(selectedDay),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),

                    // Sessions List
                    Expanded(
                      child: sessionsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        error: (err, stack) => Center(
                          child: Text('Error loading sessions', style: TextStyle(color: Colors.red[300])),
                        ),
                        data: (sessions) {
                          if (sessions.isEmpty) {
                            return Center(
                              child: Text(
                                'No sessions recorded on this day.',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 4),
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              final session = sessions[index];
                              final durationMins = (session.durationSeconds / 60).round();
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GlassCard(
                                  borderRadius: 14,
                                  blur: 10,
                                  fillOpacity: 0.08,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              session.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                                            ),
                                            child: Text(
                                              '$durationMins min',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              popupMenuTheme: PopupMenuThemeData(
                                                color: const Color(0xFF1A1A2E),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            ),
                                            child: PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert_rounded, color: Colors.white70, size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onSelected: (value) async {
                                                if (value == 'edit') {
                                                  final result = await showPostSessionModal(
                                                    context,
                                                    initialTitle: session.title,
                                                    initialNote: session.note,
                                                  );
                                                  if (result != null) {
                                                    session.title = result.$1;
                                                    session.note = result.$2;
                                                    ref.read(sessionsProvider.notifier).editSession(session);
                                                  }
                                                } else if (value == 'delete') {
                                                  ref.read(sessionsProvider.notifier).deleteSession(session.id);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Text('Edit', style: TextStyle(color: Colors.white)),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (session.note != null && session.note!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          session.note!,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                            height: 1.3,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
