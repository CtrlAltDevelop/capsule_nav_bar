import 'dart:math' as math;
import 'dart:ui' show ImageFilter, SemanticsRole;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'capsule_nav_bar_theme.dart';
import 'nav_bar_destination.dart';

/// The default duration of the indicator slide.
const Duration kCapsuleNavBarDuration = Duration(milliseconds: 300);

/// A bottom navigation bar that floats over the content as a rounded capsule,
/// its selection marked by a pill that slides between destinations.
///
/// The bar draws a destination's filled icon while it is selected and its line
/// icon otherwise, and fades a scrim up behind itself so content scrolling
/// underneath does not collide with it. Set [glass] and it frosts what passes
/// beneath it as well. Colours, shapes and metrics come from
/// [CapsuleNavBarTheme]; per-instance overrides on the widget win over it.
///
/// ```dart
/// CapsuleNavBar(
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
class CapsuleNavBar extends StatefulWidget {
  /// Creates a capsule navigation bar over [destinations], highlighting
  /// [activeIndex] and reporting taps to [onDestinationSelected].
  const CapsuleNavBar({
    super.key,
    required this.destinations,
    required this.activeIndex,
    required this.onDestinationSelected,
    this.duration = kCapsuleNavBarDuration,
    this.curve = Curves.easeInOut,
    this.showScrim = true,
    this.activeLabelOnly,
    this.activeIconScale,
    this.inactiveIconScale,
    this.activeLabelScale,
    this.activeLabelSpacing,
    this.activeItemFlex,
    this.activeItemWidth,
    this.expandedIconScale,
    this.expandedLabelScale,
    this.glass,
    this.glassBlur,
    this.height,
    this.itemWidth,
    this.itemSpacing,
    this.iconLabelSpacing,
    this.margin,
    this.barPadding,
    this.barRadius,
    this.indicatorRadius,
    this.barShape,
    this.indicatorShape,
    this.labelStyle,
    this.selectedLabelStyle,
    this.barColor,
    this.barGradient,
    this.indicatorColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.scrimColor,
    this.useSafeArea,
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
  /// [CapsuleNavBarTheme.scrimColor] to be set; without it nothing is drawn.
  final bool showScrim;

  /// Overrides [CapsuleNavBarTheme.activeLabelOnly] — whether only the
  /// selected destination shows its label, in a wider tab with a bigger label,
  /// the rest shrinking to an icon.
  final bool? activeLabelOnly;

  /// Overrides [CapsuleNavBarTheme.activeIconScale].
  final double? activeIconScale;

  /// Overrides [CapsuleNavBarTheme.inactiveIconScale].
  final double? inactiveIconScale;

  /// Overrides [CapsuleNavBarTheme.activeLabelScale].
  final double? activeLabelScale;

  /// Overrides [CapsuleNavBarTheme.activeLabelSpacing].
  final double? activeLabelSpacing;

  /// Overrides [CapsuleNavBarTheme.activeItemFlex].
  final double? activeItemFlex;

  /// Overrides [CapsuleNavBarTheme.activeItemWidth] — the selected
  /// destination's width in logical pixels, with every label kept.
  final double? activeItemWidth;

  /// Overrides [CapsuleNavBarTheme.expandedIconScale].
  final double? expandedIconScale;

  /// Overrides [CapsuleNavBarTheme.expandedLabelScale].
  final double? expandedLabelScale;

  /// Overrides [CapsuleNavBarTheme.glass] — whether the bar frosts the content
  /// behind it. Needs a translucent [barColor] to show through.
  final bool? glass;

  /// Overrides [CapsuleNavBarTheme.glassBlur].
  final double? glassBlur;

  /// Overrides [CapsuleNavBarTheme.height].
  final double? height;

  /// Overrides [CapsuleNavBarTheme.itemWidth].
  final double? itemWidth;

  /// Overrides [CapsuleNavBarTheme.itemSpacing] — the gap between
  /// destinations.
  final double? itemSpacing;

  /// Overrides [CapsuleNavBarTheme.iconLabelSpacing] — the gap between a
  /// destination's icon and its label.
  final double? iconLabelSpacing;

  /// Overrides [CapsuleNavBarTheme.margin].
  final EdgeInsetsGeometry? margin;

  /// Overrides [CapsuleNavBarTheme.barPadding].
  final EdgeInsetsGeometry? barPadding;

  /// Overrides [CapsuleNavBarTheme.barRadius]. Any [BorderRadiusGeometry]
  /// works, [BorderRadiusDirectional] included.
  final BorderRadiusGeometry? barRadius;

  /// Overrides [CapsuleNavBarTheme.indicatorRadius], on the same terms.
  final BorderRadiusGeometry? indicatorRadius;

  /// Overrides [CapsuleNavBarTheme.barShape], and with it [barRadius].
  ///
  /// Any [ShapeBorder] at all, which is how a host brings its own corner
  /// geometry — a `StadiumBorder`, or a squircle from a package such as
  /// `figma_squircle` — without this package depending on it.
  final ShapeBorder? barShape;

  /// Overrides [CapsuleNavBarTheme.indicatorShape], and with it
  /// [indicatorRadius]. Any [ShapeBorder], as for [barShape].
  final ShapeBorder? indicatorShape;

  /// Overrides [CapsuleNavBarTheme.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides [CapsuleNavBarTheme.selectedLabelStyle].
  final TextStyle? selectedLabelStyle;

  /// Overrides [CapsuleNavBarTheme.barColor].
  final Color? barColor;

  /// Overrides [CapsuleNavBarTheme.barGradient], and with it [barColor].
  final Gradient? barGradient;

  /// Overrides [CapsuleNavBarTheme.indicatorColor].
  final Color? indicatorColor;

  /// Overrides [CapsuleNavBarTheme.selectedItemColor].
  final Color? selectedItemColor;

  /// Overrides [CapsuleNavBarTheme.unselectedItemColor].
  final Color? unselectedItemColor;

  /// Overrides [CapsuleNavBarTheme.scrimColor].
  final Color? scrimColor;

  /// Overrides [CapsuleNavBarTheme.useSafeArea] — whether the bar keeps clear
  /// of the system inset at the bottom of the screen.
  final bool? useSafeArea;

  /// Screen-reader label for the bar as a whole.
  final String? semanticLabel;

  /// Key on the sliding indicator, so host tests can find and measure it.
  static const Key indicatorKey = Key('capsule_nav_bar.indicator');

  /// Key on the scrim behind the bar, for the same reason.
  static const Key scrimKey = Key('capsule_nav_bar.scrim');

  /// Key on the backdrop filter drawn when the bar is in its glass mode, so a
  /// host can assert the frost is (or is not) there.
  static const Key glassKey = Key('capsule_nav_bar.glass');

  /// Where the indicator sits along the bar's main axis, from `-1` (start) to
  /// `1` (end).
  static double indicatorAlignment(int index, int count) =>
      count < 2 ? 0 : -1 + 2 * index / (count - 1);

  @override
  State<CapsuleNavBar> createState() => _CapsuleNavBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('activeIndex', activeIndex))
      ..add(
        IterableProperty<String>(
          'destinations',
          destinations.map((d) => d.label),
        ),
      )
      ..add(
        DiagnosticsProperty<Duration>(
          'duration',
          duration,
          defaultValue: kCapsuleNavBarDuration,
        ),
      )
      ..add(
        DiagnosticsProperty<Curve>(
          'curve',
          curve,
          defaultValue: Curves.easeInOut,
        ),
      )
      ..add(FlagProperty('showScrim', value: showScrim, ifFalse: 'no scrim'))
      ..add(
        FlagProperty(
          'activeLabelOnly',
          value: activeLabelOnly ?? false,
          ifTrue: 'active label only',
        ),
      )
      ..add(FlagProperty('glass', value: glass ?? false, ifTrue: 'frosted'))
      ..add(
        FlagProperty(
          'useSafeArea',
          value: useSafeArea ?? true,
          ifFalse: 'ignores the safe area',
        ),
      )
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null));
  }
}

