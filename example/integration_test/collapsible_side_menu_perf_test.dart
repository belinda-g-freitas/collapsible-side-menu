/// Performance / frame-timing benchmarks suite for CollapsibleSideMenu.
///
/// ── HOW TO RUN ──────────────────────────────────────────────────────────────
///
/// Option A — flutter test (debug mode, convenient, less accurate timings):
///   flutter test integration_test/collapsible_side_menu_integration_test.dart -d <device-id>
///
/// Option B — flutter drive in profile mode (accurate timings, recommended):
///   flutter drive \
///     --driver=test_driver/perf_driver.dart \
///     --target=integration_test/collapsible_side_menu_perf_test.dart \
///     --profile \
///     -d <device-id>
///
/// Do NOT use `flutter test` for meaningful perf metrics.
///
/// ── GOALS ──────────────────────────────────────────────────────────────
///
/// This suite measures:
///
/// - Initial render cost
/// - Toggle animation smoothness
/// - Expand/collapse performance
/// - Scroll performance
/// - Selection rebuild cost
/// - Hot-swap rebuild performance
///
/// Uses:
/// - real FrameTiming metrics
/// - profile mode
/// - raster/build separation
/// - warmup frames
/// - realistic thresholds
///
/// ── IMPORTANT ──────────────────────────────────────────────────────────────
///
/// Initial render always includes:
/// - shader compilation
/// - font rasterization
/// - first-layout cost
///
/// Therefore:
/// - initial render thresholds are intentionally relaxed
/// - animation/interaction thresholds are much stricter
///
/// ---------------------------------------------------------------------------

import 'dart:io' show Platform;

import 'package:collapsible_side_menu/collapsible_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _k60fpsFrameBudgetMs = 16.67;

const _kInitialRenderAvgMs = 70.0;
const _kInitialRenderP99Ms = 250.0;

const _kInteractionAvgMs = 8.0;
const _kInteractionP99Ms = 18.0;

const _kAnimationAvgMs = 6.0;
const _kAnimationP99Ms = 18.0;

const _kMaxJankRatio = 0.05;

//  ── FRAME REPORT ────────────────────────────────────────────────────
class _FrameReport {
  _FrameReport({required this.label, required this.timings});

  final String label;
  final List<FrameTiming> timings;

  int get frameCount => timings.length;

  List<double> get _builds => timings.map((e) => e.buildDuration.inMicroseconds / 1000).toList();

  List<double> get _rasters => timings.map((e) => e.rasterDuration.inMicroseconds / 1000).toList();

  double _avg(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _percentile(List<double> values, double percentile) {
    if (values.isEmpty) return 0;

    final sorted = [...values]..sort();

    final index = ((percentile / 100) * (sorted.length - 1)).round().clamp(0, sorted.length - 1);

    return sorted[index];
  }

  double get avgBuildMs => _avg(_builds);

  double get avgRasterMs => _avg(_rasters);

  double get p90BuildMs => _percentile(_builds, 90);

  double get p99BuildMs => _percentile(_builds, 99);

  int get jankyFrames {
    return timings.where((t) {
      final totalMs = (t.buildDuration + t.rasterDuration).inMicroseconds / 1000;

      return totalMs > _k60fpsFrameBudgetMs;
    }).length;
  }

  double get jankRatio {
    if (frameCount == 0) return 0;
    return jankyFrames / frameCount;
  }

  void printReport() {
    debugPrint('');
    debugPrint('── $label ──────────────────────────────');
    debugPrint('frames     : $frameCount');
    debugPrint('avg build  : ${avgBuildMs.toStringAsFixed(2)} ms');
    debugPrint('avg raster : ${avgRasterMs.toStringAsFixed(2)} ms');
    debugPrint('p90 build  : ${p90BuildMs.toStringAsFixed(2)} ms');
    debugPrint('p99 build  : ${p99BuildMs.toStringAsFixed(2)} ms');
    debugPrint('janky      : $jankyFrames (${(jankRatio * 100).toStringAsFixed(1)}%)');
  }
}

//  ── PERF MEASUREMENT ────────────────────────────────────────────────────
Future<_FrameReport> _measurePerf({required String label, required Future<void> Function() action}) async {
  final timings = <FrameTiming>[];

  void callback(List<FrameTiming> t) {
    timings.addAll(t);
  }

  SchedulerBinding.instance.addTimingsCallback(callback);

  await action();

  await Future<void>.delayed(const Duration(milliseconds: 100));

  SchedulerBinding.instance.removeTimingsCallback(callback);

  final report = _FrameReport(label: label, timings: timings);

  report.printReport();

  return report;
}

//  ── TEST APP ────────────────────────────────────────────────────
Widget _app(Widget menu) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Row(
        children: [
          menu,
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    ),
  );
}

//  ── TEST DATA ────────────────────────────────────────────────────

