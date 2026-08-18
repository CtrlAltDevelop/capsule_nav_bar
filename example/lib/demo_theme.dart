import 'package:floating_nav_bar/floating_nav_bar.dart';
import 'package:material_ui/material_ui.dart';

/// A theme with [FloatingNavBarTheme] registered, so the demo shows the bar
/// wearing a host's palette rather than the scheme-derived fallback.
ThemeData buildDemoTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: brightness,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [
      FloatingNavBarTheme(
        barColor: scheme.surfaceContainerLow.withValues(alpha: 0.94),
        indicatorColor: scheme.primaryContainer,
        selectedItemColor: scheme.onPrimaryContainer,
        unselectedItemColor: scheme.onSurfaceVariant,
        barShadows: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 1),
            spreadRadius: 2,
          ),
        ],
        scrimColor: scheme.surface,
      ),
    ],
  );
}
