
import 'package:flutter/widgets.dart' show BorderRadius, Color, Decoration, EdgeInsetsGeometry, TextStyle;

abstract class BaseTileStyle {
  /// The height of the tile.
  final double tileHeight;

  /// Text style for the title when the tile is unselected.
  final TextStyle? titleStyle;

  /// Text style for the title when the tile is selected.
  final TextStyle? selectedTitleStyle;

  /// color of tiles when unselected. If set, it applies to default color to widgets like Icon, Text, etc. It can be overridden by setting color in the widget itself.
  final Color? color;

  /// If set, it applies as default color to widgets like Icon, Text, etc. It can be overridden by setting color in the widget itself.
  final Color? selectedColor;

  /// Color of tiles when hovered
  final Color? hoverColor;

  /// Tile background color when unslected. It will be used as background color for the tile if not overridden in [decoration] or [selectedDecoration]
  final Color backgroundColor;

  /// Tile background color when selected. It will be used as background color for the tile if not overridden in [decoration] or [selectedDecoration]
  final Color? selectedBackgroundColor;

  /// Will be used as border radius for tile if not overridden in [decoration] or [selectedIndicator]
  final BorderRadius borderRadius;

  /// The decoration for the tile when unselected.
  final Decoration? decoration;

  /// The decoration for the tile when selected.
  final Decoration? selectedDecoration;

  /// Selected indicator is a line that appears on the side of the selected tile. It can be used to indicate the selected tile in a more visually appealing way.
  final Decoration? selectedIndicator;

  /// The decoration line at the side of the open tile
  ///
  /// Only apply to tiles with sub tiles
  final double selectedIndicatorWidth;

  /// Inner padding
  final EdgeInsetsGeometry padding;

  /// Outer padding
  final EdgeInsetsGeometry margin;

  /// The horizontal spacing betwwen leading, title and trailing widgets.
  ///
  /// It will be used when the menu is open. It will be ignored when the menu is closed.
  final double horizontalSpacing;

  /// The size of the leading icon
  final double? leadingIconSize;

  /// The size of the trailing icon
  final double? trailingIconSize;

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
    this.selectedIndicatorWidth = 0.5,
    this.leadingIconSize,
    this.trailingIconSize,
  });
}
