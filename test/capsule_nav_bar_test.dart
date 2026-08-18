import 'package:capsule_nav_bar/capsule_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget host(
    Widget child, {
    TextDirection direction = TextDirection.ltr,
    CapsuleNavBarTheme? theme,
    double width = 390,
  }) => MaterialApp(
    theme: ThemeData(extensions: theme == null ? const [] : [theme]),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(left: 0, bottom: 0, width: width, child: child),
          ],
        ),
      ),
    ),
  );

  const destinations = [
    NavBarDestination(
      label: 'Home',
      lineIcon: Icons.home_outlined,
      fillIcon: Icons.home,
    ),
    NavBarDestination(
      label: 'Search',
      lineIcon: Icons.search_outlined,
      fillIcon: Icons.search,
    ),
    NavBarDestination(
      label: 'Account',
      lineIcon: Icons.person_outline,
      fillIcon: Icons.person,
    ),
  ];

  final indicator = find.byKey(CapsuleNavBar.indicatorKey);
  final scrim = find.byKey(CapsuleNavBar.scrimKey);

  Rect rectOf(WidgetTester tester, Finder finder) =>
      tester.getRect(finder.first);

  group('CapsuleNavBar', () {
    testWidgets('renders every label', (tester) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('draws the filled icon only for the active destination', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 1,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsNothing);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);
    });

    testWidgets('reports the tapped index', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: taps.add,
          ),
        ),
      );

      await tester.tap(find.text('Account'));
      expect(taps, [2]);
    });

    testWidgets('reports a tap on the already-active destination', (
      tester,
    ) async {
      final taps = <int>[];
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: taps.add,
          ),
        ),
      );

      await tester.tap(find.text('Home'));
      expect(taps, [0], reason: 'the host resets that branch to its root');
    });

    testWidgets('highlights a tap without waiting for the host', (
      tester,
    ) async {
      // activeIndex never moves, standing in for a host that is still
      // switching route — the bar must highlight the tap regardless.
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('ignores an out-of-range activeIndex', (tester) async {
      Widget bar(int index) => host(
        CapsuleNavBar(
          destinations: destinations,
          activeIndex: index,
          onDestinationSelected: (_) {},
        ),
      );

      await tester.pumpWidget(bar(2));
      await tester.pumpWidget(bar(-1));
      await tester.pumpAndSettle();

      expect(
        find.byIcon(Icons.person),
        findsOneWidget,
        reason: 'the highlight stays put while a router is between branches',
      );
    });

    testWidgets('sizes the indicator to one destination', (tester) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      // 390 is wider than three destinations need, so each keeps the default
      // itemWidth and the indicator matches it.
      expect(rectOf(tester, indicator).width, closeTo(70, 0.01));
    });

    testWidgets('fills the width when its destinations need all of it', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: [...destinations, ...destinations.take(2)],
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      // Five destinations at 70 plus 8 of bar padding is 358 — exactly 390
      // less the 16 margin either side.
      expect(rectOf(tester, indicator).width, closeTo(70, 0.01));
    });

    testWidgets('slides the indicator to the tapped destination', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );
      final start = rectOf(tester, indicator).left;

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      expect(rectOf(tester, indicator).left, greaterThan(start));
    });

    testWidgets('slides the indicator leftwards under RTL', (tester) async {
      Widget bar(int index) => host(
        CapsuleNavBar(
          destinations: destinations,
          activeIndex: index,
          onDestinationSelected: (_) {},
        ),
        direction: TextDirection.rtl,
      );

      await tester.pumpWidget(bar(0));
      final first = rectOf(tester, indicator).left;

      await tester.pumpWidget(bar(2));
      await tester.pumpAndSettle();

      expect(rectOf(tester, indicator).left, lessThan(first));
    });

    testWidgets('shrinks the bar to the width it is given', (tester) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
          width: 200,
        ),
      );

      // 200 - 32 margin - 8 padding, shared three ways.
      expect(rectOf(tester, indicator).width, closeTo(160 / 3, 0.01));
    });

    testWidgets('takes only the width its destinations need', (tester) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
            itemWidth: 50,
          ),
          width: 600,
        ),
      );

      expect(rectOf(tester, indicator).width, closeTo(50, 0.01));
    });

    testWidgets('draws no scrim without a scrim colour', (tester) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
          theme: const CapsuleNavBarTheme(
            barColor: Color(0xFFFFFFFF),
            indicatorColor: Color(0xFFEEEEEE),
            selectedItemColor: Color(0xFF000000),
            unselectedItemColor: Color(0xFF888888),
          ),
        ),
      );

      expect(scrim, findsNothing);
    });

    testWidgets('draws the scrim when the theme sets its colour', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
          theme: const CapsuleNavBarTheme(
            barColor: Color(0xFFFFFFFF),
            indicatorColor: Color(0xFFEEEEEE),
            selectedItemColor: Color(0xFF000000),
            unselectedItemColor: Color(0xFF888888),
            scrimColor: Color(0xFFFFFFFF),
          ),
        ),
      );

      expect(scrim, findsOneWidget);
    });

    testWidgets('drops the scrim for showScrim: false', (tester) async {
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 0,
            onDestinationSelected: (_) {},
            showScrim: false,
            scrimColor: const Color(0xFFFFFFFF),
          ),
        ),
      );

      expect(scrim, findsNothing);
    });

    testWidgets('exposes destinations as buttons with their selected state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 1,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Search')),
        matchesSemantics(
          label: 'Search',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
          hasSelectedState: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('prefers a destination semanticLabel over its label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          CapsuleNavBar(
            destinations: const [
              NavBarDestination(
                label: 'Acct',
                lineIcon: Icons.person_outline,
                semanticLabel: 'Account',
              ),
            ],
            activeIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      expect(find.bySemanticsLabel('Account'), findsOneWidget);
      handle.dispose();
    });
  });

  group('NavBarDestination', () {
    test('falls back to the line icon when no fill icon is given', () {
      const destination = NavBarDestination(
        label: 'Home',
        lineIcon: Icons.home_outlined,
      );

      expect(destination.fillIcon, Icons.home_outlined);
      expect(destination.iconFor(selected: true), Icons.home_outlined);
    });

    test('picks the icon for the state', () {
      const destination = NavBarDestination(
        label: 'Home',
        lineIcon: Icons.home_outlined,
        fillIcon: Icons.home,
      );

      expect(destination.iconFor(selected: true), Icons.home);
      expect(destination.iconFor(selected: false), Icons.home_outlined);
    });

    test('compares by value', () {
      const a = NavBarDestination(label: 'Home', lineIcon: Icons.home);
      const b = NavBarDestination(label: 'Home', lineIcon: Icons.home);
      const c = NavBarDestination(label: 'Away', lineIcon: Icons.home);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('CapsuleNavBarTheme', () {
    const theme = CapsuleNavBarTheme(
      barColor: Color(0xFF111111),
      indicatorColor: Color(0xFF222222),
      selectedItemColor: Color(0xFF333333),
      unselectedItemColor: Color(0xFF444444),
    );

    test('copyWith keeps unset fields', () {
      final copy = theme.copyWith(indicatorColor: const Color(0xFF999999));

      expect(copy.indicatorColor, const Color(0xFF999999));
      expect(copy.barColor, theme.barColor);
      expect(copy.height, theme.height);
    });

    test('lerp interpolates colours and metrics', () {
      final other = theme.copyWith(height: 100, itemWidth: 100);
      final mid = theme.lerp(other, 0.5);

      expect(mid.height, (theme.height + 100) / 2);
      expect(mid.itemWidth, (theme.itemWidth + 100) / 2);
    });

    test('lerp with null returns itself', () {
      expect(theme.lerp(null, 0.5), same(theme));
    });

    test('colorFor follows the selected state', () {
      expect(theme.colorFor(selected: true), theme.selectedItemColor);
      expect(theme.colorFor(selected: false), theme.unselectedItemColor);
    });

    test('smoothCorners picks the shape', () {
      expect(theme.resolvedBarShape, isA<RoundedSuperellipseBorder>());
      expect(
        theme.copyWith(smoothCorners: false).resolvedBarShape,
        isA<RoundedRectangleBorder>(),
      );
    });

    test('an explicit shape wins over the radius', () {
      const shape = StadiumBorder();

      expect(theme.copyWith(barShape: shape).resolvedBarShape, shape);
      expect(
        theme.copyWith(indicatorShape: shape).resolvedIndicatorShape,
        shape,
      );
    });

    testWidgets('of falls back to a scheme-derived palette', (tester) async {
      late CapsuleNavBarTheme resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = CapsuleNavBarTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      final scheme = ThemeData().colorScheme;
      expect(resolved.indicatorColor, scheme.primaryContainer);
    });

    testWidgets('of returns the registered extension', (tester) async {
      late CapsuleNavBarTheme resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [theme]),
          home: Builder(
            builder: (context) {
              resolved = CapsuleNavBarTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.barColor, theme.barColor);
    });
  });
}
