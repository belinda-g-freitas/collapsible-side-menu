import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/data/side_menu_item.dart';
import '../models/styles/base_tile_style.dart';
import '../models/styles/sub_menu_tile_style.dart';
import '../utils/menu_constants.dart';
import '../utils/types.dart';
import 'colored_content.dart';

class SubTileWidget extends StatelessWidget {
  const SubTileWidget({
    super.key,
    required this.subTile,
    this.subStyle,
    required this.style,
    required this.isSelected,
    required this.textColor,
    required this.onTap,
  });

  final SubTileData subTile;
  final SubMenuTileStyle? subStyle;
  final BaseTileStyle style;
  final bool isSelected;
  final Color textColor;
  final VoidCallback onTap;

  Widget? _leading() {
    final Widget? leading = (isSelected ? subTile.selectedLeading : null) ?? subTile.leading;
    final double? iconSize = subStyle?.leadingIconSize ?? style.leadingIconSize;

    return leading != null
        ? Flexible(
            child: IconTheme.merge(
              data: IconThemeData(size: iconSize),
              child: leading,
            ),
          )
        : null;
  }

  Widget? _trailing() {
    final double? iconSize = subStyle?.trailingIconSize ?? style.trailingIconSize;

    return subTile.trailing != null
        ? Expanded(
            child: IconTheme.merge(
              data: IconThemeData(size: iconSize),
              child: subTile.trailing!,
            ),
          )
        : null;
  }

  TextStyle? _textStyle(BuildContext context) {
    return ((isSelected
                ? (subStyle?.defaultSubTilesStyle?.selectedTitleStyle ?? subStyle?.selectedTitleStyle)
                : (subStyle?.defaultSubTilesStyle?.titleStyle ?? subStyle?.titleStyle)) ??
            TextTheme.of(context).bodySmall)
        ?.copyWith(fontWeight: .w400, color: textColor);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = subStyle?.borderRadius ?? MenuConstants.borderRadius;

    return Material(
      color: MenuConstants.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        hoverColor: subStyle?.hoverColor ?? style.hoverColor,
        child: Container(
          height: subStyle?.tileHeight ?? MenuConstants.subTileHeight,
          padding: subStyle?.padding ?? const .fromSTEB(10, 0, 10, 0),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: isSelected ? (subStyle?.selectedBackgroundColor ?? style.selectedBackgroundColor) : null,
          ),
          child: ColoredContent(
            color: textColor,
            child: Row(
              spacing: subStyle?.horizontalSpacing ?? MenuConstants.horizontalSpacing,
              children: [
                ?_leading(),
                Expanded(flex: 5, child: Text(subTile.title, style: _textStyle(context))),
                ?_trailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // coverage:ignore-start
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // tile identity
    properties.add(StringProperty('title', subTile.title));
    // state
    properties.add(FlagProperty('isSelected', value: isSelected, ifTrue: 'selected'));
    properties.add(ColorProperty('textColor', textColor));
    // style resolution
    properties.add(FlagProperty('hasSubStyle', value: subStyle != null, ifTrue: 'custom subStyle'));
    properties.add(
      DiagnosticsProperty<BorderRadius?>(
        'resolvedBorderRadius',
        subStyle?.borderRadius ?? MenuConstants.borderRadius,
        defaultValue: null,
      ),
    );
    properties.add(DoubleProperty('resolvedTileHeight', subStyle?.tileHeight ?? MenuConstants.subTileHeight));
    // optional features
    properties.add(FlagProperty('hasLeading', value: subTile.leading != null, ifTrue: 'has leading'));
    properties.add(FlagProperty('hasSelectedLeading', value: subTile.selectedLeading != null, ifTrue: 'has selectedLeading'));
    properties.add(FlagProperty('hasTrailing', value: subTile.trailing != null, ifTrue: 'has trailing'));
  }

  // coverage:ignore-end
}
