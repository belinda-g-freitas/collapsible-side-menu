import 'dart:async' show Timer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'enums/auto_open_from.dart';
import 'enums/menu_behaviour.dart';
import 'models/data/custom_menu_child.dart';
import 'models/data/side_menu_item.dart';
import 'models/side_menu_controller.dart';
import 'models/styles/menu_tile_style.dart';
import 'models/styles/side_menu_style.dart';
import 'models/styles/sub_menu_tile_style.dart';
import 'models/styles/toggle_button_style.dart';
import 'side_menu_state_mixin.dart';
import 'utils/menu_constants.dart';
import 'widgets/colored_content.dart';
import 'widgets/side_menu_divider.dart';
import 'widgets/side_menu_tile.dart';
import 'widgets/side_menu_title.dart';
import 'widgets/toggle_button.dart';

/// Signature for the `header` and `footer` widgets
///
/// It exposes the menu state (opened/collapsed);
/// in case you want to adapt the header or footer but also don't want to use a [controller]
typedef MenuHeaderBuilder = Widget Function(BuildContext context, bool isOpen);

@immutable
class _SelectionState {
  const _SelectionState({this.index, this.path = const []});

  /// Current selected index
  final int? index;

  /// Path to detect which sub-tile is active
  final List<int> path;

  @override
  bool operator ==(covariant _SelectionState other) {
    if (identical(this, other)) return true;

    return other.index == index && listEquals(other.path, path);
  }

  @override
  int get hashCode => Object.hash(index, Object.hashAll(path));
}

//
class CollapsibleSideMenu extends StatefulWidget {
  const CollapsibleSideMenu({
    super.key,
    this.header,
    this.footer,
    this.customMenuChild,
    this.items = const [],
    this.spacerAfterItems,
    this.onIndexChanged,
    this.controller,
    this.defaultBehaviour = .auto,
    this.autoFrom = .tablet,
    this.minWidth = MenuConstants.minWidth,
    this.maxWidth = MenuConstants.maxWidth,
    this.hasToggleButton = true,
    this.toggleButtonStyle,
    this.duration = MenuConstants.duration,
    this.animationCurve = Curves.linear,
    this.menuStyle,
    this.defaultIndex,
  }) : assert(minWidth >= 0.0),
       assert(maxWidth > minWidth),
       assert(toggleButtonStyle != null ? hasToggleButton : true);

  /// Menu header widget
  final MenuHeaderBuilder? header;

  /// Menu footer widget
  final MenuHeaderBuilder? footer;

  /// Menu custom child
  ///
  /// You are responsible of making it fit whatever the menu state
  final CustomMenuChild? customMenuChild;

  /// Menu elements
  final List<SideMenuItem> items;

  /// A spacer to insert after items
  final Spacer? spacerAfterItems;

  /// Notifeier on selected index changes
  final ValueChanged<int>? onIndexChanged;

  /// Menu controller
  final SideMenuController? controller;

  /// Menu state on init or when screen width changes
  ///
  /// If [MenuBehaviour.auto], the menu opens when the screen is wide enough and collapse when the screen is narrow.
  ///
  /// If [MenuBehaviour.collapse], the menu collapses on screen width changes.
  /// Menu width is [minWidth] then.
  ///
  /// If [MenuBehaviour.open], the menu opens on screen width changes.
  /// Menu width is [maxWidth] then.
  final MenuBehaviour defaultBehaviour;

  /// [AutoOpenFrom.tablet], opens menu from tablets breakpoint width
  ///
  /// [AutoOpenFrom.desktop], opens menu from desktop breakpoint width
  final AutoOpenFrom autoFrom;

  /// Menu min width (when collapsed)
  final double minWidth;

  /// Menu max width (when open)
  final double maxWidth;

  /// Whether to show the toggle button on the menu
  final bool hasToggleButton;

  /// Set only if [hasToggleButton] is true, else it will throw
  final ToggleButtonStyle? toggleButtonStyle;