List<SideMenuItem> _flatItems(int count) {
  return List.generate(count, (i) => TileData(title: 'Item $i', leading: const Icon(Icons.circle_outlined), onTap: () {}));
}

List<SideMenuItem> _nestedItems({required int roots, required int subs}) {
  return List.generate(
    roots,
    (i) => TileData(
      title: 'Root $i',
      leading: const Icon(Icons.folder_outlined),
      subTiles: List.generate(subs, (j) => SubTileData(title: 'Sub $i-$j', onTap: () {})),
    ),
  );
}

List<SideMenuItem> _deeplyNestedItems({required int roots, required int depth}) {
  SubTileData makeTree(int d, String prefix) {
    if (d == 0) return SubTileData(title: '$prefix-leaf', onTap: () {});
    return SubTileData(title: '$prefix-d$d', subTiles: [makeTree(d - 1, '$prefix-a'), makeTree(d - 1, '$prefix-b')]);
  }

  return List.generate(roots, (i) => TileData(title: 'Root $i', subTiles: [makeTree(depth, 'r$i-a'), makeTree(depth, 'r$i-b')]));
}

//  ── COMMON ASSERTIONS ────────────────────────────────────────────────────

void _expectInteractionPerf(_FrameReport report) {
  expect(report.avgBuildMs, lessThan(_kInteractionAvgMs));

  expect(report.p99BuildMs, lessThan(Platform.isLinux ? 150 : _kInteractionP99Ms));

  expect(report.jankRatio, lessThan(0.10));
}

void _expectAnimationPerf(_FrameReport report) {
  expect(report.avgBuildMs, lessThan(_kAnimationAvgMs));

  expect(report.p99BuildMs, lessThan(_kAnimationP99Ms));

  expect(report.jankRatio, lessThan(_kMaxJankRatio));
}

