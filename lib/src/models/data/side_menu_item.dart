import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Divider, EdgeInsetsGeometry, TextAlign, TextStyle, Widget;

import '../../utils/types.dart';
import '../styles/menu_tile_style.dart';
import '../styles/sub_menu_tile_style.dart';

typedef TileBadgeBuilder = Widget? Function(Widget tile);

mixin _BaseSideMenuData {
  /// Tile title
  String get title;

  /// Leading widget to show before title
  Widget? get leading;

  /// Leading widget to show when tile is selected
  Widget? get selectedLeading;

  /// Trailing widget to show after title
  Widget? get trailing;

  /// Use it to show your custom badge
  TileBadgeBuilder? get badgeBuilder;

  /// Action when user taps the tile
  VoidCallback? get onTap;
}

//
sealed class SideMenuItem {
  const SideMenuItem();
  // SideMenuItem({int? id}) : _id = _nextId();
  // final int _id;

  // String get id => 'sidemenuitem_$_id';

  // static int _counter = 0;
  // static int _nextId() => _counter++;

  // @protected
  // int get rawId => _id; // exposed internally so subclasses can pass it through copyWith
}

class TitleData extends SideMenuItem {
  const TitleData({required this.title, this.titleStyle, this.textAlign, this.padding});

  final String title;
  final TextStyle? titleStyle;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? padding;

  // TitleData copyWith({String? title, TextStyle? titleStyle, TextAlign? textAlign, EdgeInsetsGeometry? padding}) {
  //   return TitleData(
  //     title: title ?? this.title,
  //     titleStyle: titleStyle ?? this.titleStyle,
  //     textAlign: textAlign ?? this.textAlign,
  //     padding: padding ?? this.padding,
  //   );
  // }
}

class DividerData extends SideMenuItem {
  const DividerData({this.divider = const Divider(), this.padding});

  final Widget divider;
  final EdgeInsetsGeometry? padding;
}

class TileData extends SideMenuItem with _BaseSideMenuData {
  const TileData({
    required this.title,
    this.leading,
    this.selectedLeading,
    this.trailing,
    this.style,
    this.subTiles = const [],
    this.badgeBuilder,
    this.onTap,
    this.hasSelectedIndicator = true,
    // this.initiallyExpanded = false,
    this.tooltip,
  });

  /// Should tile show a selection indicator
  ///
  /// Defaults to [true]
  final bool hasSelectedIndicator;

  /// Tile style
  final MenuTileStyle? style;

  /// Tile subtiles
  final List<SubTileData> subTiles;

  /// To override the default tooltip (which is [title]) when menu is collapsed
  final String? tooltip;

  /// Should tile with subtiles be expanded by default
  // final bool initiallyExpanded;

  /// Tile title
  @override
  final String title;

  /// Leading widget to show before title
  @override
  final Widget? leading;

  /// Leading widget to show when tile is selected
  @override
  final Widget? selectedLeading;

  /// Trailing widget to show after title
  @override
  final Widget? trailing;

  /// Use it to show your custom badge
  @override
  final TileBadgeBuilder? badgeBuilder;

  /// Action when user taps the tile
  @override
  final VoidCallback? onTap;

  TileData resolveWith([final MenuTileStyle? style]) {
    return TileData(
      title: title,
      leading: leading,
      trailing: trailing,
      selectedLeading: selectedLeading,
      style: this.style ?? style,
      subTiles: subTiles,
      badgeBuilder: badgeBuilder,
      onTap: onTap,
      hasSelectedIndicator: hasSelectedIndicator,
      // initiallyExpanded: initiallyExpanded,
      tooltip: tooltip,
    );
  }

  TileData copyWith({
    String? title,
    Widget? leading,
    Widget? selectedLeading,
    Widget? trailing,
    String? tooltip,
    List<SubTileData>? subTiles,
    TileBadgeBuilder? badgeBuilder,
    MenuTileStyle? style,
    VoidCallback? onTap,
    bool? hasSelectedIndicator,
    bool? initiallyExpanded,
  }) {
    return TileData(
      title: title ?? this.title,
      leading: leading ?? this.leading,
      selectedLeading: selectedLeading ?? this.selectedLeading,
      trailing: trailing ?? this.trailing,
      tooltip: tooltip ?? this.tooltip,
      subTiles: subTiles ?? this.subTiles,
      badgeBuilder: badgeBuilder ?? this.badgeBuilder,
      style: style ?? this.style,
      onTap: onTap ?? this.onTap,
      hasSelectedIndicator: hasSelectedIndicator ?? this.hasSelectedIndicator,
      // initiallyExpanded: initiallyExpanded ?? this.initiallyExpanded,
    );
  }

  @override
  bool operator ==(covariant TileData other) {
    if (identical(this, other)) return true;

    return other.hasSelectedIndicator == hasSelectedIndicator &&
        other.style == style &&
        listEquals(other.subTiles, subTiles) &&
        other.tooltip == tooltip &&
        // other.initiallyExpanded == initiallyExpanded &&
        other.title == title &&
        other.leading == leading &&
        other.selectedLeading == selectedLeading &&
        other.trailing == trailing &&
        other.badgeBuilder == badgeBuilder &&
        other.onTap == onTap;
  }

  @override
  int get hashCode {
    return hasSelectedIndicator.hashCode ^
        style.hashCode ^
        subTiles.hashCode ^
        tooltip.hashCode ^
        // initiallyExpanded.hashCode ^
        title.hashCode ^
        leading.hashCode ^
        selectedLeading.hashCode ^
        trailing.hashCode ^
        badgeBuilder.hashCode ^
        onTap.hashCode;
  }
}

/// Can only be called from [TileData.subTiles]
///
/// Will be ignored if called directly inside [CollapsibleSideMenu.items]
class SubTileData extends SideMenuItem with _BaseSideMenuData {
  final List<SubTileData> subTiles;
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

  SubTileData({
    required this.title,
    this.leading,
    this.selectedLeading,
    this.trailing,
    this.style,
    this.subTiles = const [],
    this.badgeBuilder,
    this.onTap,
  });

  SubTileData resolveWith([final SubMenuTileStyle? style]) {
    return SubTileData(
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
        title.hashCode ^
        leading.hashCode ^
        selectedLeading.hashCode ^
        trailing.hashCode ^
        badgeBuilder.hashCode ^
        onTap.hashCode;
  }
}