  /// Menu state animation duration
  final Duration duration;

  /// The open/collapse animation curve
  final Curve animationCurve;

  /// Menu look
  final SideMenuStyle? menuStyle;

  /// The default selected index if [items] is not empty and [items.length] > [defaultIndex]
  final int? defaultIndex;

  @override
  State<CollapsibleSideMenu> createState() => _CollapsibleSideMenuState();
}

class _CollapsibleSideMenuState extends State<CollapsibleSideMenu> with SideMenuStateMixin {
  late MenuTileStyle _defaultStyle;
  late SideMenuStyle _menuStyle;
  late Color _backgroundColor, _unselectedColor;
  late List<SideMenuItem> _items;
  late double _lastWidth;
  late Decoration _decoration;
  late bool _isMenuOpen;
  late final ValueNotifier<_SelectionState> _selection;
  final ValueNotifier<Set<String>> _openNodes = ValueNotifier({});
  static const _debounceDuration = Duration(milliseconds: 110);
  Timer? _resizeDebounce;
  bool _isWidthInitialized = false, _derivedValuesInitialized = false;

  //
  void onSelect(int rootIndex, List<int> path) {
    _selection.value = _SelectionState(index: rootIndex, path: path);
    widget.onIndexChanged?.call(rootIndex);
  }

  void _toggleNode(List<int> path) {
    final key = path.join('-');
    final updated = Set<String>.from(_openNodes.value);

    updated.contains(key) ? updated.remove(key) : updated.add(key);
    _openNodes.value = updated; // no setState, only SideMenuTile listeners rebuild
  }

  void _openMenu() {
    if (!_isMenuOpen) setState(() => _isMenuOpen = true);
  }

  void _closeMenu() {
    if (_isMenuOpen) setState(() => _isMenuOpen = false);
  }

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void _getMenuState(double width) {
    _isMenuOpen = openMenuState(behaviour: widget.defaultBehaviour, from: widget.autoFrom, deviceWidth: width);
  }

  void _setMenuState(double width) {
    _lastWidth = width;
    _getMenuState(_lastWidth);
  }

  void _setDecoration() {
    _decoration = BoxDecoration(color: _backgroundColor, boxShadow: [?_menuStyle.boxShadow], borderRadius: _menuStyle.borderRadius);
  }

  void _attachController(SideMenuController controller) {
    controller.open = _openMenu;
    controller.close = _closeMenu;
    controller.toggle = _toggleMenu;
    controller.isCollapsed = () => !_isMenuOpen;
  }

