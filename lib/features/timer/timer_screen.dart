import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/time_formatter.dart';
import '../../core/window/window_mode.dart';
import '../../shared/widgets/glass_card.dart';
import '../journal/widgets/post_session_modal.dart';
import '../journal/widgets/journal_screen.dart';
import 'providers/timer_provider.dart';
import 'providers/window_mode_provider.dart';
import 'widgets/rive_timer_animation.dart';

/// The primary screen of ZenithTimer.
///
/// Layout (top → bottom inside a [GlassCard]):
///   1. **Header row** — app name + window-mode toggle
///   2. **Rive placeholder** — coloured semi-transparent container (swap
///      for `RiveAnimation.asset(...)` when the .riv file is ready)
///   3. **Session type label** — "FOCUS", "SHORT BREAK", "LONG BREAK"
///   4. **MM:SS countdown** — large, prominent number
///   5. **Controls** — Start / Pause / Reset  (hidden when complete)
///   6. **Session Complete button** — appears only when timer hits 00:00
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    ref.read(windowModeProvider.notifier).setMode(WindowMode.dynamicWallpaper);
  }

  @override
  void onWindowRestore() {
    ref.read(windowModeProvider.notifier).setMode(WindowMode.floatingWidget);
  }

  @override
  void onWindowUnmaximize() {
    ref.read(windowModeProvider.notifier).setMode(WindowMode.floatingWidget);
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(windowModeProvider);
    final isWallpaper = mode == WindowMode.dynamicWallpaper;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DragToMoveArea(
          child: Container(
            // Gradient backdrop that shows through the transparent window in floating mode.
            // In wallpaper mode, it's completely transparent so elements float on the desktop.
            decoration: isWallpaper ? null : const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0D1A), // near-black navy
                  Color(0xFF1A0D2E), // deep violet
                  Color(0xFF0D1A2E), // deep blue
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // ── 1. Header ──────────────────────────────────────────────
                    const _HeaderRow(),

                    const SizedBox(height: 24),

                    // ── 2 + 3 + 4. Rive placeholder + labels + countdown ──────
                    Expanded(child: _TimerBody(isWallpaper: isWallpaper)),

                    const SizedBox(height: 20),

                    // ── 5 + 6. Controls / Session Complete ────────────────────
                    const _ControlsArea(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header row
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderRow extends ConsumerWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(windowModeProvider);
    final isWallpaper = mode == WindowMode.dynamicWallpaper;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: 310, // 350 total - 40 horizontal padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZENITH',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ).createShader(const Rect.fromLTWH(0, 0, 80, 20)),
                  ),
                ),
                Text(
                  'TIMER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 6,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            // Window-mode toggle pill & History Button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.history_rounded, size: 20),
                  color: AppColors.textMuted,
                  tooltip: 'Journal History',
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, anim, secondary) => const JournalScreen(),
                        transitionsBuilder: (context, anim, secondary, child) {
                          return FadeTransition(opacity: anim, child: child);
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                _ModeToggle(isWallpaper: isWallpaper),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.textMuted,
                  tooltip: 'Close App',
                  onPressed: () => windowManager.close(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode toggle pill
// ─────────────────────────────────────────────────────────────────────────────

class _ModeToggle extends ConsumerWidget {
  const _ModeToggle({required this.isWallpaper});

  final bool isWallpaper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inner = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isWallpaper ? Icons.wallpaper_rounded : Icons.widgets_outlined,
          size: 14,
          color: isWallpaper ? AppColors.accent : AppColors.primary,
        ),
        const SizedBox(width: 6),
        Text(
          isWallpaper ? 'Wallpaper' : 'Widget',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        // Animated dot indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isWallpaper ? AppColors.accent : AppColors.primary,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () => ref.read(windowModeProvider.notifier).toggle(),
      child: isWallpaper
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: inner,
            )
          : GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: 30,
              blur: 10,
              fillOpacity: 0.12,
              child: inner,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer body (Rive placeholder + session label + countdown)
// ─────────────────────────────────────────────────────────────────────────────

class _TimerBody extends ConsumerWidget {
  const _TimerBody({this.isWallpaper = false});
  
  final bool isWallpaper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(timerProvider.select((s) => s.remainingSeconds));
    final sessionType = ref.watch(timerProvider.select((s) => s.sessionType));
    final isComplete = ref.watch(timerProvider.select((s) => s.isComplete));

    // `fraction` is no longer needed here — RiveTimerDisplay reads
    // timerProvider directly and drives the Rive Level input itself.
    final sessionColor = _colorForSession(sessionType);
    final sessionLabel = _labelForSession(sessionType);

    final innerContent = FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Rive animation ─────────────────────────────────────────────
          // RiveTimerDisplay loads the active animation, drives its "Level" input
          // from timerProvider, and wraps itself in a glassmorphism shell.
          // In wallpaper mode, it takes up much more space to look impressive.
          SizedBox(
            width: isWallpaper ? 380 : 190,
            height: isWallpaper ? 380 : 190,
            child: const RiveTimerDisplay(),
          ),

          const SizedBox(height: 20),
          
          // ── Animation Selector Trigger ─────────────────────────────────
          const AnimationSelectorButton(),

          const SizedBox(height: 20),

          const SizedBox(height: 28),

          // ── Session type label ──────────────────────────────────────────
          AnimatedOpacity(
            opacity: isComplete ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              sessionLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: sessionColor.withValues(alpha: 0.9),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── MM:SS countdown ─────────────────────────────────────────────
          AnimatedOpacity(
            opacity: isComplete ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              TimeFormatter.mmss(remaining),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w200,
                color: AppColors.textPrimary,
                letterSpacing: -2,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );

    if (isWallpaper) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: innerContent,
      );
    }

    return GlassCard(
      borderRadius: 32,
      blur: 20,
      fillOpacity: 0.07,
      padding: const EdgeInsets.all(16),
      child: innerContent,
    );
  }

  Color _colorForSession(SessionType type) => switch (type) {
        SessionType.work => AppColors.workSession,
        SessionType.shortBreak => AppColors.shortBreak,
        SessionType.longBreak => AppColors.longBreak,
      };

  String _labelForSession(SessionType type) => switch (type) {
        SessionType.work => 'FOCUS',
        SessionType.shortBreak => 'SHORT BREAK',
        SessionType.longBreak => 'LONG BREAK',
      };
}

// _RivePlaceholder removed — replaced by RiveTimerDisplay (rive_timer_animation.dart)

// ─────────────────────────────────────────────────────────────────────────────
// Controls area — Start/Pause/Reset OR Session Complete button
// ─────────────────────────────────────────────────────────────────────────────

class _ControlsArea extends ConsumerWidget {
  const _ControlsArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isComplete = ref.watch(timerProvider.select((s) => s.isComplete));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: isComplete
          ? const _SessionCompleteButton(key: ValueKey('complete'))
          : const _TimerControls(key: ValueKey('controls')),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start / Pause / Reset controls
// ─────────────────────────────────────────────────────────────────────────────

class _TimerControls extends ConsumerWidget {
  const _TimerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(timerProvider.select((s) => s.isRunning));
    final notifier = ref.read(timerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Reset
        _IconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Reset',
          size: 44,
          iconSize: 22,
          color: AppColors.textMuted,
          onTap: notifier.reset,
        ),

        const SizedBox(width: 20),

        // Start / Pause — primary
        _PrimaryPlayButton(isRunning: isRunning, onTap: () {
          isRunning ? notifier.pause() : notifier.start();
        }),

        const SizedBox(width: 20),

        // Spacer icon (skip button placeholder — Phase 3)
        _IconButton(
          icon: Icons.skip_next_rounded,
          tooltip: 'Skip session',
          size: 44,
          iconSize: 22,
          color: AppColors.textMuted,
          onTap: notifier.reset, // skip behaves as reset for now
        ),
      ],
    );
  }
}

