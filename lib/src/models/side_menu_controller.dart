import 'package:flutter/foundation.dart' show ValueChanged, protected;
import 'package:flutter/widgets.dart' show WidgetsBinding;

import '../utils/types.dart';

class SideMenuController {
  VoidCallback? _open;
  VoidCallback? _close;
  VoidCallback? _toggle;
  bool _isAttached = false;

  void open() {
    assert(_isAttached, _notAttachedMessage('open'));
    _open?.call();
  }

  void close() {
    assert(_isAttached, _notAttachedMessage('close'));
    _close?.call();
  }

  void toggle() {
    assert(_isAttached, _notAttachedMessage('toggle'));
    _toggle?.call();
  }

  ValueChanged<bool>? onCollapsedChanged;

  /// Called internally by [CollapsibleSideMenu], not meant for public use.
  @protected
  void attach({required VoidCallback open, required VoidCallback close, required VoidCallback toggle}) {
    _open = open;
    _close = close;
    _toggle = toggle;
    _isAttached = true;
  }

  /// Called internally whenever the menu's open/collapsed state changes.
  @protected
  void updateCollapsed(bool isCollapsed) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => onCollapsedChanged?.call(isCollapsed));

  String _notAttachedMessage(String method) =>
      'SideMenuController.$method() was called, but this controller is not attached to a CollapsibleSideMenu. '
      'Make sure you pass it via CollapsibleSideMenu(controller: yourController).';

  @protected
  void detach() {
    _open = null;
    _close = null;
    _toggle = null;
    _isAttached = false;
  }
}
