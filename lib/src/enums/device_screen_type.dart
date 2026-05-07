enum DeviceScreenType {
  desktop(breakpoint: 950),
  tablet(breakpoint: 600),
  mobile(breakpoint: 320);

  const DeviceScreenType({required this.breakpoint});

  final int breakpoint;

  static bool fromDesktop(double width) => width >= DeviceScreenType.desktop.breakpoint;

  static bool fromTablet(double width) => width >= DeviceScreenType.tablet.breakpoint;
}
