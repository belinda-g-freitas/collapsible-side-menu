import 'package:flutter/material.dart';

class ColoredContent extends StatelessWidget {
  /// Returns `const SizedBox.shrink()` if [child] is null
  const ColoredContent({super.key, required this.color, this.child});

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) return const SizedBox.shrink();

    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: IconTheme.merge(
        data: IconThemeData(color: color),
        child: child!,
      ),
    );
  }
}
