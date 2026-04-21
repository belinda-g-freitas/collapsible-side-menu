import 'package:flutter/material.dart' show BorderRadius, Color, Decoration, EdgeInsetsGeometry, TextStyle;

import '../../utils/menu_constants.dart';
import 'base_tile_style.dart';
import 'sub_menu_tile_style.dart';

class MenuTileStyle extends BaseTileStyle {
  final double subTileHeight;
  final SubMenuTileStyle? subTileStyle;

  MenuTileStyle({
    super.titleStyle,
    super.selectedTitleStyle,
    super.color,
    super.selectedColor,
    super.hoverColor,
    super.backgroundColor = MenuConstants.transparent,
    super.selectedBackgroundColor,
    super.borderRadius = MenuConstants.borderRadius,
    super.decoration,
    super.selectedDecoration,
    super.selectedIndicator,
    super.padding = .zero,
    super.margin = MenuConstants.tileMargin,
    this.subTileStyle,
    super.tileHeight = MenuConstants.tileHeight,
    this.subTileHeight = MenuConstants.subTileHeight,
    super.horizontalSpacing = 3,
  }) : assert(padding.isNonNegative),
       assert(margin.isNonNegative),
       assert(decoration == null || decoration.debugAssertIsValid()),
       assert(selectedDecoration == null || selectedDecoration.debugAssertIsValid()),
       assert(selectedIndicator == null || selectedIndicator.debugAssertIsValid());

  /// Uses values from this style if default are null
  MenuTileStyle resolveWith(final MenuTileStyle? style) {
    if (style == null) return this;

    return MenuTileStyle(
      titleStyle: titleStyle ?? style.titleStyle,
      selectedTitleStyle: selectedTitleStyle ?? style.selectedTitleStyle,
      color: color ?? style.color,
      selectedColor: selectedColor ?? style.selectedColor,
      hoverColor: hoverColor ?? style.hoverColor,
      backgroundColor: style.backgroundColor,
      selectedBackgroundColor: selectedBackgroundColor ?? style.selectedBackgroundColor,
      borderRadius: style.borderRadius,
      decoration: decoration ?? style.decoration,
      selectedDecoration: selectedDecoration ?? style.selectedDecoration,
      selectedIndicator: selectedIndicator ?? style.selectedIndicator,
      padding: style.padding,
      margin: style.margin,
      subTileStyle: subTileStyle ?? style.subTileStyle,
      horizontalSpacing: horizontalSpacing,
    );
  }

  MenuTileStyle copyWith({
    TextStyle? titleStyle,
    TextStyle? selectedTitleStyle,
    Color? color,
    Color? selectedColor,
    Color? hoverColor,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    BorderRadius? borderRadius,
    double? tileHeight,
    double? subTileHeight,
    Decoration? decoration,
    Decoration? selectedDecoration,
    Decoration? selectedIndicator,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    SubMenuTileStyle? subTileStyle,
    double? horizontalSpacing,
  }) {
    return MenuTileStyle(
      titleStyle: titleStyle ?? this.titleStyle,
      selectedTitleStyle: selectedTitleStyle ?? this.selectedTitleStyle,
      color: color ?? this.color,
      selectedColor: selectedColor ?? this.selectedColor,
      hoverColor: hoverColor ?? this.hoverColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedBackgroundColor: selectedBackgroundColor ?? this.selectedBackgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      tileHeight: tileHeight ?? this.tileHeight,
      subTileHeight: subTileHeight ?? this.subTileHeight,
      decoration: decoration ?? this.decoration,
      selectedDecoration: selectedDecoration ?? this.selectedDecoration,
      selectedIndicator: selectedIndicator ?? this.selectedIndicator,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      subTileStyle: subTileStyle ?? this.subTileStyle,
      horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
    );
  }

  @override
  String toString() {
    return 'MenuTileStyle(titleStyle: $titleStyle, selectedTitleStyle: $selectedTitleStyle, color: $color, selectedColor: $selectedColor, hoverColor: $hoverColor, backgroundColor: $backgroundColor, selectedBackgroundColor: $selectedBackgroundColor, borderRadius: $borderRadius, tileHeight: $tileHeight, subTileHeight: $subTileHeight, decoration: $decoration, selectedDecoration: $selectedDecoration, selectedIndicator: $selectedIndicator, padding: $padding, margin: $margin, subTileStyle: $subTileStyle, horizontalSpacing: $horizontalSpacing)';
  }

  @override
  bool operator ==(covariant MenuTileStyle other) {
    if (identical(this, other)) return true;

    return other.titleStyle == titleStyle &&
        other.selectedTitleStyle == selectedTitleStyle &&
        other.color == color &&
        other.selectedColor == selectedColor &&
        other.hoverColor == hoverColor &&
        other.backgroundColor == backgroundColor &&
        other.selectedBackgroundColor == selectedBackgroundColor &&
        other.borderRadius == borderRadius &&
        other.tileHeight == tileHeight &&
        other.subTileHeight == subTileHeight &&
        other.decoration == decoration &&
        other.selectedDecoration == selectedDecoration &&
        other.selectedIndicator == selectedIndicator &&
        other.padding == padding &&
        other.margin == margin &&
        other.subTileStyle == subTileStyle &&
        other.horizontalSpacing == horizontalSpacing;
  }

  @override
  int get hashCode {
    return titleStyle.hashCode ^
        selectedTitleStyle.hashCode ^
        color.hashCode ^
        selectedColor.hashCode ^
        hoverColor.hashCode ^
        backgroundColor.hashCode ^
        selectedBackgroundColor.hashCode ^
        borderRadius.hashCode ^
        tileHeight.hashCode ^
        subTileHeight.hashCode ^
        decoration.hashCode ^
        selectedDecoration.hashCode ^
        selectedIndicator.hashCode ^
        padding.hashCode ^
        margin.hashCode ^
        subTileStyle.hashCode ^
        horizontalSpacing.hashCode;
  }
}
