import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collapsible_side_menu/collapsible_side_menu.dart';
import 'package:collapsible_side_menu/src/models/data/side_menu_item_data.dart';
import 'package:collapsible_side_menu/src/side_menu_width_mixin.dart';
import 'package:collapsible_side_menu/src/widgets/colored_content.dart';
import 'package:collapsible_side_menu/src/widgets/side_menu_divider.dart';
import 'package:collapsible_side_menu/src/widgets/side_menu_tile.dart';
import 'package:collapsible_side_menu/src/widgets/toggle_button.dart';

class _TestWidthCalculator with SideMenuWidthMixin {}

void main() {
  // Helpers

  /// Wraps [SideMenu] in a minimal testable app.
  Widget buildApp({
    required SideMenuBuilder builder,
    SideMenuController? controller,
    MenuBehaviour defaultBehaviour = MenuBehaviour.auto,
    double minWidth = 50,
    double maxWidth = 250,
    bool hasToggleButton = true,
    ToggleButtonStyle? toggleButtonStyle,
    Duration duration = Duration.zero, // skip animations in tests
    SideMenuStyle? menuStyle,
    int? defaultIndex,
    double screenWidth = 1200, // desktop by default
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: MediaQuery(
        data: MediaQueryData(size: Size(screenWidth, 800)),
        child: Scaffold(
          body: Row(
            children: [
              CollapsibleSideMenu(
                builder: builder,
                controller: controller,
                defaultBehaviour: defaultBehaviour,
                minWidth: minWidth,
                maxWidth: maxWidth,
                hasToggleButton: hasToggleButton,
                toggleButtonStyle: toggleButtonStyle,
                duration: duration,
                menuStyle: menuStyle,
                defaultIndex: defaultIndex,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  SideMenuBuilder simpleBuilder({List<SideMenuItemData>? items, Widget? header, Widget? footer, Widget? customChild}) {
    return (context, data) => SideMenu(
      header: header,
      footer: footer,
      items:
          items ??
          [
            TileData(title: 'Home', leading: const Icon(Icons.home)),

            TileData(title: 'Settings', leading: const Icon(Icons.settings)),
          ],
      customChild: customChild,
    );
  }

  // 1. Rendering & initial state

  group('SideMenu — rendering', () {
    testWidgets('renders without errors with minimal config', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder()));
      expect(find.byType(CollapsibleSideMenu), findsOneWidget);
    });

    testWidgets('renders toggle button when hasToggleButton is true', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(), hasToggleButton: true));
      expect(find.byType(ToggleButton), findsOneWidget);
    });

    testWidgets('does NOT render toggle button when hasToggleButton is false', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(), hasToggleButton: false));
      expect(find.byType(ToggleButton), findsNothing);
    });

    testWidgets('renders header when provided', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(header: const Text('MyHeader'))));
      expect(find.text('MyHeader'), findsOneWidget);
    });

    testWidgets('renders footer when provided', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(footer: const Text('MyFooter'))));
      expect(find.text('MyFooter'), findsOneWidget);
    });

    testWidgets('renders all tile titles when menu is open', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.open));
      await tester.pump();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders SideMenuDivider', (tester) async {
      await tester.pumpWidget(
        buildApp(
          builder: (ctx, data) => SideMenu(
            items: [
              TileData(title: 'Home'),
              const DividerData(),
              TileData(title: 'Settings'),
            ],
          ),
          defaultBehaviour: MenuBehaviour.open,
        ),
      );
      await tester.pump();
      expect(find.byType(SideMenuDivider), findsOneWidget);
    });

    testWidgets('renders SideMenuTitleData as section title', (tester) async {
      await tester.pumpWidget(
        buildApp(
          builder: (ctx, data) => SideMenu(
            items: [
              const TitleData(title: 'Navigation'),
              TileData(title: 'Home'),
            ],
          ),
          defaultBehaviour: MenuBehaviour.open,
        ),
      );
      await tester.pump();
      expect(find.text('Navigation'), findsOneWidget);
    });
  });

  // 2. MenuBehaviour.auto

  group('MenuBehaviour.auto', () {
    testWidgets('opens on desktop screen (width >= 1200)', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.auto, screenWidth: 1200));
      await tester.pump();
      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      final BoxConstraints constraints = (animatedContainer.constraints)!;
      expect(constraints.maxWidth, 250);
    });

    testWidgets('collapses on mobile screen (width < 1200)', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.auto, screenWidth: 600));
      await tester.pump();
      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      final BoxConstraints constraints = (animatedContainer.constraints)!;
      expect(constraints.minWidth, 50);
    });
  });

  // 3. MenuBehaviour.open

  group('MenuBehaviour.open', () {
    testWidgets('always starts at maxWidth regardless of screen size', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.open, screenWidth: 400));
      await tester.pump();
      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect((animatedContainer.constraints)!.maxWidth, 250);
    });
  });

  // 4. MenuBehaviour.compact

  group('MenuBehaviour.compact', () {
    testWidgets('always starts at minWidth regardless of screen size', (tester) async {
      await tester.pumpWidget(buildApp(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.compact, screenWidth: 1920));
      await tester.pump();
      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect((animatedContainer.constraints)!.minWidth, 50);
    });
  });

  // 5. Toggle button

  group('Toggle button', () {
    testWidgets('tapping toggle button opens a collapsed menu', (tester) async {
      await tester.pumpWidget(
        buildApp(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.compact, hasToggleButton: true, duration: Duration.zero),
      );
      await tester.pump();

      // Hover to make toggle button visible, then tap
      final toggleFinder = find.byType(ToggleButton);
      await tester.tap(toggleFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect((animatedContainer.constraints)!.maxWidth, 250);
    });

    testWidgets('tapping toggle button closes an open menu', (tester) async {
      await tester.pumpWidget(
        buildApp(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.open, hasToggleButton: true, duration: Duration.zero),
      );
      await tester.pump();

      await tester.tap(find.byType(ToggleButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect((animatedContainer.constraints)!.minWidth, 50);
    });
  });

  // 6. SideMenuController

  group('SideMenuController', () {
    testWidgets('controller.open() opens the menu', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(
        buildApp(
          builder: simpleBuilder(),
          controller: controller,
          defaultBehaviour: MenuBehaviour.compact,
          hasToggleButton: false,
          duration: Duration.zero,
        ),
      );
      await tester.pump();

      controller.open();
      await tester.pump();

      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect((animatedContainer.constraints)!.maxWidth, 250);
    });

    testWidgets('controller.close() closes the menu', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(
        buildApp(
          builder: simpleBuilder(),
          controller: controller,
          defaultBehaviour: MenuBehaviour.open,
          hasToggleButton: false,
          duration: Duration.zero,
        ),
      );
      await tester.pump();

      controller.close();
      await tester.pump();

      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect((animatedContainer.constraints)!.minWidth, 50);
    });

    testWidgets('controller.toggle() toggles menu state', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(
        buildApp(
          builder: simpleBuilder(),
          controller: controller,
          defaultBehaviour: MenuBehaviour.compact,
          hasToggleButton: false,
          duration: Duration.zero,
        ),
      );
      await tester.pump();

      // open
      controller.toggle();
      await tester.pump();
      final openContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect((openContainer.constraints)!.maxWidth, 250);

      // close
      controller.toggle();
      await tester.pump();
      final closedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect((closedContainer.constraints)!.minWidth, 50);
    });

    testWidgets('controller.isCollapsed reflects current state', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(
        buildApp(
          builder: simpleBuilder(),
          controller: controller,
          defaultBehaviour: MenuBehaviour.compact,
          hasToggleButton: false,
          duration: Duration.zero,
        ),
      );
      await tester.pump();

      expect(controller.isCollapsed, isTrue);

      controller.open();
      await tester.pump();

      expect(controller.isCollapsed, isFalse);
    });

    testWidgets('theme change does NOT reset manually overridden width', (tester) async {
      final controller = SideMenuController();
      final themeNotifier = ValueNotifier(ThemeMode.light);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, mode, _) => MaterialApp(
            themeMode: mode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Scaffold(
                body: Row(
                  children: [
                    CollapsibleSideMenu(
                      builder: simpleBuilder(),
                      controller: controller,
                      defaultBehaviour: MenuBehaviour.auto,
                      hasToggleButton: false,
                      duration: Duration.zero,
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Manually collapse
      controller.close();
      await tester.pump();

      // Trigger a theme change (causes didChangeDependencies)
      themeNotifier.value = ThemeMode.dark;
      await tester.pump();
      await tester.pump();

      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      // Should stay collapsed despite auto behaviour on desktop
      expect((animatedContainer.constraints)!.minWidth, 50);
    });
  });

  // 7. Selection

  group('Selection', () {
    testWidgets('tapping a tile selects it', (tester) async {
      int? selected;
      await tester.pumpWidget(
        buildApp(
          builder: (ctx, data) => SideMenu(
            items: [
              TileData(title: 'Home', onTap: () => selected = data.selectedIndex),
              TileData(title: 'Settings'),
            ],
          ),
          defaultBehaviour: MenuBehaviour.open,
          hasToggleButton: false,
          duration: Duration.zero,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(selected, isNotNull);
    });

    testWidgets('defaultIndex pre-selects a tile', (tester) async {
      await tester.pumpWidget(
        buildApp(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, defaultIndex: 1, duration: Duration.zero),
      );
      await tester.pump();

      // The second tile (index 1 = Settings) should be selected
      final tiles = tester.widgetList<SideMenuTile>(find.byType(SideMenuTile));
      final settingsTile = tiles.elementAt(1);
      expect(settingsTile.isSelected, isTrue);
    });

    testWidgets('selectedIndex is passed to builder', (tester) async {
      int? builtSelectedIndex;
      await tester.pumpWidget(
        buildApp(
          builder: (ctx, data) {
            builtSelectedIndex = data.selectedIndex;
            return SideMenu(
              items: [
                TileData(title: 'Home'),
                TileData(title: 'Settings'),
              ],
            );
          },
          defaultBehaviour: MenuBehaviour.open,
          hasToggleButton: false,
          defaultIndex: 0,
          duration: Duration.zero,
        ),
      );
      await tester.pump();
      expect(builtSelectedIndex, 0);
    });
  });

  // 8. Sub-tiles

  group('Sub-tiles', () {
    testWidgets('tapping a parent tile with subtiles expands them', (tester) async {
      await tester.pumpWidget(
        buildApp(
          builder: (ctx, data) => SideMenu(
            items: [
              TileData(
                title: 'Parent',
                subTiles: [
                  SubTileData(title: 'Child A'),
                  SubTileData(title: 'Child B'),
                ],
              ),
            ],
          ),
          defaultBehaviour: MenuBehaviour.open,
          hasToggleButton: false,
          duration: Duration.zero,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Parent'));
      await tester.pump();

      expect(find.text('Child A'), findsOneWidget);
      expect(find.text('Child B'), findsOneWidget);
    });

    testWidgets('tapping expanded parent tile collapses subtiles', (tester) async {
      await tester.pumpWidget(
        buildApp(
          builder: (ctx, data) => SideMenu(
            items: [
              TileData(
                title: 'Parent',
                subTiles: [SubTileData(title: 'Child A')],
              ),
            ],
          ),
          defaultBehaviour: MenuBehaviour.open,
          hasToggleButton: false,
          duration: Duration.zero,
        ),
      );
      await tester.pump();

      // expand
      await tester.tap(find.text('Parent'));
      await tester.pump();

      // collapse
      await tester.tap(find.text('Parent'));
      await tester.pump();

      // Child A is still in the tree (maintainState) but not visible
      final visibility = tester.widget<Visibility>(find.ancestor(of: find.text('Child A'), matching: find.byType(Visibility)).first);
      expect(visibility.visible, isFalse);
    });

    testWidgets('tapping a sub-tile calls its onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildApp(
          builder: (ctx, data) => SideMenu(
            items: [
              TileData(
                title: 'Parent',
                subTiles: [SubTileData(title: 'Child A', onTap: () => tapped = true)],
              ),
            ],
          ),
          defaultBehaviour: MenuBehaviour.open,
          hasToggleButton: false,
          duration: Duration.zero,
        ),
      );
      await tester.pump();

      // Expand parent
      await tester.tap(find.text('Parent'));
      await tester.pump();

      // Tap child
      await tester.tap(find.text('Child A'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  // 9. RTL support

  group('RTL', () {
    testWidgets('menu renders correctly in RTL direction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Scaffold(
                body: Row(
                  children: [
                    CollapsibleSideMenu(builder: simpleBuilder(), defaultBehaviour: MenuBehaviour.open, hasToggleButton: true, duration: Duration.zero),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CollapsibleSideMenu), findsOneWidget);
    });
  });

  // 10. SideMenuStyle

  group('SideMenuStyle', () {
    testWidgets('custom backgroundColor is applied', (tester) async {
      await tester.pumpWidget(
        buildApp(
          builder: simpleBuilder(),
          menuStyle: SideMenuStyle(backgroundColor: Colors.red),
          hasToggleButton: false,
          defaultBehaviour: MenuBehaviour.open,
        ),
      );
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('custom textDirection overrides app direction', (tester) async {
      await tester.pumpWidget(
        buildApp(
          builder: simpleBuilder(),
          menuStyle: SideMenuStyle(textDirection: TextDirection.rtl),
          hasToggleButton: false,
          defaultBehaviour: MenuBehaviour.open,
        ),
      );
      await tester.pump();
      expect(find.byType(Directionality), findsWidgets);
    });
  });

  // 11. SideMenuWidthMixin unit tests

  group('SideMenuWidthMixin', () {
    final calc = _TestWidthCalculator();
    const min = 50.0;
    const max = 250.0;

    test('auto returns maxWidth on desktop (width >= 992)', () {
      final result = calc.calculateWidthSize(behaviour: MenuBehaviour.auto, minWidth: min, maxWidth: max, currentWidth: 0, deviceWidth: 1200);
      expect(result, max);
    });

    test('auto returns minWidth on mobile (width < 992)', () {
      final result = calc.calculateWidthSize(behaviour: MenuBehaviour.auto, minWidth: min, maxWidth: max, currentWidth: 0, deviceWidth: 600);
      expect(result, min);
    });

    test('open always returns maxWidth when not custom', () {
      final result = calc.calculateWidthSize(behaviour: MenuBehaviour.open, minWidth: min, maxWidth: max, currentWidth: 0, deviceWidth: 400);
      expect(result, max);
    });

    test('compact always returns minWidth when not custom', () {
      final result = calc.calculateWidthSize(behaviour: MenuBehaviour.compact, minWidth: min, maxWidth: max, currentWidth: 0, deviceWidth: 1920);
      expect(result, min);
    });

    test('preserves custom width (user override)', () {
      const customWidth = 150.0;
      final result = calc.calculateWidthSize(
        behaviour: MenuBehaviour.auto,
        minWidth: min,
        maxWidth: max,
        currentWidth: customWidth,
        deviceWidth: 1200,
      );
      expect(result, customWidth);
    });

    test('zeroWidth is treated as uninitialized and recalculates', () {
      final result = calc.calculateWidthSize(behaviour: MenuBehaviour.open, minWidth: min, maxWidth: max, currentWidth: 0, deviceWidth: 1200);
      expect(result, max);
    });
  });

  // 12. SideMenuData model

  group('SideMenuData', () {
    test('assert fails when both items and customChild are null', () {
      expect(() => SideMenu(), throwsA(isA<AssertionError>()));
    });

    test('valid with items only', () {
      expect(() => SideMenu(items: [TileData(title: 'Home')]), returnsNormally);
    });

    test('valid with customChild only', () {
      expect(() => const SideMenu(customChild: SizedBox()), returnsNormally);
    });
  });

  // 13. SideMenuTileData model

  group('SideMenuTileData', () {
    test('copyWith overrides only specified fields', () {
      final tile = TileData(title: 'Home', hasSelectedIndicator: true);
      final copy = tile.copyWith(title: 'Dashboard');
      expect(copy.title, 'Dashboard');
      expect(copy.hasSelectedIndicator, isTrue);
    });

    test('resolveWith uses provided style when tile style is null', () {
      final tile = TileData(title: 'Home');
      final style = MenuTileStyle(color: Colors.blue);
      final resolved = tile.resolveWith(style);
      expect(resolved.style, style);
    });

    test('resolveWith keeps tile style when already set', () {
      final tileStyle = MenuTileStyle(color: Colors.red);
      final tile = TileData(title: 'Home', style: tileStyle);
      final resolved = tile.resolveWith(MenuTileStyle(color: Colors.blue));
      expect(resolved.style?.color, Colors.red);
    });
  });

  // 14. ColoredContent

  group('ColoredContent', () {
    testWidgets('propagates color via DefaultTextStyle and IconTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ColoredContent(
            color: Colors.purple,
            child: Builder(
              builder: (ctx) {
                final textColor = DefaultTextStyle.of(ctx).style.color;
                final iconColor = IconTheme.of(ctx).color;
                return Column(children: [Text('textColor: $textColor'), Text('iconColor: $iconColor')]);
              },
            ),
          ),
        ),
      );
      expect(find.textContaining('purple'), findsWidgets);
    });
  });
}
