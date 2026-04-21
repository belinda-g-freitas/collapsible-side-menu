import 'enums/device_screen_type.dart';
import 'enums/menu_behaviour.dart';
import 'utils/menu_constants.dart';

mixin SideMenuWidthMixin {
  late MenuBehaviour behaviour;
  late double currentWidth;
  late double deviceWidth;
  late double minWidth;
  late double maxWidth;

  double calculateWidthSize({
    required MenuBehaviour behaviour,
    required double minWidth,
    required double maxWidth,
    required double currentWidth,
    required double deviceWidth,
  }) {
    this.behaviour = behaviour;
    this.minWidth = minWidth;
    this.maxWidth = maxWidth;
    this.currentWidth = currentWidth;
    this.deviceWidth = deviceWidth;

    return switch (behaviour) {
      .open => _open(),
      .compact => _compact(),
      .auto => _auto(),
    };
  }

  double _auto() {
    if (_isPossibleWidthChange()) return DeviceScreenType.isDesktop(deviceWidth) ? maxWidth : minWidth;

    return currentWidth;
  }

  double _open() {
    if (_isPossibleWidthChange()) return maxWidth;

    return currentWidth;
  }

  double _compact() {
    if (_isPossibleWidthChange()) return minWidth;

    return currentWidth;
  }

  bool _isPossibleWidthChange() => currentWidth == MenuConstants.zeroWidth || !_isCurrentWidthCustom();

  bool _isCurrentWidthCustom() => currentWidth != maxWidth && currentWidth != minWidth;
}
