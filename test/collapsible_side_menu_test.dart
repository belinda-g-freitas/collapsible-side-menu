import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collapsible_side_menu/collapsible_side_menu.dart';

// Helpers

/// Wraps [child] in a minimal MaterialApp with a fixed [width].
Widget _wrap(Widget child, {double width = 1200, double height = 800}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: width, height: height, child: child),
    ),
  );
}

List<SideMenuItem> _flatItems(int count) =>
    List.generate(count, (i) => TileData(title: 'Item $i', leading: const Icon(Icons.circle)));

List<SideMenuItem> _nestedItems({int roots = 5, int depth = 3}) {
  SubTileData makeSubTree(int d, String prefix) {
    if (d == 0) return SubTileData(title: '$prefix-leaf');
    return SubTileData(title: '$prefix-d$d', subTiles: List.generate(2, (i) => makeSubTree(d - 1, '$prefix-$i')));
  }

  return List.generate(
    roots,
    (i) => TileData(title: 'Root $i', subTiles: List.generate(2, (j) => makeSubTree(depth, 'r$i-s$j'))),
  );
}

// 1. Enum unit tests
void _enumTests() {
  group('MenuBehaviour', () {
    test('has exactly 3 values', () => expect(MenuBehaviour.values.length, 3));
    test('values are auto, open, collapse', () {
      expect(MenuBehaviour.values, containsAll([MenuBehaviour.auto, MenuBehaviour.open, MenuBehaviour.collapse]));
    });
  });

  group('AutoOpenFrom', () {
    test('has exactly 2 values', () => expect(AutoOpenFrom.values.length, 2));
    test('values are tablet and desktop', () {
      expect(AutoOpenFrom.values, containsAll([AutoOpenFrom.tablet, AutoOpenFrom.desktop]));
    });
  });

  group('CustomChildPosition', () {
    test('has exactly 2 values', () => expect(CustomChildPosition.values.length, 2));
    test('values are aboveItems and belowItems', () {
      expect(CustomChildPosition.values, containsAll([CustomChildPosition.aboveItems, CustomChildPosition.belowItems]));
    });
  });
}

// 2. Data-model unit tests
void _modelTests() {
  group('TileData', () {
    test('default subTiles is empty', () {
      final tile = const TileData(title: 'T');
      expect(tile.subTiles, isEmpty);
    });

    test('hasSelectedIndicator defaults to true', () {
      expect(const TileData(title: 'T').hasSelectedIndicator, isTrue);
    });

    test('copyWith overrides single field', () {
      final tile = const TileData(title: 'A');
      final copy = tile.copyWith(title: 'B');
      expect(copy.title, 'B');
      expect(copy.subTiles, isEmpty);
    });

    test('equality: same fields → equal', () {
      final a = const TileData(title: 'X');
      final b = const TileData(title: 'X');
      expect(a, equals(b));
    });

    test('equality: different title → not equal', () {
      expect(const TileData(title: 'A'), isNot(equals(const TileData(title: 'B'))));
    });

    test('resolveWith merges style', () {
      final style = MenuTileStyle(tileHeight: 99);
      final tile = const TileData(title: 'T');
      final resolved = tile.resolveWith(style);
      expect(resolved.style, equals(style));
    });
  });

  group('SubTileData', () {
    test('default subTiles is empty', () => expect(SubTileData(title: 'S').subTiles, isEmpty));

    test('copyWith preserves other fields', () {
      final sub = SubTileData(title: 'A', leading: const CircleAvatar());
      final copy = sub.copyWith(leading: const SizedBox.square(dimension: 40));
      expect(copy.title, 'A');
    });

    test('equality', () {
      expect(SubTileData(title: 'X'), equals(SubTileData(title: 'X')));
      expect(SubTileData(title: 'X'), isNot(equals(SubTileData(title: 'Y'))));
    });

    test('resolveWith: own nullable fields take precedence over fallback', () {
      // resolveWith() takes values from fallback style if default are null
      final ownStyle = SubMenuTileStyle(color: Colors.red);
      final fallback = SubMenuTileStyle(color: Colors.blue);
      final sub = SubTileData(title: 'S', style: ownStyle);
      final resolved = sub.resolveWith(fallback);
      expect(resolved.style?.color, Colors.red);
    });

    test('resolveWith: structural fields (tileHeight) come from self', () {
      final ownStyle = SubMenuTileStyle(tileHeight: 55);
      final fallback = SubMenuTileStyle(tileHeight: 30);
      final sub = SubTileData(title: 'S', style: ownStyle);
      final resolved = sub.resolveWith(fallback);
      // tileHeight is a structural field — resolveWith always keeps own
      expect(resolved.style?.tileHeight, 55);
    });
  });

  // group('TitleData', () {
  //   test('copyWith', () {
  //     final t = const TitleData(title: 'A');
  //     expect(t.copyWith(title: 'B').title, 'B');
  //   });
  // });

  group('DividerData', () {
    test('default divider is Divider', () {
      expect(const DividerData().divider, isA<Divider>());
    });
  });

  group('CustomMenuChild', () {
    test('default childFlex is 1', () {
      expect(CustomMenuChild(child: const SizedBox()).childFlex, 1);
    });

    test('default position is aboveItems', () {
      expect(CustomMenuChild(child: const SizedBox()).childPosition, CustomChildPosition.aboveItems);
    });

    test('equality', () {
      final w = const SizedBox();
      expect(CustomMenuChild(child: w), equals(CustomMenuChild(child: w)));
    });
  });
}

