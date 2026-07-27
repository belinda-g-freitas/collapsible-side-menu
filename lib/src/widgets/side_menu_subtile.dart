import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/data/side_menu_item.dart';
import '../models/styles/sub_menu_tile_style.dart';
import '../utils/menu_constants.dart';
import '../utils/utils.dart';
import 'open_indicator_icon.dart';
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
  final ValueChanged<List<int>> onSelectPath;
  final ValueChanged<List<int>> onToggle;
  final ValueNotifier<Set<String>> openNodes;

  @override
  State<SideMenuSubTile> createState() => _SideMenuSubTileState();
}

class _SideMenuSubTileState extends State<SideMenuSubTile> {
  late SubMenuTileStyle _style;
  late List<int> _nodeKey;
  late SubTileData tile;
  late List<SubTileData> subTiles;
  late String _nodeKeyString;
  late bool _hasSubtiles;

  bool _isOpen(Set<String> nodes) => nodes.contains(_nodeKeyString);
  //
  Widget _createView(bool isOpen) {
    Widget view = _tile(isOpen);

    // has badge
    final badge = tile.badgeBuilder?.call(view);
    if (badge != null) view = badge;

    return view;
  }

  // leading, title and trailing of the tile
  Widget _tile(bool isOpen) {
    final Color color = _getChildColor(isOpen);
    final Widget? leading = _leading(color, isOpen);

    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: Row(
        spacing: _style.horizontalSpacing,
        children: [
          ?leading,
          _title(color, isOpen, hasLeading: leading != null),
          ...?_trailing(color, isOpen),
        ],
      ),
    );
  }

  //
  Widget? _leading(Color color, bool isOpen) {
    final Widget? selectedLeading = isOpen && tile.selectedLeading != null ? tile.selectedLeading : tile.leading;

    return selectedLeading == null
        ? null
        : Expanded(
            child: SizedBox(
              height: double.maxFinite,
              child: Center(
                child: IconTheme.merge(
                  data: IconThemeData(color: color, size: tile.style?.trailingIconSize),
                  child: selectedLeading,
                ),
              ),
            ),
          );
  }

  Widget _title(Color color, bool isOpen, {required bool hasLeading}) {
    final TextStyle? textStyle = (isOpen ? _style.selectedTitleStyle : _style.titleStyle) ?? TextTheme.of(context).bodySmall;

    return Expanded(
      flex: 5,
      child: Padding(
        padding: hasLeading ? .zero : const .fromSTEB(10, 0, 0, 0),
        child: Text(
          tile.title,
          style: textStyle?.copyWith(color: textStyle.color ?? (isOpen ? _style.selectedColor : _style.color)),
          maxLines: 1,
          overflow: textStyle?.overflow ?? .ellipsis,
        ),
      ),
    );
  }

  Widget _openIcon(Color color) => OpenIndicatorIcon(nodeKey: _nodeKeyString, openNodes: widget.openNodes, color: color);

  List<Widget>? _trailing(Color color, bool isOpen) {
    Widget openIcon = _openIcon(color);

    if (tile.trailing != null) {
      final Widget trailing = Expanded(
        child: SizedBox(
          height: double.maxFinite,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(color: color, size: tile.style?.trailingIconSize),
              child: tile.trailing!,
            ),
          ),
        ),
      );

      return [
        trailing,
        // icon indicating tile has sub-tiles
        if (_hasSubtiles) openIcon,
      ];
    }

    if (_hasSubtiles) return [openIcon];

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
    _nodeKeyString = _nodeKey.join('-');
    tile = widget.tile;
    subTiles = tile.subTiles;
    _hasSubtiles = subTiles.isNotEmpty;
    _style = tile.style ?? SubMenuTileStyle();
  }

  @override
  void didUpdateWidget(covariant SideMenuSubTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.basePath, widget.basePath)) {
      _nodeKey = widget.basePath;
      _nodeKeyString = _nodeKey.join('-');
    }
    //
    if (oldWidget.tile != widget.tile) {
      tile = widget.tile;
      subTiles = tile.subTiles;
      _hasSubtiles = subTiles.isNotEmpty;
    } else if (!listEquals(oldWidget.tile.subTiles, widget.tile.subTiles)) {
      subTiles = tile.subTiles;
      _hasSubtiles = subTiles.isNotEmpty;
    }
    //
    if (oldWidget.tile.style != widget.tile.style) _style = tile.style ?? SubMenuTileStyle();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _style.margin,
      child: Material(
        color: MenuConstants.transparent,
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: widget.openNodes,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _style.borderRadius,
              border: BorderDirectional(
                start: BorderSide(color: _style.color!, width: _style.selectedBorderWidth),
                bottom: BorderSide(color: _style.color!, width: _style.selectedBorderWidth),
              ),
            ),
            child: Padding(
              padding: const .only(top: MenuConstants.tilesVerticalSpacing),
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                spacing: MenuConstants.tilesVerticalSpacing,
                children: _subTiles(),
              ),
            ),
          ),
          builder: (_, nodes, child) {
            final isOpen = _isOpen(nodes);

            return Column(
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
                  hoverColor: isOpen ? Colors.transparent : _style.hoverColor,
                  child: Container(
                    height: _style.tileHeight,
                    padding: _style.padding,
                    decoration:
                        (isOpen ? _style.selectedDecoration : _style.decoration) ??
                        ShapeDecoration(
                          shape: RoundedRectangleBorder(borderRadius: _style.borderRadius),
                          color: isOpen ? _style.selectedBackgroundColor : _style.backgroundColor,
                        ),
                    child: _createView(isOpen),
                  ),
                ),
                // sub tiles
                // We set maintainState to true to keep sub-menus states (selected sub-tile and opened sub-menu)
                Visibility(visible: isOpen, maintainState: true, child: child!),
              ],
            );
          },
        ),
      ),
    );
  }

  // coverage:ignore-start
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // tile identity
    properties.add(StringProperty('title', tile.title));
    properties.add(IntProperty('index', widget.index));
    properties.add(DiagnosticsProperty<List<int>>('basePath', _nodeKey));
    properties.add(DiagnosticsProperty<List<int>>('selectedPath', widget.selectedPath));
    // state
    properties.add(FlagProperty('_isOpen', value: _isOpen(widget.openNodes.value), ifTrue: 'expanded', ifFalse: 'collapsed'));
    properties.add(FlagProperty('isMenuOpen', value: widget.isMenuOpen, ifTrue: 'menu-open'));
    // structure
    properties.add(IntProperty('subTileCount', subTiles.length));
    properties.add(IterableProperty<String>('openNodes', widget.openNodes.value));
    // style
    properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', _style.borderRadius, defaultValue: null));
    properties.add(DoubleProperty('tileHeight', _style.tileHeight));
    properties.add(DoubleProperty('selectedIndicatorWidth', _style.selectedBorderWidth));
    // optional features
    properties.add(FlagProperty('hasBadge', value: tile.badgeBuilder != null, ifTrue: 'has badge'));
    properties.add(FlagProperty('hasLeading', value: tile.leading != null, ifTrue: 'has leading'));
    properties.add(FlagProperty('hasSelectedLeading', value: tile.selectedLeading != null, ifTrue: 'has selectedLeading'));
    properties.add(FlagProperty('hasTrailing', value: tile.trailing != null, ifTrue: 'has trailing'));
  }

  // coverage:ignore-end
}
