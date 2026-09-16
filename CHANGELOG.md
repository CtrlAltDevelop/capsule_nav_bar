# Changelog

## 1.2.1

- **Fixed:** a focused destination was announced as an ordinary button. The
  tile's semantics exclude its children, so the focus state the `InkWell`
  reports never reached a screen reader; the tile now carries `focusable` and
  `focused` itself.
- **Fixed:** an assistive tap went straight to `onDestinationSelected` and
  skipped the platform's tap feedback, which a pointer or the keyboard got.
  All three take the one path now.
- The bar depends on the bottom inset and the text scale specifically rather
  than on the whole `MediaQuery`, so it no longer rebuilds on every unrelated
  metric change — the keyboard coming up, say.
- Dependencies are given as explicit ranges (`material_ui: ">=1.0.0 <2.0.0"`)
  rather than carets, widening the floor to `material_ui` 1.0.0. The package
  analyses and its tests pass against that floor.

## 1.2.0

- **Fixed:** `barGradient` threw a `ShapeDecoration` assertion unless `glass`
  was also set — the plain bar passed both a colour and a gradient, which the
  decoration does not take together.
- Destinations are keyboard-operable: they take focus in the traversal order and
  answer Enter and Space, where before only a pointer could reach them. They
  gain hover, focus and pressed states, clipped to the pill's own shape, and
  they give the platform's tap feedback.
- The bar keeps clear of the bottom system inset — the home indicator, or a
  gesture bar — adding it under `margin` and stretching the scrim over it.
  `useSafeArea` turns it off, on the theme and per instance.
- The bar grows with the platform's text scale rather than ellipsizing its
  labels, capped at `maxHeightScale` times `height`.
- "Reduce motion" is honoured: the indicator snaps to the selection instead of
  sliding to it.
- `CapsuleNavBarTheme` compares by value and describes itself in the devtools,
  so a theme change no longer rebuilds on identity alone.
- `CapsuleNavBarTheme.lerpDouble` is private now; it was an internal helper
  shadowing `dart:ui`'s. **Breaking** only for code that called it directly.
- Tooling, none of which changes the widget: a CI workflow, goldens covering
  light, dark, RTL, a gradient fill and a large text scale, stricter analysis
  (`public_member_api_docs` and the strict language modes among them), and a
  `.pubignore` that keeps the README's GIF out of the archive — 213 KB now,
  from 284 KB.

## 1.1.0

- `glass` — an opt-in backdrop blur behind the bar, for the frosted look, with
  `glassBlur` for its sigma. Off by default, since a `BackdropFilter` is not
  free. On the theme and per instance, like every other knob.
- The blur is drawn inside the bar's own clip, so the frost stops at the
  capsule's edge, and the fill is painted *over* it — frosted glass is a
  translucent sheet laid on a blurred backdrop, where a fill painted underneath
  would be blurred along with the content and read as a smear. The border rides
  on that same layer, so it stays a hairline, while `barShadows` are painted
  outside the clip and are left alone by the blur.
- `barGradient` — the bar's fill as a gradient, for the diagonal sheen a glass
  surface catches. Wins over `barColor`.
- `CapsuleNavBar.glassKey`, on the backdrop filter, so a host can assert the
  frost is there.

## 1.0.0

- First release.
- `CapsuleNavBar` — a bottom navigation bar that floats over the content as a
  rounded capsule, its selection marked by a pill sliding between destinations.
  The bar sizes itself to its destinations and gives up width only when what it
  is offered cannot hold them.
- `NavBarDestination` — a label and the pair of icons drawn for it: the line
  icon while another destination is selected, the filled one while this is.
- A scrim that fades the ambient background up behind the bar, so content
  scrolling underneath does not collide with it. Off when no
  `CapsuleNavBarTheme.scrimColor` is set.
- Taps are highlighted before they are reported, so the bar stays responsive
  while the host switches a router branch. An out-of-range `activeIndex` — the
  `-1` a router reports between branches — leaves the highlight alone.
- `CapsuleNavBarTheme`, a `ThemeExtension` covering colours, text styles,
  shapes and metrics, with `copyWith` and `lerp`. With none registered, the
  palette is derived from the ambient `ColorScheme`.
- Corners are drawn by `RoundedSuperellipseBorder`, in the framework since
  Flutter 3.32, so the smoothed iOS-style squircle costs no extra dependency.
  `barShape` and `indicatorShape` take a whole `ShapeBorder`, on the theme or
  per instance, so a host can bring corner geometry this package does not ship
  — a `figma_squircle` squircle, for instance — and keep that dependency in its
  own pubspec.
- Right-to-left is handled by positioning the indicator with
  `AlignmentDirectional`.
- Destinations are exposed to screen readers as buttons carrying their selected
  state.
- README screenshots and the animated GIF are generated from the real widgets by
  `example/test/screenshots_test.dart` and `example/tool/record_nav_gif.dart`.
- Material comes from the `material_ui` package, not from
  `package:flutter/material.dart`. The types this package exposes —
  `ThemeExtension`, `ThemeData`, `ColorScheme`, `TextTheme` — are
  `material_ui`'s, and those are distinct from the framework's classes of the
  same name, so a host registering `CapsuleNavBarTheme` has to be on
  `material_ui` too.
