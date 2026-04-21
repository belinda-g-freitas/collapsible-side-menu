import 'package:flutter/material.dart';

import '../../utils/menu_constants.dart';
import 'menu_tile_style.dart';

class SideMenuStyle {
  /// If null, it will be set to `ColorScheme.of(context).primary`
  final Color? backgroundColor;
  final BoxShadow? boxShadow;

  /// If null, it will be set to default from `Directionality.of(context)`
  final TextDirection? textDirection;

  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final MenuTileStyle? defaultTileStyle;

  SideMenuStyle({
    this.backgroundColor,
    this.boxShadow,
    this.textDirection,
    this.borderRadius = MenuConstants.borderRadius,
    this.padding = MenuConstants.menuInnerPadding,
    this.margin = MenuConstants.outerPadding,
    this.defaultTileStyle,
  }) : assert(padding.isNonNegative),
       assert(margin.isNonNegative);

  @override
  String toString() {
    return 'SideMenuStyle(backgroundColor: $backgroundColor, boxShadow: $boxShadow, textDirection: $textDirection, borderRadius: $borderRadius, padding: $padding, margin: $margin, defaultTileStyle: $defaultTileStyle)';
  }
}
