import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'enums/menu_behaviour.dart';
import 'models/data/side_menu_builder_data.dart';
import 'models/data/side_menu_data.dart';
import 'models/data/side_menu_item_data.dart';
import 'models/side_menu_controller.dart';
import 'models/styles/menu_tile_style.dart';
import 'models/styles/side_menu_style.dart';
import 'models/styles/sub_menu_tile_style.dart';
import 'models/styles/toggle_button_style.dart';
import 'side_menu_width_mixin.dart';
import 'utils/menu_constants.dart';
import 'widgets/colored_content.dart';
import 'widgets/side_menu_divider.dart';
import 'widgets/side_menu_tile.dart';
import 'widgets/side_menu_title.dart';
import 'widgets/toggle_button.dart';

typedef SideMenuBuilder = SideMenuData Function(BuildContext context, SideMenuBuilderData data);

class _SelectionState {
  const _SelectionState({this.index, this.path = const []});

  final int? index;
  final List<int> path;
}

//
class SideMenu extends StatefulWidget {
  const SideMenu({
    super.key,
    required this.builder,
    this.controller,
    this.defaultBehaviour = .auto,
    this.minWidth = MenuConstants.minWidth,
    this.maxWidth = MenuConstants.maxWidth,
    this.hasToggleButton = true,
    this.toggleButtonStyle,
    this.duration = MenuConstants.duration,
    this.menuStyle,
    this.defaultIndex,
  }) : assert(minWidth >= 0.0),
       assert(maxWidth > minWidth),
       assert(toggleButtonStyle != null ? hasToggleButton : true);

  final SideMenuBuilder builder;
  final SideMenuController? controller;
  final MenuBehaviour defaultBehaviour;
  final double minWidth;
  final double maxWidth;
  final bool hasToggleButton;

  /// Set only if [hasToggleButton] is true, else it will throw
  final ToggleButtonStyle? toggleButtonStyle;
  final Duration duration;
  final SideMenuStyle? menuStyle;

