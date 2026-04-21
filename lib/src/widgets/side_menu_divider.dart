import 'package:flutter/material.dart';
import '../models/data/side_menu_item_data.dart';

class SideMenuDivider extends StatelessWidget {
  const SideMenuDivider({super.key, required this.data});
  final SideMenuDividerData data;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: data.padding ?? .zero, child: data.divider);
  }
}
