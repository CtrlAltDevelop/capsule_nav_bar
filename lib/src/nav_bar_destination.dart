import 'package:flutter/widgets.dart';

/// One destination of a [CapsuleNavBar].
///
/// A destination is a [label] and the pair of icons drawn for it: [lineIcon]
/// while another destination is selected, [fillIcon] while this one is.
/// Material's outlined and filled variants pair up directly, and so does any
/// other family shipping two weights, which gives the bar its
/// filled-on-select look for free:
///
/// ```dart
/// const NavBarDestination(
///   label: 'Home',
///   lineIcon: Icons.home_outlined,
///   fillIcon: Icons.home,
/// )
/// ```
///
/// With only one weight to hand, pass it as both.
@immutable
class NavBarDestination {
  const NavBarDestination({
    required this.label,
    required this.lineIcon,
    IconData? fillIcon,
    this.semanticLabel,
    this.tooltip,
  }) : fillIcon = fillIcon ?? lineIcon;

  /// The text shown under the icon.
  final String label;

  /// The icon drawn while the destination is *not* selected.
  final IconData lineIcon;

  /// The icon drawn while the destination is selected. Defaults to [lineIcon].
  final IconData fillIcon;

  /// Screen-reader label. Falls back to [label].
  final String? semanticLabel;

  /// Long-press tooltip. No tooltip is shown when null.
  final String? tooltip;

  /// The icon for the destination in the given state.
  IconData iconFor({required bool selected}) => selected ? fillIcon : lineIcon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavBarDestination &&
          other.label == label &&
          other.lineIcon == lineIcon &&
          other.fillIcon == fillIcon &&
          other.semanticLabel == semanticLabel &&
          other.tooltip == tooltip;

  @override
  int get hashCode =>
      Object.hash(label, lineIcon, fillIcon, semanticLabel, tooltip);
}
