import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../data/models/session_entry.dart';
import '../providers/journal_provider.dart';

/// Minimalist summary card shown when the user taps a date on the calendar.
///
/// Displays total focus time and a scrollable list of session notes for [day].
class DaySummaryCard extends ConsumerWidget {
  const DaySummaryCard({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsForDayProvider(day));
    final totalAsync = ref.watch(totalFocusSecondsForDayProvider(day));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: AppColors.accent, size: 16),
              const SizedBox(width: 8),
              Text(
                _formatDate(day),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Total focus time
          totalAsync.when(
            data: (seconds) => Row(
              children: [
                Text(
                  AppStrings.totalFocusTime,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textMuted),
                ),
                const Spacer(),
                Text(
                  TimeFormatter.focusSummary(seconds),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                      ),
                ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),

          const Divider(color: AppColors.surfaceBorder, height: 24),

          // Session list
          sessionsAsync.when(
            data: (sessions) => sessions.isEmpty
                ? Text(
                    AppStrings.noSessionsToday,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                  )
                : Column(
                    children: sessions
                        .map((s) => _SessionRow(session: s))
                        .toList(),
                  ),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / '
      '${d.month.toString().padLeft(2, '0')} / '
      '${d.year}';
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final SessionEntry session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TimeFormatter.focusSummary(session.durationSeconds),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (session.note != null && session.note!.isNotEmpty)
                  Text(
                    session.note!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
