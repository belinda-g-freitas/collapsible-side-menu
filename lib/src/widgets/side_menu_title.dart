import 'package:flutter/material.dart';
import '../models/data/side_menu_item_data.dart';

class SideMenuTitle extends StatelessWidget {
  const SideMenuTitle({super.key, required this.data, required this.color});
  final SideMenuTitleData data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextStyle? defaultStyle = TextTheme.of(context).bodySmall;

    return Padding(
      padding: data.padding ?? .zero,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: color, fontSize: defaultStyle?.fontSize, fontWeight: defaultStyle?.fontWeight),
        child: Text(data.title, style: data.titleStyle, maxLines: 1, textAlign: data.textAlign, overflow: data.titleStyle?.overflow ?? .ellipsis),
      ),
    );
  }
}
