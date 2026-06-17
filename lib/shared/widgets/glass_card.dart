import 'dart:ui';

import 'package:flutter/material.dart';

/// A reusable glassmorphism container.
///
/// Achieved with three layers stacked inside a [ClipRRect]:
/// 1. [BackdropFilter] — Gaussian blur applied to whatever is painted behind
///    the card (works in both window modes since the scaffold is transparent).
/// 2. A semi-transparent white fill that gives the "frosted glass" tint.
/// 3. A subtle 1-dp border at reduced opacity to define the card edges.
///
/// ## Parameters
/// | Parameter    | Default | Description                                    |
/// |--------------|---------|------------------------------------------------|
/// | blur         | 18      | BackdropFilter sigma — higher = more blurred   |
/// | fillOpacity  | 0.10    | White fill alpha — lower = more transparent    |
/// | borderRadius | 24      | Corner radius in dp                            |
/// | padding      | 20 all  | Inner padding                                  |
///
/// ## Usage
/// ```dart
/// GlassCard(
///   child: Text('ZenithTimer'),
/// )
///
/// // Custom transparency for overlays:
/// GlassCard(
///   blur: 30,
///   fillOpacity: 0.06,
///   borderRadius: 16,
///   child: TimerDisplay(),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24.0,
    this.blur = 18.0,
    this.fillOpacity = 0.10,
    this.borderOpacity = 0.25,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  /// Gaussian blur sigma applied to content behind the card.
  final double blur;

  /// Opacity of the white fill layer (0.0 = fully transparent, 1.0 = opaque).
  final double fillOpacity;

  /// Opacity of the 1-dp border.
  final double borderOpacity;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            // Frosted glass tint
            color: Colors.white.withValues(alpha: fillOpacity),
            // Hairline border
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
