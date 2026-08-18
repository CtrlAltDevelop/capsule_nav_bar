// Records the README's animated GIF from the real widgets:
//
//   cd example && flutter test tool/record_nav_gif.dart
//
// It taps the bar through its destinations, grabs a frame every 50ms, and
// encodes them into ../../screenshots/nav.gif.
//
// It lives outside test/ on purpose: it writes a file rather than asserting
// anything, so it should not run as part of `flutter test`.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:capsule_nav_bar/capsule_nav_bar.dart';
import 'package:capsule_nav_bar_example/demo_destinations.dart';
import 'package:capsule_nav_bar_example/demo_theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';

/// The recorded canvas, in logical pixels: a phone's width, and just enough
/// height to show the bar over the content it floats above.
const Size _canvasSize = Size(390, 150);

/// One frame every 50ms, which is 20fps — smooth enough for a 300ms slide.
const Duration _step = Duration(milliseconds: 50);

const Key _canvasKey = Key('canvas');

/// Loads the fonts the widgets actually draw with; `flutter test` otherwise
/// renders every glyph as an Ahem box.
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

/// Placeholder page content for the recording — flat blocks rather than the
/// demo's cards, which are unreadable at this size and cost a few hundred KB of
/// GIF to encode.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      child: Column(
        spacing: 12,
        children: [
          for (final width in const [1.0, 0.82, 0.6])
            Expanded(
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('record the destination-change GIF', (tester) async {
    tester.view
      ..physicalSize = _canvasSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var index = 0;
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildDemoTheme(Brightness.light),
        home: RepaintBoundary(
          key: _canvasKey,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Stack(
                children: [
                  const _Backdrop(),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CapsuleNavBar(
                      destinations: demoDestinations,
                      activeIndex: index,
                      onDestinationSelected: (i) => setState(() => index = i),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final frames = <img.Image>[];

    /// Grabs whatever is on screen right now.
    Future<void> grab() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(_canvasKey),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final width = image.width;
        final height = image.height;
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        frames.add(
          img.Image.fromBytes(
            width: width,
            height: height,
            bytes: Uint8List.fromList(data!.buffer.asUint8List()).buffer,
            numChannels: 4,
          ),
        );
      });
    }

    /// Advances the clock, grabbing a frame per step.
    Future<void> roll(Duration total) async {
      for (var t = Duration.zero; t < total; t += _step) {
        await tester.pump(_step);
        await grab();
      }
    }

    /// Taps a destination, then records the slide and the pause after it.
    Future<void> pick(String label) async {
      await tester.tap(find.text(label));
      await roll(const Duration(milliseconds: 400));
      await roll(const Duration(milliseconds: 250));
    }

    await grab();
    await roll(const Duration(milliseconds: 250));
    await pick('Trade');
    await pick('Tools');
    await pick('Account');
    await pick('Explore');
    await pick('Home');

    // The UI is flat colour: a handful of greys, one purple and the text. So
    // dithering only adds noise and weight, and a 256-colour palette is far
    // more than the frames use.
    final encoder = img.GifEncoder(
      repeat: 0,
      numColors: 32,
      dither: img.DitherKernel.none,
    )..delay = _step.inMilliseconds ~/ 10;
    for (final frame in frames) {
      encoder.addFrame(frame, duration: _step.inMilliseconds ~/ 10);
    }

    final bytes = encoder.finish();
    expect(bytes, isNotNull, reason: 'the encoder produced no GIF');

    final out = File('../screenshots/nav.gif')..writeAsBytesSync(bytes!);
    // ignore: avoid_print — this is a generator script, not a test.
    print(
      'wrote ${out.path}: ${frames.length} frames, '
      '${(bytes.length / 1024).round()} KB',
    );
  });
}
