import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Everything a [CapsuleNavBar] needs to paint itself.
///
/// Register it as a [ThemeExtension] so the bar follows your app's light and
/// dark themes:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(extensions: [CapsuleNavBarTheme.fromScheme(scheme)]),
/// );
/// ```
///
/// When no extension is registered, [CapsuleNavBarTheme.of] derives a usable
/// palette from the ambient [ColorScheme], so the bar looks reasonable with no
/// setup at all.
@immutable
class CapsuleNavBarTheme extends ThemeExtension<CapsuleNavBarTheme>
    with Diagnosticable {
  /// Creates a theme for [CapsuleNavBar]. Only the four colours are required;
  /// every metric and shape has a default.
  const CapsuleNavBarTheme({
    required this.barColor,
    this.barGradient,
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
    this.glass = false,
    this.glassBlur = 20,
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
    this.useSafeArea = true,
    this.maxHeightScale = 1.6,
  }) : assert(maxHeightScale >= 1, 'maxHeightScale must be at least 1');

  /// Fill of the floating bar itself.
  ///
  /// Give it an alpha below 1 for the frosted look the bar is built for — it
  /// clips its children, so content scrolling underneath shows through.
  final Color barColor;

  /// Fill of the bar as a gradient, for the diagonal sheen a glass surface
  /// catches. Wins over [barColor] when set.
  ///
  /// Like [barColor] it is painted over the blur when [glass] is set, so keep
  /// its stops translucent.
  final Gradient? barGradient;

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

  /// Whether the bar frosts what is behind it, blurring the content it floats
  /// over the way iOS' translucent chrome does.
  ///
  /// The blur is drawn behind [barColor] and clipped to the bar's shape, so it
  /// only shows through a translucent fill — give [barColor] an alpha well
  /// below 1 or the glass is hidden under an opaque slab. It costs a
  /// [BackdropFilter], which is not free on low-end devices, so it is off by
  /// default.
  ///
  /// [barShadows] are painted outside the clip either way, so they are not
  /// smeared by the blur.
  final bool glass;

  /// Blur sigma used when [glass] is set, on both axes.
  final double glassBlur;

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

  /// Whether the bar keeps clear of the system inset at the bottom of the
  /// screen — the home indicator, or a gesture bar.
  ///
  /// The inset is added to [margin]'s bottom and to [scrimHeight], so the bar
  /// floats [margin] above the safe area rather than above the screen edge.
  /// Turn it off when the bar is already inside a [SafeArea], or when it is
  /// not at the bottom of the screen at all.
  final bool useSafeArea;

  /// How far [height] is allowed to grow with the platform's text scale.
  ///
  /// Labels grow with the ambient [TextScaler], so a fixed-height bar
  /// ellipsizes them at the larger accessibility sizes. The bar instead grows
  /// with the scale, up to this multiple of [height]. Set it to `1` to pin the
  /// bar to [height] and let long labels ellipsize.
  final double maxHeightScale;

  /// The registered [CapsuleNavBarTheme], or one derived from the ambient
  /// [ColorScheme] when the host has not registered an extension.
  static CapsuleNavBarTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<CapsuleNavBarTheme>() ??
        fromScheme(theme.colorScheme);
  }

  /// A palette derived from [scheme]: a tinted pill on a translucent surface.
  static CapsuleNavBarTheme fromScheme(ColorScheme scheme) =>
      CapsuleNavBarTheme(
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

  /// [height], grown with [textScaler] up to [maxHeightScale] times itself.
  double heightFor(TextScaler textScaler) =>
      height * textScaler.scale(1).clamp(1.0, maxHeightScale);

  /// The icon and label colour for a destination in the given state.
  Color colorFor({required bool selected}) =>
      selected ? selectedItemColor : unselectedItemColor;

  @override
  CapsuleNavBarTheme copyWith({
    Color? barColor,
    Gradient? barGradient,
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
    bool? glass,
    double? glassBlur,
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
    bool? useSafeArea,
    double? maxHeightScale,
  }) => CapsuleNavBarTheme(
    barColor: barColor ?? this.barColor,
    barGradient: barGradient ?? this.barGradient,
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
    glass: glass ?? this.glass,
    glassBlur: glassBlur ?? this.glassBlur,
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
    useSafeArea: useSafeArea ?? this.useSafeArea,
    maxHeightScale: maxHeightScale ?? this.maxHeightScale,
  );

  @override
  CapsuleNavBarTheme lerp(CapsuleNavBarTheme? other, double t) {
    if (other == null) return this;
    return CapsuleNavBarTheme(
      barColor: Color.lerp(barColor, other.barColor, t) ?? barColor,
      barGradient: Gradient.lerp(barGradient, other.barGradient, t),
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
      glass: t < 0.5 ? glass : other.glass,
      glassBlur: _lerpDouble(glassBlur, other.glassBlur, t),
      barShadows:
          BoxShadow.lerpList(barShadows, other.barShadows, t) ?? barShadows,
      barPadding:
          EdgeInsetsGeometry.lerp(barPadding, other.barPadding, t) ??
          barPadding,
      itemPadding:
          EdgeInsetsGeometry.lerp(itemPadding, other.itemPadding, t) ??
          itemPadding,
      margin: EdgeInsetsGeometry.lerp(margin, other.margin, t) ?? margin,
      height: _lerpDouble(height, other.height, t),
      itemWidth: _lerpDouble(itemWidth, other.itemWidth, t),
      iconSize: _lerpDouble(iconSize, other.iconSize, t),
      iconLabelSpacing: _lerpDouble(
        iconLabelSpacing,
        other.iconLabelSpacing,
        t,
      ),
      scrimColor: Color.lerp(scrimColor, other.scrimColor, t),
      scrimHeight: _lerpDouble(scrimHeight, other.scrimHeight, t),
      useSafeArea: t < 0.5 ? useSafeArea : other.useSafeArea,
      maxHeightScale: _lerpDouble(maxHeightScale, other.maxHeightScale, t),
    );
  }

  /// `ui.lerpDouble` without the nullable return, since both ends are set.
  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  /// Every field, in declaration order — the one list [operator ==],
  /// [hashCode] and [debugFillProperties] all read, so none of them can fall
  /// behind a field added later.
  List<Object?> get _fields => [
    barColor,
    barGradient,
    indicatorColor,
    selectedItemColor,
    unselectedItemColor,
    labelStyle,
    selectedLabelStyle,
    fontFamily,
    barRadius,
    indicatorRadius,
    barShape,
    indicatorShape,
    smoothCorners,
    glass,
    glassBlur,
    barPadding,
    itemPadding,
    margin,
    height,
    itemWidth,
    iconSize,
    iconLabelSpacing,
    scrimColor,
    scrimHeight,
    useSafeArea,
    maxHeightScale,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CapsuleNavBarTheme &&
        // The shadow list is compared by value; the rest are immutable.
        listEquals(other.barShadows, barShadows) &&
        listEquals(other._fields, _fields);
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(_fields), Object.hashAll(barShadows));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('barColor', barColor))
      ..add(
        DiagnosticsProperty<Gradient>(
          'barGradient',
          barGradient,
          defaultValue: null,
        ),
      )
      ..add(ColorProperty('indicatorColor', indicatorColor))
      ..add(ColorProperty('selectedItemColor', selectedItemColor))
      ..add(ColorProperty('unselectedItemColor', unselectedItemColor))
      ..add(
        DiagnosticsProperty<TextStyle>(
          'labelStyle',
          labelStyle,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<TextStyle>(
          'selectedLabelStyle',
          selectedLabelStyle,
          defaultValue: null,
        ),
      )
      ..add(StringProperty('fontFamily', fontFamily, defaultValue: null))
      ..add(DiagnosticsProperty<BorderRadiusGeometry>('barRadius', barRadius))
      ..add(
        DiagnosticsProperty<BorderRadiusGeometry>(
          'indicatorRadius',
          indicatorRadius,
        ),
      )
      ..add(
        DiagnosticsProperty<ShapeBorder>(
          'barShape',
          barShape,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ShapeBorder>(
          'indicatorShape',
          indicatorShape,
          defaultValue: null,
        ),
      )
      ..add(
        FlagProperty(
          'smoothCorners',
          value: smoothCorners,
          ifFalse: 'circular corners',
        ),
      )
      ..add(FlagProperty('glass', value: glass, ifTrue: 'frosted'))
      ..add(DoubleProperty('glassBlur', glassBlur))
      ..add(
        IterableProperty<BoxShadow>(
          'barShadows',
          barShadows,
          defaultValue: const <BoxShadow>[],
        ),
      )
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('barPadding', barPadding))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('itemPadding', itemPadding))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin))
      ..add(DoubleProperty('height', height))
      ..add(DoubleProperty('itemWidth', itemWidth))
      ..add(DoubleProperty('iconSize', iconSize))
      ..add(DoubleProperty('iconLabelSpacing', iconLabelSpacing))
      ..add(ColorProperty('scrimColor', scrimColor, defaultValue: null))
      ..add(DoubleProperty('scrimHeight', scrimHeight))
      ..add(
        FlagProperty(
          'useSafeArea',
          value: useSafeArea,
          ifFalse: 'ignores the safe area',
        ),
      )
      ..add(DoubleProperty('maxHeightScale', maxHeightScale));
  }
}
