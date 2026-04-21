import 'package:flutter/material.dart';

class Utils {
  static bool isRTL(BuildContext context) => Directionality.of(context) == .rtl;

  static Color? getDecorationColor(Decoration? decoration) => switch (decoration) {
    BoxDecoration d => d.color,
    ShapeDecoration d => d.color,
    _ => null,
  };

  static bool pathStartsWith(List<int> full, List<int> path) {
    if (path.length != full.length) return false;
    for (int i = 0; i < path.length; i++) {
      if (path[i] != full[i]) return false;
    }
    return true;
  }
}
