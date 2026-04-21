import 'package:flutter/material.dart';

class ColorSchemePreview extends StatelessWidget {
  const ColorSchemePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = ColorScheme.of(context);
    final colors = <String, Color>{
      'primary': cs.primary,
      'onPrimary': cs.onPrimary,
      'primaryContainer': cs.primaryContainer,
      'onPrimaryContainer': cs.onPrimaryContainer,
      'secondary': cs.secondary,
      'onSecondary': cs.onSecondary,
      'secondaryContainer': cs.secondaryContainer,
      'onSecondaryContainer': cs.onSecondaryContainer,
      'tertiary': cs.tertiary,
      'onTertiary': cs.onTertiary,
      'tertiaryContainer': cs.tertiaryContainer,
      'onTertiaryContainer': cs.onTertiaryContainer,
      'error': cs.error,
      'onError': cs.onError,
      'errorContainer': cs.errorContainer,
      'onErrorContainer': cs.onErrorContainer,
      'surface': cs.surface,
      'onSurface': cs.onSurface,
      'surfaceVariant': cs.surfaceContainerHighest,
      'onSurfaceVariant': cs.onSurfaceVariant,
      'outline': cs.outline,
      'outlineVariant': cs.outlineVariant,
      'inverseSurface': cs.inverseSurface,
      'onInverseSurface': cs.onInverseSurface,
      'inversePrimary': cs.inversePrimary,
      'scrim': cs.scrim,
      'shadow': cs.shadow,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('ColorScheme Preview')),
      body: ListView.builder(
        padding: const .all(16),
        itemCount: colors.entries.length,
        itemBuilder: (_, i) {
          final e = colors.entries.elementAt(i);

          return Container(
            margin: const .only(bottom: 8),
            padding: const .symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: e.value,
              borderRadius: .circular(8),
              border: .all(color: cs.outline.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  e.key,
                  style: TextStyle(color: ThemeData.estimateBrightnessForColor(e.value) == .dark ? Colors.white : Colors.black, fontWeight: .w500),
                ),
                Text(
                  '#${e.value.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    color: ThemeData.estimateBrightnessForColor(e.value) == .dark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
