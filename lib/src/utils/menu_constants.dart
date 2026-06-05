import 'package:flutter/material.dart';

class MenuConstants {
  // numbers
  static const double minWidth = 50;
  static const double maxWidth = 250;

  static const double radius = 10;
  static const double tileHeight = 40;
  static const double subTileHeight = 30;
  static const double subTileSelectedIndicatorHeight = 15;
  static const double horizontalSpacing = 3;
  static const double selectedBorderWidth = 0.5;
  static const double tilesVerticalSpacing = 2;

  // Colors
  static const Color transparent = Color(0x00_000000);
  static const Color black = Color(0xFF_000000);
  static const Color white = Color(0xFF_FFFFFF);

  // Paddings
  static const EdgeInsetsDirectional textStartPadding = .only(start: 16);
  static const EdgeInsetsGeometry tileMargin = .zero;
  static const EdgeInsetsGeometry menuInnerPadding = .symmetric(horizontal: 7, vertical: 12.9);
  static const EdgeInsetsGeometry menuOuterPadding = .all(4);

  // OTHERS
  static const Duration duration = Duration(milliseconds: 250);
  static const BorderRadius borderRadius = .all(.circular(radius));
  static const Size selectedIndicatorSize = Size(4, 20);
  static const Widget emptyWidget = SizedBox.shrink();

  /// Equivalent to [Icons.keyboard_double_arrow_right_rounded] but with matchTextDirection set to true.
  static const IconData toggleButtonIcon = IconData(0xf0348, fontFamily: 'MaterialIcons', matchTextDirection: true);
}
