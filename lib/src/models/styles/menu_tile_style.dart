import 'package:flutter/widgets.dart' show EdgeInsetsGeometry, Size;

import '../../utils/menu_constants.dart';
import 'base_tile_style.dart';
import 'sub_menu_tile_style.dart';

class MenuTileStyle extends BaseTileStyle {
  final double subTileHeight;
  final Size selectedIndicatorSize;
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
    this.selectedIndicatorSize = MenuConstants.selectedIndicatorSize,
    super.selectedBorderWidth,
    super.padding = EdgeInsetsGeometry.zero,
    super.margin = MenuConstants.tileMargin,
    this.subTileStyle,
    super.tileHeight = MenuConstants.tileHeight,
    this.subTileHeight = MenuConstants.subTileHeight,
    super.horizontalSpacing = MenuConstants.horizontalSpacing,
    super.leadingIconSize,
    super.trailingIconSize,
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
      tileHeight: tileHeight,
      subTileHeight: subTileHeight,
      leadingIconSize: leadingIconSize ?? style.leadingIconSize,
      trailingIconSize: trailingIconSize ?? style.trailingIconSize,
      selectedBorderWidth: selectedBorderWidth,
      selectedIndicatorSize: selectedIndicatorSize,
    );
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
        other.horizontalSpacing == horizontalSpacing &&
        other.leadingIconSize == leadingIconSize &&
        other.trailingIconSize == trailingIconSize &&
        other.selectedBorderWidth == selectedBorderWidth &&
        other.selectedIndicatorSize == selectedIndicatorSize;
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
        horizontalSpacing.hashCode ^
        leadingIconSize.hashCode ^
        trailingIconSize.hashCode ^
        selectedBorderWidth.hashCode ^
        selectedIndicatorSize.hashCode;
  }
}
