import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
        child: Icon(nodes.contains(nodeKey) ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 14, color: color),
      ),
    );
  }
}
