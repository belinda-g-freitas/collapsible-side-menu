import 'package:flutter/material.dart';

import '../models/styles/toggle_button_style.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key, required this.onTap, required this.textDirection, this.style, required this.isOpen});

  final void Function() onTap;
  final TextDirection textDirection;
  final ToggleButtonStyle? style;
  final bool isOpen;

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  static const IconData leftIcon = Icons.keyboard_double_arrow_left_rounded, rightIcon = Icons.keyboard_double_arrow_right_rounded;
  late IconData icon;
  late ToggleButtonStyle buttonStyle;
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    buttonStyle = widget.style ?? const ToggleButtonStyle().copyWith(iconColor: IconTheme.of(context).color);
    icon =
        buttonStyle.icon ??
        (widget.textDirection == .ltr
            ? widget.isOpen
                  ? leftIcon
                  : rightIcon
            : widget.isOpen
            ? rightIcon
            : leftIcon);

    return PositionedDirectional(
      top: buttonStyle.topPosition,
      // end: -10,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hover) {
          setState(() => _visible = hover);
        },
        child: AnimatedOpacity(
          opacity: _visible ? 1 : buttonStyle.opacity,
          duration: .zero,
          child: CircleAvatar(
            radius: 12.9,
            backgroundColor: ColorScheme.of(context).inversePrimary,
            child: Icon(icon, color: buttonStyle.iconColor, size: buttonStyle.iconSize),
          ),
        ),
      ),
    );
  }
}
