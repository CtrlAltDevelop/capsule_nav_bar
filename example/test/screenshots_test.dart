// Renders the README screenshots from the real widgets, so they can be
// regenerated whenever the bar changes:
//
//   cd example && flutter test --update-goldens test/screenshots_test.dart
//
// The images land in ../../screenshots/ and are shown in README.md and in
// pubspec.yaml's screenshots section.
import 'dart:io';

import 'package:capsule_nav_bar/capsule_nav_bar.dart';
import 'package:capsule_nav_bar_example/demo_content.dart';
import 'package:capsule_nav_bar_example/demo_destinations.dart';
import 'package:capsule_nav_bar_example/demo_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Width of one phone-sized strip, so the bar is shown at the size it is
/// actually used at.
const double _stripWidth = 390;

/// `flutter test` renders text with the placeholder Ahem font unless real
/// fonts are registered, so load the ones the bar actually draws with.
Future<void> _loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return;
  final fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';

  Future<void> load(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    await (FontLoader(
      family,
    )..addFont(file.readAsBytes().then((b) => ByteData.view(b.buffer)))).load();
  }

  await load('Roboto', '$fonts/Roboto-Regular.ttf');
  await load('MaterialIcons', '$fonts/MaterialIcons-Regular.otf');
}

/// The widgets on a plain backdrop, at the width they are shown at.
Widget _canvas(List<Widget> children) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildDemoTheme(Brightness.light),
  home: ColoredBox(
    color: const Color(0xFFF1F1F4),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: children,
        ),
      ),
    ),
  ),
);

/// The bottom of a page: content running under the bar, and the bar over it.
///
/// [brightness] applies a whole theme rather than a palette, so the strip shows
/// the bar picking its own `CapsuleNavBarTheme` out of the ambient one.
Widget _strip({
  required Brightness brightness,
  required int activeIndex,
  double height = 224,
}) {
  final theme = buildDemoTheme(brightness);

  return ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(20)),
    child: SizedBox(
      width: _stripWidth,
      height: height,
      child: Theme(
        data: theme,
        child: ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Stack(
            children: [
              DemoContent(index: activeIndex, itemCount: 3),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CapsuleNavBar(
                  destinations: demoDestinations,
                  activeIndex: activeIndex,
                  onDestinationSelected: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// The bar with nothing behind it, for showing where the pill sits.
Widget _bareBar(int activeIndex) => SizedBox(
  width: _stripWidth,
  child: CapsuleNavBar(
    destinations: demoDestinations,
    activeIndex: activeIndex,
    onDestinationSelected: (_) {},
    showScrim: false,
  ),
);

void main() {
  setUpAll(_loadFonts);

  testWidgets('the bar over content, light and dark', (tester) async {
    tester.view
      ..physicalSize = const Size(876, 1048)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _canvas([
        _strip(brightness: Brightness.light, activeIndex: 0),
        _strip(brightness: Brightness.dark, activeIndex: 4),
      ]),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../screenshots/bar.png'),
    );
  });

  testWidgets('the pill at three selections', (tester) async {
    tester.view
      ..physicalSize = const Size(876, 680)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_canvas([_bareBar(0), _bareBar(2), _bareBar(4)]));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../screenshots/states.png'),
    );
  });
}
