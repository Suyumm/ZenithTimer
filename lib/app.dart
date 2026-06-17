import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/timer/timer_screen.dart';

/// Root application widget, wrapped by [ProviderScope] in [main].
///
/// Window-mode changes are now handled directly inside [WindowModeNotifier]
/// (see `window_mode_provider.dart`) — no ref.listen needed here.
class ZenithApp extends StatelessWidget {
  const ZenithApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenithTimer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Inter',
      ),
      home: const TimerScreen(),
    );
  }
}
