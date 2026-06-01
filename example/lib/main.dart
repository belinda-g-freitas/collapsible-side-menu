import 'package:collapsible_side_menu/collapsible_side_menu.dart';
import 'package:flutter/material.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(.system);
const Color appColor = Color(0xFF_292CFF);
const RoundedRectangleBorder roundedBorder = .new(borderRadius: .all(.circular(10)));

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
          title: 'Collapsible Side Menu Example',
          color: appColor,
          themeMode: mode,
          theme: _themeData(brightness: .light, scaffoldBackgroundColor: const Color(0xff_f3f3f9)),
          darkTheme: _themeData(brightness: .dark, scaffoldBackgroundColor: const Color(0xff_1a1d21)),
          home: MediaQuery.withNoTextScaling(child: const ExampleScreen()),
        );
      },
    );
  }
}

//
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _controller = SideMenuController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: .start,
        children: [
          // start menu
          CollapsibleSideMenu(
            defaultIndex: 3,
            defaultBehaviour: .open,
            menuStyle: SideMenuStyle(textDirection: .rtl),
            toggleButtonStyle: const ToggleButtonStyle(topPosition: 55, iconSize: 16),
            header: (_, isOpen) {
              return Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    spacing: 10,
                    mainAxisSize: .min,
                    children: [
                      const Flexible(child: CircleAvatar(radius: 22, child: FlutterLogo())),
                      if (isOpen)
                        const Flexible(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                'Joanna Doe',
                                overflow: .ellipsis,
                                style: TextStyle(fontWeight: .w500, fontSize: 14.5),
                              ),
                              Text(
                                'joanna.doe.404@flutter.dev',
                                overflow: .ellipsis,
                                style: TextStyle(fontSize: 12, fontWeight: .w300),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Divider(thickness: .5),
                ],
              );
            },
            footer: (_, isOpen) {
              return Column(
                mainAxisAlignment: .end,
                crossAxisAlignment: .start,
                children: [
                  const Divider(thickness: .5),
                  Text('v1.0.1+1', style: TextStyle(fontSize: isOpen ? 12 : 10)),
                ],
              );
            },
            items: [
              TileData(
                title: 'User management',
                leading: const Icon(Icons.person_outline, size: 18),
                selectedLeading: const Icon(Icons.person, size: 18),
                subTiles: [
                  SubTileData(title: 'Customers'),
                  SubTileData(
                    title: 'Employees',
                    subTiles: [
                      SubTileData(title: 'Drivers'),
                      SubTileData(title: 'HR'),
                      SubTileData(title: 'Accountants'),
                      SubTileData(title: 'Marketing'),
                    ],
                  ),
                  SubTileData(
                    title: 'Admins',
                    subTiles: [
                      SubTileData(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sudo')));
                        },
                        title: 'Sudo',
                        leading: const Icon(Icons.shield, size: 18),
                      ),
                      SubTileData(title: 'Super-admins'),
                      SubTileData(title: 'Admins'),
                    ],
                  ),
                  SubTileData(title: 'Salaries', trailing: const Icon(Icons.attach_money, size: 18)),
                ],
              ),
              //
              const DividerData(),
              const TitleData(title: 'OTHERS'),
              TileData(onTap: () {}, title: 'Vehicle', leading: const Icon(Icons.car_rental, size: 18)),
              TileData(
                onTap: () {},
                title: 'Conversations',
                leading: const Icon(Icons.chat_bubble_outline, size: 18),
                selectedLeading: const Icon(Icons.chat_bubble, size: 18),
                badgeBuilder: (tile) => Badge.count(count: 100, maxCount: 9, offset: const Offset(-2, -4)),
              ),
              TileData(title: 'Labels', leading: const Icon(Icons.label_outline), selectedLeading: const Icon(Icons.label)),
              TileData(
                onTap: () {
                  showAdaptiveAboutDialog(context: context);
                },
                title: 'About',
                leading: const Icon(Icons.info_outline, size: 18),
                selectedLeading: const Icon(Icons.info, size: 18),
              ),
              TileData(
                onTap: () {
                  showLicensePage(context: context);
                },
                title: 'Licenses',
                leading: const Icon(Icons.copyright_outlined, size: 18),
                selectedLeading: const Icon(Icons.copyright, size: 18),
              ),
            ],
            onIndexChanged: (index) {
              debugPrint('current index: $index');
            },
          ),
          // app content
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const .symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 15,
                  children: [
                    SegmentedButton<ThemeMode>(
                      segments: ThemeMode.values.map((e) => ButtonSegment(value: e, label: Text(e.name))).toList(),
                      selected: {themeModeNotifier.value},
                      onSelectionChanged: (value) => setState(() => themeModeNotifier.value = value.first),
                    ),
                    const Expanded(child: ColorSchemePreview()),
                  ],
                ),
              ),
            ),
          ),
          // end menu
          CollapsibleSideMenu(
            controller: _controller,
            hasToggleButton: false,
            defaultIndex: 1,
            duration: const Duration(milliseconds: 350),
            menuStyle: SideMenuStyle(textDirection: .rtl, backgroundColor: ColorScheme.of(context).onPrimaryFixed),
            customMenuChild: CustomMenuChild(
              child: const FlutterLogo(style: .stacked, size: 40),
              childFlex: 0,
              childPosition: .belowItems,
            ),
            items: [
              TileData(
                onTap: () {
                  _controller.toggle();
                },
                title: 'Toggle menu',
              ),
              TileData(title: 'Example 2'),
              TileData(
                onTap: () {
                  showLicensePage(context: context);
                },
                title: 'Licenses',
                leading: const Icon(Icons.copyright_outlined, size: 18),
                selectedLeading: const Icon(Icons.copyright, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
class ColorSchemePreview extends StatelessWidget {
  const ColorSchemePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = ColorScheme.of(context);
    final colors = <String, Color>{
      'primary': cs.primary,
      'onPrimary': cs.onPrimary,
      'primaryContainer': cs.primaryContainer,
      'onPrimaryContainer': cs.onPrimaryContainer,
      'primaryFixed': cs.primaryFixed,
      'onPrimaryFixed': cs.onPrimaryFixed,
      'primaryFixedDim': cs.primaryFixedDim,
      'onPrimaryFixedVariant': cs.onPrimaryFixedVariant,
      'inversePrimary': cs.inversePrimary,
      //
      'secondary': cs.secondary,
      'onSecondary': cs.onSecondary,
      'secondaryContainer': cs.secondaryContainer,
      'onSecondaryContainer': cs.onSecondaryContainer,
      'secondaryFixed': cs.secondaryFixed,
      'onSecondaryFixed': cs.onSecondaryFixed,
      'secondaryFixedDim': cs.secondaryFixedDim,
      'onSecondaryFixedVariant': cs.onSecondaryFixedVariant,
      //
      'tertiary': cs.tertiary,
      'onTertiary': cs.onTertiary,
      'tertiaryContainer': cs.tertiaryContainer,
      'onTertiaryContainer': cs.onTertiaryContainer,
      'tertiaryFixed': cs.tertiaryFixed,
      'onTertiaryFixed': cs.onTertiaryFixed,
      'tertiaryFixedDim': cs.tertiaryFixedDim,
      'onTertiaryFixedVariant': cs.onTertiaryFixedVariant,
      //
      'error': cs.error,
      'onError': cs.onError,
      'errorContainer': cs.errorContainer,
      'onErrorContainer': cs.onErrorContainer,
      //
      'surface': cs.surface,
      'onSurface': cs.onSurface,
      'inverseSurface': cs.inverseSurface,
      'onInverseSurface': cs.onInverseSurface,
      'surfaceContainerLow': cs.surfaceContainerLow,
      'surfaceContainerLowest': cs.surfaceContainerLowest,
      'surfaceContainerHigh': cs.surfaceContainerHigh,
      'surfaceVariant': cs.surfaceContainerHighest,
      'surfaceBright': cs.surfaceBright,
      'surfaceDim': cs.surfaceDim,
      'surfaceTint': cs.surfaceTint,
      'onSurfaceVariant': cs.onSurfaceVariant,
      //
      'outline': cs.outline,
      'outlineVariant': cs.outlineVariant,
      //
      'scrim': cs.scrim,
      'shadow': cs.shadow,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('ColorScheme Preview')),
      body: ListView.builder(
        padding: const .all(16),
        itemCount: colors.entries.length,
        itemBuilder: (_, i) {
          final e = colors.entries.elementAt(i);
          final color = ThemeData.estimateBrightnessForColor(e.value) == .dark ? Colors.white : Colors.black;

          return Container(
            margin: const .only(bottom: 8),
            padding: const .symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: e.value,
              borderRadius: .circular(8),
              border: .all(color: cs.outline.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    e.key,
                    style: TextStyle(color: color, fontWeight: .w500),
                  ),
                ),
                Flexible(
                  child: Text(
                    '#${e.value.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(color: color, fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
