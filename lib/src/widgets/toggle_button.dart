import 'package:flutter/material.dart';

import '../models/styles/toggle_button_style.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key, required this.onTap, required this.textDirection, this.style, required this.isOpen, required this.duration});

  final void Function() onTap;
  final TextDirection textDirection;
  final ToggleButtonStyle? style;
  final bool isOpen;
  final Duration duration;

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  static const IconData _leftIcon = Icons.keyboard_double_arrow_left_rounded, _rightIcon = Icons.keyboard_double_arrow_right_rounded;
  late Widget _icon;
  late ToggleButtonStyle _buttonStyle;
  bool _visible = false, _isStyleInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isStyleInitialized) {
      _isStyleInitialized = true;
      _buttonStyle = widget.style ?? const ToggleButtonStyle().copyWith(iconColor: IconTheme.of(context).color);
    }
  }

  @override
  void didUpdateWidget(covariant ToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.style != widget.style) _buttonStyle = widget.style ?? const ToggleButtonStyle().copyWith(iconColor: IconTheme.of(context).color);
  }

  @override
  Widget build(BuildContext context) {
    _icon = _buttonStyle.icon != null
        ? Icon(_buttonStyle.icon!, color: _buttonStyle.iconColor, size: _buttonStyle.iconSize)
        : AnimatedRotation(
            turns: widget.isOpen ? 0.5 : 0,
            duration: widget.duration,
            child: Icon(widget.textDirection == .ltr ? _rightIcon : _leftIcon, color: _buttonStyle.iconColor, size: _buttonStyle.iconSize),
          );

    return PositionedDirectional(
      top: _buttonStyle.topPosition,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (isHovered) => setState(() => _visible = isHovered),
        child: AnimatedOpacity(
          opacity: _visible ? 1 : _buttonStyle.opacity,
          duration: .zero,
          child: CircleAvatar(radius: 12.9, backgroundColor: _buttonStyle.backgroundColor ?? ColorScheme.of(context).inversePrimary, child: _icon),
        ),
      ),
    );
  }
}
