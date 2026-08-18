import 'package:material_ui/material_ui.dart';

import 'demo_destinations.dart';

/// Stand-in page content, there to be scrolled under the bar so the scrim has
/// something to fade out.
class DemoContent extends StatelessWidget {
  const DemoContent({super.key, required this.index, this.itemCount = 24});

  /// Which destination's page this is.
  final int index;

  /// How many cards to build. Screenshots want a handful; the demo app wants
  /// enough to scroll.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destination = demoDestinations[index];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: itemCount,
      itemBuilder: (context, i) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(destination.fillIcon),
          title: Text('${destination.label} — item ${i + 1}'),
          subtitle: Text(
            'Scroll to the bottom: the scrim fades this out under the bar.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
