import '../../utils/menu_constants.dart';
import 'base_tile_style.dart';
import 'menu_tile_style.dart';

class SubMenuTileStyle extends BaseTileStyle {
  final SubMenuTileStyle? defaultSubTilesStyle;

  SubMenuTileStyle({
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
    super.padding = .zero,
    super.margin = MenuConstants.tileMargin,
    super.horizontalSpacing = MenuConstants.horizontalSpacing,
    this.defaultSubTilesStyle,
    super.tileHeight = MenuConstants.subTileHeight,
  }) : assert(padding.isNonNegative),
       assert(margin.isNonNegative),
       assert(decoration == null || decoration.debugAssertIsValid()),
       assert(selectedDecoration == null || selectedDecoration.debugAssertIsValid());

  /// Uses values from this style if default are null
  SubMenuTileStyle resolveWith([final SubMenuTileStyle? style]) {
    if (style == null) return this;

    return SubMenuTileStyle(
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
      padding: style.padding,
      margin: style.margin,
      defaultSubTilesStyle: defaultSubTilesStyle ?? style.defaultSubTilesStyle,
      horizontalSpacing: horizontalSpacing,
    );
  }

  SubMenuTileStyle merge([final MenuTileStyle? style]) {
    if (style == null) return this;

    return SubMenuTileStyle(
      titleStyle: titleStyle ?? style.subTileStyle?.titleStyle ?? style.titleStyle,
      selectedTitleStyle: selectedTitleStyle ?? style.subTileStyle?.selectedTitleStyle ?? style.selectedTitleStyle,
      color: color ?? style.subTileStyle?.color ?? style.color,
      selectedColor: selectedColor ?? style.subTileStyle?.selectedColor ?? style.selectedColor,
      hoverColor: hoverColor ?? style.subTileStyle?.hoverColor ?? style.hoverColor,
      backgroundColor: style.subTileStyle?.backgroundColor ?? backgroundColor,
      selectedBackgroundColor: selectedBackgroundColor ?? style.subTileStyle?.selectedBackgroundColor ?? style.selectedBackgroundColor,
      borderRadius: style.subTileStyle?.borderRadius ?? borderRadius,
      tileHeight: style.subTileStyle?.tileHeight ?? tileHeight,
      decoration: decoration ?? style.subTileStyle?.decoration ?? style.decoration,
      selectedDecoration: selectedDecoration ?? style.subTileStyle?.selectedDecoration ?? style.selectedDecoration,
      padding: style.subTileStyle?.padding ?? padding,
      margin: style.subTileStyle?.margin ?? margin,
      defaultSubTilesStyle: defaultSubTilesStyle ?? style.subTileStyle?.defaultSubTilesStyle ?? style.subTileStyle,
      horizontalSpacing: style.subTileStyle?.horizontalSpacing ?? horizontalSpacing,
    );
  }

  @override
  bool operator ==(covariant SubMenuTileStyle other) {
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
        other.decoration == decoration &&
        other.selectedDecoration == selectedDecoration &&
        other.selectedIndicator == selectedIndicator &&
        other.padding == padding &&
        other.margin == margin &&
        other.defaultSubTilesStyle == defaultSubTilesStyle &&
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
        decoration.hashCode ^
        selectedDecoration.hashCode ^
        selectedIndicator.hashCode ^
        padding.hashCode ^
        margin.hashCode ^
        defaultSubTilesStyle.hashCode ^
        horizontalSpacing.hashCode;
  }
}
