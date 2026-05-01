import 'dart:ui' show TextDirection;

class SideMenuBuilder {
  SideMenuBuilder({required this.isOpen, required this.textDirection, this.selectedIndex});

  final bool isOpen;
  final TextDirection textDirection;
  final int? selectedIndex;

  @override
  String toString() => 'SideMenuBuilder(isOpen: $isOpen, textDirection: $textDirection, selectedIndex: $selectedIndex)';
}
