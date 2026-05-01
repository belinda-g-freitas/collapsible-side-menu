/// Run from the example/ folder with:
///   flutter drive \
///     --driver=test_driver/perf_driver.dart \
///     --target=integration_test/side_menu_benchmark.dart \
///     --profile \
///     -d <device_id>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:collapsible_side_menu/collapsible_side_menu.dart';

// ─────────────────────────────────────────────
// Shared harness
// ─────────────────────────────────────────────

Widget harness({
  required MenuBuilder builder,
  SideMenuController? controller,
  MenuBehaviour behaviour = MenuBehaviour.open,
  MenuHeaderBuilder? header,
  MenuHeaderBuilder? footer,
  CustomMenuChild? customMenuChild,
  Spacer? spacerAfterItems,
  double minWidth = 50,
  double maxWidth = 250,
  double screenWidth = 1200,
  Duration duration = Duration.zero,
}) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    home: MediaQuery(
      data: MediaQueryData(size: Size(screenWidth, 800)),
      child: Scaffold(
        body: Row(children: [
          CollapsibleSideMenu(
            builder: builder,
            controller: controller,
            defaultBehaviour: behaviour,
            header: header,
            footer: footer,
            customMenuChild: customMenuChild,
            spacerAfterItems: spacerAfterItems,
            minWidth: minWidth,
            maxWidth: maxWidth,
            hasToggleButton: false,
            duration: duration,
          ),
          const Expanded(child: SizedBox()),
        ]),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// Scenario builders
// ─────────────────────────────────────────────

/// 20 flat tiles
MenuBuilder flatTiles20() => (_, __) => List.generate(
      20,
      (i) => TileData(title: 'Tile $i', leading: const Icon(Icons.circle)),
    );

/// 10 parents × 5 sub-tiles
MenuBuilder nestedTiles() => (_, __) => List.generate(
      10,
      (i) => TileData(
        title: 'Parent $i',
        leading: const Icon(Icons.folder),
        subTiles: List.generate(5, (j) => SubTileData(title: 'Child $i-$j')),
      ),
    );

/// Mixed: titles, dividers, tiles, nested tiles
MenuBuilder mixedItems() => (_, __) => [
      const TitleData(title: 'Section A'),
      ...List.generate(5, (i) => TileData(title: 'A-$i')),
      const DividerData(),
      const TitleData(title: 'Section B'),
      ...List.generate(
        5,
        (i) => TileData(
          title: 'B-$i',
          subTiles: List.generate(3, (j) => SubTileData(title: 'B-$i-$j')),
        ),
      ),
    ];

/// Builder that uses selectedIndex and isOpen (exercises SideMenuBuilder data)
MenuBuilder reactiveBuilder() => (_, data) => List.generate(
      10,
      (i) => TileData(
        title: data.isOpen ? 'Open Tile $i' : 'T$i',
        leading: Icon(i == data.selectedIndex ? Icons.star : Icons.circle),
      ),
    );

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────

Future<double> measureFrames(WidgetTester tester, int count) async {
  final sw = Stopwatch()..start();
  for (int i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  sw.stop();
  return sw.elapsedMilliseconds.toDouble();
}

Future<void> toggleCycles(
  WidgetTester tester,
  SideMenuController controller,
  int cycles, {
  Duration animDuration = const Duration(milliseconds: 200),
}) async {
  for (int i = 0; i < cycles; i++) {
    controller.open();
    await tester.pump();
    await tester.pump(animDuration + const Duration(milliseconds: 50));
    controller.close();
    await tester.pump();
    await tester.pump(animDuration + const Duration(milliseconds: 50));
  }
}

// ─────────────────────────────────────────────
// Benchmarks
// ─────────────────────────────────────────────

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initial render ─────────────────────

  group('Benchmark: initial render', () {
    testWidgets('flat 20 tiles — open', (tester) async {
      await binding.watchPerformance(
        () async {
          await tester.pumpWidget(harness(builder: flatTiles20()));
          await tester.pumpAndSettle();
        },
        reportKey: 'initial_render_flat_20_open',
      );
    });

    testWidgets('flat 20 tiles — compact', (tester) async {
      await binding.watchPerformance(
        () async {
          await tester.pumpWidget(harness(
            builder: flatTiles20(),
            behaviour: MenuBehaviour.compact,
          ));
          await tester.pumpAndSettle();
        },
        reportKey: 'initial_render_flat_20_compact',
      );
    });

    testWidgets('nested 10×5 — open', (tester) async {
      await binding.watchPerformance(
        () async {
          await tester.pumpWidget(harness(builder: nestedTiles()));
          await tester.pumpAndSettle();
        },
        reportKey: 'initial_render_nested_10x5_open',
      );
    });

    testWidgets('mixed items — open', (tester) async {
      await binding.watchPerformance(
        () async {
          await tester.pumpWidget(harness(builder: mixedItems()));
          await tester.pumpAndSettle();
        },
        reportKey: 'initial_render_mixed_open',
      );
    });

    testWidgets('with header and footer builders', (tester) async {
      await binding.watchPerformance(
        () async {
          await tester.pumpWidget(harness(
            builder: flatTiles20(),
            header: (_, isOpen) => Row(children: [
              const CircleAvatar(radius: 20, child: FlutterLogo()),
              if (isOpen) const Text('John Doe'),
            ]),
            footer: (_, isOpen) => Column(children: [
              const Divider(),
              if (isOpen) const Text('v1.0.0'),
            ]),
          ));
          await tester.pumpAndSettle();
        },
        reportKey: 'initial_render_with_header_footer',
      );
    });
  });

  // ── 2. Toggle animation ───────────────────

  group('Benchmark: toggle animation', () {
    testWidgets('flat 20 tiles — real duration, 10 cycles', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(harness(
        builder: flatTiles20(),
        controller: controller,
        behaviour: MenuBehaviour.compact,
        duration: const Duration(milliseconds: 200), // real duration
      ));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async => toggleCycles(tester, controller, 10),
        reportKey: 'toggle_animation_flat_20_x10',
      );
    });

    testWidgets('nested 10×5 — real duration, 10 cycles', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(harness(
        builder: nestedTiles(),
        controller: controller,
        behaviour: MenuBehaviour.compact,
        duration: const Duration(milliseconds: 200),
      ));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async => toggleCycles(tester, controller, 10),
        reportKey: 'toggle_animation_nested_10x5_x10',
      );
    });

    testWidgets('with header+footer — real duration, 10 cycles', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(harness(
        builder: flatTiles20(),
        controller: controller,
        behaviour: MenuBehaviour.compact,
        duration: const Duration(milliseconds: 200),
        header: (_, isOpen) => Row(children: [
          const CircleAvatar(radius: 20, child: FlutterLogo()),
          if (isOpen) const Text('John Doe'),
        ]),
        footer: (_, isOpen) => isOpen ? const Text('v1.0.0') : const SizedBox.shrink(),
      ));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async => toggleCycles(tester, controller, 10),
        reportKey: 'toggle_animation_with_header_footer_x10',
      );
    });
  });

  // ── 3. Tile selection rebuild ─────────────

  group('Benchmark: tile selection', () {
    testWidgets('sequential — 20 tiles, 20 taps', (tester) async {
      await tester.pumpWidget(harness(builder: flatTiles20()));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          for (int i = 0; i < 20; i++) {
            await tester.tap(find.text('Tile $i', skipOffstage: false));
            await tester.pump();
          }
        },
        reportKey: 'selection_sequential_20_tiles',
      );
    });

    testWidgets('rapid alternating — 2 tiles, 50 taps', (tester) async {
      await tester.pumpWidget(harness(
        builder: (_, __) => [
          TileData(title: 'Alpha'),
          TileData(title: 'Beta'),
        ],
      ));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          for (int i = 0; i < 50; i++) {
            await tester.tap(find.text(i.isEven ? 'Alpha' : 'Beta', skipOffstage: false));
            await tester.pump();
          }
        },
        reportKey: 'selection_rapid_alternating_x50',
      );
    });

    testWidgets('reactive builder — selection triggers builder rebuild', (tester) async {
      // Exercises the new ValueListenableBuilder + _builder(isOpen, selection.index) path
      await tester.pumpWidget(harness(builder: reactiveBuilder()));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          for (int i = 0; i < 10; i++) {
            await tester.tap(find.text('Open Tile $i', skipOffstage: false));
            await tester.pump();
          }
        },
        reportKey: 'selection_reactive_builder_x10',
      );
    });
  });

  // ── 4. Sub-tile expand/collapse ───────────

  group('Benchmark: subtile expand/collapse', () {
    testWidgets('expand all 10 parents sequentially', (tester) async {
      await tester.pumpWidget(harness(builder: nestedTiles()));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          for (int i = 0; i < 10; i++) {
            await tester.tap(find.text('Parent $i', skipOffstage: false));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 50));
          }
        },
        reportKey: 'subtile_expand_all_10_parents',
      );
    });

    testWidgets('rapid toggle same parent — 20 cycles', (tester) async {
      await tester.pumpWidget(harness(builder: nestedTiles()));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          for (int i = 0; i < 20; i++) {
            await tester.tap(find.text('Parent 0', skipOffstage: false));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 30));
          }
        },
        reportKey: 'subtile_rapid_toggle_x20',
      );
    });

    testWidgets('expand + select child — 5 parents', (tester) async {
      await tester.pumpWidget(harness(builder: nestedTiles()));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          for (int i = 0; i < 5; i++) {
            await tester.tap(find.text('Parent $i', skipOffstage: false));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 30));
            await tester.tap(find.text('Child $i-0', skipOffstage: false));
            await tester.pump();
          }
        },
        reportKey: 'subtile_expand_and_select_x5',
      );
    });
  });

  // ── 5. Header/Footer builder cost ─────────

  group('Benchmark: header/footer builders', () {
    testWidgets('header rebuilds on toggle — 10 cycles', (tester) async {
      final controller = SideMenuController();

      // Header uses isOpen — rebuilds on every toggle
      await tester.pumpWidget(harness(
        builder: flatTiles20(),
        controller: controller,
        behaviour: MenuBehaviour.compact,
        duration: Duration.zero,
        header: (_, isOpen) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: isOpen
              ? const Row(key: ValueKey('open'), children: [
                  CircleAvatar(radius: 20, child: FlutterLogo()),
                  SizedBox(width: 8),
                  Text('John Doe'),
                ])
              : const CircleAvatar(key: ValueKey('closed'), radius: 20, child: FlutterLogo()),
        ),
        footer: (_, isOpen) => isOpen
            ? const Column(children: [Divider(), Text('v1.0.0')])
            : const SizedBox.shrink(),
      ));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async => toggleCycles(tester, controller, 10, animDuration: Duration.zero),
        reportKey: 'header_footer_builder_toggle_x10',
      );
    });

    testWidgets('header null — no header overhead', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(harness(
        builder: flatTiles20(),
        controller: controller,
        behaviour: MenuBehaviour.compact,
        duration: Duration.zero,
      ));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async => toggleCycles(tester, controller, 10, animDuration: Duration.zero),
        reportKey: 'no_header_footer_toggle_x10',
      );
    });
  });

  // ── 6. Scrolling ──────────────────────────

  group('Benchmark: scrolling', () {
    testWidgets('scroll 20 tiles up and down — open', (tester) async {
      await tester.pumpWidget(harness(builder: flatTiles20()));
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          await tester.fling(find.byType(ListView), const Offset(0, -600), 1500);
          await tester.pumpAndSettle();
          await tester.fling(find.byType(ListView), const Offset(0, 600), 1500);
          await tester.pumpAndSettle();
        },
        reportKey: 'scroll_flat_20_open',
      );
    });
  });

  // ── 7. Theme change ───────────────────────

  group('Benchmark: theme change', () {
    testWidgets('light → dark → light — 5 cycles, menu open', (tester) async {
      final themeNotifier = ValueNotifier(ThemeMode.light);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, mode, __) => MaterialApp(
            themeMode: mode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Scaffold(
                body: Row(children: [
                  CollapsibleSideMenu(
                    builder: flatTiles20(),
                    defaultBehaviour: MenuBehaviour.open,
                    hasToggleButton: false,
                    duration: Duration.zero,
                  ),
                  const Expanded(child: SizedBox()),
                ]),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          for (int i = 0; i < 5; i++) {
            themeNotifier.value = ThemeMode.dark;
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 50));
            themeNotifier.value = ThemeMode.light;
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 50));
          }
        },
        reportKey: 'theme_change_5_cycles_open',
      );
    });

    testWidgets('theme change — manually closed menu stays closed', (tester) async {
      final controller = SideMenuController();
      final themeNotifier = ValueNotifier(ThemeMode.light);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, mode, __) => MaterialApp(
            themeMode: mode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Scaffold(
                body: Row(children: [
                  CollapsibleSideMenu(
                    builder: flatTiles20(),
                    controller: controller,
                    defaultBehaviour: MenuBehaviour.auto,
                    hasToggleButton: false,
                    duration: Duration.zero,
                  ),
                  const Expanded(child: SizedBox()),
                ]),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.close();
      await tester.pumpAndSettle();

      await binding.watchPerformance(
        () async {
          for (int i = 0; i < 5; i++) {
            themeNotifier.value = ThemeMode.dark;
            await tester.pump();
            themeNotifier.value = ThemeMode.light;
            await tester.pump();
          }
        },
        reportKey: 'theme_change_override_preserved_5_cycles',
      );

      // Correctness: menu must still be collapsed despite auto on desktop
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect((animatedContainer.constraints)!.minWidth, 50);
    });
  });

  // ── 8. RepaintBoundary effectiveness ──────

  group('Benchmark: RepaintBoundary', () {
    testWidgets('selection with RepaintBoundary per tile — frame timing', (tester) async {
      await tester.pumpWidget(harness(builder: flatTiles20()));
      await tester.pumpAndSettle();

      final sw = Stopwatch()..start();
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.text('Tile $i', skipOffstage: false));
        await tester.pump();
      }
      sw.stop();

      final msPerTap = sw.elapsedMilliseconds / 20;
      debugPrint('[BENCHMARK] RepaintBoundary — avg ms/tap rebuild: $msPerTap');
      // Target: < 8ms (half the 16ms budget)
    });
  });

  // ── 9. Frame timing probe ─────────────────

  group('Benchmark: frame timing probe', () {
    testWidgets('ms/frame during toggle open animation', (tester) async {
      final controller = SideMenuController();
      await tester.pumpWidget(harness(
        builder: flatTiles20(),
        controller: controller,
        behaviour: MenuBehaviour.compact,
        duration: const Duration(milliseconds: 200),
      ));
      await tester.pumpAndSettle();

      controller.open();
      const animFrames = 13; // ~200ms / 16ms
      final elapsed = await measureFrames(tester, animFrames);
      final msPerFrame = elapsed / animFrames;

      debugPrint('[BENCHMARK] toggle open — avg ms/frame: $msPerFrame');
      // Target after RepaintBoundary fix: < 16.6ms
      // Previous result before fix: ~33ms
    });

    testWidgets('ms/frame during rapid selection', (tester) async {
      await tester.pumpWidget(harness(builder: flatTiles20()));
      await tester.pumpAndSettle();

      final sw = Stopwatch()..start();
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.text('Tile $i', skipOffstage: false));
        await tester.pump();
      }
      sw.stop();

      debugPrint('[BENCHMARK] selection — avg ms/tap: ${sw.elapsedMilliseconds / 20}');
    });

    testWidgets('ms/frame during subtile expand', (tester) async {
      await tester.pumpWidget(harness(builder: nestedTiles()));
      await tester.pumpAndSettle();

      final sw = Stopwatch()..start();
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Parent $i', skipOffstage: false));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 30));
      }
      sw.stop();

      debugPrint('[BENCHMARK] subtile expand — avg ms/tap: ${sw.elapsedMilliseconds / 10}');
    });
  });
}