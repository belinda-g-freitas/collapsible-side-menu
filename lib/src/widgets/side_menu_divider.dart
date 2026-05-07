import 'package:flutter/material.dart';
import '../models/data/side_menu_item.dart';

class SideMenuDivider extends StatelessWidget {
  const SideMenuDivider({super.key, required this.data});
  final DividerData data;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: data.padding ?? .zero, child: data.divider);
  }
}
