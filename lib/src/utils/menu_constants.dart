import 'package:flutter/material.dart';

class MenuConstants {
  /// Size
  static const double minWidth = 50;
  static const double maxWidth = 250;

  /// zeroWidth = 0
  static const double zeroWidth = 0;
  static const double radius = 10;
  static const double tileHeight = 40;
  static const double subTileHeight = 30;
  static const double selectedIndicatorHeight = 20;
  static const double subTileSelectedIndicatorHeight = 15;
  static const double selectedIndicatorWidth = 4;
  static const double horizontalSpacing = 3;

  /// Durations
  static const Duration duration = Duration(milliseconds: 200);

  /// Colors
  // static const Color selectedColor = AppColors.appColor;
  static const Color transparent = Color(0x00_000000);

  /// Paddings
  static const EdgeInsetsDirectional textStartPadding = .only(start: 16);
  static const EdgeInsetsGeometry tileMargin = .symmetric(vertical: 2);
  static const EdgeInsetsGeometry menuInnerPadding = .symmetric(horizontal: 7, vertical: 12.9);
  static const EdgeInsetsGeometry outerPadding = .all(4);

  static const BorderRadius borderRadius = .all(.circular(radius));
}
