import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../settings/providers/settings_provider.dart';

/// Stub settings screen — controls for work/break durations and alarm.
/// Full implementation in Phase 3.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.settingsTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _DurationTile(
              label: AppStrings.workDuration,
              duration: settings.workDuration,
              onChanged: ref.read(settingsProvider.notifier).setWorkDuration,
            ),
            _DurationTile(
              label: AppStrings.shortBreakDuration,
              duration: settings.shortBreakDuration,
              onChanged:
                  ref.read(settingsProvider.notifier).setShortBreakDuration,
            ),
            _DurationTile(
              label: AppStrings.longBreakDuration,
              duration: settings.longBreakDuration,
              onChanged:
                  ref.read(settingsProvider.notifier).setLongBreakDuration,
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  const _DurationTile({
    required this.label,
    required this.duration,
    required this.onChanged,
  });

  final String label;
  final Duration duration;
  final void Function(Duration) onChanged;

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes;
    return ListTile(
      title: Text(label,
          style: const TextStyle(color: AppColors.textSecondary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: AppColors.textMuted),
            onPressed: minutes > 1
                ? () => onChanged(Duration(minutes: minutes - 1))
                : null,
          ),
          Text('${minutes}m',
              style: const TextStyle(color: AppColors.textPrimary)),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textMuted),
            onPressed: minutes < 120
                ? () => onChanged(Duration(minutes: minutes + 1))
                : null,
          ),
        ],
      ),
    );
  }
}
