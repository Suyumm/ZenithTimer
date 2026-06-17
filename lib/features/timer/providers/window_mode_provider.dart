import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/window/window_mode.dart';
import '../../../core/window/window_manager_service.dart';

/// Riverpod provider that tracks the active [WindowMode] and synchronises
/// every state change directly to [WindowManagerService.instance.applyMode].
///
/// **Single responsibility**: this notifier owns both the state *and* the
/// side-effect — no need for a `ref.listen` in `app.dart`.
///
/// Usage:
/// ```dart
/// // Read current mode
/// final mode = ref.watch(windowModeProvider);
///
/// // Toggle from a button
/// ref.read(windowModeProvider.notifier).toggle();
///
/// // Set explicitly
/// ref.read(windowModeProvider.notifier).setMode(WindowMode.dynamicWallpaper);
/// ```
final windowModeProvider =
    NotifierProvider<WindowModeNotifier, WindowMode>(WindowModeNotifier.new);

class WindowModeNotifier extends Notifier<WindowMode> {
  @override
  WindowMode build() {
    // Seed from the service so Riverpod state always matches the real
    // window state set during WindowManagerService.initialize().
    return WindowManagerService.instance.currentMode;
  }

  /// Switches to [mode] and applies it to the native window immediately.
  ///
  /// The call to [WindowManagerService.applyMode] is fire-and-forget
  /// (unawaited) because Riverpod notifier methods are synchronous.
  /// Window geometry changes happen asynchronously on the platform thread
  /// and do not need to block UI updates.
  void setMode(WindowMode mode) {
    if (state == mode) return;
    state = mode;
    WindowManagerService.instance.applyMode(mode);
  }

  /// Toggles between [WindowMode.floatingWidget] and
  /// [WindowMode.dynamicWallpaper].
  void toggle() {
    setMode(
      state == WindowMode.floatingWidget
          ? WindowMode.dynamicWallpaper
          : WindowMode.floatingWidget,
    );
  }
}
