import 'package:flutter/material.dart' show Widget, Spacer;

import '../../enums/custom_child_position.dart';

class CustomMenuChild {
  final Widget child;
  final int childFlex;
  final Spacer? spacerAfterChild;
  final CustomChildPosition childPosition;

  CustomMenuChild({required this.child, this.childFlex = 1, this.spacerAfterChild, this.childPosition = CustomChildPosition.aboveItems});

  @override
  bool operator ==(covariant CustomMenuChild other) {
    if (identical(this, other)) return true;

    return other.child == child && other.childFlex == childFlex && other.spacerAfterChild == spacerAfterChild && other.childPosition == childPosition;
  }

  @override
  int get hashCode {
    return child.hashCode ^ childFlex.hashCode ^ spacerAfterChild.hashCode ^ childPosition.hashCode;
  }
}
