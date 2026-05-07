import 'enums/auto_open_from.dart';
import 'enums/device_screen_type.dart';
import 'enums/menu_behaviour.dart';

mixin SideMenuStateMixin {
  bool openMenuState({required MenuBehaviour behaviour, required AutoOpenFrom from, required double deviceWidth}) {
    return switch (behaviour) {
      .open => true,
      .collapse => false,
      .auto => switch (from) {
        .tablet => DeviceScreenType.fromTablet(deviceWidth),
        .desktop => DeviceScreenType.fromDesktop(deviceWidth),
      },
    };
  }
}
