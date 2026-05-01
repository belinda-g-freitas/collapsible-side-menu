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

  final SubTileData tile;
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
  late SubMenuTileStyle _style;
  late List<int> _nodeKey;
  late SubTileData tile;
  late List<SubTileData> subTiles;

  bool get _isOpen => widget.openNodes.contains(_nodeKey.join('-'));
  //
  Widget _createView() {
    Widget view = _tile();

    // has badge
    final badge = tile.badgeBuilder?.call(view);
    if (badge != null) view = badge;

    return view;
  }

  // leading, title and trailing of the tile
  Widget _tile() {
    final Color color = _getChildColor(_isOpen);
    final Widget? leading = _leading(color);

    return Row(
      spacing: _style.horizontalSpacing,
      children: [
        ?leading,
        _title(color, hasLeading: leading != null),
        ...?_trailing(color),
      ],
    );
  }

  //
  Widget? _leading(Color color) {
    final Widget? selectedLeading = _isOpen && tile.selectedLeading != null ? tile.selectedLeading : tile.leading;

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
    final TextStyle? textStyle = (_isOpen ? _style.selectedTitleStyle : _style.titleStyle) ?? TextTheme.of(context).bodySmall;

    return Expanded(
      flex: 5,
      child: Padding(
        padding: hasLeading ? .zero : const .fromSTEB(10, 0, 0, 0),
        child: Text(
          tile.title,
          style: textStyle?.copyWith(color: textStyle.color ?? (_isOpen ? _style.selectedColor : _style.color)),
          maxLines: 1,
          overflow: textStyle?.overflow ?? .ellipsis,
        ),
      ),
    );
  }

  List<Widget>? _trailing(Color color) {
    Widget openIcon = Padding(
      padding: const .fromSTEB(0, 0, 5, 0),
      child: Icon(_isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 14, color: color),
    );

    if (tile.trailing != null) {
      final Widget trailing = Expanded(
        child: SizedBox(
          height: double.maxFinite,
          child: ColoredContent(color: color, child: tile.trailing!),
        ),
      );

      return [
        trailing,
        // icon indicating tile has sub-tiles
        if (subTiles.isNotEmpty) openIcon,
      ];
    }

    if (subTiles.isNotEmpty) return [openIcon];

    return null;
  }

  //
  List<Widget> _subTiles() {
    return List.generate(subTiles.length, (i) {
      final SubTileData subTile = subTiles[i];
      final path = [..._nodeKey, i];
      final isSelected = Utils.pathStartsWith(widget.selectedPath, path);

      return subTile.subTiles.isEmpty
          ? SubTileWidget(
              key: ValueKey(path.join('-')),
              subTile: subTile,
              subStyle: subTile.style,
              style: _style,
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
                tile: subTile.copyWith(style: _style),
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
        ? _style.selectedColor ?? _style.selectedTitleStyle?.color ?? Colors.white
        : _style.color ?? _style.titleStyle?.color ?? Colors.white;
  }

  @override
  void initState() {
    super.initState();

    _nodeKey = widget.basePath;
    tile = widget.tile;
    subTiles = tile.subTiles;
    _style = tile.style ?? SubMenuTileStyle();
  }

  @override
  void didUpdateWidget(covariant SideMenuSubTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.basePath, widget.basePath)) _nodeKey = widget.basePath;
    if (oldWidget.tile != widget.tile) tile = widget.tile;
    if (!listEquals(oldWidget.tile.subTiles, widget.tile.subTiles)) subTiles = tile.subTiles;
    if (oldWidget.tile.style != widget.tile.style) _style = tile.style ?? SubMenuTileStyle();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Utils.isRTL(context);

    return Padding(
      padding: _style.margin,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            // tile
            InkWell(
              onTap: () {
                widget.onToggle(_nodeKey);
                tile.onTap?.call();
              },
              borderRadius: _style.borderRadius,
              // no hover effect when expanded
              hoverColor: _isOpen ? Colors.transparent : _style.hoverColor,
              child: Container(
                height: _style.tileHeight,
                padding: _style.padding,
                decoration:
                    (_isOpen ? _style.selectedDecoration : _style.decoration) ??
                    ShapeDecoration(
                      shape: RoundedRectangleBorder(borderRadius: _style.borderRadius),
                      color: _isOpen ? _style.selectedBackgroundColor : _style.backgroundColor,
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
                  borderRadius: _style.borderRadius,
                  border: Border(
                    left: isRTL ? BorderSide.none : BorderSide(color: _style.color!, width: _style.openMenuLineWidth),
                    right: isRTL ? BorderSide(color: _style.color!, width: _style.openMenuLineWidth) : BorderSide.none,
                    bottom: BorderSide(color: _style.color!, width: _style.openMenuLineWidth),
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
    properties.add(StringProperty('title', tile.title));
    properties.add(IntProperty('index', widget.index));
    properties.add(DiagnosticsProperty<List<int>>('basePath', _nodeKey));
    properties.add(DiagnosticsProperty<List<int>>('selectedPath', widget.selectedPath));
    // state
    properties.add(FlagProperty('_isOpen', value: _isOpen, ifTrue: 'expanded', ifFalse: 'collapsed'));
    properties.add(FlagProperty('isMenuOpen', value: widget.isMenuOpen, ifTrue: 'menu-open'));
    // structure
    properties.add(IntProperty('subTileCount', subTiles.length));
    properties.add(IterableProperty<String>('openNodes', widget.openNodes));
    // style
    properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', _style.borderRadius, defaultValue: null));
    properties.add(DoubleProperty('tileHeight', _style.tileHeight));
    properties.add(DoubleProperty('openMenuLineWidth', _style.openMenuLineWidth));
    // optional features
    properties.add(FlagProperty('hasBadge', value: tile.badgeBuilder != null, ifTrue: 'has badge'));
    properties.add(FlagProperty('hasLeading', value: tile.leading != null, ifTrue: 'has leading'));
    properties.add(FlagProperty('hasSelectedLeading', value: tile.selectedLeading != null, ifTrue: 'has selectedLeading'));
    properties.add(FlagProperty('hasTrailing', value: tile.trailing != null, ifTrue: 'has trailing'));
  }
}
