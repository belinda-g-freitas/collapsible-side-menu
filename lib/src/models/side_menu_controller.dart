import '../utils/types.dart';

class SideMenuController {
  late VoidCallback open;
  late VoidCallback close;
  late VoidCallback toggle;
  late bool Function() isCollapsed;
}
