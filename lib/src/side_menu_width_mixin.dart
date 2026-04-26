import 'enums/device_screen_type.dart';
import 'enums/menu_behaviour.dart';
import 'utils/menu_constants.dart';

mixin SideMenuWidthMixin {
  double calculateWidthSize({
    required MenuBehaviour behaviour,
    required double minWidth,
    required double maxWidth,
    required double currentWidth,
    required double deviceWidth,
  }) {

    return switch (behaviour) {
      .open => _open(currentWidth, minWidth, maxWidth),
      .compact => _compact(currentWidth, minWidth, maxWidth),
      .auto => _auto(currentWidth, minWidth, maxWidth, deviceWidth),
    };
  }

  double _auto(double currentWidth, double minWidth, double maxWidth, double deviceWidth) {
    if (_isPossibleWidthChange(currentWidth, minWidth, maxWidth)) {
      return DeviceScreenType.isDesktop(deviceWidth) ? maxWidth : minWidth;
    }

    return currentWidth;
  }

  double _open(double currentWidth, double minWidth, double maxWidth) {
    if (_isPossibleWidthChange(currentWidth, minWidth, maxWidth)) return maxWidth;

    return currentWidth;
  }

  double _compact(double currentWidth, double minWidth, double maxWidth) {
    if (_isPossibleWidthChange(currentWidth, minWidth, maxWidth)) return minWidth;

    return currentWidth;
  }

  bool _isPossibleWidthChange(double currentWidth, double minWidth, double maxWidth) {
    return currentWidth == MenuConstants.zeroWidth || !_isCurrentWidthCustom(currentWidth, minWidth, maxWidth);
  }

  bool _isCurrentWidthCustom(double currentWidth, double minWidth, double maxWidth) {
    return currentWidth != maxWidth && currentWidth != minWidth;
  }
}
