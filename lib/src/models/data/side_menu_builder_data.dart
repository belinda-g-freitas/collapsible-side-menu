import 'dart:ui' show TextDirection;

class SideMenuBuilderData {
  SideMenuBuilderData({
    required this.isOpen,
    required this.minWidth,
    required this.maxWidth,
    required this.currentWidth,
    required this.textDirection,
  });

  final bool isOpen;
  final double minWidth;
  final double maxWidth;
  final double currentWidth;
  final TextDirection textDirection;

  @override
  String toString() {
    return 'SideMenuBuilderData(isOpen: $isOpen, minWidth: $minWidth, maxWidth: $maxWidth, currentWidth: $currentWidth)';
  }
}