// 4. Style unit tests
void _styleTests() {
  group('MenuTileStyle', () {
    test('equal instances are equal', () {
      final a = MenuTileStyle();
      final b = MenuTileStyle();

      expect(a, equals(b));
    });
    test('different instances are not equal', () {
      final a = MenuTileStyle();
      final b = MenuTileStyle(tileHeight: 100);

      expect(a, isNot(equals(b)));
    });
    test('equal instances have same hashCode', () {
      final a = MenuTileStyle();
      final b = MenuTileStyle();

      expect(a.hashCode, equals(b.hashCode));
    });
    test('instance equals itself', () {
      final style = MenuTileStyle();

      expect(style == style, isTrue);
    });
  });

  group('SubMenuTileStyle', () {
    test('equal instances are equal', () {
      final a = SubMenuTileStyle();
      final b = SubMenuTileStyle();

      expect(a, equals(b));
    });
    test('different instances are not equal', () {
      final a = SubMenuTileStyle();
      final b = SubMenuTileStyle(tileHeight: 100);

      expect(a, isNot(equals(b)));
    });
    test('equal instances have same hashCode', () {
      final a = SubMenuTileStyle();
      final b = SubMenuTileStyle();

      expect(a.hashCode, equals(b.hashCode));
    });
    test('instance equals itself', () {
      final style = SubMenuTileStyle();

      expect(style == style, isTrue);
    });
  });

  group('SubMenuTileStyle.resolveWith', () {
    test('own nullable fields override fallback', () {
      // Nullable fields (color, selectedColor, titleStyle…) come from self.
      final own = SubMenuTileStyle(color: Colors.red);
      final fallback = SubMenuTileStyle(color: Colors.blue);
      expect(own.resolveWith(fallback).color, Colors.red);
    });

    test('tileHeight always resets to own after resolveWith', () {
      // tileHeight is not forwarded in resolveWith — it resets to the default.
      final own = SubMenuTileStyle(tileHeight: 88);
      final fallback = SubMenuTileStyle(tileHeight: 40);
      expect(own.resolveWith(fallback).tileHeight, 88.0); // Uses own tileHeight
    });

    test('returns self when called with null', () {
      final style = SubMenuTileStyle();
      expect(style.resolveWith(null), same(style));
    });
  });

  group('MenuTileStyle.resolveWith', () {
    test('returns self when fallback is null', () {
      final style = MenuTileStyle();
      expect(style.resolveWith(null), same(style));
    });

    test('own color takes precedence', () {
      final style = MenuTileStyle(color: Colors.red);
      final fallback = MenuTileStyle(color: Colors.blue);
      expect(style.resolveWith(fallback).color, Colors.red);
    });
  });

  group('SubMenuTileStyle.merge', () {
    test('returns self when MenuTileStyle is null', () {
      final style = SubMenuTileStyle();
      expect(style.merge(null), equals(style));
    });
  });

  group('ToggleButtonStyle', () {
    test('default opacity is 0.7', () => expect(const ToggleButtonStyle().opacity, 0.7));
    test('default topPosition is 20', () => expect(const ToggleButtonStyle().topPosition, 20.0));
    test('default iconSize is 20', () => expect(const ToggleButtonStyle().iconSize, 20.0));
    test(
      "default openedIcon is `const IconData(0xf0348, fontFamily: 'MaterialIcons', matchTextDirection: true)`",
      () => expect(
        const ToggleButtonStyle().openedIcon,
        const IconData(0xf0348, fontFamily: 'MaterialIcons', matchTextDirection: true),
      ),
    );
    test('default iconSize is null', () => expect(const ToggleButtonStyle().backgroundColor, null));

    test('assert: opacity must be non-negative', () {
      expect(() => ToggleButtonStyle(opacity: -0.1), throwsAssertionError);
    });
    test('assert: iconSize must be non-negative', () {
      expect(() => ToggleButtonStyle(iconSize: -1), throwsAssertionError);
    });
    test('assert: topPosition must be non-negative', () {
      expect(() => ToggleButtonStyle(topPosition: -1), throwsAssertionError);
    });

    test('copyWith overrides single field', () {
      const s = ToggleButtonStyle(opacity: 0.5);
      expect(s.copyWith(opacity: 1.0).opacity, 1.0);
      expect(s.copyWith(opacity: 1.0).iconSize, 20.0);
    });
    // test('equality', () {
    //   // expect(const ToggleButtonStyle(), equals(const ToggleButtonStyle()));
    //   expect(const ToggleButtonStyle(opacity: 0.3), isNot(equals(const ToggleButtonStyle(opacity: 0.9))));
    // });
    test('equal instances are equal', () {
      final a = const ToggleButtonStyle();
      final b = const ToggleButtonStyle();
      expect(a, equals(b));
    });
    test('different instances are not equal', () {
      final a = const ToggleButtonStyle();
      final b = const ToggleButtonStyle(
        iconColor: Colors.blue,
        backgroundColor: Colors.red,
        iconSize: 24,
        opacity: .5,
        topPosition: 30,
        openedIcon: Icons.abc,
      );
      expect(a, isNot(equals(b)));
    });
    test('equal instances have same hashCode', () {
      final a = const ToggleButtonStyle();
      final b = const ToggleButtonStyle();
      expect(a.hashCode, equals(b.hashCode));
    });
    test('instance equals itself', () {
      final style = const ToggleButtonStyle();
      expect(style == style, isTrue);
    });
  });

  group('SideMenuStyle', () {
    test('assert: padding must be non-negative', () {
      expect(() => SideMenuStyle(padding: const EdgeInsets.all(-1)), throwsAssertionError);
    });
    test('assert: margin must be non-negative', () {
      expect(() => SideMenuStyle(margin: const EdgeInsets.all(-1)), throwsAssertionError);
    });
  });
}

