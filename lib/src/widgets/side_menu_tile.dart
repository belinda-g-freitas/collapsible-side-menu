import 'package:flutter/material.dart';

import '../models/data/side_menu_item_data.dart';
import '../models/styles/menu_tile_style.dart';
import '../models/styles/sub_menu_tile_style.dart';
import '../utils/utils.dart';
import 'colored_content.dart';
import 'side_menu_sub_tile.dart';
import 'sub_tile_widget.dart';

class SideMenuTile extends StatefulWidget {
  const SideMenuTile({
    super.key,
    required this.tile,
    required this.isSelected,
    required this.isMenuOpen,
    required this.minWidth,
    required this.sideMenuBackgroundColor,
    required this.selectedPath,
    required this.basePath,
    required this.onSelectPath,
    required this.onToggle,
    required this.openNodes,
  });

  final SideMenuTileData tile;
  final bool isSelected;
  final bool isMenuOpen;
  final double minWidth;
  final Color sideMenuBackgroundColor;
  final List<int> selectedPath;
  final List<int> basePath;
  final void Function(List<int> path) onSelectPath;
  final void Function(List<int> path) onToggle;
  final Set<String> openNodes;

  @override
  State<SideMenuTile> createState() => _SideMenuTileState();
}

class _SideMenuTileState extends State<SideMenuTile> {
  late MenuTileStyle style;
  late Color _anchorForegroundColor;
  static const double _anchorHorizPadding = 10;

  bool _isSelectedPath(List<int> path) => Utils.pathStartsWith(widget.selectedPath, path);

