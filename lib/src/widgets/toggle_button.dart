import 'package:flutter/material.dart';

import '../models/styles/toggle_button_style.dart';
import '../utils/types.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key, required this.onTap, this.style, required this.isOpen, required this.duration});

  final VoidCallback onTap;
  final ToggleButtonStyle? style;

  /// Whether the menu is currently open or closed. This is used to determine the rotation of the icon.
  final bool isOpen;

  /// The duration of the animation when the button is toggled. This is used to synchronize the rotation of the icon with the opening and closing of the menu.
  final Duration duration;

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late ToggleButtonStyle _buttonStyle;
  bool _visible = false, _isStyleInitialized = false;

  void _setVisible(bool value) {
    if (_visible == value) return;
    setState(() => _visible = value);
  }

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

    if (oldWidget.style != widget.style) {
      _buttonStyle = widget.style ?? const ToggleButtonStyle().copyWith(iconColor: IconTheme.of(context).color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: _buttonStyle.topPosition,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setVisible(true),
        onExit: (_) => _setVisible(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : _buttonStyle.opacity,
            duration: .zero,
            child: CircleAvatar(
              radius: 12.9,
              backgroundColor: _buttonStyle.backgroundColor ?? ColorScheme.of(context).inversePrimary,
              child: AnimatedRotation(
                turns: widget.isOpen ? 0.5 : 0,
                duration: widget.duration,
                child: Icon(_buttonStyle.openedIcon, color: _buttonStyle.iconColor, size: _buttonStyle.iconSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