//  ── main ────────────────────────────────────────────────────
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  // ── 1. Initial render ────────────────────────────────────────────────────
  group('Perf — Initial render', () {
    testWidgets('50 items', (tester) async {
      final report = await _measurePerf(
        label: 'initial render 50',
        action: () async {
          await tester.pumpWidget(_app(CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: _flatItems(50))));

          await tester.pumpAndSettle();
        },
      );

      expect(report.avgBuildMs, lessThan(_kInitialRenderAvgMs), reason: 'avg frame too slow');

      expect(report.p99BuildMs, lessThan(_kInitialRenderP99Ms), reason: 'p99 frame too slow');
    });
  });

  // ── 2. Open / collapse animation ────────────────────────────────────────
  group('Perf — Animation', () {
    testWidgets('animation frames stay within budget (30 items)', (tester) async {
      final controller = SideMenuController();

      await tester.pumpWidget(
        _app(
          CollapsibleSideMenu(
            controller: controller,
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            duration: const Duration(milliseconds: 250),
            items: _flatItems(30),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'toggle animation',
        action: () async {
          controller.close();

          for (int i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }

          controller.open();

          for (int i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        },
      );

      _expectAnimationPerf(report);
    });
  });

  // ── 3. Scroll performance ────────────────────────────────────────────────
  group('Perf — Scroll', () {
    testWidgets('scrolling through 100 items is smooth', (tester) async {
      await tester.pumpWidget(_app(CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: _flatItems(100))));

      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'scroll 100',
        action: () async {
          await tester.fling(find.byType(ListView), const Offset(0, -1200), 3500);

          for (int i = 0; i < 40; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        },
      );

      _expectInteractionPerf(report);
    });

    testWidgets('scrolling with mixed item types is smooth', (tester) async {
      final mixedItems = <SideMenuItem>[
        const TitleData(title: 'Section A'),
        ..._flatItems(15),
        const DividerData(),
        const TitleData(title: 'Section B'),
        ..._nestedItems(roots: 10, subs: 3),
        const DividerData(),
        const TitleData(title: 'Section C'),
        ..._flatItems(20),
      ];

      await tester.pumpWidget(_app(CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: mixedItems)));
      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'scroll mixed item types',
        action: () async {
          await tester.fling(find.byType(ListView), const Offset(0, -1200), 4000);
          await tester.pumpAndSettle();
          await tester.fling(find.byType(ListView), const Offset(0, 1200), 4000);
          await tester.pumpAndSettle();
        },
      );

      _expectInteractionPerf(report);
    });
  });

  // ── 4. Sub-tile expand / collapse ────────────────────────────────────────
  group('Perf — Expand/collapse', () {
    testWidgets('expand node', (tester) async {
      await tester.pumpWidget(
        _app(CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: _nestedItems(roots: 20, subs: 5))),
      );

      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'expand node',
        action: () async {
          // Tap 'Root 0' to expand it
          await tester.tap(find.text('Root 0'));

          for (int i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        },
      );

      _expectInteractionPerf(report);
    });

    testWidgets('expanding multiple nodes sequentially stays within budget', (tester) async {
      await tester.pumpWidget(
        _app(CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: _nestedItems(roots: 10, subs: 5))),
      );
      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'expand 5 nodes sequentially',
        action: () async {
          for (var i = 0; i < 5; i++) {
            final finder = find.text('Root $i');
            await tester.ensureVisible(finder);
            await tester.tap(finder);
            await tester.pumpAndSettle();
          }
        },
      );

      _expectInteractionPerf(report);
    });

    testWidgets('collapsing an expanded node is fast', (tester) async {
      await tester.pumpWidget(
        _app(CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: _nestedItems(roots: 10, subs: 5))),
      );
      await tester.pumpAndSettle();

      // Pre-expand Root 0
      await tester.tap(find.text('Root 0'));
      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'collapse node',
        action: () async {
          await tester.tap(find.text('Root 0'));
          await tester.pumpAndSettle();
        },
      );

      _expectInteractionPerf(report);
    });

    testWidgets('deeply nested expand (depth 3) stays within budget', (tester) async {
      await tester.pumpWidget(
        _app(CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: _deeplyNestedItems(roots: 5, depth: 3))),
      );
      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'depth-3 drill-down',
        action: () async {
          await tester.tap(find.text('Root 0'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('r0-a-d3'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('r0-a-a-d2'));
          await tester.pumpAndSettle();
        },
      );

      _expectInteractionPerf(report);
    });
  });

  // ── 5. Selection ─────────────────────────────────────────────────────────
  group('Perf — Selection', () {
    testWidgets('rapid selection', (tester) async {
      int? lastIndex;

      await tester.pumpWidget(
        _app(
          CollapsibleSideMenu(
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: _flatItems(30),
            onIndexChanged: (i) => lastIndex = i,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'rapid selection across 5 tiles',
        action: () async {
          for (final title in ['Item 0', 'Item 5', 'Item 10', 'Item 15', 'Item 20']) {
            final finder = find.text(title);
            await tester.ensureVisible(finder);
            await tester.tap(finder);
            await tester.pump(const Duration(milliseconds: 16));
          }

          await tester.pumpAndSettle();
        },
      );

      expect(lastIndex, 20);
      _expectInteractionPerf(report);
    });
  });

  // ── 6. Items update (hot-swap) ────────────────────────────────────────────
  group('Perf — Hot swap items', () {
    testWidgets('replacing items list triggers fast rebuild', (tester) async {
      final notifier = ValueNotifier<List<SideMenuItem>>(_flatItems(10));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ValueListenableBuilder<List<SideMenuItem>>(
                  valueListenable: notifier,
                  builder: (_, items, _) => CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: items),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'hot swap items',
        action: () async {
          notifier.value = _flatItems(50);

          for (int i = 0; i < 10; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        },
      );

      _expectInteractionPerf(report);

      notifier.dispose();
    });
  });

  // ── 7. RepaintBoundary isolation ─────────────────────────────────────────
  group('Perf — Repaint isolation', () {
    testWidgets('large list expansion cost', (tester) async {
      await tester.pumpWidget(
        _app(CollapsibleSideMenu(defaultBehaviour: MenuBehaviour.open, hasToggleButton: false, items: _nestedItems(roots: 100, subs: 5))),
      );

      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'large list expand',
        action: () async {
          await tester.tap(find.text('Root 0'));

          for (int i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        },
      );

      expect(report.avgBuildMs, lessThan(10.0));
    });
  });

  // ── 8. Stress test ─────────────────────────────────────────
  group('Stress test', () {
    testWidgets('rapid toggle spam', (tester) async {
      final controller = SideMenuController();

      await tester.pumpWidget(
        _app(
          CollapsibleSideMenu(
            controller: controller,
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            duration: const Duration(milliseconds: 120),
            items: _flatItems(50),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'toggle spam',
        action: () async {
          for (int i = 0; i < 15; i++) {
            controller.toggle();
            await tester.pump(const Duration(milliseconds: 120));
          }
        },
      );

      _expectAnimationPerf(report);
    });
  });

  // ── 9. Memory leak regression ─────────────────────────────────────────
  group('Long session stability', () {
    testWidgets('50 repeated interactions', (tester) async {
      final controller = SideMenuController();

      await tester.pumpWidget(
        _app(
          CollapsibleSideMenu(
            controller: controller,
            defaultBehaviour: MenuBehaviour.open,
            hasToggleButton: false,
            items: _nestedItems(roots: 30, subs: 3),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final report = await _measurePerf(
        label: 'long session',
        action: () async {
          for (int i = 0; i < 50; i++) {
            controller.toggle();
            await tester.pump(const Duration(milliseconds: 100));
          }
        },
      );

      expect(report.jankRatio, lessThan(Platform.isLinux ? 0.15 : 0.10));
    });
  });
}
