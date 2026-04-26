import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/data/side_menu_item_data.dart';
import '../models/styles/menu_tile_style.dart';
import '../models/styles/sub_menu_tile_style.dart';
import '../utils/menu_constants.dart';
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
  static const double _anchorHorizPadding = 10;
  final MenuController _menuController = MenuController();
  late MenuTileStyle style;
  late Color _anchorForegroundColor;

  bool _isSelectedPath(List<int> path) => Utils.pathStartsWith(widget.selectedPath, path);

  bool get _isSubTileSelected => widget.openNodes.contains(widget.basePath.join('-'));

  void _updateStyle() {
    style = widget.tile.style!;
    _anchorForegroundColor = style.color ?? style.titleStyle?.color ?? ColorScheme.of(context).onPrimary;
  }

  //
  Widget _collapsedSubTile(SideMenuSubTileData subTile, List<int> path) {
    final isSelected = _isSelectedPath(path);

    return SubTileWidget(
      subTile: subTile,
      subStyle: subTile.style,
      style: style,
      textColor: _getChildColor(isSelected),
      isSelected: isSelected,
      onTap: () {
        subTile.onTap?.call();
        widget.onSelectPath(path);
        if (_menuController.isOpen) _menuController.close();
      },
    );
  }

  //
  Widget _createView() {
    final Color color = _getChildColor(widget.isSelected);
    Widget tile = _tile(color);

    // has badge
    final badge = widget.tile.badgeBuilder?.call(tile);
    if (badge != null) tile = badge;

    // has selected indicator
    if (widget.isSelected && widget.tile.hasSelectedIndicator) {
      tile = _selectedLine(color, child: tile);
    }

    return tile;
  }

  //
  List<Widget> _collapsedSubTiles(Color textColor, List<int> parentPath) {
    return [
      Padding(
        padding: const .fromSTEB(0, 5, 0, 5),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              widget.tile.title,
              style: TextTheme.of(context).labelMedium?.copyWith(color: textColor, fontWeight: .w400),
            ),
            Divider(color: textColor, thickness: 1, height: 1),
          ],
        ),
      ),
      ...List.generate(widget.tile.subTiles.length, (i) {
        final subTile = widget.tile.subTiles[i];
        final path = [...parentPath, i];

        return subTile.subTiles.isEmpty ? _collapsedSubTile(subTile, path) : _buildCollapsedSubTile(subTile, path, textColor);
      }),
    ];
  }

  Widget _buildCollapsedSubTile(SideMenuSubTileData tile, List<int> parentPath, Color textColor) {
    TextStyle? textStyle;

    return SubmenuButton(
      alignmentOffset: const Offset(_anchorHorizPadding, 0),
      menuChildren: List.generate(tile.subTiles.length, (i) {
        final subTile = tile.subTiles[i];
        final subStyle = subTile.style;
        final path = [...parentPath, i];
        final isSelected = _isSelectedPath(path);
        textStyle =
            ((isSelected
                        ? (subStyle?.defaultSubTilesStyle?.selectedTitleStyle ?? subStyle?.selectedTitleStyle)
                        : (subStyle?.defaultSubTilesStyle?.titleStyle ?? subStyle?.titleStyle)) ??
                    TextTheme.of(context).labelSmall)
                ?.copyWith(fontWeight: .w400, color: textColor);

        return subTile.subTiles.isEmpty
            ? _collapsedSubTile(subTile, path)
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
      final path = [...parentPath, i];
      final isSelected = _isSelectedPath(path);

      return subTile.subTiles.isEmpty
          ? SubTileWidget(
              key: ValueKey(path.join('-')),
              subTile: subTile,
              subStyle: subTile.style,
              style: style,
              textColor: _getChildColor(isSelected),
              isSelected: isSelected,
              onTap: () {
                subTile.onTap?.call();
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
        ?leading,
        ?_title(color, hasLeading: leading != null),
        ...?_trailing(color),
      ],
    );
  }

  //
  Widget? _leading(Color color) {
    final Widget? selectedLeading = widget.isSelected && widget.tile.selectedLeading != null ? widget.tile.selectedLeading : widget.tile.leading;

    return selectedLeading != null
        ? Expanded(
            child: SizedBox(
              height: double.maxFinite,
              child: ColoredContent(color: color, child: selectedLeading),
            ),
          )
        : widget.isMenuOpen
        ? null
        : Expanded(
            child: Center(
              child: Text(
                widget.tile.title[0],
                style: TextStyle(fontWeight: .w600, color: color),
              ),
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
            overflow: textStyle?.overflow ?? .ellipsis,
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
        child: Icon(_isSubTileSelected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 14, color: color),
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
        : Container(
            constraints: BoxConstraints.loose(widget.tile.selectedIndicatorSize),
            decoration: BoxDecoration(borderRadius: MenuConstants.borderRadius, color: color),
          );

    return Stack(alignment: .centerStart, children: [child, line]);
  }

  // the color of leading, title and trailing when selected or not
  Color _getChildColor(bool condition) {
    return condition
        ? style.selectedColor ?? style.selectedTitleStyle?.color ?? ColorScheme.of(context).onPrimary
        : style.color ?? style.titleStyle?.color ?? ColorScheme.of(context).onPrimary;
  }

  @override
  void initState() {
    super.initState();
    _updateStyle();
  }

  @override
  void didChangeDependencies() {
    _updateStyle();

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SideMenuTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tile.style != widget.tile.style) _updateStyle();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final menuTheme = MenuTheme.of(context);
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
        return isRTL
            ? Offset(position.target.dx - (position.tooltipSize.width + widget.minWidth / 2), position.target.dy - position.tooltipSize.height / 2)
            : Offset(position.target.dx + widget.minWidth / 2, position.target.dy - position.tooltipSize.height / 2);
      },
      constraints: BoxConstraints(minHeight: style.tileHeight / 1.5),
      child: view,
    );
    final Widget singleTile = InkWell(
      onTap: () {
        widget.tile.onTap?.call();

        if (widget.tile.subTiles.isEmpty) {
          widget.onSelectPath(widget.basePath);
        } else {
          widget.onToggle(widget.basePath);
        }
      },
      borderRadius: style.borderRadius,
      hoverColor: style.hoverColor,
      child: Container(
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
                  controller: _menuController,
                  clipBehavior: .antiAlias,
                  menuChildren: _collapsedSubTiles(_anchorForegroundColor, widget.basePath),
                  alignmentOffset: Offset(widget.minWidth / 7, 0),
                  style: menuTheme.style?.copyWith(alignment: .topEnd),
                  child: InkWell(
                    borderRadius: style.borderRadius,
                    onTap: () => _menuController.isOpen ? _menuController.close() : _menuController.open(),
                    child: viewWithTooltip,
                  ),
                ),
              ),
      ),
    );

    return Padding(
      padding: style.margin,
      child: Material(
        color: Colors.transparent,
        child: widget.tile.subTiles.isEmpty
            ? singleTile
            : Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  // tile
                  singleTile,
                  // subtiles
                  // We set maintainState to true to keep sub-menus states (selected sub-tile and opened sub-menu)
                  Visibility(
                    visible: widget.isMenuOpen && _isSubTileSelected,
                    maintainState: true,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: style.borderRadius,
                        border: Border(
                          left: isRTL ? BorderSide.none : BorderSide(color: style.color!, width: style.openMenuLineWidth),
                          right: isRTL ? BorderSide(color: style.color!, width: style.openMenuLineWidth) : BorderSide.none,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisSize: .min,
                        children: [const SizedBox(height: 2), ..._subTiles(widget.basePath)],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // tile identity
    properties.add(StringProperty('title', widget.tile.title));
    properties.add(DiagnosticsProperty<List<int>>('basePath', widget.basePath));
    properties.add(DiagnosticsProperty<List<int>>('selectedPath', widget.selectedPath));
    // state
    properties.add(FlagProperty('isSelected', value: widget.isSelected, ifTrue: 'selected'));
    properties.add(FlagProperty('isMenuOpen', value: widget.isMenuOpen, ifTrue: 'open', ifFalse: 'collapsed'));
    properties.add(FlagProperty('_isSubTileSelected', value: _isSubTileSelected, ifTrue: 'subtile-expanded'));
    // structure
    properties.add(IntProperty('subTileCount', widget.tile.subTiles.length));
    properties.add(IterableProperty<String>('openNodes', widget.openNodes));
    // layout
    properties.add(DoubleProperty('minWidth', widget.minWidth));
    properties.add(ColorProperty('sideMenuBackgroundColor', widget.sideMenuBackgroundColor));
    // style (only when available — style is assigned in build)
    if (mounted) {
      properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', style.borderRadius, defaultValue: null));
      properties.add(DoubleProperty('tileHeight', style.tileHeight));
      properties.add(ColorProperty('resolvedForegroundColor', _anchorForegroundColor));
    }
    // optional features
    properties.add(FlagProperty('hasBadge', value: widget.tile.badgeBuilder != null, ifTrue: 'has badge'));
    properties.add(FlagProperty('hasSelectedIndicator', value: widget.tile.hasSelectedIndicator, ifTrue: 'has indicator'));
    properties.add(FlagProperty('hasLeading', value: widget.tile.leading != null, ifTrue: 'has leading'));
    properties.add(FlagProperty('hasTrailing', value: widget.tile.trailing != null, ifTrue: 'has trailing'));
  }
}
