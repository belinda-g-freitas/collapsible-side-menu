import 'dart:developer' show log;

import 'package:flutter/material.dart';

import 'package:collapsible_side_menu/collapsible_side_menu.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(.system);
final appColorNotifier = ValueNotifier<Color>(const Color(0xFF_292CFF));
const appColors = [
  Color(0xFF_F43F5E),
  Color(0xFF_9333EA),
  Color(0xFF_F2A900),
  Color(0xFF_2196F3),
  Color(0xFF_292CFF),
  Color(0xFF_0D9488),
];
const borderRadius = BorderRadius.all(.circular(10));
const RoundedRectangleBorder roundedBorder = .new(borderRadius: borderRadius);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  ThemeData _themeData({required Color color, Brightness brightness = .light, required Color scaffoldBackgroundColor}) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: color, brightness: brightness),
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
      builder: (_, mode, _) {
        return ValueListenableBuilder(
          valueListenable: appColorNotifier,
          builder: (_, appColor, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Collapsible Menu Example',
              themeMode: mode,
              theme: _themeData(color: appColor, scaffoldBackgroundColor: const Color(0xff_f3f3f9)),
              darkTheme: _themeData(color: appColor, brightness: .dark, scaffoldBackgroundColor: const Color(0xff_1a1d21)),
              home: MediaQuery.withNoTextScaling(child: const ExampleScreen()),
            );
          },
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
  late final SideMenuController _controller;
  bool? _isCollapsed;

  @override
  void initState() {
    super.initState();

    _controller = SideMenuController()
      ..onCollapsedChanged = (isCollapsed) {
        log('Menu is now ${isCollapsed ? "collapsed" : "open"}');

        setState(() => _isCollapsed = isCollapsed);
      };
  }

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
            menuStyle: SideMenuStyle(textDirection: .ltr),
            toggleButtonStyle: const ToggleButtonStyle(topPosition: 55, iconSize: 16),
            header: (_, isOpen) {
              return Column(
                crossAxisAlignment: .start,
                children: [
                  SideMenuHeader(
                    isOpen: isOpen,
                    leading: const CircleAvatar(radius: 22, child: FlutterLogo()),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: borderRadius,
                      border: Border.all(color: Colors.white, width: .5),
                    ),
                    trailing: const CircleAvatar(radius: 16),
                    child: const Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          'Joanna Doe',
                          overflow: .ellipsis,
                          style: TextStyle(fontWeight: .w500, fontSize: 15),
                        ),
                        Text(
                          'joanna.doe.404@flutter.dev',
                          overflow: .ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: .w300),
                        ),
                      ],
                    ),
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
            customMenuChild: CustomMenuChild(
              childFlex: 0,
              childPosition: .belowItems,
              child: Builder(
                builder: (ctx) {
                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(borderRadius: borderRadius, border: Border.all(width: .5)),
                      padding: const EdgeInsets.all(10),
                      child: const Text('This is a LTR menu', overflow: .ellipsis),
                    ),
                    onTap: () => ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text('Menu width is: ${CollapsibleSideMenu.maybeOf(ctx)?.widget.maxWidth}')),
                      ),
                  );
                },
              ),
            ),
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
              const TileData(title: 'Vehicle', leading: Icon(Icons.car_rental, size: 18)),
              TileData(
                onTap: () {},
                title: 'Conversations',
                leading: const Icon(Icons.chat_bubble_outline, size: 18),
                selectedLeading: const Icon(Icons.chat_bubble, size: 18),
                // use whatever badge package ou UI you want by wrapping tile with it
                badgeBuilder: (tile) => Badge.count(count: 100, maxCount: 9, offset: const Offset(-2, -4), child: tile),
              ),
              const TileData(title: 'Labels', leading: Icon(Icons.label_outline), selectedLeading: Icon(Icons.label)),
              TileData(
                onTap: () => showAdaptiveAboutDialog(context: context),
                tooltip: 'About app',
                title: 'About',
                leading: const Icon(Icons.info_outline, size: 18),
                selectedLeading: const Icon(Icons.info, size: 18),
              ),
              TileData(
                onTap: () => showLicensePage(context: context),
                title: 'Licenses',
                leading: const Icon(Icons.copyright_outlined, size: 18),
                selectedLeading: const Icon(Icons.copyright, size: 18),
              ),
            ],
            onIndexChanged: (index) {
              log('current index: $index');
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
                    Wrap(
                      runSpacing: 5,
                      spacing: 3,
                      crossAxisAlignment: .center,
                      children: [
                        const Text('App Colors: '),
                        ...List.generate(appColors.length, (i) {
                          final color = appColors[i];
                          final bool isActive = appColorNotifier.value == color;
                          final widget = Container(
                            height: 30,
                            width: 30,
                            margin: const .all(3.5),
                            decoration: BoxDecoration(color: color, borderRadius: borderRadius),
                          );

                          return GestureDetector(
                            onTap: () => setState(() => appColorNotifier.value = color),
                            child: isActive
                                ? DecoratedBox(
                                    decoration: BoxDecoration(borderRadius: borderRadius, border: .all(color: Colors.grey)),
                                    child: widget,
                                  )
                                : widget,
                          );
                        }),
                      ],
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
              childFlex: 0,
              childPosition: .aboveItems,
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  ListTile(
                    leading: _isCollapsed == true ? const CircleAvatar(radius: 18, child: Text('LTR')) : null,
                    title: _isCollapsed == true
                        ? null
                        : Text(
                            'This is a RTL menu',
                            style: TextStyle(color: ColorScheme.of(context).primaryFixed),
                            overflow: .ellipsis,
                          ),
                    contentPadding: const EdgeInsets.all(5),
                  ),
                  Divider(color: ColorScheme.of(context).primaryFixed),
                ],
              ),
            ),
            footer: (_, _) => const Center(child: FlutterLogo(style: .stacked, size: 40)),
            items: [
              TileData(onTap: () => _controller.toggle(), title: 'Toggle menu'),
              const TileData(title: 'Example 2'),
              TileData(
                onTap: () => showLicensePage(context: context),
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
