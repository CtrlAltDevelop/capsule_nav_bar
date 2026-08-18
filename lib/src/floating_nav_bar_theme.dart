import 'package:material_ui/material_ui.dart';

/// Everything a [FloatingNavBar] needs to paint itself.
///
/// Register it as a [ThemeExtension] so the bar follows your app's light and
/// dark themes:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(extensions: [FloatingNavBarTheme.fromScheme(scheme)]),
/// );
/// ```
///
/// When no extension is registered, [FloatingNavBarTheme.of] derives a usable
/// palette from the ambient [ColorScheme], so the bar looks reasonable with no
/// setup at all.
@immutable
class FloatingNavBarTheme extends ThemeExtension<FloatingNavBarTheme> {
  const FloatingNavBarTheme({
    required this.barColor,
    required this.indicatorColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    this.labelStyle,
    this.selectedLabelStyle,
    this.fontFamily,
    this.barRadius = const BorderRadius.all(Radius.circular(32)),
    this.indicatorRadius = const BorderRadius.all(Radius.circular(30)),
    this.barShape,
    this.indicatorShape,
    this.smoothCorners = true,
    this.barShadows = const <BoxShadow>[],
    this.barPadding = const EdgeInsets.all(4),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.height = 56,
    this.itemWidth = 70,
    this.iconSize = 20,
    this.iconLabelSpacing = 4,
    this.scrimColor,
    this.scrimHeight = 56,
  });

  /// Fill of the floating bar itself.
  ///
  /// Give it an alpha below 1 for the frosted look the bar is built for — it
  /// clips its children, so content scrolling underneath shows through.
  final Color barColor;

  /// Fill of the indicator (the "pill") that slides behind the selected item.
  final Color indicatorColor;

  /// Icon and label colour of the selected destination. Must contrast with
  /// [indicatorColor].
  final Color selectedItemColor;

  /// Icon and label colour of every other destination.
  final Color unselectedItemColor;

  /// Style of unselected labels. When null the ambient `labelSmall` is used.
  ///
  /// Anything it sets wins: a [labelStyle] with its own `color` or
  /// `fontFamily` is used as given rather than being overwritten.
  final TextStyle? labelStyle;

  /// Style of the selected label. Falls back to [labelStyle].
  final TextStyle? selectedLabelStyle;

  /// Font family for every label, for hosts that only want to swap the
  /// typeface. A family set on one of the styles above wins over this.
  final String? fontFamily;

  /// Corner radii of the bar. Ignored when [barShape] is set.
  ///
  /// Any [BorderRadiusGeometry] works: one radius for all four corners, a
  /// different radius per corner, elliptical corners, or the directional
  /// [BorderRadiusDirectional], which follows the text direction.
  final BorderRadiusGeometry barRadius;

  /// Corner radii of the indicator, on the same terms as [barRadius]. Ignored
  /// when [indicatorShape] is set.
  final BorderRadiusGeometry indicatorRadius;

  /// Shape of the bar. Overrides [barRadius] when set; defaults to a rounded
  /// rectangle of [barRadius].
  final ShapeBorder? barShape;

  /// Shape of the indicator. Overrides [indicatorRadius] when set; defaults to
  /// a rounded rectangle of [indicatorRadius].
  final ShapeBorder? indicatorShape;

  /// Whether the default shapes round their corners as a superellipse — the
  /// smoothed, iOS-style squircle — rather than as a plain circular arc.
  ///
  /// Drawn by the engine through [RoundedSuperellipseBorder], so it costs no
  /// more than an ordinary [RoundedRectangleBorder].
  final bool smoothCorners;

  /// Shadows cast by the bar, lifting it off the content behind it.
  final List<BoxShadow> barShadows;

  /// Inset between the bar's edge and its items — the gap the indicator sits
  /// inside.
  final EdgeInsetsGeometry barPadding;

