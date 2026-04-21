import 'package:flutter/material.dart';

import 'enums/menu_behaviour.dart';
import 'models/data/side_menu_builder_data.dart';
import 'models/data/side_menu_data.dart';
import 'models/data/side_menu_item_animation_data.dart';
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

typedef SideMenuBuilder = SideMenuData Function(SideMenuBuilderData data, int? selectedIndex);

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
  late Color _backgroundColor;
  double _currentWidth = MenuConstants.zeroWidth;
  int? _selectedIndex;
  List<int> selectedPath = [];
  final Set<String> openNodes = {};

  @override
  void initState() {
    if (widget.controller != null) {
      widget.controller!.open = _openMenu;
      widget.controller!.close = _closeMenu;
      widget.controller!.toggle = _toggleMenu;
      widget.controller!.isCollapsed = _isMenuCollapsed;
    }

    super.initState();
  }


  void onSelect(int rootIndex, List<int> path) {
    setState(() {
      _selectedIndex = rootIndex;
      selectedPath = path;
    });
  }

  void toggleNode(List<int> path) {
    final key = path.join('-');

    setState(() {
      if (openNodes.contains(key)) {
        openNodes.remove(key);
      } else {
        openNodes.add(key);
      }
    });
  }

  bool _isMenuCollapsed() => _currentWidth == widget.minWidth;

  bool _isMenuOpen() => _currentWidth != widget.minWidth;

  void _openMenu() => setState(() => _currentWidth = widget.maxWidth);

  void _closeMenu() => setState(() => _currentWidth = widget.minWidth);

  void _toggleMenu() => setState(() => _currentWidth = _currentWidth == widget.minWidth ? widget.maxWidth : widget.minWidth);

  @override
  void didUpdateWidget(covariant SideMenu oldWidget) {
    if (oldWidget.defaultBehaviour != widget.defaultBehaviour || oldWidget.minWidth != widget.minWidth || oldWidget.maxWidth != widget.maxWidth) {
      _calculateMenuWidthSize();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _calculateMenuWidthSize();

    super.didChangeDependencies();
  }

  void _calculateMenuWidthSize() {
    final width = calculateWidthSize(
      minWidth: widget.minWidth,
      maxWidth: widget.maxWidth,
      currentWidth: _currentWidth,
      behaviour: widget.defaultBehaviour,
      deviceWidth: MediaQuery.widthOf(context),
    );

    if (width != _currentWidth) _currentWidth = width;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    _backgroundColor = widget.menuStyle?.backgroundColor ?? colorScheme.primary;
    _defaultStyle = MenuTileStyle(
      hoverColor: colorScheme.onSecondaryContainer,
      color: _getUnSelectedColor(colorScheme.onPrimary),
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
    final child = _content();

    if (widget.hasToggleButton) return _hasToggleButton(child: child);
    return child;
  }

  Widget _content() {
    final size = MediaQuery.sizeOf(context);

    final content = AnimatedContainer(
      duration: widget.duration,
      width: _currentWidth,
      margin: widget.menuStyle?.margin,
      padding: widget.menuStyle?.padding,
      decoration: BoxDecoration(color: _backgroundColor, boxShadow: [?widget.menuStyle?.boxShadow], borderRadius: widget.menuStyle?.borderRadius),
      constraints: BoxConstraints(minHeight: size.height, maxHeight: size.height, minWidth: widget.minWidth, maxWidth: widget.maxWidth),
      child: _body(),
    );

    if (widget.menuStyle?.textDirection != null) {
      return Directionality(textDirection: widget.menuStyle!.textDirection!, child: content);
    }

    return content;
  }

  Widget _buildAnimatedPart({required SideMenuItemAnimationData? animData, required Widget child}) {
    if (animData != null) {
      return AnimatedScale(scale: _isMenuOpen() ? 1 : animData.mainScale, duration: animData.duration, child: child);
    }

    return child;
  }

  Widget _buildMenuItem(SideMenuItemData tile, int currentIndex) {
    switch (tile) {
      case (SideMenuTitleData _):
        return SideMenuTitle(data: tile, color: _getUnSelectedColor(ColorScheme.of(context).onPrimary));

      case (SideMenuDividerData _):
        return SideMenuDivider(data: tile);

      case (SideMenuTileData _):
        final MenuTileStyle defaultStyle = widget.menuStyle?.defaultTileStyle?.resolveWith(_defaultStyle) ?? _defaultStyle;
        final MenuTileStyle style = tile.style?.resolveWith(defaultStyle) ?? defaultStyle;

        return SideMenuTile(
          key: ValueKey('tile_$currentIndex'),
          minWidth: widget.minWidth,
          isMenuOpen: _isMenuOpen(),
          isSelected: currentIndex == _selectedIndex,
          tile: tile.copyWith(style: style),
          sideMenuBackgroundColor: _backgroundColor,
          // path handling
          basePath: [currentIndex],
          selectedPath: _selectedIndex == currentIndex ? selectedPath : [],
          onSelectPath: (path) => onSelect(currentIndex, path),
          onToggle: toggleNode,
          openNodes: openNodes
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _body() {
    final SideMenuData data = _builder();
    final Color color = _getUnSelectedColor(ColorScheme.of(context).onPrimary);
    final List<Widget> customChild = [
      if (data.customChild != null)
        Expanded(
          flex: data.customChildFlex,
          child: _buildAnimatedPart(
            animData: data.animCustomChild,
            child: ColoredContent(color: color, child: data.customChild!),
          ),
        ),
      ?data.spacerAfterCustomChild,
    ];
    if (_selectedIndex == null && (data.items?.length ?? 0) > (widget.defaultIndex ?? 0)) {
      _selectedIndex = widget.defaultIndex;
    }

    return Column(
      mainAxisSize: .max,
      children: [
        // header
        if (data.header != null)
          _buildAnimatedPart(
            animData: data.animHeader,
            child: ColoredContent(color: color, child: data.header!),
          ),

        // custom child above items
        if (data.customChildPosition == .aboveItems) ...customChild,

        // items
        if (data.items != null)
          Expanded(
            child: _buildAnimatedPart(
              animData: data.animItems,
              child: ListView.builder(itemCount: data.items!.length, itemBuilder: (_, i) => _buildMenuItem(data.items![i], i)),
            ),
          ),
        ?data.spacerAfterItems,

        // custom child below items
        if (data.customChildPosition == .belowItems) ...customChild,

        // footer
        if (data.footer != null)
          _buildAnimatedPart(
            animData: data.animFooter,
            child: ColoredContent(color: color, child: data.footer!),
          ),
      ],
    );
  }

  SideMenuData _builder() {
    return widget.builder(
      SideMenuBuilderData(
        currentWidth: _currentWidth,
        minWidth: widget.minWidth,
        maxWidth: widget.maxWidth,
        isOpen: _isMenuOpen(),
        textDirection: widget.menuStyle?.textDirection ?? Directionality.of(context),
      ),
      _selectedIndex,
    );
  }

  Widget _hasToggleButton({required Widget child}) {
    final textDirection = widget.menuStyle?.textDirection ?? Directionality.of(context);

    return Stack(
      alignment: textDirection == .ltr ? .centerEnd : .centerStart,
      children: [
        child,
        ToggleButton(style: widget.toggleButtonStyle, textDirection: textDirection, isOpen: _isMenuOpen(), onTap: () => _toggleMenu()),
      ],
    );
  }

  Color _getUnSelectedColor(Color replacement) {
    return widget.menuStyle?.backgroundColor != null
        ? ThemeData.estimateBrightnessForColor(widget.menuStyle!.backgroundColor!) == .dark
              ? Colors.white
              : Colors.black
        : replacement;
  }
}
