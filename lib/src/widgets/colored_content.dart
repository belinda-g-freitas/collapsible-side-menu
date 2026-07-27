import 'package:flutter/material.dart';

import '../utils/menu_constants.dart';

class ColoredContent extends StatelessWidget {
  /// Returns `MenuConstants.emptyWidget` if [child] is null
  const ColoredContent({super.key, required this.color, this.child});

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) return MenuConstants.emptyWidget;

    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: IconTheme.merge(
        data: IconThemeData(color: color),
        child: child!,
        // ListTileTheme.merge(textColor: color, iconColor: color, child: child!),
      ),
    );
  }
}
