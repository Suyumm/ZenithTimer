import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_strings.dart';
import '../../journal/widgets/post_session_modal.dart';
import '../providers/timer_provider.dart';

/// Animated button that morphs into view when [TimerState.isComplete] is true.
///
/// Tapping it:
///   1. Opens the [PostSessionModal] to capture a journal note.
///   2. Calls [TimerNotifier.confirmSessionComplete] which saves to Isar.
///   3. Advances the timer to the next Pomodoro phase.
class SessionCompleteButton extends ConsumerStatefulWidget {
  const SessionCompleteButton({super.key});

  @override
  ConsumerState<SessionCompleteButton> createState() =>
      _SessionCompleteButtonState();
}

class _SessionCompleteButtonState
    extends ConsumerState<SessionCompleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.sessionCompleteMorph,
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    // Trigger the entrance animation immediately.
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    // Show the Post-Session Note modal and wait for the user's note.
    final note = await showPostSessionModal(context);

    if (!mounted) return;

    // Save to Isar and advance the Pomodoro cycle.
    await ref.read(timerProvider.notifier).confirmSessionComplete(note: note);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: _onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: const LinearGradient(
                colors: [
                  AppColors.completeGradientStart,
                  AppColors.completeGradientEnd,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  AppStrings.sessionComplete,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.tapToLog,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
