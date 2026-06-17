import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../journal/providers/journal_provider.dart';
import '../journal/widgets/day_summary_card.dart';

/// Full-page journal view with [TableCalendar] and [DaySummaryCard].
///
/// Tapping a day updates [selectedDayProvider] and slides in the summary.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(currentMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.journalTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // Calendar
            _ZenithCalendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: (selected, focused) {
                ref.read(selectedDayProvider.notifier).select(selected);
                ref.read(currentMonthProvider.notifier).setMonth(focused);
              },
            ),

            const SizedBox(height: 20),

            // Summary card — slides in when a day is selected
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: DaySummaryCard(
                key: ValueKey(selectedDay),
                day: selectedDay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Styled calendar widget
// ---------------------------------------------------------------------------

class _ZenithCalendar extends StatelessWidget {
  const _ZenithCalendar({
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: onDaySelected,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: 16,
            ),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white70),
        rightChevronIcon:
            const Icon(Icons.chevron_right, color: Colors.white70),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle:
            const TextStyle(color: AppColors.textSecondary),
        weekendTextStyle:
            const TextStyle(color: AppColors.textMuted),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(color: AppColors.primary),
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        weekendStyle: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
        ),
      ),
    );
  }
}
