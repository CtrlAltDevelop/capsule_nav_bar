@Tags(['golden'])
library;

import 'package:capsule_nav_bar/capsule_nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Goldens are rasterised, so they are tagged and run on one platform only —
/// see the `golden` job in `.github/workflows/ci.yaml`. Regenerate them with
/// `flutter test --update-goldens test/goldens_test.dart`.
void main() {
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

  Widget host(
    Widget child, {
    Brightness brightness = Brightness.light,
    TextDirection direction = TextDirection.ltr,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: brightness,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: scheme),
      home: Directionality(
        textDirection: direction,
        child: ColoredBox(
          color: scheme.surface,
          child: SizedBox(
            width: 390,
            height: 120,
            child: Align(alignment: Alignment.bottomCenter, child: child),
          ),
        ),
      ),
    );
  }

  Future<void> expectGolden(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CapsuleNavBar),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('light, second destination selected', (tester) async {
    await tester.pumpWidget(
      host(
        CapsuleNavBar(
          destinations: destinations,
          activeIndex: 1,
          onDestinationSelected: (_) {},
        ),
      ),
    );
    await expectGolden(tester, 'light');
  });

  testWidgets('dark, first destination selected', (tester) async {
    await tester.pumpWidget(
      host(
        CapsuleNavBar(
          destinations: destinations,
          activeIndex: 0,
          onDestinationSelected: (_) {},
        ),
        brightness: Brightness.dark,
      ),
    );
    await expectGolden(tester, 'dark');
  });

  testWidgets('rtl starts the pill from the right', (tester) async {
    await tester.pumpWidget(
      host(
        CapsuleNavBar(
          destinations: destinations,
          activeIndex: 0,
          onDestinationSelected: (_) {},
        ),
        direction: TextDirection.rtl,
      ),
    );
    await expectGolden(tester, 'rtl');
  });

  testWidgets('a gradient fill with shadows and square corners', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        CapsuleNavBar(
          destinations: destinations,
          activeIndex: 2,
          onDestinationSelected: (_) {},
          barGradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          selectedItemColor: const Color(0xFF1E1B4B),
          unselectedItemColor: const Color(0xFFE0E7FF),
        ),
      ),
    );
    await expectGolden(tester, 'gradient');
  });

  testWidgets('grown by a large text scale', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
        child: host(
          CapsuleNavBar(
            destinations: destinations,
            activeIndex: 1,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    await expectGolden(tester, 'text_scale');
  });
}