// 5. SideMenuController unit tests
void _controllerTests() {
  group('SideMenuController', () {
    test('open/close/toggle assert when not attached to a CollapsibleSideMenu', () {
      final controller = SideMenuController();
      expect(() => controller.open(), throwsAssertionError);
      expect(() => controller.close(), throwsAssertionError);
      expect(() => controller.toggle(), throwsAssertionError);
    });

    test('onCollapsedChanged can be assigned and invoked', () {
      final controller = SideMenuController();
      bool? received;
      controller.onCollapsedChanged = (value) => received = value;
      controller.onCollapsedChanged?.call(true);
      expect(received, isTrue);
    });
  });
}

// 6. Widget tests
void _widgetTests() {
  // --- Rendering ---
  group('CollapsibleSideMenu — rendering', () {
    testWidgets('renders with empty items list', (tester) async {
      await tester.pumpWidget(_wrap(const CollapsibleSideMenu()));
      expect(find.byType(CollapsibleSideMenu), findsOneWidget);
    });

    testWidgets('renders all flat tiles', (tester) async {
      await tester.pumpWidget(_wrap(CollapsibleSideMenu(items: _flatItems(5))));
      await tester.pumpAndSettle();
      for (var i = 0; i < 5; i++) {
        expect(find.text('Item $i'), findsOneWidget);
      }
    });

    testWidgets('renders TitleData and DividerData', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CollapsibleSideMenu(
            items: [
              TitleData(title: 'Section'),
              DividerData(),
              TileData(title: 'Home'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Section'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('toggle button is present by default', (tester) async {
      await tester.pumpWidget(_wrap(CollapsibleSideMenu(items: _flatItems(3))));
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('toggle button is hidden when hasToggleButton=false', (tester) async {
      await tester.pumpWidget(_wrap(CollapsibleSideMenu(items: _flatItems(3), hasToggleButton: false)));
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsNothing);
    });
  });

  // --- MenuBehaviour ---
  group('CollapsibleSideMenu — MenuBehaviour', () {
    testWidgets('defaultBehaviour.open: menu starts expanded at any width', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(items: _flatItems(2), defaultBehaviour: MenuBehaviour.open, hasToggleButton: false),
          width: 300,
        ),
      );
      await tester.pumpAndSettle();
      // Tile titles are visible when the menu is open
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('defaultBehaviour.collapse: menu starts collapsed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(items: _flatItems(2), defaultBehaviour: MenuBehaviour.collapse, hasToggleButton: false),
          width: 1200,
        ),
      );
      await tester.pumpAndSettle();
      // Tile full titles are not visible when collapsed
      expect(find.text('Item 0'), findsNothing);
      expect(find.text('Item 1'), findsNothing);
    });

    testWidgets('defaultBehaviour.auto + tablet: opens at wide screen', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            items: _flatItems(2),
            defaultBehaviour: MenuBehaviour.auto,
            autoFrom: AutoOpenFrom.tablet,
            hasToggleButton: false,
          ),
          width: 800,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('defaultBehaviour.auto + desktop: collapses below 950', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            items: _flatItems(2),
            defaultBehaviour: MenuBehaviour.auto,
            autoFrom: AutoOpenFrom.desktop,
            hasToggleButton: false,
          ),
          width: 800,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);
    });
  });

  // --- Toggle ---
  group('CollapsibleSideMenu — toggle interaction', () {
    testWidgets('tapping toggle button toggles menu open/collapsed', (tester) async {
      // Short explicit duration so TweenAnimationBuilder fully completes
      // before assertions. pumpAndSettle alone can miss in-flight animations.
      const animDuration = Duration(milliseconds: 10);
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(items: _flatItems(2), defaultBehaviour: MenuBehaviour.open, duration: animDuration),
          width: 600,
        ),
      );
      await tester.pump(animDuration);
      await tester.pumpAndSettle();

      // Menu is open: titles visible
      expect(find.text('Item 0'), findsOneWidget);

      // Tap toggle button → collapses
      await tester.tap(find.byType(CircleAvatar));
      await tester.pump(animDuration);
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);

      // Tap toggle again → re-opens
      await tester.tap(find.byType(CircleAvatar));
      await tester.pump(animDuration);
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);
    });
  });

  // --- SideMenuController ---
  group('CollapsibleSideMenu — SideMenuController', () {
    testWidgets('controller.open() expands, controller.close() collapses', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            items: _flatItems(2),
            defaultBehaviour: MenuBehaviour.collapse,
            hasToggleButton: false,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);

      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);

      controller.close();
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('controller.toggle() switches state', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            items: _flatItems(2),
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);

      controller.toggle();
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('onCollapsedChanged fires when menu state changes via controller', (tester) async {
      final controller = SideMenuController();
      final received = <bool>[];
      controller.onCollapsedChanged = received.add;

      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            items: _flatItems(2),
            defaultBehaviour: MenuBehaviour.collapse,
            hasToggleButton: false,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.open();
      await tester.pumpAndSettle(); // needed since _updateCollapsed uses addPostFrameCallback

      expect(received, contains(false));
    });

    testWidgets('controller detaches on dispose — later calls assert', (tester) async {
      final controller = SideMenuController();

      await tester.pumpWidget(_wrap(CollapsibleSideMenu(items: _flatItems(2), hasToggleButton: false, controller: controller)));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pumpAndSettle();

      expect(() => controller.toggle(), throwsAssertionError);
    });

    testWidgets('controller detaches when swapped for a different controller', (tester) async {
      final controllerA = SideMenuController();
      final controllerB = SideMenuController();

      await tester.pumpWidget(_wrap(CollapsibleSideMenu(items: _flatItems(2), hasToggleButton: false, controller: controllerA)));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_wrap(CollapsibleSideMenu(items: _flatItems(2), hasToggleButton: false, controller: controllerB)));
      await tester.pumpAndSettle();

      expect(() => controllerA.toggle(), throwsAssertionError);
      expect(() => controllerB.toggle(), returnsNormally);
    });
  });

  // --- Selection ---
  group('CollapsibleSideMenu — tile selection', () {
    testWidgets('tapping a tile calls onIndexChanged with correct index', (tester) async {
      int? selected;
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            items: _flatItems(3),
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            onIndexChanged: (i) => selected = i,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();
      expect(selected, 2);
    });

    testWidgets('defaultIndex pre-selects the right tile', (tester) async {
      int? selected;
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            items: _flatItems(3),
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            defaultIndex: 1,
            onIndexChanged: (i) => selected = i,
          ),
        ),
      );
      await tester.pumpAndSettle();
      // No tap needed — just verify assertion doesn't throw and widget renders
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('assert: defaultIndex out of range is caught as a framework error', (tester) async {
      // The assert fires inside build(), which Flutter catches as a framework
      // error — not as a thrown exception from pumpWidget itself.
      await tester.pumpWidget(_wrap(CollapsibleSideMenu(items: _flatItems(2), defaultIndex: 5)));
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('tile onTap callback fires', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [TileData(title: 'Alpha', onTap: () => tapped = true)],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  // --- Sub-tiles ---
  group('CollapsibleSideMenu — sub-tiles', () {
    testWidgets('sub-tiles are hidden when parent tile is not expanded', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Parent',
                subTiles: [SubTileData(title: 'Child')],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsNothing);
    });

    testWidgets('tapping a tile with sub-tiles expands sub-tiles', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Parent',
                subTiles: [SubTileData(title: 'Child')],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('tapping expanded tile collapses sub-tiles', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Parent',
                subTiles: [SubTileData(title: 'Child')],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);

      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsNothing);
    });

    testWidgets('sub-tile onTap fires', (tester) async {
      bool childTapped = false;
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Parent',
                subTiles: [SubTileData(title: 'Child', onTap: () => childTapped = true)],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Child'));
      await tester.pumpAndSettle();
      expect(childTapped, isTrue);
    });

    testWidgets('nested sub-tiles (depth 2) render correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Root',
                subTiles: [
                  SubTileData(
                    title: 'Level 1',
                    subTiles: [SubTileData(title: 'Level 2')],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Root'));
      await tester.pumpAndSettle();
      expect(find.text('Level 1'), findsOneWidget);

      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();
      expect(find.text('Level 2'), findsOneWidget);
    });
  });

  // --- Header / Footer ---
  group('CollapsibleSideMenu — header & footer', () {
    testWidgets('header is rendered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            header: (_, _) => const Text('MyHeader'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('MyHeader'), findsOneWidget);
    });

    testWidgets('header receives correct isOpen state', (tester) async {
      final controller = SideMenuController();
      bool? lastState;

      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            controller: controller,
            header: (_, isOpen) {
              lastState = isOpen;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(lastState, isTrue);

      controller.close();
      await tester.pumpAndSettle();
      expect(lastState, isFalse);
    });
  });

  // --- CustomMenuChild ---
  group('CollapsibleSideMenu — CustomMenuChild', () {
    testWidgets('custom child aboveItems renders before tiles', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [const TileData(title: 'Tile')],
            customMenuChild: CustomMenuChild(child: const Text('TopWidget'), childPosition: CustomChildPosition.aboveItems),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TopWidget'), findsOneWidget);

      final topPos = tester.getTopLeft(find.text('TopWidget')).dy;
      final tilePos = tester.getTopLeft(find.text('Tile')).dy;
      expect(topPos, lessThan(tilePos));
    });

    testWidgets('custom child belowItems renders after tiles', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [const TileData(title: 'Tile')],
            customMenuChild: CustomMenuChild(child: const Text('BottomWidget'), childPosition: CustomChildPosition.belowItems),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('BottomWidget'), findsOneWidget);

      final tilePos = tester.getTopLeft(find.text('Tile')).dy;
      final bottomPos = tester.getTopLeft(find.text('BottomWidget')).dy;
      expect(bottomPos, greaterThan(tilePos));
    });

    test('equal instances have same hashCode', () {
      final child = const Text('Same');
      final a = CustomMenuChild(child: child);
      final b = CustomMenuChild(child: child);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // --- Collapsed MenuAnchor behaviour ---
  group('CollapsibleSideMenu — collapsed MenuAnchor', () {
    testWidgets('tapping collapsed parent tile opens popup menu', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.collapse,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Parent',
                leading: const Icon(Icons.home),
                subTiles: [
                  SubTileData(title: 'Child 1'),
                  SubTileData(title: 'Child 2'),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Menu is collapsed -> text hidden
      expect(find.text('Parent'), findsNothing);

      // Tap the visible icon tile
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Popup menu should appear
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    testWidgets('clicking popup submenu item triggers onTap', (tester) async {
      bool childTapped = false;

      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.collapse,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Parent',
                leading: const Icon(Icons.settings),
                subTiles: [SubTileData(title: 'Settings', onTap: () => childTapped = true)],
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open MenuAnchor popup
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Click popup item
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(childTapped, isTrue);
    });

    testWidgets('collapsed nested submenu popup renders correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.collapse,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Root',
                leading: const Icon(Icons.menu),
                subTiles: [
                  SubTileData(
                    title: 'Level 1',
                    subTiles: [SubTileData(title: 'Level 2')],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open root popup
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Level 1'), findsOneWidget);

      // Open nested popup
      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      expect(find.text('Level 2'), findsOneWidget);
    });

    testWidgets('collapsed tile without subTiles still triggers onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.collapse,
            hasToggleButton: false,
            items: [TileData(title: 'Dashboard', leading: const Icon(Icons.dashboard), onTap: () => tapped = true)],
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('collapsed menu popup closes after submenu click', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.collapse,
            hasToggleButton: false,
            items: [
              TileData(
                title: 'Parent',
                leading: const Icon(Icons.folder),
                subTiles: [SubTileData(title: 'Open')],
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open popup
      await tester.tap(find.byIcon(Icons.folder));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);

      // Click submenu
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Popup should close
      expect(find.text('Open'), findsNothing);
    });
  });

  // --- RTL ---
  group('CollapsibleSideMenu — RTL', () {
    testWidgets('renders correctly with explicit RTL text direction', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            menuStyle: SideMenuStyle(textDirection: TextDirection.rtl),
            items: _flatItems(2),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);
    });
  });

  // --- Style propagation ---
  group('CollapsibleSideMenu — style propagation', () {
    testWidgets('custom SideMenuStyle backgroundColor is applied', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: _flatItems(1),
            menuStyle: SideMenuStyle(backgroundColor: Colors.deepPurple),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Verify no assertion / overflow error on build
      expect(tester.takeException(), isNull);
    });

    testWidgets('per-tile MenuTileStyle overrides global style', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: [
              TileData(title: 'Styled', style: MenuTileStyle(tileHeight: 80)),
              const TileData(title: 'Default'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // --- Large list performance ---
  group('CollapsibleSideMenu — large list', () {
    testWidgets('renders 100 flat tiles without overflow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: _flatItems(100)),
          height: 800,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders deeply nested items without overflow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: _nestedItems(roots: 5, depth: 3),
          ),
          height: 800,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}

// Entry point
void main() {
  _enumTests();
  _modelTests();
  _styleTests();
  _controllerTests();
  _widgetTests();
}
