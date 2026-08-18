import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'floating_nav_bar_theme.dart';
import 'nav_bar_destination.dart';

/// The default duration of the indicator slide.
const Duration kFloatingNavBarDuration = Duration(milliseconds: 300);

/// A bottom navigation bar that floats over the content as a rounded capsule,
/// its selection marked by a pill that slides between destinations.
///
/// The bar draws a destination's filled icon while it is selected and its line
/// icon otherwise, and fades a scrim up behind itself so content scrolling
/// underneath does not collide with it. Colours, shapes and metrics come from
/// [FloatingNavBarTheme]; per-instance overrides on the widget win over it.
///
/// ```dart
/// FloatingNavBar(
///   destinations: const [
///     NavBarDestination(
///       label: 'Home',
///       lineIcon: Icons.home_outlined,
///       fillIcon: Icons.home,
///     ),
///     NavBarDestination(
///       label: 'Search',
///       lineIcon: Icons.search_outlined,
///       fillIcon: Icons.search,
///     ),
///   ],
///   activeIndex: _index,
///   onDestinationSelected: (i) => setState(() => _index = i),
/// )
/// ```
///
/// Place it at the bottom of a [Stack] over the content — or as a
/// `Scaffold.bottomNavigationBar`, though it is built to overlap what it sits
/// above. It sizes itself to its destinations, so give it the full width to
/// centre itself in.
///
/// The bar highlights a tap immediately and reports it afterwards, so it stays
/// responsive when [onDestinationSelected] does something slow, such as
/// switching a router branch. It then follows [activeIndex] again whenever the
/// host changes it.
///
/// The indicator is aligned along the text direction, so the bar reads
/// correctly under [TextDirection.rtl] with no extra work.
class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({
    super.key,
    required this.destinations,
    required this.activeIndex,
    required this.onDestinationSelected,
    this.duration = kFloatingNavBarDuration,
    this.curve = Curves.easeInOut,
    this.showScrim = true,
    this.height,
    this.itemWidth,
    this.margin,
    this.barPadding,
    this.barRadius,
    this.indicatorRadius,
    this.barShape,
    this.indicatorShape,
    this.labelStyle,
    this.selectedLabelStyle,
    this.barColor,
    this.indicatorColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.scrimColor,
    this.semanticLabel,
  }) : assert(destinations.length > 0, 'destinations must not be empty');

  /// The destinations, laid out in order across the bar. Must not be empty.
  final List<NavBarDestination> destinations;

  /// Index of the highlighted destination, into [destinations].
  ///
  /// A value outside the range — the `-1` a router reports while it is between
  /// branches — leaves the current highlight alone rather than clearing it.
  final int activeIndex;

  /// Called with the tapped index, after the bar has moved its indicator.
  ///
  /// The bar only tracks which destination is highlighted; this callback owns
  /// the navigation itself. It is called for the already-selected destination
  /// too, so a host can reset that branch to its root.
  final ValueChanged<int> onDestinationSelected;

  /// How long the indicator takes to slide.
  final Duration duration;

  /// The curve the indicator slides on.
  final Curve curve;

  /// Whether to fade a scrim up behind the bar. Needs
  /// [FloatingNavBarTheme.scrimColor] to be set; without it nothing is drawn.
  final bool showScrim;

  /// Overrides [FloatingNavBarTheme.height].
  final double? height;

  /// Overrides [FloatingNavBarTheme.itemWidth].
  final double? itemWidth;

  /// Overrides [FloatingNavBarTheme.margin].
  final EdgeInsetsGeometry? margin;

  /// Overrides [FloatingNavBarTheme.barPadding].
  final EdgeInsetsGeometry? barPadding;

  /// Overrides [FloatingNavBarTheme.barRadius]. Any [BorderRadiusGeometry]
  /// works, [BorderRadiusDirectional] included.
  final BorderRadiusGeometry? barRadius;

  /// Overrides [FloatingNavBarTheme.indicatorRadius], on the same terms.
  final BorderRadiusGeometry? indicatorRadius;

  /// Overrides [FloatingNavBarTheme.barShape], and with it [barRadius].
  ///
  /// Any [ShapeBorder] at all, which is how a host brings its own corner
  /// geometry — a `StadiumBorder`, or a squircle from a package such as
  /// `figma_squircle` — without this package depending on it.
  final ShapeBorder? barShape;

  /// Overrides [FloatingNavBarTheme.indicatorShape], and with it
  /// [indicatorRadius]. Any [ShapeBorder], as for [barShape].
  final ShapeBorder? indicatorShape;

  /// Overrides [FloatingNavBarTheme.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides [FloatingNavBarTheme.selectedLabelStyle].
  final TextStyle? selectedLabelStyle;

  /// Overrides [FloatingNavBarTheme.barColor].
  final Color? barColor;

  /// Overrides [FloatingNavBarTheme.indicatorColor].
  final Color? indicatorColor;

  /// Overrides [FloatingNavBarTheme.selectedItemColor].
  final Color? selectedItemColor;

  /// Overrides [FloatingNavBarTheme.unselectedItemColor].
  final Color? unselectedItemColor;

  /// Overrides [FloatingNavBarTheme.scrimColor].
  final Color? scrimColor;

  /// Screen-reader label for the bar as a whole.
  final String? semanticLabel;

  /// Key on the sliding indicator, so host tests can find and measure it.
  static const Key indicatorKey = Key('floating_nav_bar.indicator');

  /// Key on the scrim behind the bar, for the same reason.
  static const Key scrimKey = Key('floating_nav_bar.scrim');

  /// Where the indicator sits along the bar's main axis, from `-1` (start) to
  /// `1` (end).
  static double indicatorAlignment(int index, int count) =>
      count < 2 ? 0 : -1 + 2 * index / (count - 1);

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> {
  late int _activeIndex = widget.activeIndex;

  @override
  void didUpdateWidget(FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An out-of-range index — the `-1` reported while a router sits between
    // branches — is ignored, so the highlight never blinks off mid-transition.
    if (_isValid(widget.activeIndex) && widget.activeIndex != _activeIndex) {
      setState(() => _activeIndex = widget.activeIndex);
    }
  }

  bool _isValid(int index) => index >= 0 && index < widget.destinations.length;

  /// Highlights the tap before reporting it, so the bar answers the touch even
  /// while the host is still switching route.
  void _handleTap(int index) {
    if (index != _activeIndex) setState(() => _activeIndex = index);
    widget.onDestinationSelected(index);
  }

  /// The theme, with this widget's per-instance overrides applied.
  FloatingNavBarTheme _theme(BuildContext context) =>
      FloatingNavBarTheme.of(context).copyWith(
        height: widget.height,
        itemWidth: widget.itemWidth,
        margin: widget.margin,
        barPadding: widget.barPadding,
        barRadius: widget.barRadius,
        indicatorRadius: widget.indicatorRadius,
        barShape: widget.barShape,
        indicatorShape: widget.indicatorShape,
        labelStyle: widget.labelStyle,
        selectedLabelStyle: widget.selectedLabelStyle,
        barColor: widget.barColor,
        indicatorColor: widget.indicatorColor,
        selectedItemColor: widget.selectedItemColor,
        unselectedItemColor: widget.unselectedItemColor,
        scrimColor: widget.scrimColor,
      );

  @override
  Widget build(BuildContext context) {
    final theme = _theme(context);
    final direction = Directionality.of(context);
    final margin = theme.margin.resolve(direction);
    final barPadding = theme.barPadding.resolve(direction);
    final scrimColor = theme.scrimColor;
    final activeIndex = _isValid(_activeIndex) ? _activeIndex : 0;

    return Semantics(
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The bar sizes itself to its destinations, and gives up width only
          // when what it is offered cannot hold them.
          final wanted =
              widget.destinations.length * theme.itemWidth +
              barPadding.horizontal;
          final available = constraints.hasBoundedWidth
              ? math.max(0.0, constraints.maxWidth - margin.horizontal)
              : wanted;

          return Stack(
            children: [
              if (widget.showScrim && scrimColor != null)
                _Scrim(color: scrimColor, height: theme.scrimHeight),
              Padding(
                padding: margin,
                child: Align(
                  child: _Bar(
                    theme: theme,
                    destinations: widget.destinations,
                    activeIndex: activeIndex,
                    onTap: _handleTap,
                    duration: widget.duration,
                    curve: widget.curve,
                    width: math.min(wanted, available),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The gradient that fades content out from under the bar.
class _Scrim extends StatelessWidget {
  const _Scrim({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: FloatingNavBar.scrimKey,
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0), color],
            ),
          ),
        ),
      ),
    );
  }
}

/// The floating capsule: the indicator, and the destinations over it.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.theme,
    required this.destinations,
    required this.activeIndex,
    required this.onTap,
    required this.duration,
    required this.curve,
    required this.width,
  });

  final FloatingNavBarTheme theme;
  final List<NavBarDestination> destinations;
  final int activeIndex;
  final ValueChanged<int> onTap;
  final Duration duration;
  final Curve curve;
  final double width;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: width,
      height: theme.height,
      padding: theme.barPadding,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: theme.barColor,
        shape: theme.resolvedBarShape,
        shadows: theme.barShadows,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / destinations.length;
          return Stack(
            children: [
              _Indicator(
                theme: theme,
                duration: duration,
                curve: curve,
                width: itemWidth,
                alignment: FloatingNavBar.indicatorAlignment(
                  activeIndex,
                  destinations.length,
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    Expanded(
                      child: _DestinationTile(
                        destination: destinations[i],
                        theme: theme,
                        textTheme: textTheme,
                        selected: i == activeIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The pill that slides behind the selected destination.
class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.theme,
    required this.duration,
    required this.curve,
    required this.width,
    required this.alignment,
  });

  final FloatingNavBarTheme theme;
  final Duration duration;
  final Curve curve;
  final double width;
  final double alignment;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: AnimatedAlign(
          duration: duration,
          curve: curve,
          alignment: AlignmentDirectional(alignment, 0),
          child: SizedBox(
            key: FloatingNavBar.indicatorKey,
            width: width,
            height: double.infinity,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: theme.indicatorColor,
                shape: theme.resolvedIndicatorShape,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One tappable destination: its icon, its label, and its semantics.
class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.destination,
    required this.theme,
    required this.textTheme,
    required this.selected,
    required this.onTap,
  });

  final NavBarDestination destination;
  final FloatingNavBarTheme theme;
  final TextTheme textTheme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = theme.colorFor(selected: selected);

    // The pair is centred in the pill and the label is flexible, so a tall
    // font or a large text scale eats into the label's own box instead of
    // overflowing the bar.
    Widget content = Padding(
      padding: theme.itemPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: theme.iconLabelSpacing,
        children: [
          Icon(
            destination.iconFor(selected: selected),
            size: theme.iconSize,
            color: color,
          ),
          Flexible(
            child: Text(
              destination.label,
              style: theme.resolvedLabelStyle(textTheme, selected: selected),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    if (destination.tooltip != null) {
      content = Tooltip(message: destination.tooltip!, child: content);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: destination.semanticLabel ?? destination.label,
      excludeSemantics: true,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}
