import 'package:flutter/material.dart' show BorderRadius, Color, Decoration, EdgeInsetsGeometry, TextStyle;

abstract class BaseTileStyle {
  final double tileHeight;
  final TextStyle? titleStyle;
  final TextStyle? selectedTitleStyle;

  /// color of tiles when unselected. If set, it applies to default color to widgets like Icon, Text, etc. It can be overridden by setting color in the widget itself.
  final Color? color;

  /// If set, it applies as default color to widgets like Icon, Text, etc. It can be overridden by setting color in the widget itself.
  final Color? selectedColor;

  final Color? hoverColor;
  final Color backgroundColor;

  final Color? selectedBackgroundColor;

  /// Will be used as border radius for tile if not overridden in [decoration] or [selectedIndicator]
  final BorderRadius borderRadius;
  final Decoration? decoration;
  final Decoration? selectedDecoration;

  /// Selected indicator is a line that appears on the side of the selected tile. It can be used to indicate the selected tile in a more visually appealing way.
  final Decoration? selectedIndicator;

  /// Inner padding
  final EdgeInsetsGeometry padding;

  /// Outer padding
  final EdgeInsetsGeometry margin;
  final double horizontalSpacing;

  /// The decoration line at the side of the open tile
  ///
  /// Only apply to  tiles with sub tiles and when the menu is open
  final double openMenuLineWidth;

  const BaseTileStyle({
    required this.tileHeight,
    this.titleStyle,
    this.selectedTitleStyle,
    this.color,
    this.selectedColor,
    this.hoverColor,
    required this.backgroundColor,
    this.selectedBackgroundColor,
    required this.borderRadius,
    this.decoration,
    this.selectedDecoration,
    this.selectedIndicator,
    required this.padding,
    required this.margin,
    required this.horizontalSpacing,
    this.openMenuLineWidth = 0.5,
  });
}
