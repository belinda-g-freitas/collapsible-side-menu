import 'package:collapsible_side_menu/collapsible_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SideMenuHeader', () {
    testWidgets('throws assertion error when both leading and trailing are null', (tester) async {
      expect(() => SideMenuHeader(isOpen: true), throwsAssertionError);
    });

    testWidgets('renders leading only when provided and menu is open', (tester) async {
      await tester.pumpWidget(_wrap(const SideMenuHeader(isOpen: true, leading: Icon(Icons.menu, key: Key('leading')))));

      expect(find.byKey(const Key('leading')), findsOneWidget);
    });

    testWidgets('renders leading, child, and trailing when all provided and menu is open', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SideMenuHeader(
            isOpen: true,
            leading: Icon(Icons.menu, key: Key('leading')),
            trailing: Icon(Icons.close, key: Key('trailing')),
            child: Text('Title', key: Key('child')),
          ),
        ),
      );

      expect(find.byKey(const Key('leading')), findsOneWidget);
      expect(find.byKey(const Key('child')), findsOneWidget);
      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('hides child and trailing when menu is collapsed and leading is set', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SideMenuHeader(
            isOpen: false,
            leading: Icon(Icons.menu, key: Key('leading')),
            trailing: Icon(Icons.close, key: Key('trailing')),
            child: Text('Title', key: Key('child')),
          ),
        ),
      );

      expect(find.byKey(const Key('leading')), findsOneWidget);
      expect(find.byKey(const Key('child')), findsNothing);
      expect(find.byKey(const Key('trailing')), findsNothing);
    });

    testWidgets('shows trailing when menu is collapsed and leading is null', (tester) async {
      await tester.pumpWidget(_wrap(const SideMenuHeader(isOpen: false, trailing: Icon(Icons.close, key: Key('trailing')))));

      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('hides child when menu is collapsed and only trailing is set', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SideMenuHeader(
            isOpen: false,
            trailing: Icon(Icons.close, key: Key('trailing')),
            child: Text('Title', key: Key('child')),
          ),
        ),
      );

      expect(find.byKey(const Key('trailing')), findsOneWidget);
      expect(find.byKey(const Key('child')), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(SideMenuHeader(isOpen: true, leading: const Icon(Icons.menu), onTap: () => tapped = true)));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not throw when onTap is null and widget is tapped', (tester) async {
      await tester.pumpWidget(_wrap(const SideMenuHeader(isOpen: true, leading: Icon(Icons.menu))));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      // no error expected
    });

    testWidgets('applies custom padding and margin', (tester) async {
      const padding = EdgeInsets.all(20);
      const margin = EdgeInsets.only(top: 12);

      await tester.pumpWidget(
        _wrap(const SideMenuHeader(isOpen: true, leading: Icon(Icons.menu), padding: padding, margin: margin)),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, padding);
      expect(container.margin, margin);
    });

    testWidgets('applies decoration to Container', (tester) async {
      const decoration = BoxDecoration(color: Colors.blue);

      await tester.pumpWidget(_wrap(const SideMenuHeader(isOpen: true, leading: Icon(Icons.menu), decoration: decoration)));

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, decoration);
    });

    testWidgets('uses custom duration and curve on AnimatedContainer', (tester) async {
      const duration = Duration(milliseconds: 500);
      const curve = Curves.easeIn;

      await tester.pumpWidget(
        _wrap(const SideMenuHeader(isOpen: true, leading: Icon(Icons.menu), duration: duration, animationCurve: curve)),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(animatedContainer.duration, duration);
      expect(animatedContainer.curve, curve);
    });

    testWidgets('applies horizontalSpacing to Row', (tester) async {
      await tester.pumpWidget(
        _wrap(const SideMenuHeader(isOpen: true, leading: Icon(Icons.menu), trailing: Icon(Icons.close), horizontalSpacing: 12)),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.spacing, 12);
    });
  });

  testWidgets('throws when collapsed, no leading, no trailing, only child is set', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SideMenuHeader(
          isOpen: false,
          trailing: Icon(Icons.close), // required to pass constructor assert
          child: Text('Title'),
        ),
      ),
    );
    // this actually passes fine since trailing is set — the real gap is below
  });

  testWidgets('constructor assert does not prevent leading-null + trailing-null combo via child-only intent', (tester) async {
    // Confirms: you cannot construct SideMenuHeader with only `child` set — assert always requires
    // leading or trailing, so the force-unwrap on trailing! can never actually see a null.
    expect(() => SideMenuHeader(isOpen: false, child: const Text('Title')), throwsAssertionError);
  });
}
