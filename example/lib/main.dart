import 'package:floating_nav_bar/floating_nav_bar.dart';
import 'package:material_ui/material_ui.dart';

import 'demo_content.dart';
import 'demo_destinations.dart';
import 'demo_theme.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.light;
  bool _rtl = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'floating_nav_bar',
      debugShowCheckedModeBanner: false,
      theme: buildDemoTheme(Brightness.light),
      darkTheme: buildDemoTheme(Brightness.dark),
      themeMode: _mode,
      home: Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: ExamplePage(
          isDark: _mode == ThemeMode.dark,
          onToggleBrightness: () => setState(
            () => _mode = _mode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark,
          ),
          onToggleDirection: () => setState(() => _rtl = !_rtl),
        ),
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({
    super.key,
    required this.isDark,
    required this.onToggleBrightness,
    required this.onToggleDirection,
  });

  final bool isDark;
  final VoidCallback onToggleBrightness;
  final VoidCallback onToggleDirection;

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(demoDestinations[_index].label),
        actions: [
          IconButton(
            tooltip: 'Toggle brightness',
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleBrightness,
          ),
          IconButton(
            tooltip: 'Toggle text direction',
            icon: const Icon(Icons.swap_horiz),
            onPressed: widget.onToggleDirection,
          ),
        ],
      ),
      // The bar overlaps the content, so it goes in a Stack over it rather
      // than in Scaffold.bottomNavigationBar — that is what the scrim behind
      // it is for.
      body: Stack(
        children: [
          DemoContent(index: _index),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              destinations: demoDestinations,
              activeIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              semanticLabel: 'Main navigation',
            ),
          ),
        ],
      ),
    );
  }
}
