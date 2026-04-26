import 'package:flutter/material.dart' show Divider, EdgeInsetsGeometry, Size, TextAlign, TextStyle, VoidCallback, Widget;

import '../../utils/menu_constants.dart';
import '../styles/menu_tile_style.dart';
import '../styles/sub_menu_tile_style.dart';

typedef TileBadgeBuilder = Widget? Function(Widget tile);

mixin _BaseSideMenuData {
  String get title;
  Widget? get leading;
  Widget? get selectedLeading;
  Widget? get trailing;
  TileBadgeBuilder? get badgeBuilder;
  VoidCallback? get onTap;
}

//
sealed class SideMenuItemData {
  const SideMenuItemData();
}

class SideMenuTitleData extends SideMenuItemData {
  const SideMenuTitleData({required this.title, this.titleStyle, this.textAlign, this.padding});

  final String title;
  final TextStyle? titleStyle;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? padding;

  @override
  String toString() {
    return 'SideMenuTitleData(title: $title, titleStyle: $titleStyle, textAlign: $textAlign, padding: $padding)';
  }
}

class SideMenuDividerData extends SideMenuItemData {
  const SideMenuDividerData({this.divider = const Divider(), this.padding}) : super();

  final Widget divider;
  final EdgeInsetsGeometry? padding;

  SideMenuDividerData copyWith({Widget? divider, EdgeInsetsGeometry? padding}) {
    return SideMenuDividerData(divider: divider ?? this.divider, padding: padding ?? this.padding);
  }

  @override
  String toString() => 'SideMenuDividerData(divider: $divider, padding: $padding)';
}

class SideMenuTileData extends SideMenuItemData with _BaseSideMenuData {
  @override
  final String title;

  @override
  final Widget? leading;

  @override
  final Widget? selectedLeading;

  @override
  final Widget? trailing;
  @override
  final TileBadgeBuilder? badgeBuilder;

  @override
  final VoidCallback? onTap;

  final Size selectedIndicatorSize;
  final bool hasSelectedIndicator;
  final MenuTileStyle? style;
  final List<SideMenuSubTileData> subTiles;

  SideMenuTileData({
    required this.title,
    this.leading,
    this.selectedLeading,
    this.trailing,
    this.style,
    this.subTiles = const [],
    this.badgeBuilder,
    this.onTap,
    this.selectedIndicatorSize = const Size(MenuConstants.selectedIndicatorWidth, MenuConstants.selectedIndicatorHeight),
    this.hasSelectedIndicator = true,
  });

  SideMenuTileData resolveWith([final MenuTileStyle? style]) {
    return SideMenuTileData(
      title: title,
      leading: leading,
      trailing: trailing,
      selectedLeading: selectedLeading,
      style: this.style ?? style,
      subTiles: subTiles,
      badgeBuilder: badgeBuilder,
      onTap: onTap,
      selectedIndicatorSize: selectedIndicatorSize,
      hasSelectedIndicator: hasSelectedIndicator,
    );
  }

  SideMenuTileData copyWith({
    String? title,
    Widget? leading,
    Widget? selectedLeading,
    Widget? trailing,
    MenuTileStyle? style,
    List<SideMenuSubTileData>? subTiles,
    TileBadgeBuilder? badgeBuilder,
    VoidCallback? onTap,
    Size? selectedIndicatorSize,
    bool? hasSelectedIndicator,
  }) {
    return SideMenuTileData(
      title: title ?? this.title,
      leading: leading ?? this.leading,
      selectedLeading: selectedLeading ?? this.selectedLeading,
      trailing: trailing ?? this.trailing,
      style: style ?? this.style,
      subTiles: subTiles ?? this.subTiles,
      badgeBuilder: badgeBuilder ?? this.badgeBuilder,
      onTap: onTap ?? this.onTap,
      selectedIndicatorSize: selectedIndicatorSize ?? this.selectedIndicatorSize,
      hasSelectedIndicator: hasSelectedIndicator ?? this.hasSelectedIndicator,
    );
  }

  @override
  String toString() {
    return 'SideMenuTileData(title: $title, leading: $leading, selectedLeading: $selectedLeading, trailing: $trailing, badgeBuilder: $badgeBuilder, onTap: $onTap, selectedIndicatorSize: $selectedIndicatorSize, hasSelectedIndicator: $hasSelectedIndicator, style: $style, subTiles: $subTiles)';
  }
}

/// Can only be called from [SideMenuTileData.subTiles]
///
/// Will be ignored if called directly inside [SideMenuData.items]
class SideMenuSubTileData extends SideMenuItemData with _BaseSideMenuData {
  final List<SideMenuSubTileData> subTiles;
  final SubMenuTileStyle? style;

  @override
  final String title;

  @override
  final Widget? leading;

  @override
  final Widget? selectedLeading;

  @override
  final Widget? trailing;

  @override
  final TileBadgeBuilder? badgeBuilder;

  @override
  VoidCallback? onTap;

  SideMenuSubTileData({
    required this.title,
    this.leading,
    this.selectedLeading,
    this.trailing,
    this.style,
    this.subTiles = const [],
    this.badgeBuilder,
    this.onTap,
  });

  SideMenuSubTileData resolveWith([final SubMenuTileStyle? style]) {
    return SideMenuSubTileData(
      title: title,
      leading: leading,
      trailing: trailing,
      selectedLeading: selectedLeading,
      style: this.style?.resolveWith(style) ?? style,
      subTiles: subTiles,
      badgeBuilder: badgeBuilder,
      onTap: onTap,
    );
  }

  SideMenuSubTileData copyWith({
    String? title,
    Widget? leading,
    Widget? selectedLeading,
    Widget? trailing,
    SubMenuTileStyle? style,
    List<SideMenuSubTileData>? subTiles,
    TileBadgeBuilder? badgeBuilder,
    VoidCallback? onTap,
    bool? hasSelectedIndicator,
  }) {
    return SideMenuSubTileData(
      title: title ?? this.title,
      leading: leading ?? this.leading,
      selectedLeading: selectedLeading ?? this.selectedLeading,
      trailing: trailing ?? this.trailing,
      style: style ?? this.style,
      subTiles: subTiles ?? this.subTiles,
      badgeBuilder: badgeBuilder ?? this.badgeBuilder,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  String toString() {
    return 'SideMenuSubTileData(subTiles: $subTiles, style: $style, title: $title, leading: $leading, selectedLeading: $selectedLeading, trailing: $trailing, badgeBuilder: $badgeBuilder, onTap: $onTap)';
  }
}
