import 'package:flutter/material.dart';

import '../../enums/custom_child_position.dart';
import 'side_menu_item_animation_data.dart';
import 'side_menu_item_data.dart';

class SideMenuData {
  const SideMenuData({
    this.header,
    this.animHeader,
    this.footer,
    this.animFooter,
    this.items,
    this.animItems,
    this.customChild,
    this.animCustomChild,
    this.customChildFlex = 1,
    this.spacerAfterCustomChild,
    this.spacerAfterItems,
    this.customChildPosition = CustomChildPosition.aboveItems,
  }) : assert(customChild != null || items != null);

  final Widget? header;
  final SideMenuItemAnimationData? animHeader;
  final Widget? footer;
  final SideMenuItemAnimationData? animFooter;
  final List<SideMenuItemData>? items;
  final SideMenuItemAnimationData? animItems;
  final Widget? customChild;
  final SideMenuItemAnimationData? animCustomChild;
  final int customChildFlex;
  final Spacer? spacerAfterCustomChild;
  final Spacer? spacerAfterItems;
  final CustomChildPosition customChildPosition;

  @override
  String toString() {
    return 'SideMenuData(header: $header, animHeader: $animHeader, footer: $footer, animFooter: $animFooter, items: $items, animItems: $animItems, customChild: $customChild, animCustomChild: $animCustomChild, customChildFlex: $customChildFlex, spacerAfterCustomChild: $spacerAfterCustomChild, spacerAfterItems: $spacerAfterItems, customChildPosition: $customChildPosition)';
  }
}
