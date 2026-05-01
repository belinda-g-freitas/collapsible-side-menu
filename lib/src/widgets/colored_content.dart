import 'package:flutter/material.dart';

/// Returns `const SizedBox.shrink()` if [child] is null
class ColoredContent extends StatelessWidget {
  const ColoredContent({super.key, required this.color, this.child});

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) return const SizedBox.shrink();

    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: IconTheme(
        data: IconThemeData(color: color),
        child: child!,
      ),
    );
  }
}
