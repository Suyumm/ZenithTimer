import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/window/window_manager_service.dart';
import 'data/services/isar_service.dart';

/// Entry point for ZenithTimer desktop application.
///
/// Initialization order:
///   1. [WidgetsFlutterBinding.ensureInitialized] — required before any
///      plugin or async platform call.
///   2. [WindowManagerService.initialize] — configures the native window to
///      its default state (Mode B – floating widget) before the first frame
///      is rendered, preventing any flash of incorrect window geometry.
///   3. [IsarService.open] — opens the local database before the first
///      widget that might read sessions is built.
///   4. [runApp] wrapped in [ProviderScope] — starts the Riverpod graph and
///      renders the Flutter widget tree.
Future<void> main() async {
  // Step 1: binding
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: native window setup (must happen before runApp)
  await WindowManagerService.instance.initialize();

  // Step 3: open Isar database
  await IsarService.instance.open();

  // Step 4: run app
  runApp(
    const ProviderScope(
      child: ZenithApp(),
    ),
  );
}
