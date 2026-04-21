import 'package:collapsible_side_menu/src/widgets/colored_content.dart';
import 'package:flutter/material.dart';

import '../models/data/side_menu_item_data.dart';
import '../models/styles/base_tile_style.dart';
import '../models/styles/sub_menu_tile_style.dart';
import '../utils/menu_constants.dart';

class SubTileWidget extends StatelessWidget {
  const SubTileWidget({
    super.key,
    required this.subTile,
    this.subStyle,
    required this.style,
    required this.isSelected,
    required this.textColor,
    required this.onTap,
    required this.isCompact,
  });

  final SideMenuSubTileData subTile;
  final SubMenuTileStyle? subStyle;
  final BaseTileStyle style;
  final bool isSelected;
  final Color textColor;
  final VoidCallback onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final Widget? leading = isSelected ? subTile.selectedLeading : subTile.leading;

    return isCompact
        ? const SizedBox.shrink()
        : ListTile(
            leading: leading != null ? ColoredContent(color: textColor, child: leading) : null,
            trailing: subTile.trailing != null ? ColoredContent(color: textColor, child: subTile.trailing!) : null,
            minTileHeight: subStyle?.tileHeight ?? MenuConstants.subTileHeight,
            title: Text(
              subTile.title,
              style: ((isSelected ? subStyle?.titleStyle : style.titleStyle) ?? TextTheme.of(context).labelSmall)?.copyWith(
                color: textColor,
                fontWeight: .w400,
              ),
            ),
            selected: isSelected,
            dense: true,
            // minLeadingWidth: 0,
            horizontalTitleGap: subStyle?.horizontalSpacing ?? style.horizontalSpacing,
            contentPadding: subStyle?.padding ?? const .fromSTEB(10, 0, 10, 0),
            hoverColor: subStyle?.hoverColor ?? style.hoverColor,
            shape: RoundedRectangleBorder(borderRadius: subStyle?.borderRadius ?? style.borderRadius),
            selectedColor: subStyle?.selectedColor ?? style.selectedColor,
            selectedTileColor: subStyle?.selectedBackgroundColor ?? style.selectedBackgroundColor,
            onTap: onTap,
          );
  }
}