class _CapsuleNavBarState extends State<CapsuleNavBar> {
  late int _activeIndex = widget.activeIndex;

  @override
  void didUpdateWidget(CapsuleNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only a change by the host moves the highlight: an unrelated rebuild
    // mid-navigation carries the old index and must not snap a tap back. An
    // out-of-range index — the `-1` reported while a router sits between
    // branches — is ignored, so the highlight never blinks off either.
    if (widget.activeIndex != oldWidget.activeIndex &&
        _isValid(widget.activeIndex) &&
        widget.activeIndex != _activeIndex) {
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
  CapsuleNavBarTheme _theme(BuildContext context) =>
      CapsuleNavBarTheme.of(context).copyWith(
        activeLabelOnly: widget.activeLabelOnly,
        activeIconScale: widget.activeIconScale,
        inactiveIconScale: widget.inactiveIconScale,
        activeLabelScale: widget.activeLabelScale,
        activeLabelSpacing: widget.activeLabelSpacing,
        activeItemFlex: widget.activeItemFlex,
        activeItemWidth: widget.activeItemWidth,
        expandedIconScale: widget.expandedIconScale,
        expandedLabelScale: widget.expandedLabelScale,
        glass: widget.glass,
        glassBlur: widget.glassBlur,
        height: widget.height,
        itemWidth: widget.itemWidth,
        itemSpacing: widget.itemSpacing,
        iconLabelSpacing: widget.iconLabelSpacing,
        margin: widget.margin,
        barPadding: widget.barPadding,
        barRadius: widget.barRadius,
        indicatorRadius: widget.indicatorRadius,
        barShape: widget.barShape,
        indicatorShape: widget.indicatorShape,
        labelStyle: widget.labelStyle,
        selectedLabelStyle: widget.selectedLabelStyle,
        barColor: widget.barColor,
        barGradient: widget.barGradient,
        // The theme's gradient would otherwise win over a colour set here.
        clearBarGradient: widget.barColor != null && widget.barGradient == null,
        indicatorColor: widget.indicatorColor,
        selectedItemColor: widget.selectedItemColor,
        unselectedItemColor: widget.unselectedItemColor,
        scrimColor: widget.scrimColor,
        useSafeArea: widget.useSafeArea,
      );

  @override
  Widget build(BuildContext context) {
    final theme = _theme(context);
    final direction = Directionality.of(context);
    final barPadding = theme.barPadding.resolve(direction);
    final scrimColor = theme.scrimColor;
    final activeIndex = _isValid(_activeIndex) ? _activeIndex : 0;

    // The home indicator (or gesture bar) is added under the bar rather than
    // eaten out of its margin, so the bar floats the full margin above it.
    // Read through the targeted accessors, so the bar rebuilds when the inset
    // or the text scale changes and not on every unrelated MediaQuery change —
    // the keyboard coming up, say.
    final safeInset = theme.useSafeArea
        ? MediaQuery.viewPaddingOf(context).bottom
        : 0.0;
    final margin =
        theme.margin.resolve(direction) + EdgeInsets.only(bottom: safeInset);
    // Labels grow with the text scale, so the bar grows with them.
    final height = theme.heightFor(MediaQuery.textScalerOf(context));

    return Semantics(
      role: SemanticsRole.tabBar,
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The bar sizes itself to its destinations, and gives up width only
          // when what it is offered cannot hold them.
          final count = widget.destinations.length;
          final wanted =
              count * theme.itemWidth +
              (count - 1) * theme.itemSpacing +
              barPadding.horizontal;
          final available = constraints.hasBoundedWidth
              ? math.max(0.0, constraints.maxWidth - margin.horizontal)
              : wanted;

          return Stack(
            children: [
              if (widget.showScrim && scrimColor != null)
                _Scrim(
                  color: scrimColor,
                  height: theme.scrimHeight + safeInset,
                ),
              Padding(
                padding: margin,
                // heightFactor shrink-wraps the bar, so a bounded slot such as
                // Scaffold.bottomNavigationBar is not filled top to bottom.
                child: Align(
                  heightFactor: 1,
                  child: _Bar(
                    theme: theme,
                    destinations: widget.destinations,
                    activeIndex: activeIndex,
                    activeLabelOnly: theme.activeLabelOnly,
                    expanded:
                        theme.activeLabelOnly || theme.activeItemWidth != null,
                    onTap: _handleTap,
                    duration: widget.duration,
                    curve: widget.curve,
                    width: math.min(wanted, available),
                    height: height,
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
      key: CapsuleNavBar.scrimKey,
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
    required this.activeLabelOnly,
    required this.expanded,
    required this.onTap,
    required this.duration,
    required this.curve,
    required this.width,
    required this.height,
  });

  final CapsuleNavBarTheme theme;
  final List<NavBarDestination> destinations;
  final int activeIndex;
  final bool activeLabelOnly;
  final bool expanded;
  final ValueChanged<int> onTap;
  final Duration duration;
  final Curve curve;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final content = Padding(
      padding: theme.barPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _DestinationTile tile(int i) => _DestinationTile(
            destination: destinations[i],
            index: i,
            count: destinations.length,
            theme: theme,
            textTheme: textTheme,
            selected: i == activeIndex,
            activeLabelOnly: activeLabelOnly,
            expanded: expanded,
            duration: duration,
            curve: curve,
            onTap: () => onTap(i),
          );

          // The selected destination takes more of the bar than the rest — a
          // fixed width, or a number of shares — so its label has room:
          // "Social Trade" would not fit a plain equal share. Everything slides
          // together.
          if (expanded) {
            final count = destinations.length;
            final gap = theme.itemSpacing;
            // What the gaps leave to share out between the destinations.
            final inner = math.max(
              0.0,
              constraints.maxWidth - (count - 1) * gap,
            );
            final active = count == 1
                ? inner
                : (theme.activeItemWidth ??
                          theme.activeItemFlex *
                              inner /
                              (count - 1 + theme.activeItemFlex))
                      .clamp(0.0, inner);
            final unit = count == 1 ? 0.0 : (inner - active) / (count - 1);
            final snap = MediaQuery.disableAnimationsOf(context);
            Widget slot({
              required double start,
              required double width,
              required Widget child,
              Key? key,
            }) => AnimatedPositionedDirectional(
              key: key,
              duration: snap ? Duration.zero : duration,
              curve: curve,
              start: start,
              width: width,
              top: 0,
              bottom: 0,
              child: child,
            );
            double startOf(int i) => i <= activeIndex
                ? i * (unit + gap)
                : (i - 1) * (unit + gap) + active + gap;
            return Stack(
              children: [
                slot(
                  key: CapsuleNavBar.indicatorKey,
                  start: activeIndex * (unit + gap),
                  width: active,
                  child: RepaintBoundary(
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: theme.indicatorColor,
                        shape: theme.resolvedIndicatorShape,
                      ),
                    ),
                  ),
                ),
                for (var i = 0; i < destinations.length; i++)
                  slot(
                    start: startOf(i),
                    width: i == activeIndex ? active : unit,
                    child: tile(i),
                  ),
              ],
            );
          }

          final itemWidth =
              (constraints.maxWidth -
                  (destinations.length - 1) * theme.itemSpacing) /
              destinations.length;
          return Stack(
            children: [
              _Indicator(
                theme: theme,
                duration: duration,
                curve: curve,
                width: itemWidth,
                alignment: CapsuleNavBar.indicatorAlignment(
                  activeIndex,
                  destinations.length,
                ),
              ),
              Row(
                spacing: theme.itemSpacing,
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    Expanded(child: tile(i)),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Without the frost the bar is one decorated, clipped box.
    if (!theme.glass) {
      return Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          // ShapeDecoration takes one fill or the other, never both.
          color: theme.barGradient == null ? theme.barColor : null,
          gradient: theme.barGradient,
          shape: theme.resolvedBarShape,
          shadows: theme.barShadows,
        ),
        child: content,
      );
    }

    final shape = theme.resolvedBarShape;

    return Container(
      width: width,
      height: height,
      // Clip and shadows only. The shadows fall outside the clip, so the blur
      // below cannot smear them, and the fill is deliberately not painted here
      // — see below. The border comes off this copy for the same reason: it is
      // drawn crisply over the frost instead of through it.
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: shape is OutlinedBorder
            ? shape.copyWith(side: BorderSide.none)
            : shape,
        shadows: theme.barShadows,
      ),
      child: BackdropFilter(
        key: CapsuleNavBar.glassKey,
        filter: ImageFilter.blur(
          sigmaX: theme.glassBlur,
          sigmaY: theme.glassBlur,
        ),
        // The fill sits *over* the blur, not under it: frosted glass is a
        // translucent sheet laid on a blurred backdrop. Painting it first
        // would instead blur the fill along with the content and read as a
        // smear. The border rides on the same layer, so it stays a hairline.
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: theme.barGradient == null ? theme.barColor : null,
            gradient: theme.barGradient,
            shape: shape,
          ),
          child: content,
        ),
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

  final CapsuleNavBarTheme theme;
  final Duration duration;
  final Curve curve;
  final double width;
  final double alignment;

  @override
  Widget build(BuildContext context) {
    // "Reduce motion" is honoured by snapping the pill into place rather than
    // sliding it; the selection still reads, it just does not travel.
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Positioned.fill(
      child: RepaintBoundary(
        child: AnimatedAlign(
          duration: animate ? duration : Duration.zero,
          curve: curve,
          alignment: AlignmentDirectional(alignment, 0),
          child: SizedBox(
            key: CapsuleNavBar.indicatorKey,
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

/// The overlay opacity for a tile in the given interaction states, following
/// Material's own pressed-over-hover-over-focused order.
double _overlayAlpha(Set<WidgetState> states) {
  if (states.contains(WidgetState.pressed)) return 0.12;
  if (states.contains(WidgetState.hovered)) return 0.08;
  if (states.contains(WidgetState.focused)) return 0.10;
  return 0;
}

/// One tappable destination: its icon, its label, and its semantics.
class _DestinationTile extends StatefulWidget {
  const _DestinationTile({
    required this.destination,
    required this.index,
    required this.count,
    required this.theme,
    required this.textTheme,
    required this.selected,
    required this.activeLabelOnly,
    required this.expanded,
    required this.duration,
    required this.curve,
    required this.onTap,
  });

  final NavBarDestination destination;
  final int index;
  final int count;
  final CapsuleNavBarTheme theme;
  final TextTheme textTheme;
  final bool selected;
  final bool activeLabelOnly;
  final bool expanded;
  final Duration duration;
  final Curve curve;
  final VoidCallback onTap;

  @override
  State<_DestinationTile> createState() => _DestinationTileState();
}

class _DestinationTileState extends State<_DestinationTile> {
  // The tile's own semantics exclude its children, so the focus state the
  // InkWell reports would otherwise never reach a screen reader.
  bool _focused = false;

  /// Reports the tap, with the platform's own feedback — the one path for the
  /// pointer, the keyboard and an assistive tap alike.
  void _activate() {
    Feedback.forTap(context);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final theme = widget.theme;
    final selected = widget.selected;
    final color = theme.colorFor(selected: selected);

    // The pair is centred in the pill and the label is flexible, so a tall
    // font or a large text scale eats into the label's own box instead of
    // overflowing the bar.
    // "Reduce motion" snaps the size and label change, as it does the pill.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.duration;
    final showLabel = !widget.activeLabelOnly || selected;
    final iconSize =
        theme.iconSize *
        (widget.activeLabelOnly
            ? (selected ? theme.activeIconScale : theme.inactiveIconScale)
            : (widget.expanded && selected ? theme.expandedIconScale : 1));
    Widget icon = TweenAnimationBuilder<double>(
      tween: Tween(end: iconSize),
      duration: duration,
      curve: widget.curve,
      builder: (context, size, _) => Icon(
        destination.iconFor(selected: selected),
        size: size,
        color: color,
      ),
    );
    if (destination.showBadge) {
      final badgeLabel = destination.badgeLabel;
      icon = Badge(
        label: badgeLabel == null ? null : Text(badgeLabel),
        child: icon,
      );
    }

    final base = theme.resolvedLabelStyle(widget.textTheme, selected: selected);
    final labelScale = !selected
        ? 1.0
        : widget.activeLabelOnly
        ? theme.activeLabelScale
        : widget.expanded
        ? theme.expandedLabelScale
        : 1.0;
    final style = labelScale == 1
        ? base
        : base.copyWith(fontSize: (base.fontSize ?? 12) * labelScale);
    final text = Text(
      destination.label,
      // The animated style below owns it in the uneven layout, so the label
      // grows with the selection instead of jumping.
      style: widget.expanded ? null : style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
    final label = Padding(
      padding: EdgeInsets.only(
        top: widget.activeLabelOnly
            ? theme.activeLabelSpacing
            : theme.iconLabelSpacing,
      ),
      child: widget.expanded
          ? AnimatedDefaultTextStyle(
              style: style,
              duration: duration,
              curve: widget.curve,
              child: text,
            )
          : text,
    );

    Widget content = Padding(
      padding: theme.itemPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          // In the active-only mode the label folds away and fades rather than
          // popping out. Otherwise it is plain, as there is nothing to animate.
          Flexible(
            child: !widget.activeLabelOnly
                ? label
                : AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: widget.curve,
                    switchOutCurve: widget.curve,
                    transitionBuilder: (child, animation) => SizeTransition(
                      sizeFactor: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: showLabel
                        ? KeyedSubtree(
                            key: const ValueKey(true),
                            // SizeTransition start-aligns its child, so the
                            // label spans the tile to stay centred.
                            child: SizedBox(
                              width: double.infinity,
                              child: label,
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey(false)),
                  ),
          ),
        ],
      ),
    );

    if (destination.tooltip != null) {
      content = Tooltip(message: destination.tooltip!, child: content);
    }

    // "Tab 2 of 3", as Material's own bar announces. The web's tab role already
    // carries the position; and a host without Material localizations simply
    // gets no hint rather than an exception.
    final position = kIsWeb
        ? null
        : Localizations.of<MaterialLocalizations>(
            context,
            MaterialLocalizations,
          )?.tabLabel(tabIndex: widget.index + 1, tabCount: widget.count);

    return Semantics(
      role: SemanticsRole.tab,
      button: true,
      selected: selected,
      focusable: true,
      focused: _focused,
      label: destination.semanticLabel ?? destination.label,
      hint: position,
      value: destination.showBadge ? destination.badgeLabel : null,
      excludeSemantics: true,
      onTap: _activate,
      // A transparent Material of its own, so the ink from the tap lands over
      // the indicator instead of on some far-away ancestor underneath it.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          // InkWell brings the keyboard with it: the tile takes focus in the
          // traversal order and answers Enter and Space, which a bare
          // GestureDetector never did.
          onTap: _activate,
          onFocusChange: (focused) => setState(() => _focused = focused),
          customBorder: theme.resolvedIndicatorShape,
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => theme
                .colorFor(selected: selected)
                .withValues(alpha: _overlayAlpha(states)),
          ),
          child: content,
        ),
      ),
    );
  }
}