  void _recomputeDerivedValues() {
    final colorScheme = ColorScheme.of(context);
    final newBg = _menuStyle.backgroundColor ?? colorScheme.primary;
    if (_derivedValuesInitialized && newBg == _backgroundColor) return; // too avoid rebuilding widgets when not needed

    _derivedValuesInitialized = true;
    _backgroundColor = newBg;
    _unselectedColor = _getUnSelectedColor(colorScheme.onPrimary);
    _defaultStyle = MenuTileStyle(
      hoverColor: colorScheme.onSecondaryContainer,
      color: _unselectedColor,
      selectedColor: ThemeData.estimateBrightnessForColor(colorScheme.inversePrimary) == .light ? Colors.black : Colors.white,
      titleStyle: const TextStyle(fontSize: 13.7),
      selectedTitleStyle: const TextStyle(fontSize: 13.7, fontWeight: .w500),
      subTileStyle: SubMenuTileStyle(
        hoverColor: colorScheme.onSecondaryContainer,
        color: _getUnSelectedColor(colorScheme.onSecondary),
        selectedColor: colorScheme.onSecondaryContainer,
        titleStyle: const TextStyle(fontSize: 12.3),
        selectedTitleStyle: const TextStyle(fontSize: 12.3, fontWeight: .w500),
        decoration: const BoxDecoration(borderRadius: MenuConstants.borderRadius),
        selectedDecoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: MenuConstants.borderRadius),
      ),
      selectedBackgroundColor: colorScheme.inversePrimary,
      decoration: const BoxDecoration(borderRadius: MenuConstants.borderRadius),
      selectedDecoration: BoxDecoration(color: colorScheme.inversePrimary, borderRadius: MenuConstants.borderRadius),
    );
    _setDecoration();
  }

  //
  Widget _content(bool isOpen) {
    final content = Padding(
      padding: _menuStyle.margin,
      child: DecoratedBox(
        decoration: _decoration,
        child: Padding(
          padding: _menuStyle.padding,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: isOpen ? widget.maxWidth : widget.minWidth),
            duration: widget.duration,
            curve: widget.animationCurve,
            child: _body(isOpen),
            builder: (_, width, child) => SizedBox(width: width, child: child),
          ),
        ),
      ),
    );

    // set directionality
    return Directionality(textDirection: _menuStyle.textDirection ?? Directionality.of(context), child: content);
  }

  Widget _buildMenuItem({required SideMenuItem tile, required int currentIndex, int? selectedIndex, required List<int> path, required bool isOpen}) {
    final isSelected = currentIndex == selectedIndex;

    switch (tile) {
      case (TitleData _):
        return SideMenuTitle(data: tile, color: _unselectedColor);

      case (DividerData _):
        return SideMenuDivider(data: tile);

      case (TileData _):
        final MenuTileStyle defaultStyle = _menuStyle.defaultTileStyle?.resolveWith(_defaultStyle) ?? _defaultStyle;
        final MenuTileStyle style = tile.style?.resolveWith(defaultStyle) ?? defaultStyle;

        return RepaintBoundary(
          child: SideMenuTile(
            key: ValueKey(tile.id ?? 'tile_$currentIndex'),
            minWidth: widget.minWidth,
            isMenuOpen: isOpen,
            isSelected: isSelected,
            tile: tile.copyWith(style: style),
            sideMenuBackgroundColor: _backgroundColor,
            // path handling
            basePath: [currentIndex],
            selectedPath: isSelected ? path : [],
            onSelectPath: (path) => onSelect(currentIndex, path),
            onToggle: _toggleNode,
            openNodes: _openNodes,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _body(bool isOpen) {
    final CustomMenuChild? customChild = widget.customMenuChild;
    final Color color = _unselectedColor;
    final List<Widget> customMenuChild = [
      if (customChild != null)
        Expanded(
          flex: customChild.childFlex,
          child: ColoredContent(key: const Key('customChild'), color: color, child: customChild.child),
        ),
      ?customChild?.spacerAfterChild,
    ];

    return Column(
      mainAxisSize: .max,
      children: [
        // header
        if (widget.header != null)
          RepaintBoundary(
            child: ColoredContent(key: const Key('header'), color: color, child: widget.header?.call(context, isOpen)),
          ),

        // custom child above items
        if (customChild?.childPosition == .aboveItems) ...customMenuChild,

        // items
        if (_items.isNotEmpty) ...[
          Expanded(
            child: ValueListenableBuilder<_SelectionState>(
              valueListenable: _selection,
              builder: (_, selection, _) {
                return ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    return _buildMenuItem(tile: _items[i], currentIndex: i, selectedIndex: selection.index, path: selection.path, isOpen: isOpen);
                  },
                  addAutomaticKeepAlives: false,
                  addSemanticIndexes: false,
                );
              },
            ),
          ),
          ?widget.spacerAfterItems,
        ],

        // custom child below items
        if (customChild?.childPosition == .belowItems) ...customMenuChild,

        // footer
        if (widget.header != null)
          RepaintBoundary(
            child: ColoredContent(key: const Key('footer'), color: color, child: widget.footer?.call(context, isOpen)),
          ),
      ],
    );
  }

  Widget _hasToggleButton({required Widget child, required bool isOpen}) {
    return Stack(
      alignment: .centerEnd,
      children: [
        child,
        ToggleButton(style: widget.toggleButtonStyle, duration: widget.duration, isOpen: isOpen, onTap: _toggleMenu),
      ],
    );
  }

  Color _getUnSelectedColor(Color replacement) {
    final Color? bg = _menuStyle.backgroundColor;

    if (bg != null) return ThemeData.estimateBrightnessForColor(bg) == .dark ? Colors.white : Colors.black;
    return replacement;
  }

  //
  @override
  void initState() {
    super.initState();

    _menuStyle = widget.menuStyle ?? SideMenuStyle();
    _selection = ValueNotifier(_SelectionState(index: widget.defaultIndex));
    if (widget.controller != null) _attachController(widget.controller!);
    _items = widget.items;
  }

  @override
  void didChangeDependencies() {
    _recomputeDerivedValues();

    final width = MediaQuery.widthOf(context);
    if (!_isWidthInitialized) {
      _isWidthInitialized = true;
      _setMenuState(width);
    }
    //
    if (_lastWidth != width) {
      _isWidthInitialized = true;

      _resizeDebounce?.cancel();
      _resizeDebounce = Timer(_debounceDuration, () {
        if (!mounted) return;
        _setMenuState(width);
        setState(() {});
      });
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant CollapsibleSideMenu oldWidget) {
    final width = MediaQuery.widthOf(context);
    if (_lastWidth != width || oldWidget.defaultBehaviour != widget.defaultBehaviour) {
      _setMenuState(width);
    }
    // set menu style
    if (oldWidget.menuStyle != widget.menuStyle) {
      _menuStyle = widget.menuStyle ?? SideMenuStyle();
      if (oldWidget.menuStyle?.boxShadow != widget.menuStyle?.boxShadow) _setDecoration();
    }
    // set controller
    if (oldWidget.controller != widget.controller && widget.controller != null) _attachController(widget.controller!);
    // set default values
    if (oldWidget.menuStyle != widget.menuStyle) _recomputeDerivedValues();
    //
    if (oldWidget.items != widget.items) _items = widget.items;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.defaultIndex == null || (widget.defaultIndex! < _items.length),
      'defaultIndex (${widget.defaultIndex}) is out of range for items.length (${_items.length})',
    );
    final bool isOpen = _isMenuOpen;
    final child = SafeArea(child: RepaintBoundary(child: _content(isOpen)));

    if (widget.hasToggleButton) return _hasToggleButton(child: child, isOpen: isOpen);
    return child;
  }

  @override
  void dispose() {
    _selection.dispose();
    _openNodes.dispose();
    _resizeDebounce?.cancel();

    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(FlagProperty('hasToggleButton', value: widget.hasToggleButton, ifTrue: 'toggle enabled', ifFalse: 'toggle disabled'))
      ..add(EnumProperty<MenuBehaviour>('defaultBehaviour', widget.defaultBehaviour))
      ..add(EnumProperty<AutoOpenFrom>('autoFrom', widget.autoFrom))
      ..add(DoubleProperty('minWidth', widget.minWidth))
      ..add(DoubleProperty('maxWidth', widget.maxWidth))
      ..add(DoubleProperty('currentWidth', _isMenuOpen ? widget.maxWidth : widget.minWidth))
      ..add(IntProperty('selectedIndex', _selection.value.index))
      ..add(IterableProperty<int>('selectedPath', _selection.value.path))
      ..add(IntProperty('openNodesCount', _openNodes.value.length))
      ..add(DiagnosticsProperty<Duration>('duration', widget.duration))
      ..add(DiagnosticsProperty<Curve>('animationCurve', widget.animationCurve))
      ..add(ColorProperty('backgroundColor', _backgroundColor))
      ..add(DiagnosticsProperty<SideMenuStyle>('menuStyle', _menuStyle))
      ..add(ObjectFlagProperty<SideMenuController>.has('controller', widget.controller))
      ..add(IntProperty('defaultIndex', widget.defaultIndex))
      ..add(FlagProperty('isOpen', value: _isMenuOpen, ifTrue: 'opened', ifFalse: 'collapsed'));
  }
}
