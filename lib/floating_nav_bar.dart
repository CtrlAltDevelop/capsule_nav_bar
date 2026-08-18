/// A bottom navigation bar that floats over the content as a rounded capsule,
/// its selection marked by a pill that slides between destinations.
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
///   activeIndex: index,
///   onDestinationSelected: (i) => setState(() => index = i),
/// );
/// ```
///
/// Colours, shapes and metrics come from [FloatingNavBarTheme], registered as a
/// `ThemeExtension`; with none registered the bar derives a palette from the
/// ambient `ColorScheme`.
library;

export 'src/floating_nav_bar.dart';
export 'src/floating_nav_bar_theme.dart';
export 'src/nav_bar_destination.dart';