class _PrimaryPlayButton extends StatelessWidget {
  const _PrimaryPlayButton({
    required this.isRunning,
    required this.onTap,
  });

  final bool isRunning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isRunning
              ? LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.06),
                  ],
                )
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: isRunning
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Icon(
          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 44,
    this.iconSize = 22,
    this.color = Colors.white70,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          child: Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session Complete button (morphs in when timer hits 00:00)
// ─────────────────────────────────────────────────────────────────────────────

class _SessionCompleteButton extends ConsumerStatefulWidget {
  const _SessionCompleteButton({super.key});

  @override
  ConsumerState<_SessionCompleteButton> createState() =>
      _SessionCompleteButtonState();
}

class _SessionCompleteButtonState
    extends ConsumerState<_SessionCompleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _glow;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _glow = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    // 1. Open the Post-Session Note modal
    final result = await showPostSessionModal(context);

    if (!mounted) return;

    // 2. Save to Isar and advance the Pomodoro cycle
    if (result != null) {
      final (title, note) = result;
      await ref.read(timerProvider.notifier).confirmSessionComplete(
            title: title,
            note: note,
          );
    } else {
      // User tapped skip
      await ref.read(timerProvider.notifier).confirmSessionComplete(
            title: 'Untitled Session',
            note: null,
          );
    }

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          return GestureDetector(
            onTap: _onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  colors: [AppColors.completeGradientStart, AppColors.completeGradientEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.3 + 0.3 * _glow.value,
                    ),
                    blurRadius: 20 + 20 * _glow.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Session Complete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Tap to log your session',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
