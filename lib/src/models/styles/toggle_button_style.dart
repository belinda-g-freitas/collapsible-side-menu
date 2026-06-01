import 'package:flutter/material.dart' show Color, IconData;

class ToggleButtonStyle {
  const ToggleButtonStyle({this.iconColor, this.topPosition = 20, this.opacity = 0.7, this.iconSize = 20, this.icon, this.backgroundColor})
    : assert(topPosition >= 0.0),
      assert(opacity >= 0.0),
      assert(iconSize >= 0.0);

  final Color? iconColor;
  final double topPosition;
  final double opacity;
  final double iconSize;

  /// If you want your button to support RTL, don't forget to add a [IconData] with `matchTextDirection = true`
  ///
  /// Else you'll have to manage icon rotation yourself
  final IconData? icon;
  final Color? backgroundColor;

  ToggleButtonStyle copyWith({Color? iconColor, double? topPosition, double? opacity, double? iconSize, IconData? icon, Color? backgroundColor}) {
    return ToggleButtonStyle(
      iconColor: iconColor ?? this.iconColor,
      topPosition: topPosition ?? this.topPosition,
      opacity: opacity ?? this.opacity,
      iconSize: iconSize ?? this.iconSize,
      icon: icon ?? this.icon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  bool operator ==(covariant ToggleButtonStyle other) {
    if (identical(this, other)) return true;

    return other.iconColor == iconColor &&
        other.topPosition == topPosition &&
        other.opacity == opacity &&
        other.iconSize == iconSize &&
        other.icon == icon &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode {
    return iconColor.hashCode ^ topPosition.hashCode ^ opacity.hashCode ^ iconSize.hashCode ^ icon.hashCode ^ backgroundColor.hashCode;
  }
}
