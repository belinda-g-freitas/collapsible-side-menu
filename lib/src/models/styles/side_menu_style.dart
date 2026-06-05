import 'package:flutter/material.dart';

import '../../utils/menu_constants.dart';
import 'menu_tile_style.dart';

class SideMenuStyle {
  /// If null, it will be set to `ColorScheme.of(context).primary`
  final Color? backgroundColor;

  /// Will be used as the color of the overlay when the menu is collapsed and the user taps on it to expand it.
  ///
  /// If null, [backgroundColor] will be used
  final Color? collapsedOverlayColor;

  /// Shadow under the whole menu
  final BoxShadow? boxShadow;

  /// If null, it will be set to default from `Directionality.of(context)`
  final TextDirection? textDirection;

  /// Menu's border radius
  final BorderRadiusGeometry borderRadius;

  /// Menu's inner padding
  final EdgeInsetsGeometry padding;

  /// Menu's outer padding
  final EdgeInsetsGeometry margin;

  /// The default style for the menu tiles. It will be used for all tiles that don't have a style set.
  final MenuTileStyle? defaultTileStyle;

  SideMenuStyle({
    this.backgroundColor,
    this.collapsedOverlayColor,
    this.boxShadow,
    this.textDirection,
    this.borderRadius = MenuConstants.borderRadius,
    this.padding = MenuConstants.menuInnerPadding,
    this.margin = MenuConstants.menuOuterPadding,
    this.defaultTileStyle,
  }) : assert(padding.isNonNegative),
       assert(margin.isNonNegative);
}
