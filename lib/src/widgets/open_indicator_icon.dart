import 'package:flutter/material.dart';

import '../utils/menu_constants.dart';

class OpenIndicatorIcon extends StatelessWidget {
  const OpenIndicatorIcon({super.key, required this.nodeKey, required this.openNodes, required this.color});

  final String nodeKey;
  final ValueNotifier<Set<String>> openNodes;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: openNodes,
      builder: (_, nodes, _) => Padding(
        padding: const .fromLTRB(0, 0, 5, 0),
        child: AnimatedRotation(
          turns: nodes.contains(nodeKey) ? 0.5 : 0,
          duration: MenuConstants.duration,
          child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: color),
        ),
      ),
    );
  }
}
