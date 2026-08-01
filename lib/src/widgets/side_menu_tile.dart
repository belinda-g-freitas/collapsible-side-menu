import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/data/side_menu_item.dart';
import '../models/styles/menu_tile_style.dart';
import '../models/styles/sub_menu_tile_style.dart';
import '../utils/menu_constants.dart';
import '../utils/utils.dart';
import 'open_indicator_icon.dart';
import 'side_menu_subtile.dart';
import 'sub_tile_widget.dart';

class SideMenuTile extends StatefulWidget {
  const SideMenuTile({
    super.key,
    required this.tile,
    required this.isSelected,
    required this.isMenuOpen,
    required this.horizontalOffset,
    required this.anchorBackgroundColor,
    required this.selectedPath,
    required this.basePath,
    required this.onSelectPath,
    required this.onToggle,
    required this.openNodes,
  });

  final TileData tile;
  final bool isSelected;
  final bool isMenuOpen;
  final double horizontalOffset;
  final Color anchorBackgroundColor;
  final List<int> selectedPath;
  final List<int> basePath;
  final ValueChanged<List<int>> onSelectPath;
  final ValueChanged<List<int>> onToggle;
  final ValueNotifier<Set<String>> openNodes;

  @override
  State<SideMenuTile> createState() => _SideMenuTileState();
}

class _SideMenuTileState extends State<SideMenuTile> {
  static const double _anchorHorizPadding = 10;
  final MenuController _menuController = MenuController();
  late MenuTileStyle _style;
  late Color _anchorForegroundColor;
  late List<int> _nodeKey;
  late TileData tile;
  late List<SubTileData> subTiles;
  late String _nodeKeyString;
  late bool _hasSubtiles;
  bool _derivedValuesInitialized = false;

  bool _isSelectedPath(List<int> path) => Utils.pathStartsWith(widget.selectedPath, path);

  bool _isSubTileSelected(Set<String> nodes) => nodes.contains(_nodeKeyString);

  void _updateStyle() {
    final newStyle = tile.style!;
    if (_derivedValuesInitialized && _style == newStyle) return;

    _derivedValuesInitialized = true;
    _style = tile.style!;
    _anchorForegroundColor = _style.color ?? _style.titleStyle?.color ?? ColorScheme.of(context).onPrimary;
  }

  //
  Widget _createView() {
    final Color color = _getChildColor(widget.isSelected);
    Widget view = _tile(color);

    // has badge
    final badge = tile.badgeBuilder?.call(view);
    if (badge != null) view = badge;

    // has selected indicator
    if (widget.isSelected && tile.hasSelectedIndicator) {
      view = _selectedLine(color, child: view);
    }

    return view;
  }

