import 'package:flutter/material.dart' show Widget, Spacer;

import '../../enums/custom_child_position.dart';

class CustomMenuChild {
  final Widget? child;
  final int childFlex;
  final Spacer? spacerAfterChild;
  final CustomChildPosition childPosition;
  CustomMenuChild({this.child, required this.childFlex, this.spacerAfterChild, required this.childPosition});

  @override
  String toString() {
    return 'CustomMenuChildData(child: $child, childFlex: $childFlex, spacerAfterChild: $spacerAfterChild, childPosition: $childPosition)';
  }

  @override
  bool operator ==(covariant CustomMenuChild other) {
    if (identical(this, other)) return true;

    return other.child == child &&
        other.childFlex == childFlex &&
        other.spacerAfterChild == spacerAfterChild &&
        other.childPosition == childPosition;
  }

  @override
  int get hashCode {
    return child.hashCode ^ childFlex.hashCode ^ spacerAfterChild.hashCode ^ childPosition.hashCode;
  }
}
