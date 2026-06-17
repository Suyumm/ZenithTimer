// Import only `ImageFilter` from dart:ui to avoid the PaintingStyle type
// conflict that arises when rive_native also exports its own PaintingStyle.
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Use an `as rive` prefix so every Rive type is unambiguous.
import 'package:rive/rive.dart' as rive;

import '../../../core/constants/app_colors.dart';
import '../providers/timer_provider.dart';

// =============================================================================
// Providers
// =============================================================================

/// Manages the currently active Rive Animation Config.
class SelectedAnimationNotifier extends Notifier<AnimationConfig> {
  @override
  AnimationConfig build() => availableAnimations.first;

  void setAnimation(AnimationConfig config) {
    state = config;
  }
}

final selectedAnimationProvider =
    NotifierProvider<SelectedAnimationNotifier, AnimationConfig>(
        SelectedAnimationNotifier.new);

// =============================================================================
// Animation Selector Data & Trigger Button
// =============================================================================

class AnimationConfig {
  final String title;
  final String assetPath;
  final IconData icon;
  final String stateMachineName;
  final String inputName;
  final bool invertValue;

  const AnimationConfig({
    required this.title,
    required this.assetPath,
    required this.icon,
    required this.stateMachineName,
    required this.inputName,
    this.invertValue = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimationConfig &&
          runtimeType == other.runtimeType &&
          assetPath == other.assetPath;

  @override
  int get hashCode => assetPath.hashCode;
}

// -----------------------------------------------------------------------------
// HOW TO FIND RIVE CONFIGURATION:
// 1. Open your .riv file in the Rive Editor (or the web viewer).
// 2. Look at the left panel for "State Machines". Write that exact name into `stateMachineName` (e.g. "State Machine 1").
// 3. Select the State Machine, look at the "Inputs" panel (Numbers/Booleans/Triggers). Write the exact name of the Number input into `inputName`.
// 4. Case sensitivity matters! "level" is not the same as "Level".
// -----------------------------------------------------------------------------
const List<AnimationConfig> availableAnimations = [
  AnimationConfig(
    title: 'Octopus',
    assetPath: 'assets/rive/waterbar.riv',
    icon: Icons.water_drop_rounded,
    stateMachineName: 'State Machine', // Known from logs
    inputName: 'Level',                // Capital L
    invertValue: true,                // False = Drains from 100 to 0
  ),
  AnimationConfig(
    title: 'Life Tree',
    assetPath: 'assets/rive/tree.riv',
    icon: Icons.park_rounded,
    stateMachineName: 'State Machine 1', // TODO: Verify in Rive Editor
    inputName: 'input',                  // TODO: Verify in Rive Editor
    invertValue: true,                   // True = Grows from 0 to 100
  ),
  AnimationConfig(
    title: 'Love',
    assetPath: 'assets/rive/energybar.riv',
    icon: Icons.battery_charging_full_rounded,
    stateMachineName: 'State Machine ', // Has a trailing space!
    inputName: 'Energy',
    invertValue: false,
  ),
  AnimationConfig(
    title: 'Ice Cream',
    assetPath: 'assets/rive/loader.riv',
    icon: Icons.loop_rounded,
    stateMachineName: 'State Machine 1', // TODO: Verify in Rive Editor
    inputName: 'percentage',             // TODO: Verify in Rive Editor
    invertValue: true,
  ),
  AnimationConfig(
    title: 'Candy',
    assetPath: 'assets/rive/purpleloader.riv',
    icon: Icons.change_circle_rounded,
    stateMachineName: 'State Machine 1', // TODO: Verify in Rive Editor
    inputName: 'Percentage',             // TODO: Verify in Rive Editor
    invertValue: true,
  ),
  AnimationConfig(
    title: 'Powerade',
    assetPath: 'assets/rive/blend.riv',
    icon: Icons.blender_rounded,
    stateMachineName: 'State Machine 1',
    inputName: 'numValue', // Found via debug logs
    invertValue: true,
  ),
  AnimationConfig(
    title: 'Clean Car',
    assetPath: 'assets/rive/cleancar.riv',
    icon: Icons.directions_car_rounded,
    stateMachineName: 'State Machine 1', // TODO: Verify in Rive Editor
    inputName: 'Control',                // TODO: Verify in Rive Editor
    invertValue: true,
  ),
  AnimationConfig(
    title: 'Ratatouille',
    assetPath: 'assets/rive/grater.riv',
    icon: Icons.kitchen_rounded,
    stateMachineName: 'State Machine 1', // TODO: Verify in Rive Editor
    inputName: 'Loader',                 // TODO: Verify in Rive Editor
    invertValue: true,
  ),
  AnimationConfig(
    title: 'Hope Tree',
    assetPath: 'assets/rive/treee.riv',
    icon: Icons.park_rounded,
    stateMachineName: 'State Machine 1', // TODO: Verify in Rive Editor
    inputName: 'Tree grow',              // TODO: Verify in Rive Editor
    invertValue: true,
  ),
];

/// A sleek Glassmorphism button that opens the animation selection dialog.
class AnimationSelectorButton extends ConsumerWidget {
  const AnimationSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.4),
          builder: (context) => const _AnimationSelectionDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D1A).withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 24,
          color: AppColors.accent.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

// =============================================================================
// Animation Selection Dialog
// =============================================================================

class _AnimationSelectionDialog extends ConsumerWidget {
  const _AnimationSelectionDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAnimation = ref.watch(selectedAnimationProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1A).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              const BoxShadow(
                color: Color(0x4DC084FC),
                blurRadius: 64,
                spreadRadius: -20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Animation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: availableAnimations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final option = availableAnimations[index];
                    final isSelected = currentAnimation == option;

                    return _AnimationOptionTile(
                      option: option,
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(selectedAnimationProvider.notifier)
                            .setAnimation(option);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimationOptionTile extends StatelessWidget {
  const _AnimationOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AnimationConfig option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 20,
              color: isSelected
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.title,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// RiveTimerDisplay
// =============================================================================

/// Loads the active Rive animation and drives its `Level` input from
/// [timerProvider], wrapped in a fully responsive Glassmorphism container.
class RiveTimerDisplay extends ConsumerStatefulWidget {
  const RiveTimerDisplay({super.key}); // Removed fixed size property to make it responsive

  @override
  ConsumerState<RiveTimerDisplay> createState() => _RiveTimerDisplayState();
}

class _RiveTimerDisplayState extends ConsumerState<RiveTimerDisplay>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Rive constants
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Rive objects
  // ---------------------------------------------------------------------------

  rive.RiveWidgetController? _controller;

  // ignore: deprecated_member_use
  rive.NumberInput? _levelInput;

  bool _loading = true;
  String? _error;
  late AnimationConfig _currentConfig;

  late final Ticker _ticker;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _currentConfig = ref.read(selectedAnimationProvider);
    _ticker = createTicker((_) {
      if (_controller != null) {
        _controller!.scheduleRepaint();
      }
    });
    _ticker.start();
    _loadRiveFile(_currentConfig);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // File loading
  // ---------------------------------------------------------------------------

  Future<void> _loadRiveFile(AnimationConfig config) async {
    try {
      final file = await rive.File.asset(
        config.assetPath,
        riveFactory: rive.Factory.flutter,
      );

      if (!mounted) {
        file?.dispose();
        return;
      }

      if (file == null) {
        setState(() {
          _error = 'Failed to decode ${config.assetPath}';
          _loading = false;
        });
        return;
      }

      rive.RiveWidgetController? controller;
      // ignore: deprecated_member_use
      rive.NumberInput? levelInput;

      // Try to load the exact state machine from the config
      try {
        final tempController = rive.RiveWidgetController(
          file,
          stateMachineSelector: rive.StateMachineNamed(config.stateMachineName),
        );
        
        // ignore: deprecated_member_use
        final tempInput = tempController.stateMachine.number(config.inputName);
        if (tempInput != null) {
          controller = tempController;
          levelInput = tempInput;
          debugPrint('[RiveTimerDisplay] Loaded state machine: "${config.stateMachineName}" with input "${config.inputName}"');
        } else {
          // If the specific input isn't found, we can still show the animation ambiently
          controller = tempController;
          debugPrint('[RiveTimerDisplay] ⚠️ Input "${config.inputName}" not found in state machine "${config.stateMachineName}". Playing ambiently.');
        }
      } catch (_) {
        // Fallback to auto-select if the state machine doesn't exist at all
        debugPrint('[RiveTimerDisplay] Falling back to default Rive controller (auto-select)');
        try {
          controller = rive.RiveWidgetController(file);
        } catch (_) {}
      }

      if (controller != null) {
        debugPrint('\n================ RIVE DEBUG INFO ================');
        try {
          final sm = controller.stateMachine;
          debugPrint('Active State Machine: "${sm.name}"');
          debugPrint('Available Inputs:');
          for (final input in sm.inputs) {
            debugPrint(' - Name: "${input.name}", Type: ${input.runtimeType}');
          }
        } catch (e) {
          debugPrint('Could not read state machine inputs: $e');
        }
        debugPrint('=================================================\n');
      }

      setState(() {
        _controller = controller;
        _levelInput = levelInput;
        _loading = false;
        _error = null;
      });

      // Sync immediately so the fill level is correct before the timer starts.
      _syncLevel(ref.read(timerProvider).remainingFraction);
    } catch (e, stack) {
      debugPrint('[RiveTimerDisplay] ❌ Error: $e\n$stack');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Level sync helper
  // ---------------------------------------------------------------------------

  void _syncLevel(double fraction) {
    if (_levelInput == null) return;
    
    // Convert 0.0-1.0 fraction to 0-100 percentage
    double percentage = fraction.clamp(0.0, 1.0) * 100.0;
    
    // Invert if required by the config (e.g. Tree grows as timer drains)
    if (_currentConfig.invertValue) {
      percentage = 100.0 - percentage;
    }
    
    _levelInput!.value = percentage;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Listen for animation config changes from the provider
    ref.listen<AnimationConfig>(selectedAnimationProvider, (previous, next) {
      if (previous != next && next != _currentConfig) {
        setState(() {
          _loading = true;
          _error = null;
          _currentConfig = next;
        });
        _controller?.dispose();
        _controller = null;
        _levelInput = null;
        _loadRiveFile(next);
      }
    });

    final targetFraction = ref.watch(
      timerProvider.select((s) => s.remainingFraction),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fallback for unbounded constraints (e.g. if placed directly in a ScrollView)
        if (constraints.maxWidth.isInfinite || constraints.maxHeight.isInfinite) {
          return SizedBox(
            width: 300,
            height: 300,
            child: _GlassmorphismContainer(
              child: _buildContent(targetFraction),
            ),
          );
        }

        // Dynamically scale up/down gracefully using 85% of available parent constraints
        return Center(
          child: FractionallySizedBox(
            widthFactor: 0.85,
            heightFactor: 0.85,
            child: _GlassmorphismContainer(
              child: _buildContent(targetFraction),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(double targetFraction) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null || _controller == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.accent.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Animation\nunavailable',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetFraction),
      duration: const Duration(seconds: 1),
      curve: Curves.linear,
      builder: (context, animatedFraction, child) {
        _syncLevel(animatedFraction);
        // Ticker now handles repaint
        return child!;
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: rive.RiveWidget(
          controller: _controller!,
          fit: rive.Fit.contain,
        ),
      ),
    );
  }
}

// =============================================================================
// _GlassmorphismContainer
// =============================================================================

class _GlassmorphismContainer extends StatelessWidget {
  const _GlassmorphismContainer({required this.child});

  final Widget child;

  static const double _radius      = 32.0;
  static const double _blur        = 28.0;
  static const double _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    // Fully responsive: expands to fill the constraints given by LayoutBuilder
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4DC084FC), 
                blurRadius: 52,
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Color(0x2634D399), 
                blurRadius: 36,
                spreadRadius: -10,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0xAA000000), 
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
              child: Container(
                color: const Color(0xBB080812),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: child,
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(_radius),
                            gradient: const RadialGradient(
                              center: Alignment.center,
                              radius: 0.85,
                              colors: [
                                Colors.transparent,
                                Color(0xA6000010), 
                              ],
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      // Highlights the top 22% dynamically based on the parent's actual height
                      height: constraints.maxHeight * 0.22,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(_radius),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _GradientBorderPainter(
                            borderRadius: _radius,
                            borderWidth: _borderWidth,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,    
                                AppColors.accent,     
                                Color(0x00FFFFFF),    
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// _GradientBorderPainter
// =============================================================================

class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.borderWidth,
  });

  final Gradient gradient;
  final double borderRadius;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect  = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final shader = gradient.createShader(rect);

    final glowPaint = Paint()
      ..shader      = shader
      ..strokeWidth = borderWidth * 5
      ..style       = PaintingStyle.stroke
      ..isAntiAlias = true
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(rrect, glowPaint);

    final crispPaint = Paint()
      ..shader      = shader
      ..strokeWidth = borderWidth
      ..style       = PaintingStyle.stroke
      ..isAntiAlias = true;
    canvas.drawRRect(rrect, crispPaint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.gradient     != gradient     ||
      old.borderRadius != borderRadius ||
      old.borderWidth  != borderWidth;
}
