import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'window_mode.dart'; 

class WindowManagerService {
  WindowManagerService._();
  static final WindowManagerService instance = WindowManagerService._();
  
  WindowMode _currentMode = WindowMode.floatingWidget; 
  WindowMode get currentMode => _currentMode;

  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(350, 500), 
      minimumSize: Size(300, 400),
      center: true,
      backgroundColor: Colors.transparent, 
      skipTaskbar: false, 
      titleBarStyle: TitleBarStyle.hidden, 
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show(); 
      await windowManager.focus(); 
    });
  }

  Future<void> applyMode(WindowMode mode) async {
    _currentMode = mode;
    if (mode == WindowMode.floatingWidget) {
      await _setFloatingWidgetMode();
    } else if (mode == WindowMode.dynamicWallpaper) {
      await _setDynamicWallpaperMode();
    }
  }

  Future<void> _setFloatingWidgetMode() async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setFullScreen(false);
    await windowManager.setResizable(true); // Allow resize briefly to set size
    await windowManager.setSize(const Size(350, 500));
    await windowManager.setResizable(false); // Lock it
    await windowManager.setAlignment(Alignment.center);
  }

  Future<void> _setDynamicWallpaperMode() async {
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setResizable(true);
    await windowManager.setFullScreen(true);
  }
}