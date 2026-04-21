import 'package:flutter/material.dart' show Color, IconData;

class ToggleButtonStyle {
  const ToggleButtonStyle({this.iconColor, this.topPosition = 20, this.opacity = 0.7, this.iconSize = 20, this.icon})
    : assert(topPosition >= 0.0),
      assert(opacity >= 0.0),
      assert(iconSize >= 0.0);

  final Color? iconColor;
  final double topPosition;
  final double opacity;
  final double iconSize;
  final IconData? icon;

  ToggleButtonStyle copyWith({Color? iconColor, double? topPosition, double? opacity, double? iconSize, IconData? icon}) {
    return ToggleButtonStyle(
      iconColor: iconColor ?? this.iconColor,
      topPosition: topPosition ?? this.topPosition,
      opacity: opacity ?? this.opacity,
      iconSize: iconSize ?? this.iconSize,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'ToggleButtonStyle(iconColor: $iconColor, topPosition: $topPosition, opacity: $opacity, iconSize: $iconSize, icon: $icon)';
  }
}
