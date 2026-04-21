import 'package:flutter/material.dart';

import 'package:collapsible_side_menu_example/example_screen.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(.system);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const Color appColor = Color(0xFF_F2A900);
  static const RoundedRectangleBorder roundedBorder = .new(borderRadius: .all(.circular(10)));

  ThemeData _themeData({required Brightness brightness, required Color scaffoldBackgroundColor}) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: appColor, brightness: brightness),
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      menuTheme: MenuThemeData(
        style: MenuStyle(shape: .all(roundedBorder)),
        submenuIcon: .all(const Icon(Icons.arrow_forward_ios_rounded, size: 12)),
      ),
      menuButtonTheme: MenuButtonThemeData(style: ButtonStyle(shape: .all(roundedBorder))),
      badgeTheme: const BadgeThemeData(
        textStyle: TextStyle(fontSize: 9, color: Colors.white),
        textColor: Colors.white,
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Collapsible Side Menu',
          color: appColor,
          themeMode: mode,
          theme: _themeData(brightness: .light, scaffoldBackgroundColor: Color(0xff_f3f3f9)),
          darkTheme: _themeData(brightness: .dark, scaffoldBackgroundColor: Color(0xff_1a1d21)),
          home: MediaQuery.withNoTextScaling(child: ExampleScreen()),
        );
      },
    );
  }
}
