import 'dart:ui' show TextDirection;

class SideMenuBuilderData {
  SideMenuBuilderData({required this.isOpen, required this.currentWidth, required this.textDirection, this.selectedIndex});

  final bool isOpen;
  final double currentWidth;
  final TextDirection textDirection;
  final int? selectedIndex;

  @override
  String toString() {
    return 'SideMenuBuilderData(isOpen: $isOpen, currentWidth: $currentWidth, textDirection: $textDirection, selectedIndex: $selectedIndex)';
  }
}
