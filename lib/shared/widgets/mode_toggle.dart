import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/window/window_mode.dart';
import '../../features/timer/providers/window_mode_provider.dart';

/// A pill-shaped toggle that switches the desktop window between
/// [WindowMode.floatingWidget] and [WindowMode.dynamicWallpaper].
class ModeToggle extends ConsumerWidget {
  const ModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(windowModeProvider);
    final isWallpaper = mode == WindowMode.dynamicWallpaper;

    return GestureDetector(
      onTap: () => ref.read(windowModeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 120,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.surface,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Stack(
          children: [
            // Sliding indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment:
                  isWallpaper ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 60,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                ),
              ),
            ),
            // Labels
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Icon(
                      Icons.widgets_outlined,
                      size: 16,
                      color:
                          isWallpaper ? AppColors.textMuted : Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Icon(
                      Icons.wallpaper_rounded,
                      size: 16,
                      color:
                          isWallpaper ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
