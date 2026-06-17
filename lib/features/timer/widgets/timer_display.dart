import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/time_formatter.dart';
import '../providers/timer_provider.dart';

/// Displays the MM:SS countdown and session type label.
///
/// Rebuilds only when [TimerState.remainingSeconds] or
/// [TimerState.sessionType] changes, not on every provider tick.
class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(
      timerProvider.select((s) => s.remainingSeconds),
    );
    final sessionType = ref.watch(
      timerProvider.select((s) => s.sessionType),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _sessionLabel(sessionType),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        Text(
          TimeFormatter.mmss(remaining),
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }

  String _sessionLabel(SessionType type) => switch (type) {
        SessionType.work => 'FOCUS',
        SessionType.shortBreak => 'SHORT BREAK',
        SessionType.longBreak => 'LONG BREAK',
      };
}
