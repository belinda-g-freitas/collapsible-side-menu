import 'package:flutter/material.dart';

class ColoredContent extends StatelessWidget {
  const ColoredContent({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: IconTheme(
        data: IconThemeData(color: color),
        child: child,
      ),
    );
  }
}
