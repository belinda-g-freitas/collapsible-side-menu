import 'package:flutter/foundation.dart' show VoidCallback, listEquals;
import 'package:flutter/material.dart' show Divider, EdgeInsetsGeometry, TextAlign, TextStyle, VoidCallback, Widget;

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
sealed class SideMenuItem {
  const SideMenuItem();
}

class TitleData extends SideMenuItem {
  const TitleData({required this.title, this.titleStyle, this.textAlign, this.padding});

  final String title;
  final TextStyle? titleStyle;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? padding;

  TitleData copyWith({String? title, TextStyle? titleStyle, TextAlign? textAlign, EdgeInsetsGeometry? padding}) {
    return TitleData(
      title: title ?? this.title,
      titleStyle: titleStyle ?? this.titleStyle,
      textAlign: textAlign ?? this.textAlign,
      padding: padding ?? this.padding,
    );
  }
}

class DividerData extends SideMenuItem {
  const DividerData({this.divider = const Divider(), this.padding}) : super();

  final Widget divider;
  final EdgeInsetsGeometry? padding;
}

class TileData extends SideMenuItem with _BaseSideMenuData {
  final bool hasSelectedIndicator;
  final MenuTileStyle? style;
  final List<SubTileData> subTiles;
  final String? id;

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

  TileData({
    this.id,
    required this.title,
    this.leading,
    this.selectedLeading,
    this.trailing,
    this.style,
    this.subTiles = const [],
    this.badgeBuilder,
    this.onTap,

    this.hasSelectedIndicator = true,
  });

  TileData resolveWith([final MenuTileStyle? style]) {
    return TileData(
      id: id,
      title: title,
      leading: leading,
      trailing: trailing,
      selectedLeading: selectedLeading,
      style: this.style ?? style,
      subTiles: subTiles,
      badgeBuilder: badgeBuilder,
      onTap: onTap,
      hasSelectedIndicator: hasSelectedIndicator,
    );
  }

  TileData copyWith({
    String? title,
    Widget? leading,
    Widget? selectedLeading,
    Widget? trailing,
    TileBadgeBuilder? badgeBuilder,
    VoidCallback? onTap,
    bool? hasSelectedIndicator,
    MenuTileStyle? style,
    List<SubTileData>? subTiles,
    String? id,
  }) {
    return TileData(
      title: title ?? this.title,
      leading: leading ?? this.leading,
      selectedLeading: selectedLeading ?? this.selectedLeading,
      trailing: trailing ?? this.trailing,
      badgeBuilder: badgeBuilder ?? this.badgeBuilder,
      onTap: onTap ?? this.onTap,
      hasSelectedIndicator: hasSelectedIndicator ?? this.hasSelectedIndicator,
      style: style ?? this.style,
      subTiles: subTiles ?? this.subTiles,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(covariant TileData other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.leading == leading &&
        other.selectedLeading == selectedLeading &&
        other.trailing == trailing &&
        other.badgeBuilder == badgeBuilder &&
        other.onTap == onTap &&
        other.hasSelectedIndicator == hasSelectedIndicator &&
        other.style == style &&
        listEquals(other.subTiles, subTiles) &&
        other.id == id;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        leading.hashCode ^
        selectedLeading.hashCode ^
        trailing.hashCode ^
        badgeBuilder.hashCode ^
        onTap.hashCode ^
        hasSelectedIndicator.hashCode ^
        style.hashCode ^
        subTiles.hashCode ^
        id.hashCode;
  }
}

/// Can only be called from [TileData.subTiles]
///
/// Will be ignored if called directly inside [CollapsibleSideMenu.items]
class SubTileData extends SideMenuItem with _BaseSideMenuData {
  final List<SubTileData> subTiles;
  final SubMenuTileStyle? style;
  final String? id;

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

  SubTileData({
    required this.title,
    this.leading,
    this.selectedLeading,
    this.trailing,
    this.style,
    this.subTiles = const [],
    this.badgeBuilder,
    this.onTap,
    this.id,
  });

  SubTileData resolveWith([final SubMenuTileStyle? style]) {
    return SubTileData(
      id: id,
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

  SubTileData copyWith({
    List<SubTileData>? subTiles,
    SubMenuTileStyle? style,
    String? id,
    String? title,
    Widget? leading,
    Widget? selectedLeading,
    Widget? trailing,
    TileBadgeBuilder? badgeBuilder,
    VoidCallback? onTap,
  }) {
    return SubTileData(
      subTiles: subTiles ?? this.subTiles,
      style: style ?? this.style,
      id: id ?? this.id,
      title: title ?? this.title,
      leading: leading ?? this.leading,
      selectedLeading: selectedLeading ?? this.selectedLeading,
      trailing: trailing ?? this.trailing,
      badgeBuilder: badgeBuilder ?? this.badgeBuilder,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  bool operator ==(covariant SubTileData other) {
    if (identical(this, other)) return true;

    return listEquals(other.subTiles, subTiles) &&
        other.style == style &&
        other.id == id &&
        other.title == title &&
        other.leading == leading &&
        other.selectedLeading == selectedLeading &&
        other.trailing == trailing &&
        other.badgeBuilder == badgeBuilder &&
        other.onTap == onTap;
  }

  @override
  int get hashCode {
    return subTiles.hashCode ^
        style.hashCode ^
        id.hashCode ^
        title.hashCode ^
        leading.hashCode ^
        selectedLeading.hashCode ^
        trailing.hashCode ^
        badgeBuilder.hashCode ^
        onTap.hashCode;
  }
}