  /// Inset between one destination's edge and its icon and label, which sit
  /// centred in whatever room is left.
  final EdgeInsetsGeometry itemPadding;

  /// Inset between the bar and the edges of the space it is given. The bottom
  /// value is how far the bar floats above the bottom of that space.
  final EdgeInsetsGeometry margin;

  /// Height of the bar, [barPadding] included.
  final double height;

  /// Width of one destination, and so of the indicator.
  ///
  /// The bar sizes itself to `destinations.length * itemWidth` plus
  /// [barPadding]. Items shrink below this width only when the bar would
  /// otherwise not fit.
  final double itemWidth;

  /// Size of a destination's icon.
  final double iconSize;

  /// Gap between a destination's icon and its label.
  final double iconLabelSpacing;

  /// Colour the scrim behind the bar fades up to, masking content that scrolls
  /// under it. No scrim is drawn when null — usually the same colour as
  /// [barColor], at full opacity.
  final Color? scrimColor;

  /// Height of that scrim, measured from the bottom of the bar's own space.
  final double scrimHeight;

  /// The registered [FloatingNavBarTheme], or one derived from the ambient
  /// [ColorScheme] when the host has not registered an extension.
  static FloatingNavBarTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<FloatingNavBarTheme>() ??
        fromScheme(theme.colorScheme);
  }

  /// A palette derived from [scheme]: a tinted pill on a translucent surface.
  static FloatingNavBarTheme fromScheme(ColorScheme scheme) =>
      FloatingNavBarTheme(
        barColor: scheme.surfaceContainer.withValues(alpha: 0.8),
        indicatorColor: scheme.primaryContainer,
        selectedItemColor: scheme.onPrimaryContainer,
        unselectedItemColor: scheme.onSurfaceVariant,
        scrimColor: scheme.surface,
      );

  /// The bar shape, defaulting to a rectangle of [barRadius].
  ShapeBorder get resolvedBarShape => barShape ?? shapeFor(barRadius);

  /// The indicator shape, defaulting to a rectangle of [indicatorRadius].
  ShapeBorder get resolvedIndicatorShape =>
      indicatorShape ?? shapeFor(indicatorRadius);

  /// A rectangle with [radius] corners, smoothed into a superellipse when
  /// [smoothCorners] is set.
  ///
  /// Both shapes take a [BorderRadiusGeometry], so any radius the framework
  /// can express is drawn as given — including [BorderRadiusDirectional],
  /// which the shape resolves against the ambient text direction.
  OutlinedBorder shapeFor(BorderRadiusGeometry radius) => smoothCorners
      ? RoundedSuperellipseBorder(borderRadius: radius)
      : RoundedRectangleBorder(borderRadius: radius);

  /// The style for a destination's label, with this theme's colour and family
  /// filled in wherever the host left them unset.
  TextStyle resolvedLabelStyle(TextTheme textTheme, {required bool selected}) {
    final override = selected ? (selectedLabelStyle ?? labelStyle) : labelStyle;
    final base = override ?? textTheme.labelSmall ?? const TextStyle();
    return base.copyWith(
      color: override?.color ?? colorFor(selected: selected),
      fontFamily: override?.fontFamily ?? fontFamily ?? base.fontFamily,
    );
  }

  /// The icon and label colour for a destination in the given state.
  Color colorFor({required bool selected}) =>
      selected ? selectedItemColor : unselectedItemColor;

  @override
  FloatingNavBarTheme copyWith({
    Color? barColor,
    Color? indicatorColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    TextStyle? labelStyle,
    TextStyle? selectedLabelStyle,
    String? fontFamily,
    BorderRadiusGeometry? barRadius,
    BorderRadiusGeometry? indicatorRadius,
    ShapeBorder? barShape,
    ShapeBorder? indicatorShape,
    bool? smoothCorners,
    List<BoxShadow>? barShadows,
    EdgeInsetsGeometry? barPadding,
    EdgeInsetsGeometry? itemPadding,
    EdgeInsetsGeometry? margin,
    double? height,
    double? itemWidth,
    double? iconSize,
    double? iconLabelSpacing,
    Color? scrimColor,
    double? scrimHeight,
  }) => FloatingNavBarTheme(
    barColor: barColor ?? this.barColor,
    indicatorColor: indicatorColor ?? this.indicatorColor,
    selectedItemColor: selectedItemColor ?? this.selectedItemColor,
    unselectedItemColor: unselectedItemColor ?? this.unselectedItemColor,
    labelStyle: labelStyle ?? this.labelStyle,
    selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
    fontFamily: fontFamily ?? this.fontFamily,
    barRadius: barRadius ?? this.barRadius,
    indicatorRadius: indicatorRadius ?? this.indicatorRadius,
    barShape: barShape ?? this.barShape,
    indicatorShape: indicatorShape ?? this.indicatorShape,
    smoothCorners: smoothCorners ?? this.smoothCorners,
    barShadows: barShadows ?? this.barShadows,
    barPadding: barPadding ?? this.barPadding,
    itemPadding: itemPadding ?? this.itemPadding,
    margin: margin ?? this.margin,
    height: height ?? this.height,
    itemWidth: itemWidth ?? this.itemWidth,
    iconSize: iconSize ?? this.iconSize,
    iconLabelSpacing: iconLabelSpacing ?? this.iconLabelSpacing,
    scrimColor: scrimColor ?? this.scrimColor,
    scrimHeight: scrimHeight ?? this.scrimHeight,
  );

  @override
  FloatingNavBarTheme lerp(FloatingNavBarTheme? other, double t) {
    if (other == null) return this;
    return FloatingNavBarTheme(
      barColor: Color.lerp(barColor, other.barColor, t) ?? barColor,
      indicatorColor:
          Color.lerp(indicatorColor, other.indicatorColor, t) ?? indicatorColor,
      selectedItemColor:
          Color.lerp(selectedItemColor, other.selectedItemColor, t) ??
          selectedItemColor,
      unselectedItemColor:
          Color.lerp(unselectedItemColor, other.unselectedItemColor, t) ??
          unselectedItemColor,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      selectedLabelStyle: TextStyle.lerp(
        selectedLabelStyle,
        other.selectedLabelStyle,
        t,
      ),
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      barRadius:
          BorderRadiusGeometry.lerp(barRadius, other.barRadius, t) ?? barRadius,
      indicatorRadius:
          BorderRadiusGeometry.lerp(
            indicatorRadius,
            other.indicatorRadius,
            t,
          ) ??
          indicatorRadius,
      barShape: t < 0.5 ? barShape : other.barShape,
      indicatorShape: t < 0.5 ? indicatorShape : other.indicatorShape,
      smoothCorners: t < 0.5 ? smoothCorners : other.smoothCorners,
      barShadows:
          BoxShadow.lerpList(barShadows, other.barShadows, t) ?? barShadows,
      barPadding:
          EdgeInsetsGeometry.lerp(barPadding, other.barPadding, t) ??
          barPadding,
      itemPadding:
          EdgeInsetsGeometry.lerp(itemPadding, other.itemPadding, t) ??
          itemPadding,
      margin: EdgeInsetsGeometry.lerp(margin, other.margin, t) ?? margin,
      height: lerpDouble(height, other.height, t),
      itemWidth: lerpDouble(itemWidth, other.itemWidth, t),
      iconSize: lerpDouble(iconSize, other.iconSize, t),
      iconLabelSpacing: lerpDouble(iconLabelSpacing, other.iconLabelSpacing, t),
      scrimColor: Color.lerp(scrimColor, other.scrimColor, t),
      scrimHeight: lerpDouble(scrimHeight, other.scrimHeight, t),
    );
  }

  /// [ui.lerpDouble] without the nullable return, since both ends are set.
  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