  /// the default selected index if [items] != null and [items.length] > [defaultIndex]
  final int? defaultIndex;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> with SideMenuWidthMixin {
  late MenuTileStyle _defaultStyle;
  late SideMenuStyle _menuStyle;
  late Color _backgroundColor, _unselectedColor;
  double _currentWidth = MenuConstants.zeroWidth;
  bool _userHasOverridden = false;
  // int? _selectedIndex;
  // List<int> selectedPath = [];
  final Set<String> openNodes = {};
  // final ValueNotifier<int?> _selectedIndex = ValueNotifier(null);
  late final ValueNotifier<_SelectionState> _selection; // = ValueNotifier(const _SelectionState());

  void onSelect(int rootIndex, List<int> path) {
    _selection.value = _SelectionState(index: rootIndex, path: path);
    // setState(() {
    //   _selectedIndex.value = rootIndex;
    //   selectedPath = path;
    // });
  }

  void _toggleNode(List<int> path) {
    final key = path.join('-');

    setState(() => openNodes.contains(key) ? openNodes.remove(key) : openNodes.add(key));
  }

  bool get _isMenuCollapsed => _currentWidth == widget.minWidth;

  bool get _isMenuOpen => _currentWidth == widget.maxWidth;

  void _openMenu() {
    _userHasOverridden = true;
    setState(() => _currentWidth = widget.maxWidth);
  }

  void _closeMenu() {
    _userHasOverridden = true;
    setState(() => _currentWidth = widget.minWidth);
  }

  void _toggleMenu() {
    _userHasOverridden = true;
    setState(() => _currentWidth = _isMenuCollapsed ? widget.maxWidth : widget.minWidth);
  }

  void _calculateMenuWidthSize() {
    if (_userHasOverridden) return;
    
    final width = calculateWidthSize(
      minWidth: widget.minWidth,
      maxWidth: widget.maxWidth,
      currentWidth: _currentWidth,
      behaviour: widget.defaultBehaviour,
      deviceWidth: MediaQuery.widthOf(context),
    );

    if (width != _currentWidth) setState(() => _currentWidth = width);
  }

  void _attachController(SideMenuController controller) {
    controller.open = _openMenu;
    controller.close = _closeMenu;
    controller.toggle = _toggleMenu;
    controller.isCollapsed = _isMenuCollapsed;
  }

  void _recomputeDerivedValues() {
    final colorScheme = ColorScheme.of(context);
    _backgroundColor = _menuStyle.backgroundColor ?? colorScheme.primary;
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
  }

  @override
  void initState() {
    _menuStyle = widget.menuStyle ?? SideMenuStyle();
    _selection = ValueNotifier(_SelectionState(index: widget.defaultIndex));
    if (widget.controller != null) _attachController(widget.controller!);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // _calculateMenuWidthSize();
    _recomputeDerivedValues();

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SideMenu oldWidget) {
    if (oldWidget.defaultBehaviour != widget.defaultBehaviour || oldWidget.minWidth != widget.minWidth || oldWidget.maxWidth != widget.maxWidth) {
      _userHasOverridden = false;
      _calculateMenuWidthSize();
    }
    //
    if (oldWidget.menuStyle != widget.menuStyle) {
      _menuStyle = widget.menuStyle ?? SideMenuStyle();
    }
    //
    if (oldWidget.controller != widget.controller && widget.controller != null) {
      _attachController(widget.controller!);
    }
    //
    if (oldWidget.menuStyle != widget.menuStyle) {
      _recomputeDerivedValues();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool isOpen = _isMenuOpen;
    final child = _content(isOpen);

    if (widget.hasToggleButton) return _hasToggleButton(child: child, isOpen: isOpen);
    return child;
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(FlagProperty('hasToggleButton', value: widget.hasToggleButton, ifTrue: 'toggle enabled', ifFalse: 'toggle disabled'))
      ..add(EnumProperty<MenuBehaviour>('defaultBehaviour', widget.defaultBehaviour))
      ..add(DoubleProperty('minWidth', widget.minWidth))
      ..add(DoubleProperty('maxWidth', widget.maxWidth))
      ..add(DoubleProperty('currentWidth', _currentWidth))
      ..add(IntProperty('selectedIndex', _selection.value.index))
      ..add(IterableProperty<int>('selectedPath', _selection.value.path))
      ..add(IntProperty('openNodesCount', openNodes.length))
      ..add(DiagnosticsProperty<Duration>('duration', widget.duration))
      ..add(ColorProperty('backgroundColor', _backgroundColor))
      ..add(DiagnosticsProperty<SideMenuStyle>('menuStyle', _menuStyle))
      ..add(ObjectFlagProperty<SideMenuController>.has('controller', widget.controller))
      ..add(IntProperty('defaultIndex', widget.defaultIndex))
      ..add(FlagProperty('isCollapsed', value: _isMenuCollapsed, ifTrue: 'collapsed', ifFalse: 'expanded'))
      ..add(FlagProperty('isOpen', value: _isMenuOpen, ifTrue: 'open', ifFalse: 'closed'));
  }

  Widget _content(bool isOpen) {
    final size = MediaQuery.sizeOf(context);

    final content = AnimatedContainer(
      duration: widget.duration,
      width: _currentWidth,
      margin: _menuStyle.margin,
      padding: _menuStyle.padding,
      decoration: BoxDecoration(color: _backgroundColor, boxShadow: [?_menuStyle.boxShadow], borderRadius: _menuStyle.borderRadius),
      constraints: BoxConstraints(minHeight: size.height, maxHeight: size.height, minWidth: widget.minWidth, maxWidth: widget.maxWidth),
      child: _body(isOpen),
    );

    if (_menuStyle.textDirection != null) {
      return Directionality(textDirection: widget.menuStyle!.textDirection!, child: content);
    }

    return content;
  }

  Widget _buildMenuItem({required SideMenuItemData tile, required int currentIndex, int? selectedIndex, required bool isOpen}) {
    final isSelected = currentIndex == selectedIndex;

    switch (tile) {
      case (SideMenuTitleData _):
        return SideMenuTitle(data: tile, color: _unselectedColor);

      case (SideMenuDividerData _):
        return SideMenuDivider(data: tile);

      case (SideMenuTileData _):
        final MenuTileStyle defaultStyle = _menuStyle.defaultTileStyle?.resolveWith(_defaultStyle) ?? _defaultStyle;
        final MenuTileStyle style = tile.style?.resolveWith(defaultStyle) ?? defaultStyle;

        return SideMenuTile(
          key: ValueKey('tile_$currentIndex'),
          minWidth: widget.minWidth,
          isMenuOpen: isOpen,
          isSelected: isSelected,
          tile: tile.copyWith(style: style),
          sideMenuBackgroundColor: _backgroundColor,
          // path handling
          basePath: [currentIndex],
          selectedPath: isSelected ? _selection.value.path : [],
          onSelectPath: (path) => onSelect(currentIndex, path),
          onToggle: _toggleNode,
          openNodes: openNodes,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _body(bool isOpen) {
    final SideMenuData data = _builder(isOpen);
    assert(
      widget.defaultIndex == null || (data.items != null && widget.defaultIndex! < data.items!.length),
      'defaultIndex (${widget.defaultIndex}) is out of range for items.length (${data.items?.length ?? 0})',
    );
    final items = data.items;
    final Color color = _unselectedColor;
    final List<Widget> customChild = [
      if (data.customChild != null)
        Expanded(
          flex: data.customChildFlex,
          child: ColoredContent(key: const Key('customChild'), color: color, child: data.customChild!),
        ),
      ?data.spacerAfterCustomChild,
    ];

    return Column(
      mainAxisSize: .max,
      children: [
        // header
        if (data.header != null) ColoredContent(key: const Key('header'), color: color, child: data.header!),

        // custom child above items
        if (data.customChildPosition == .aboveItems) ...customChild,

        // items
        if (items != null)
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _selection,
              builder: (_, selection, _) {
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => _buildMenuItem(tile: items[i], currentIndex: i, selectedIndex: selection.index, isOpen: isOpen),
                  addAutomaticKeepAlives: false,
                  addSemanticIndexes: false,
                );
              },
            ),
          ),
        ?data.spacerAfterItems,

        // custom child below items
        if (data.customChildPosition == .belowItems) ...customChild,

        // footer
        if (data.footer != null) ColoredContent(key: const Key('footer'), color: color, child: data.footer!),
      ],
    );
  }

  SideMenuData _builder(bool isOpen) {
    return widget.builder(
      context,
      SideMenuBuilderData(
        currentWidth: _currentWidth,
        isOpen: isOpen,
        textDirection: _menuStyle.textDirection ?? Directionality.of(context),
        selectedIndex: _selection.value.index,
      ),
    );
  }

  Widget _hasToggleButton({required Widget child, required bool isOpen}) {
    final textDirection = _menuStyle.textDirection ?? Directionality.of(context);

    return Stack(
      alignment: textDirection == .ltr ? .centerEnd : .centerStart,
      children: [
        child,
        ToggleButton(style: widget.toggleButtonStyle, textDirection: textDirection, isOpen: isOpen, onTap: _toggleMenu),
      ],
    );
  }

  Color _getUnSelectedColor(Color replacement) {
    final bg = _menuStyle.backgroundColor;

    if (bg != null) return ThemeData.estimateBrightnessForColor(bg) == .dark ? Colors.white : Colors.black;
    return replacement;
  }
}