  //
  Widget _collapsedSubTile(SubTileData subTile, List<int> path) {
    final isSelected = _isSelectedPath(path);

    return SubTileWidget(
      subTile: subTile,
      subStyle: subTile.style,
      style: _style,
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
  List<Widget> _collapsedSubTiles(Color textColor, List<int> parentPath) {
    return [
      Padding(
        padding: const .fromSTEB(0, 5, 0, 5),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              tile.title,
              style: TextTheme.of(context).labelMedium?.copyWith(color: textColor, fontWeight: .w400),
            ),
            Divider(color: textColor, thickness: 1, height: 1),
          ],
        ),
      ),
      ...List.generate(subTiles.length, (i) {
        final subTile = subTiles[i];
        final path = [...parentPath, i];

        return subTile.subTiles.isEmpty ? _collapsedSubTile(subTile, path) : _buildCollapsedSubTile(subTile, path, textColor);
      }),
    ];
  }

  Widget _buildCollapsedSubTile(SubTileData tile, List<int> parentPath, Color textColor) {
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
                    TextTheme.of(context).bodySmall)
                ?.copyWith(fontWeight: .w400, color: textColor);

        return subTile.subTiles.isEmpty
            ? _collapsedSubTile(subTile, path)
            : SideMenuSubTile(
                key: ValueKey(path.join('-')),
                index: i,
                isMenuOpen: widget.isMenuOpen,
                tile: subTile.resolveWith((subTile.style ?? SubMenuTileStyle()).merge(_style)),
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
    return List.generate(subTiles.length, (i) {
      final subTile = subTiles[i];
      final path = [...parentPath, i];
      final isSelected = _isSelectedPath(path);

      return Padding(
        padding: subTile.style?.margin ?? const .fromSTEB(5, 0, 0, 0),
        child: subTile.subTiles.isEmpty
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
            : SideMenuSubTile(
                key: ValueKey(path.join('-')),
                index: i,
                isMenuOpen: widget.isMenuOpen,
                tile: subTile.resolveWith((subTile.style ?? SubMenuTileStyle()).merge(_style)),
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

    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: Row(
        spacing: _style.horizontalSpacing,
        children: [
          ?leading,
          ?_title(color, hasLeading: leading != null),
          ...?_trailing(color),
        ],
      ),
    );
  }

  //
  Widget? _leading(Color color) {
    final Widget? selectedLeading = widget.isSelected && tile.selectedLeading != null ? tile.selectedLeading : tile.leading;
    return selectedLeading != null
        ? Expanded(
            child: SizedBox(
              height: double.maxFinite,
              child: Center(
                child: IconTheme.merge(
                  data: IconThemeData(color: color, size: _style.leadingIconSize),
                  child: selectedLeading,
                ),
              ),
            ),
          )
        : widget.isMenuOpen
        ? null
        : Expanded(
            child: Center(
              child: Text(tile.title[0], style: const TextStyle(fontWeight: .w600)),
            ),
          );
  }

  Widget? _title(Color color, {required bool hasLeading}) {
    if (widget.isMenuOpen) {
      final TextStyle? textStyle =
          (widget.isSelected ? _style.selectedTitleStyle : _style.titleStyle) ?? TextTheme.of(context).bodySmall;

      return Expanded(
        flex: 5,
        child: Padding(
          padding: hasLeading ? .zero : const .fromSTEB(10, 0, 0, 0),
          child: Text(
            tile.title,
            style: textStyle?.copyWith(color: textStyle.color ?? color),
            maxLines: 1,
            overflow: textStyle?.overflow ?? .ellipsis,
          ),
        ),
      );
    }

    return null;
  }

  Widget _openIcon(Color color) => OpenIndicatorIcon(nodeKey: _nodeKeyString, openNodes: widget.openNodes, color: color);

  List<Widget>? _trailing(Color color) {
    if (widget.isMenuOpen) {
      Widget openIcon = _openIcon(color);

      if (tile.trailing != null) {
        final Widget trailing = Expanded(
          child: SizedBox(
            height: double.maxFinite,
            child: Center(
              child: IconTheme.merge(
                data: IconThemeData(color: color, size: _style.trailingIconSize),
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
    }

    return null;
  }

  //
  Widget _selectedLine(Color color, {required Widget child}) {
    // get decoration if not null & set color if null
    final Decoration? decoration = switch (_style.selectedIndicator) {
      BoxDecoration d when d.color == null => d.copyWith(color: color),
      ShapeDecoration d when d.color == null => ShapeDecoration(
        color: color,
        shape: d.shape,
        shadows: d.shadows,
        gradient: d.gradient,
        image: d.image,
      ),
      _ => _style.selectedIndicator,
    };

    // selected line
    final Widget line = decoration != null
        ? Container(constraints: BoxConstraints.loose(_style.selectedIndicatorSize), decoration: decoration)
        : Container(
            constraints: BoxConstraints.loose(_style.selectedIndicatorSize),
            decoration: BoxDecoration(borderRadius: MenuConstants.borderRadius, color: color),
          );

    return Stack(alignment: .centerStart, children: [child, line]);
  }

  // the color of leading, title and trailing when selected or not
  Color _getChildColor(bool condition) {
    return condition
        ? _style.selectedColor ?? _style.selectedTitleStyle?.color ?? Colors.white
        : _style.color ?? _style.titleStyle?.color ?? Colors.white;
  }

  /// set [TileData.initiallyExpanded] is tile has children
  // void _seedInitiallyExpanded() {
  //   if (_hasSubtiles) {
  //     if (widget.tile.initiallyExpanded && !widget.openNodes.value.contains(_nodeKeyString)) {
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (!mounted) return;
  //         final updated = Set<String>.from(widget.openNodes.value)..add(_nodeKeyString);
  //         widget.openNodes.value = updated;
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();

    _nodeKey = widget.basePath;
    _nodeKeyString = _nodeKey.join('-');
    //
    tile = widget.tile;
    subTiles = tile.subTiles;
    _hasSubtiles = subTiles.isNotEmpty;
    _updateStyle(); // important it comes after tile and subtiles

    // Seed initial expansion once; afterwards openNodes is the sole source of truth.
    // _seedInitiallyExpanded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _updateStyle();
  }

  @override
  void didUpdateWidget(covariant SideMenuTile oldWidget) {
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
      // _seedInitiallyExpanded(); // new: re-seed since this is effectively a "new" tile at this slot
    } else if (!listEquals(oldWidget.tile.subTiles, widget.tile.subTiles)) {
      subTiles = tile.subTiles;
      _hasSubtiles = subTiles.isNotEmpty;
    }
    //
    if (oldWidget.tile.style != widget.tile.style) _updateStyle(); // important it comes after tile and subtiles
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    //
    final Decoration tileDecoration =
        (widget.isSelected ? _style.selectedDecoration : _style.decoration) ??
        ShapeDecoration(
          shape: RoundedRectangleBorder(borderRadius: _style.borderRadius),
          color: widget.isSelected ? _style.selectedBackgroundColor ?? colorScheme.secondaryContainer : _style.backgroundColor,
        );
    final Widget view = _createView();
    // Tooltip only built when menu is collapsed. Avoid building it eagerly when isMenuOpen (it won't be used).
    final Widget viewWithTooltip = widget.isMenuOpen
        ? view // skip tooltip construction entirely
        : Tooltip(
            message: tile.tooltip ?? tile.title,
            enableTapToDismiss: false,
            textStyle: TextStyle(color: colorScheme.onSurface, fontWeight: .w400),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha(233),
              borderRadius: _style.borderRadius,
              border: .all(color: colorScheme.onSurface, width: .3),
            ),
            positionDelegate: (position) {
              final double width = position.targetSize.width / 2 + widget.horizontalOffset, dx = position.target.dx;

              return Offset(
                Directionality.of(context) == .rtl ? dx - (position.tooltipSize.width + width) : dx + width,
                position.target.dy - position.tooltipSize.height / 2,
              );
            },
            constraints: BoxConstraints(minHeight: _style.tileHeight / 1.5),
            child: view,
          );
    final Widget singleTile = InkWell(
      onTap: () {
        tile.onTap?.call();

        // toggle opened or selected states
        if (_hasSubtiles) {
          widget.onToggle(_nodeKey);
        } else {
          widget.onSelectPath(_nodeKey);
        }
      },
      borderRadius: _style.borderRadius,
      hoverColor: _style.hoverColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
        height: _style.tileHeight,
        padding: _style.padding,
        decoration: tileDecoration,
        child: widget.isMenuOpen
            ? view
            : !_hasSubtiles
            ? viewWithTooltip
            : MenuTheme(
                data: MenuThemeData(
                  style: MenuTheme.of(context).style?.copyWith(
                    alignment: .topEnd,
                    elevation: .all(3),
                    side: .all(BorderSide(color: _anchorForegroundColor, width: .7)),
                    backgroundColor: .all(widget.anchorBackgroundColor),
                    padding: .all(const .symmetric(horizontal: _anchorHorizPadding, vertical: 7)),
                  ),
                  submenuIcon: .all(Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _anchorForegroundColor)),
                ),
                child: MenuAnchor(
                  controller: _menuController,
                  clipBehavior: .antiAlias,
                  menuChildren: _collapsedSubTiles(_anchorForegroundColor, _nodeKey),
                  alignmentOffset: Offset(widget.horizontalOffset, 0),
                  style: const MenuStyle(alignment: .topEnd),
                  child: InkWell(
                    borderRadius: _style.borderRadius,
                    onTap: () => _menuController.isOpen ? _menuController.close() : _menuController.open(),
                    child: viewWithTooltip,
                  ),
                ),
              ),
      ),
    );

    if (!_hasSubtiles) {
      return Padding(
        padding: _style.margin,
        child: Material(color: MenuConstants.transparent, child: singleTile),
      );
    }

    return Padding(
      padding: _style.margin,
      child: Material(
        color: MenuConstants.transparent,
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            // tile
            singleTile,
            // subtiles
            ValueListenableBuilder<Set<String>>(
              valueListenable: widget.openNodes,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _style.borderRadius,
                  border: BorderDirectional(
                    top: BorderSide(color: _style.color!, width: _style.selectedBorderWidth),
                    start: BorderSide(color: _style.color!, width: _style.selectedBorderWidth),
                  ),
                ),
                child: Padding(
                  padding: const .only(top: MenuConstants.tilesVerticalSpacing), // spacing between tile and sub-tiles
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    spacing: MenuConstants.tilesVerticalSpacing,
                    children: _subTiles(_nodeKey),
                  ),
                ),
              ),
              builder: (_, nodes, child) {
                // We set maintainState to true to keep sub-menus states (selected sub-tile and opened sub-menus)
                return Visibility(visible: widget.isMenuOpen && _isSubTileSelected(nodes), maintainState: true, child: child!);
              },
            ),
          ],
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
    properties.add(DiagnosticsProperty<List<int>>('basePath', _nodeKey));
    properties.add(DiagnosticsProperty<List<int>>('selectedPath', widget.selectedPath));
    // state
    properties.add(FlagProperty('isSelected', value: widget.isSelected, ifTrue: 'selected'));
    properties.add(FlagProperty('isMenuOpen', value: widget.isMenuOpen, ifTrue: 'open', ifFalse: 'collapsed'));
    properties.add(
      FlagProperty('_isSubTileSelected', value: _isSubTileSelected(widget.openNodes.value), ifTrue: 'subtile-expanded'),
    );
    // structure
    properties.add(IntProperty('subTileCount', subTiles.length));
    properties.add(IterableProperty<String>('openNodes', widget.openNodes.value));
    // layout
    properties.add(ColorProperty('sideMenuBackgroundColor', widget.anchorBackgroundColor));
    // style (only when available — style is assigned in build)
    if (mounted) {
      properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', _style.borderRadius, defaultValue: null));
      properties.add(DoubleProperty('tileHeight', _style.tileHeight));
      properties.add(ColorProperty('resolvedForegroundColor', _anchorForegroundColor));
    }
    // optional features
    properties.add(FlagProperty('hasBadge', value: tile.badgeBuilder != null, ifTrue: 'has badge'));
    properties.add(FlagProperty('hasSelectedIndicator', value: tile.hasSelectedIndicator, ifTrue: 'has indicator'));
    properties.add(FlagProperty('hasLeading', value: tile.leading != null, ifTrue: 'has leading'));
    properties.add(FlagProperty('hasTrailing', value: tile.trailing != null, ifTrue: 'has trailing'));
  }

  // coverage:ignore-end
}
