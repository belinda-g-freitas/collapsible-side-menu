import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/data/side_menu_item_data.dart';
import '../models/styles/sub_menu_tile_style.dart';
import '../utils/utils.dart';
import 'colored_content.dart';
import 'sub_tile_widget.dart';

class SideMenuSubTile extends StatefulWidget {
  const SideMenuSubTile({
    super.key,
    required this.tile,
    required this.index,
    required this.isMenuOpen,
    required this.selectedPath,
    required this.basePath,
    required this.onSelectPath,
    required this.onToggle,
    required this.openNodes,
  });

  final SideMenuSubTileData tile;
  final int index;
  final bool isMenuOpen;
  final List<int> selectedPath;
  final List<int> basePath;
  final void Function(List<int> path) onSelectPath;
  final void Function(List<int> path) onToggle;
  final Set<String> openNodes;

  @override
  State<SideMenuSubTile> createState() => _SideMenuSubTileState();
}

class _SideMenuSubTileState extends State<SideMenuSubTile> {
  late SubMenuTileStyle style;

  bool get _isOpen => widget.openNodes.contains(widget.basePath.join('-'));
  //
  Widget _createView() {
    Widget tile = _tile();

    // has badge
    final badge = widget.tile.badgeBuilder?.call(tile);
    if (badge != null) tile = badge;

    return tile;
  }

  // leading, title and trailing of the tile
  Widget _tile() {
    final Color color = _getChildColor(_isOpen);
    final Widget? leading = _leading(color);

    return Row(
      spacing: style.horizontalSpacing,
      children: [
        ?leading,
        _title(color, hasLeading: leading != null),
        ...?_trailing(color),
      ],
    );
  }

  //
  Widget? _leading(Color color) {
    final Widget? selectedLeading = _isOpen && widget.tile.selectedLeading != null ? widget.tile.selectedLeading : widget.tile.leading;

    return selectedLeading == null
        ? null
        : Expanded(
            child: SizedBox(
              height: double.maxFinite,
              child: ColoredContent(color: color, child: selectedLeading),
            ),
          );
  }

  Widget _title(Color color, {required bool hasLeading}) {
    final TextStyle? textStyle = (_isOpen ? style.selectedTitleStyle : style.titleStyle) ?? TextTheme.of(context).bodySmall;

    return Expanded(
      flex: 5,
      child: Padding(
        padding: hasLeading ? .zero : const .fromSTEB(10, 0, 0, 0),
        child: Text(
          widget.tile.title,
          style: textStyle?.copyWith(color: textStyle.color ?? (_isOpen ? style.selectedColor : style.color)),
          maxLines: 1,
          overflow: textStyle?.overflow ?? .ellipsis,
        ),
      ),
    );
  }

  List<Widget>? _trailing(Color color) {
    Widget openIcon = Padding(
      padding: const .fromSTEB(0, 0, 5, 0),
      child: IconTheme(
        data: IconThemeData(color: color),
        child: Icon(_isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 14, color: color),
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

    return null;
  }

  //
  List<Widget> _subTiles() {
    return List.generate(widget.tile.subTiles.length, (i) {
      final SideMenuSubTileData subTile = widget.tile.subTiles[i];
      final path = [...widget.basePath, i];
      final isSelected = Utils.pathStartsWith(widget.selectedPath, path);

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
                tile: subTile.copyWith(style: style),
                basePath: path,
                selectedPath: widget.selectedPath,
                openNodes: widget.openNodes,
                onToggle: widget.onToggle,
                onSelectPath: widget.onSelectPath,
              ),
            );
    });
  }

  // the color of leading, title and trailing when selected or not
  Color _getChildColor(bool condition) {
    return condition
        ? style.selectedColor ?? style.selectedTitleStyle?.color ?? ColorScheme.of(context).onPrimary
        : style.color ?? style.titleStyle?.color ?? ColorScheme.of(context).onPrimary;
  }

  @override
  void initState() {
    style = widget.tile.style ?? SubMenuTileStyle();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant SideMenuSubTile oldWidget) {
    if (oldWidget.tile.style != widget.tile.style) {
      style = widget.tile.style ?? SubMenuTileStyle();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Utils.isRTL(context);

    return Padding(
      padding: style.margin,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            // tile
            InkWell(
              onTap: () {
                widget.onToggle(widget.basePath);
                widget.tile.onTap?.call();
              },
              borderRadius: style.borderRadius,
              // no hover effect when expanded
              hoverColor: _isOpen ? Colors.transparent : style.hoverColor,
              child: Container(
                height: style.tileHeight,
                padding: style.padding,
                decoration:
                    (_isOpen ? style.selectedDecoration : style.decoration) ??
                    ShapeDecoration(
                      shape: RoundedRectangleBorder(borderRadius: style.borderRadius),
                      color: _isOpen ? style.selectedBackgroundColor : style.backgroundColor,
                    ),
                child: _createView(),
              ),
            ),
            // sub tiles
            // We set maintainState to true to keep sub-menus states (selected sub-tile and opened sub-menu)
            Visibility(
              visible: _isOpen,
              maintainState: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: style.borderRadius,
                  border: Border(
                    left: isRTL ? BorderSide.none : BorderSide(color: style.color!, width: style.openMenuLineWidth),
                    right: isRTL ? BorderSide(color: style.color!, width: style.openMenuLineWidth) : BorderSide.none,
                    bottom: BorderSide(color: style.color!, width: style.openMenuLineWidth),
                  ),
                ),
                child: Column(crossAxisAlignment: .start, mainAxisSize: .min, children: [const SizedBox(height: 2), ..._subTiles()]),
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
    properties.add(IntProperty('index', widget.index));
    properties.add(DiagnosticsProperty<List<int>>('basePath', widget.basePath));
    properties.add(DiagnosticsProperty<List<int>>('selectedPath', widget.selectedPath));
    // state
    properties.add(FlagProperty('_isOpen', value: _isOpen, ifTrue: 'expanded', ifFalse: 'collapsed'));
    properties.add(FlagProperty('isMenuOpen', value: widget.isMenuOpen, ifTrue: 'menu-open'));
    // structure
    properties.add(IntProperty('subTileCount', widget.tile.subTiles.length));
    properties.add(IterableProperty<String>('openNodes', widget.openNodes));
    // style
    properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', style.borderRadius, defaultValue: null));
    properties.add(DoubleProperty('tileHeight', style.tileHeight));
    properties.add(DoubleProperty('openMenuLineWidth', style.openMenuLineWidth));
    // optional features
    properties.add(FlagProperty('hasBadge', value: widget.tile.badgeBuilder != null, ifTrue: 'has badge'));
    properties.add(FlagProperty('hasLeading', value: widget.tile.leading != null, ifTrue: 'has leading'));
    properties.add(FlagProperty('hasSelectedLeading', value: widget.tile.selectedLeading != null, ifTrue: 'has selectedLeading'));
    properties.add(FlagProperty('hasTrailing', value: widget.tile.trailing != null, ifTrue: 'has trailing'));
  }
}