  bool get _isSubTileSelected => widget.openNodes.contains(widget.basePath.join('-'));

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final menuTheme = MenuTheme.of(context);
    style = widget.tile.style!;
    _anchorForegroundColor = style.color ?? style.titleStyle?.color ?? colorScheme.onPrimary;
    final bool isRTL = Utils.isRTL(context);
    final Widget view = _createView();
    final Widget viewWithTooltip = Tooltip(
      message: widget.tile.title,
      enableTapToDismiss: false,
      textStyle: TextStyle(color: colorScheme.onSurface, fontWeight: .w400),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(233),
        borderRadius: style.borderRadius,
        border: .all(color: colorScheme.onSurface, width: .3),
      ),
      positionDelegate: (position) {
        return Offset(position.target.dx + widget.minWidth / 2, position.target.dy - position.tooltipSize.height / 2);
      },
      constraints: BoxConstraints(minHeight: style.tileHeight / 1.5),
      child: view,
    );
    final Widget singleTile = Container(
      height: style.tileHeight,
      padding: style.padding,
      decoration:
          (widget.isSelected ? style.selectedDecoration : style.decoration) ??
          ShapeDecoration(
            shape: RoundedRectangleBorder(borderRadius: style.borderRadius),
            color: widget.isSelected ? style.selectedBackgroundColor ?? colorScheme.secondaryContainer : style.backgroundColor,
          ),
      child: widget.isMenuOpen
          ? view
          : widget.tile.subTiles.isEmpty
          ? viewWithTooltip
          : MenuTheme(
              data: MenuThemeData(
                style: menuTheme.style?.copyWith(
                  alignment: .topEnd,
                  elevation: .all(3),
                  side: .all(BorderSide(color: _anchorForegroundColor, width: .7)),
                  backgroundColor: .all(widget.sideMenuBackgroundColor),
                  padding: .all(const .symmetric(horizontal: _anchorHorizPadding, vertical: 7)),
                ),
                submenuIcon: .all(Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _anchorForegroundColor)),
              ),
              child: MenuAnchor(
                clipBehavior: .antiAlias,
                menuChildren: _closedSubTiles(_anchorForegroundColor, widget.basePath),
                alignmentOffset: Offset(widget.minWidth / 7, 0),
                style: menuTheme.style?.copyWith(alignment: .topEnd),
                builder: (_, controller, _) {
                  return InkWell(
                    borderRadius: style.borderRadius,
                    onTap: () => controller.isOpen ? controller.close() : controller.open(),
                    child: viewWithTooltip,
                  );
                },
              ),
            ),
    );

    return Padding(
      padding: style.margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.tile.onTap?.call(widget.isSelected);

            if (widget.tile.subTiles.isEmpty) {
              widget.onSelectPath(widget.basePath);
            } else {
              widget.onToggle(widget.basePath);
            }
          },
          borderRadius: style.borderRadius,
          overlayColor: .resolveWith((_) => Colors.transparent),
          child: widget.tile.subTiles.isEmpty
              ? singleTile
              : DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: style.borderRadius,
                    border: _isSubTileSelected
                        ? Border(
                            left: isRTL ? BorderSide.none : BorderSide(color: style.color!, width: style.openMenuLineWidth),
                            right: isRTL ? BorderSide(color: style.color!, width: style.openMenuLineWidth) : BorderSide.none,
                          )
                        : null,
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisSize: .min,
                      children: [
                        singleTile,
                        // Offstage(
                        //   offstage: !(widget.isMenuOpen && _isSubTileSelected),
                        //   child: Column(
                        //     crossAxisAlignment: .start,
                        //     mainAxisSize: .min,
                        //     children: [const SizedBox(height: 2), ..._subTiles(widget.basePath)],
                        //   ),
                        // ),
                        Visibility(
                          visible: widget.isMenuOpen && _isSubTileSelected,
                          maintainState: true,
                          child: Column(
                            crossAxisAlignment: .start,
                            mainAxisSize: .min,
                            children: [const SizedBox(height: 2), ..._subTiles(widget.basePath)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  //
  Widget _createView() {
    final Color color = _getChildColor(widget.isSelected);
    Widget tile = _tile(color);

    // has badge
    if (widget.tile.badgeBuilder != null && widget.tile.badgeBuilder!(tile) != null) {
      tile = widget.tile.badgeBuilder!(tile)!;
    }
    // has selected indicator
    if (widget.isSelected && widget.tile.hasSelectedIndicator) {
      tile = _selectedLine(color, child: tile);
    }

    return tile;
  }

  //
  List<Widget> _closedSubTiles(Color textColor, List<int> parentPath) {
    final TextStyle? textStyle = TextTheme.of(context).labelMedium?.copyWith(color: textColor);
    List<Widget> subTiles = [
      Padding(
        padding: const .fromSTEB(0, 5, 0, 5),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(widget.tile.title, style: textStyle?.copyWith(fontWeight: .w400)),
            Divider(color: textColor, thickness: 1, height: 1),
          ],
        ),
      ),
      ...List.generate(widget.tile.subTiles.length, (i) {
        final subTile = widget.tile.subTiles[i];
        final SubMenuTileStyle? subStyle = subTile.style;
        final path = [...parentPath, i];
        final isSelected = _isSelectedPath(path);

        return subTile.subTiles.isEmpty
            ? SubTileWidget(
                key: ValueKey(path.join('-')),
                subTile: subTile,
                subStyle: subStyle,
                style: style,
                textColor: _getChildColor(isSelected),
                isSelected: isSelected,
                isCompact: false,
                onTap: () {
                  widget.onSelectPath(path);
                  subTile.onTap?.call(isSelected);
                },
              )
            : _buildClosedSubTile(subTile, textStyle: textStyle, path);
      }),
    ];

    return subTiles;
  }

  Widget _buildClosedSubTile(SideMenuSubTileData tile, List<int> parentPath, {TextStyle? textStyle}) {
    return SubmenuButton(
      // style: MenuItemButton.styleFrom(minimumSize: const Size.fromHeight(35)),
      alignmentOffset: const Offset(_anchorHorizPadding, 0),
      menuChildren: List.generate(tile.subTiles.length, (i) {
        final subTile = tile.subTiles[i];
        final SubMenuTileStyle? subStyle = subTile.style;
        final path = [...parentPath, i];
        final isSelected = _isSelectedPath(path);

        return subTile.subTiles.isEmpty
            ? SubTileWidget(
                key: ValueKey(path.join('-')),
                subTile: subTile,
                subStyle: subStyle,
                style: style,
                textColor: _getChildColor(isSelected),
                isSelected: isSelected,
                isCompact: false,
                onTap: () {
                  widget.onSelectPath(path);
                  subTile.onTap?.call(isSelected);
                },
              )
            : SideMenuSubTile(
                key: ValueKey(path.join('-')),
                index: i,
                isMenuOpen: widget.isMenuOpen,
                tile: subTile.resolveWith((subTile.style ?? SubMenuTileStyle()).merge(style)),
                basePath: path,
                selectedPath: widget.selectedPath,
                onSelectPath: widget.onSelectPath,
                onToggle: widget.onToggle,
                openNodes: widget.openNodes,
              );
      }),
      child: Text(tile.title, style: textStyle),
    );
  }

  //
  List<Widget> _subTiles(List<int> parentPath) {
    return List.generate(widget.tile.subTiles.length, (i) {
      final subTile = widget.tile.subTiles[i];
      final SubMenuTileStyle? subStyle = subTile.style;
      final path = [...parentPath, i];
      final isSelected = _isSelectedPath(path);

      return subTile.subTiles.isEmpty
          ? SubTileWidget(
              key: ValueKey(path.join('-')),
              subTile: subTile,
              subStyle: subStyle,
              style: style,
              textColor: _getChildColor(isSelected),
              isSelected: isSelected,
              isCompact: !widget.isMenuOpen,
              onTap: () {
                subTile.onTap?.call(true);
                widget.onSelectPath(path);
              },
            )
          : Padding(
              padding: subTile.style?.margin ?? const .fromSTEB(5, 0, 0, 0),
              child: SideMenuSubTile(
                key: ValueKey(path.join('-')),
                index: i,
                isMenuOpen: widget.isMenuOpen,
                tile: subTile.resolveWith((subTile.style ?? SubMenuTileStyle()).merge(style)),
                basePath: path,
                selectedPath: widget.selectedPath,
                onSelectPath: widget.onSelectPath,
                onToggle: widget.onToggle,
                openNodes: widget.openNodes,
              ),
            );
    });
  }

  //
  Widget _tile(Color color) {
    final Widget? leading = _leading(color);

    return Row(
      spacing: style.horizontalSpacing,
      children: [
        ?_leading(color),
        ?_title(color, hasLeading: leading != null),
        ...?_trailing(color),
      ],
    );
  }

  //
  Widget? _leading(Color color) {
    final Widget? selectedLeading = widget.isSelected && widget.tile.selectedLeading != null ? widget.tile.selectedLeading : widget.tile.leading;

    return selectedLeading == null
        ? null
        : Expanded(
            child: SizedBox(
              height: double.maxFinite,
              child: ColoredContent(color: color, child: selectedLeading),
            ),
          );
  }

  Widget? _title(Color color, {required bool hasLeading}) {
    if (widget.isMenuOpen) {
      final TextStyle? textStyle = (widget.isSelected ? style.selectedTitleStyle : style.titleStyle) ?? TextTheme.of(context).bodySmall;

      return Expanded(
        flex: 5,
        child: Padding(
          padding: hasLeading ? .zero : const .fromSTEB(10, 0, 0, 0),
          child: Text(
            widget.tile.title,
            style: textStyle?.copyWith(color: textStyle.color ?? color),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
      );
    }

    return null;
  }

  List<Widget>? _trailing(Color color) {
    if (widget.isMenuOpen) {
      Widget openIcon = Padding(
        padding: const .fromSTEB(0, 0, 5, 0),
        child: IconTheme(
          data: IconThemeData(color: color),
          child: Icon(_isSubTileSelected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 14, color: color),
        ),
      );

      if (widget.tile.trailing != null) {
        final Widget trailing = Expanded(
          child: SizedBox(
            height: double.maxFinite,
            child: ColoredContent(color: color, child: widget.tile.trailing!),
          ),
        );

        return [
          trailing,
          // icon indicating tile has sub-tiles
          if (widget.tile.subTiles.isNotEmpty) openIcon,
        ];
      }

      if (widget.tile.subTiles.isNotEmpty) return [openIcon];
    }

    return null;
  }

  //
  Widget _selectedLine(Color color, {required Widget child}) {
    // get decoration if not null & set color if null
    final Decoration? decoration = switch (style.selectedIndicator) {
      BoxDecoration d when d.color == null => d.copyWith(color: color),
      ShapeDecoration d when d.color == null => ShapeDecoration(
        color: color,
        shape: d.shape,
        shadows: d.shadows,
        gradient: d.gradient,
        image: d.image,
      ),
      _ => style.selectedIndicator,
    };

    // selected line
    final Widget line = decoration != null
        ? Container(constraints: BoxConstraints.loose(widget.tile.selectedIndicatorSize), decoration: decoration)
        : SizedBox.fromSize(
            size: widget.tile.selectedIndicatorSize,
            child: ColoredBox(color: color),
          );

    return Stack(alignment: .centerStart, children: [child, line]);
  }

  // the color of leading, title and trailing when selected or not
  Color _getChildColor(bool condition) {
    return condition
        ? style.selectedColor ?? style.selectedTitleStyle?.color ?? ColorScheme.of(context).onPrimary
        : style.color ?? style.titleStyle?.color ?? ColorScheme.of(context).onPrimary;
  }

  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(StringProperty('title', widget.title));
  // }
}
