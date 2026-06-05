import 'package:flutter/material.dart' show Color, IconData;

import '../../utils/menu_constants.dart';

class ToggleButtonStyle {
  const ToggleButtonStyle({
    this.iconColor,
    this.topPosition = 20,
    this.opacity = 0.7,
    this.iconSize = 20,
    this.openedIcon = MenuConstants.toggleButtonIcon,
    this.backgroundColor,
  }) : assert(topPosition >= 0.0),
       assert(opacity >= 0.0),
       assert(iconSize >= 0.0);

  final Color? iconColor;
  final double topPosition;
  final double opacity;
  final double iconSize;

  /// Icon to be shown when the menu is open. It will rotate depending on menu state,
  /// so if you want to use a custom icon, make sure it looks good in both states (open and closed).
  ///
  /// If you want your button to support RTL, don't forget to add a [IconData] with `matchTextDirection` set to true,
  /// else you'll have to manage icon rotation yourself
  final IconData openedIcon;
  final Color? backgroundColor;

  ToggleButtonStyle copyWith({
    Color? iconColor,
    double? topPosition,
    double? opacity,
    double? iconSize,
    IconData? openedIcon,
    Color? backgroundColor,
  }) {
    return ToggleButtonStyle(
      iconColor: iconColor ?? this.iconColor,
      topPosition: topPosition ?? this.topPosition,
      opacity: opacity ?? this.opacity,
      iconSize: iconSize ?? this.iconSize,
      openedIcon: openedIcon ?? this.openedIcon,
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
        other.openedIcon == openedIcon &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode {
    return iconColor.hashCode ^
        topPosition.hashCode ^
        opacity.hashCode ^
        iconSize.hashCode ^
        openedIcon.hashCode ^
        backgroundColor.hashCode;
  }
}
