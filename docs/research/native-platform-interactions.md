# Native platform interactions in skribble

Research date: 2026-09-19

This study examines what `adaptive_platform_ui` 1.0.1 implements, which interactions it delegates to system controls, and which parts are Flutter approximations. It then audits skribble's current interaction surface and proposes a widgets-only architecture, rollout plan, and verification matrix. The evidence comes from the published package, its tagged source and tests, the current skribble codebase, Flutter documentation, and first-party Apple and Android guidance.

## Summary

`adaptive_platform_ui` is three implementations behind one Dart API:

1. iOS 26 and later can use UIKit controls embedded through `UiKitView`.
2. Earlier iOS releases use Flutter's Cupertino widgets or custom Flutter widgets.
3. Android and most other platforms use Flutter's Material widgets. The Android plugin itself is empty.

The package's most substantial idea is not its widget-by-widget platform switch. It is the fixed navigation chrome introduced in 1.0.0. A registry lets each route publish its toolbar state. A host above the navigator chooses the active route, keeps the bar fixed while pages move, follows the route animation during push, pop, and interactive back gestures, and accounts for nested navigators and covered routes. That work is materially deeper than changing colors or selecting `CupertinoButton` instead of `ElevatedButton`.

The package is also evidence for a useful boundary: native rendering does not by itself make an adaptive library complete. Several controls are only visual approximations, some public options are unused on iOS, non-mobile platforms receive Material fallbacks, and the automated checks do not exercise the Swift code or accessibility behavior. The package should therefore be treated as a source of implementation patterns and test cases, not as proof that every exported `Adaptive*` widget has native interaction fidelity.

For skribble, the upstream package is not a compatible direct dependency. Its public app shell owns `MaterialApp` or `CupertinoApp`, its core widgets import both Material and Cupertino, and its platform policy is hard-coded around `dart:io`. Its MIT license permits study and reuse with attribution, but copied source would retain Flutter Material/Cupertino coupling unless deliberately redesigned.

The recommendation is to keep skribble's pixels and adapt its behavior. Build one widgets-only interaction substrate that owns focus, keyboard activation, pointer semantics, semantic actions, scrolling, feedback, menus, and routes. Let `Wired*` painters consume that state. Do not add a parallel catalog of `Adaptive*` widgets, do not depend on `adaptive_platform_ui`, and do not use platform views for ordinary controls. The first implementation slice should be a testable interaction scope, a reusable pressable primitive, and app-level scroll behavior. Text editing and navigation should follow as dedicated projects because their native contracts are much larger than their appearance suggests.

The most valuable upstream pattern to adapt is the route-aware toolbar registry. The most important upstream warning is that visual platform branching can conceal missing keyboard, focus, semantics, and accessibility behavior. Native fidelity is a behavioral contract, not a renderer choice.

## Snapshot and provenance

The evidence below is pinned to tag `v1.0.1`, commit [`11fc9e5228f7af1c454009d92b2459c6ae4cd563`](https://github.com/berkaycatak/adaptive_platform_ui/commit/11fc9e5228f7af1c454009d92b2459c6ae4cd563), committed on 2026-09-19 at 21:58:26 +03:00. The tag was created at 22:05:03 +03:00. Pub.dev published 1.0.1 at 2026-09-19 19:05:24 UTC with archive SHA-256 `87d68bd7b8de32768891cfc39a3dccbf0f539e4c6b714ada31d86e4d11b08822`; these values are available in the [pub.dev package API](https://pub.dev/api/packages/adaptive_platform_ui). Version 1.0.0 had been published earlier that day at 10:23:38 UTC. The first public version listed by pub.dev, 0.1.0, dates to 2025-10-10.

A checksum comparison found no content differences between the 1.0.1 pub archive and the tagged checkout after excluding Git metadata and generated build directories. Source observations in this note therefore apply to the published artifact, not only to the repository's current branch.

At the research cutoff, the [pub.dev score page](https://pub.dev/packages/adaptive_platform_ui/score) reported 160/160 points, 396 likes, and 11,298 downloads in the preceding 30 days. These are volatile adoption signals, not quality guarantees. The package's [GitHub repository](https://github.com/berkaycatak/adaptive_platform_ui) reported 243 stars, 89 forks, and 46 open issues. Local history contained 259 commits, including 24 since 2026-09-01. The repository was not archived.

The published constraints are Dart `^3.9.2`, Flutter `>=1.17.0`, and `foldable ^1.0.3`. The plugin declares only iOS and Android targets ([`pubspec.yaml`](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/pubspec.yaml#L1-L38)). The actual native iOS minimum is 15.0 in both [Swift Package Manager](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/ios/adaptive_platform_ui/Package.swift#L6-L23) and [CocoaPods](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/ios/adaptive_platform_ui.podspec#L5-L23). The podspec still declares version `0.1.0`, so the package has a small metadata inconsistency even though the source path and deployment target are current.

## Architecture

The runtime selection can be summarized as follows:

| Layer                        | iOS 26+                                    | iOS before 26                                 | Android                         | Web and desktop fallback           |
| ---------------------------- | ------------------------------------------ | --------------------------------------------- | ------------------------------- | ---------------------------------- |
| App shell                    | `CupertinoApp` plus toolbar host           | `CupertinoApp` plus toolbar host              | `MaterialApp` plus toolbar host | `MaterialApp` plus toolbar host    |
| Selected controls and chrome | UIKit platform views                       | Cupertino widgets or custom Flutter widgets   | Material widgets                | Usually Material widgets           |
| Native plugin                | Ten registered iOS platform-view factories | Factories exist but Dart does not select them | Empty plugin                    | No declared plugin target          |
| Platform policy              | `Platform.isIOS` and parsed OS version     | Same                                          | `Platform.isAndroid`            | Falls through from the same checks |

`AdaptiveApp` performs the top-level split. It returns a Cupertino app on iOS and a Material app everywhere else, including its router variants ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_app.dart#L241-L470)). Both paths install `AdaptiveToolbarHost` around the routed child. On iOS, the wrapper also reconciles explicit theme mode with `MediaQuery` brightness and sets the status-bar icon style.

The package's public barrel has 41 exports. It exposes platform detection, a spring curve, SF Symbol data, the app and toolbar infrastructure, 28 `adaptive_*` source files, and eight low-level iOS 26 files ([public exports](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/adaptive_platform_ui.dart#L30-L82)). The low-level native wrappers are therefore public API rather than hidden renderer details.

The iOS plugin registers factories for a button, switch, slider, segmented control, alert, popup menu, tab bar, toolbar, blur view, and glass capsule ([Swift registration](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/ios/adaptive_platform_ui/Sources/adaptive_platform_ui/AdaptivePlatformUiPlugin.swift#L8-L82)). The [Android plugin](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/android/src/main/kotlin/com/berkaycatak/adaptive_platform_ui/AdaptivePlatformUiPlugin.kt#L5-L13) explicitly does nothing because Material controls render in Dart.

Each iOS 26 wrapper gives a `UiKitView` bounded geometry, sends creation parameters, and maintains a control-specific method channel. For example, the native button uses fixed control heights and overlays a custom Flutter child when requested ([Dart wrapper](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/ios26/ios26_button.dart#L329-L410)). The Swift side builds `UIButton.Configuration` variants and reports taps through the channel ([Swift button](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/ios/adaptive_platform_ui/Sources/adaptive_platform_ui/iOS26ButtonView.swift#L117-L271)).

This gives selected controls UIKit rendering, state behavior, and native accessibility objects. It also inherits platform-view costs. Flutter documents that `UiKitView` creation is asynchronous, paints nothing until the native view exists, needs bounded constraints, participates in Flutter's gesture arena, and is an expensive composition mechanism that should be avoided when an equivalent Flutter widget is practical ([Flutter `UiKitView` API](https://api.flutter.dev/flutter/widgets/UiKitView-class.html)). Flutter connects a platform view's accessibility nodes under the corresponding Flutter semantics node through `platformViewId` ([Flutter semantics API](https://api.flutter.dev/flutter/semantics/SemanticsNode/platformViewId.html)). This is a bridge, not a substitute for testing the combined tree.

## Platform selection

`PlatformInfo` imports `dart:io` and uses `Platform.isIOS`, `Platform.isAndroid`, and related flags, guarded only by `kIsWeb`. It parses `Platform.operatingSystemVersion` with a `Version (\d+)` regular expression, then falls back to the first number in the string ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/platform/platform_info.dart#L1-L68)). There is no injected capability object and no use of `ThemeData.platform` or `defaultTargetPlatform`.

This has four practical effects:

- Widget tests cannot select another branch with Flutter's debug platform override. One upstream test explicitly leaves the Android popup-menu path untested because the code reads the host OS directly ([test note](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/test/adaptive_popup_menu_test.dart#L89-L93)).
- An unparsable iOS version becomes `0`, so Dart declines the native path even though Swift could make the authoritative `#available(iOS 26.0, *)` check.
- `isIOS18OrLower()` is named and documented as iOS 18 or lower but actually returns true for every positive version below 26, including 19 through 25.
- macOS is detected but does not receive Cupertino behavior in the app or most controls. Web, Windows, Linux, Fuchsia, and macOS generally fall through to Material. `AdaptiveSegmentedControl` is an exception: its non-iOS, non-Android fallback is Cupertino ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_segmented_control.dart#L66-L109)).

Flutter's own adaptive constructors use the ambient target platform instead. For example, [`Switch.adaptive`](https://api.flutter.dev/flutter/material/Switch/Switch.adaptive.html) selects a Cupertino switch for both iOS and macOS according to `ThemeData.platform`. [`Checkbox.adaptive`](https://api.flutter.dev/flutter/material/Checkbox/Checkbox.adaptive.html) does the same and retains focus and semantic-label parameters. This makes the framework controls easier to exercise under widget tests and more appropriate when an application intentionally overrides platform policy.

The package also treats platform adaptation and responsive layout as mostly separate concerns. Apple asks iPhone Duo apps to resize and adjust dynamically across postures ([Apple's iPhone Duo portal](https://developer.apple.com/iphone-duo/)). Android similarly says to choose layouts from the current window size and to expect size classes to change while the app is running ([Android window-size guidance](https://developer.android.com/develop/adaptive-apps/guides/use-window-size-classes)). The upstream package has detailed Duo reserved-region handling, but its ordinary Android navigation remains a bottom bar regardless of available width.

## Implemented widget behavior

The following table describes the implementation, not just the README promise.

| API area                                    | iOS 26+                                                   | Earlier iOS                        | Android and usual fallback          | Material observations                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------------------- | --------------------------------------------------------- | ---------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AdaptiveButton`                            | Native `UIButton` when `useNative` is true                | `CupertinoButton`                  | Material button variant             | The API supports label, icon, and child forms. Native buttons use UIKit configurations, but custom Flutter children are overlays rather than native button content ([branch](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_button.dart#L159-L246)).                                                                                                                                                                                                                                                                                  |
| Switch                                      | Native `UISwitch`                                         | `CupertinoSwitch`                  | Material `Switch`                   | This is a clean system-control delegation ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_switch.dart#L60-L111)).                                                                                                                                                                                                                                                                                                                                                                                                            |
| Slider                                      | Native `UISlider`                                         | `CupertinoSlider`                  | Material `Slider`                   | The native wrapper synchronizes value, colors, divisions, and callbacks. Flutter already offers [`Slider.adaptive`](https://api.flutter.dev/flutter/material/Slider/Slider.adaptive.html), including focus and semantic formatting hooks.                                                                                                                                                                                                                                                                                                                                                                         |
| Segmented control                           | Native `UISegmentedControl`                               | `CupertinoSlidingSegmentedControl` | Material `SegmentedButton`          | The fallback for unrecognized platforms is Cupertino, unlike most package controls ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_segmented_control.dart#L66-L109)).                                                                                                                                                                                                                                                                                                                                                        |
| Checkbox and radio                          | Custom Flutter drawing                                    | Same custom drawing                | Material `Checkbox` and `Radio`     | The iOS implementations are a 22-point `GestureDetector` around a decorated `Container`; they do not add `Semantics`, focus, keyboard activation, or hover handling ([checkbox](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_checkbox.dart#L112-L188), [radio](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_radio.dart#L114-L168)).                                                                                                                   |
| Text field and form field                   | `CupertinoTextField`                                      | `CupertinoTextField`               | `TextField` or `TextFormField`      | The field delegates core editing to Flutter, so selection toolbars, keyboard gestures, spellcheck, and cursor behavior can adapt. On iOS, prefix and suffix widgets receive an extra no-op tap recognizer intended to prevent field focus. Interactive icon children therefore enter a competing gesture arena that the API does not describe ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_text_field.dart#L133-L237)).                                                                                                   |
| Card, badge, list tile, expansion tile, FAB | Custom Flutter iOS appearance                             | Same                               | Material components                 | These are hand-built appearance branches, not native Apple controls. `AdaptiveCard` is the only one in this group that explicitly adds a semantic container ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_card.dart#L82-L195)).                                                                                                                                                                                                                                                                                            |
| Form section                                | `CupertinoFormSection`                                    | Same                               | Material `Card` composition         | This delegates grouped form layout to the relevant Flutter design library ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_form_section.dart#L92-L135)).                                                                                                                                                                                                                                                                                                                                                                      |
| Tab view                                    | Cupertino segmented control plus `PageView`               | Same                               | Material `TabBar` plus `PageView`   | It is a local content switcher, separate from the app-level native tab bar ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_tab_view.dart#L115-L171)).                                                                                                                                                                                                                                                                                                                                                                        |
| Alert dialog                                | Native `UIAlertController` hosted through a platform view | `CupertinoAlertDialog`             | Material `AlertDialog`              | Standard and text-input APIs are separate. The native implementation adds its own blur, corner, and shadow treatment around the controller rather than only presenting the system object ([Dart branch](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_alert_dialog.dart#L35-L194)).                                                                                                                                                                                                                                                  |
| Popup menu                                  | Native `UIMenu` attached to a UIKit button                | `CupertinoActionSheet`             | Material `PopupMenuButton`          | The pre-26 iOS fallback is a modal action sheet, not an anchored menu or popover ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_popup_menu_button.dart#L17-L166), [fallback](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_popup_menu_button.dart#L208-L250)).                                                                                                                                                                                 |
| Context menu                                | `CupertinoContextMenu`                                    | `CupertinoContextMenu`             | Long press plus Material `showMenu` | Despite the class comment, the iOS 26 path is not a native `UIContextMenu`. `previewBuilder` is never read, and `isDisabled` is ignored by the Cupertino action conversion ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_context_menu.dart#L32-L152)).                                                                                                                                                                                                                                                                     |
| Date and time pickers                       | Cupertino modal picker                                    | Same                               | Material picker dialogs             | Android `minuteInterval` snaps the result after selection rather than constraining displayed choices. Android `dateAndTime` chains a date dialog and a time dialog. The iOS confirmation labels use Material localization, so both localization families are required ([date source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_date_picker.dart#L17-L121), [time source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_time_picker.dart#L21-L103)). |
| Tooltip                                     | Custom Flutter overlay                                    | Same                               | Material `Tooltip`                  | The iOS branch opens on tap or long press and always follows `preferBelow`; it does not implement the documented automatic flip when space is insufficient and adds no tooltip semantics ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_tooltip.dart#L141-L202), [positioning](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_tooltip.dart#L259-L310)).                                                                                         |
| Snackbar                                    | Custom top banner overlay                                 | Same                               | Material `SnackBar`                 | The iOS branch slides and fades a tappable banner. It is an application convention, not a UIKit snackbar, and has no live-region semantics ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_snackbar.dart#L24-L104)).                                                                                                                                                                                                                                                                                                         |
| Blur                                        | Native `UIVisualEffectView`                               | Flutter `BackdropFilter`           | Flutter `BackdropFilter`            | This exposes a native effect where the OS supplies one and a visual approximation elsewhere ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_blur_view.dart#L31-L85)).                                                                                                                                                                                                                                                                                                                                                        |

Flutter's adaptation guidance separates operating-system behavior from app conventions. Scrolling physics, overscroll, text editing, selection controls, navigation transitions, icon direction, and haptics are behaviors that should feel wrong when mismatched. App bars, tabs, and information architecture need an application-level decision rather than automatic substitution ([Flutter platform adaptations](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations)). The upstream package is strongest when it delegates the first category to UIKit, Cupertino, or Material. It is least convincing where a `GestureDetector` and custom painting imitate only the second category's appearance.

## Navigation, transitions, and fixed chrome

`AdaptiveToolbarHost` places one chrome layer above the navigator rather than embedding a toolbar in each route. On iOS 26 it also subscribes to foldable geometry and decides between a horizontal toolbar and the Duo trailing bar ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/toolbar/adaptive_toolbar_host.dart#L14-L126)). Each `AdaptiveScaffold` publishes a `ToolbarEntry` containing its route, navigator, enclosing routes, visibility, title overlay, and optional tab bar ([scaffold registration](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_scaffold.dart#L193-L300)). Sheets and dialogs keep local chrome because only `PageRoute` entries opt into the fixed host.

The registry chooses the newest active entry while tracking nested route coverage and whether its own navigator can pop ([registry](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/toolbar/toolbar_registry.dart#L7-L150)). Notifications are coalesced after the frame, which avoids mutating dependents while routes rebuild ([registry updates](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/toolbar/toolbar_registry.dart#L178-L247)).

`ToolbarBlend` follows the route's own animation for push, pop, and interactive back gestures. It preserves the outgoing entry after disposal long enough to fade its items, uses a 220 ms crossfade when no route animation is available, and dims covered chrome to 0.45 opacity ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/toolbar/toolbar_blend.dart#L6-L123), [transition selection](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/toolbar/toolbar_blend.dart#L141-L218)). This is why a canceled iOS back swipe can reverse the toolbar blend rather than completing a detached animation.

The Duo layout is not guessed from device names. The app consumes reserved regions and size classes from `foldable`, preserves the tab bar at the bottom of the trailing strip, and moves lower-priority toolbar actions into a native overflow menu. Each visible action group is a native glass capsule even though the vertical layout itself is Flutter-composed ([Duo vertical bar](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/toolbar/duo_vertical_bar.dart#L232-L392)). The 1.0.1 changelog says this geometry was measured against an iPhone Duo simulator and corrected for rotation, camera placement, overflow, and tab placement ([changelog](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/CHANGELOG.md#L3-L11)).

There is one important qualification to the native-tab claim. The Swift tab view explains that Apple's official minimize behavior belongs to `UITabBarController`, while this package hosts a standalone `UITabBar`. The package therefore animates scale and opacity from Dart in response to scroll notifications ([Swift comment](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/ios/adaptive_platform_ui/Sources/adaptive_platform_ui/iOS26TabBarPlatformView.swift#L328-L338), [Dart scroll bridge](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_scaffold.dart#L574-L608)). The tab bar is native. Its minimize behavior is an approximation.

Apple describes a tab bar as persistent top-level navigation that preserves each section's navigation state, and it exposes official minimize behavior when attached to the system container ([Apple tab-bar guidance](https://developer.apple.com/design/human-interface-guidelines/tab-bars)). Android expects three to five peer destinations in a navigation bar on compact windows and a rail or drawer at larger sizes ([Android navigation guidance](https://developer.android.com/design/ui/mobile/guides/layout-and-content/layout-and-nav-patterns)). The upstream implementation closely models the latest iOS chrome, but it does not provide the corresponding Android window-size transition.

## Interaction fidelity

### Native controls provide more than appearance

The UIKit-backed controls receive native control state handling and native accessibility objects, subject to the configuration applied by each wrapper. Apple notes that system buttons include interaction states, accessibility support, and appearance adaptation ([Apple button guidance](https://developer.apple.com/design/human-interface-guidelines/buttons)). System controls can also inherit platform haptics. Apple states that switches, sliders, and pickers play feedback automatically, recommends established feedback meanings, warns against overuse, and asks apps to make haptics optional ([Apple haptics guidance](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)).

The package's native button additionally triggers a medium impact on every tap and applies its own spring scale ([Swift source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/ios/adaptive_platform_ui/Sources/adaptive_platform_ui/iOS26ButtonView.swift#L317-L338)). That may be appropriate for a deliberate tactile style, but it is not simply inherited UIKit behavior and it offers no package-level preference to disable the added haptic.

Apple's current material guidance says Liquid Glass belongs in the functional layer for controls and navigation, should be used sparingly, and should not become a general content background ([Apple materials guidance](https://developer.apple.com/design/human-interface-guidelines/materials)). `AdaptiveBlurView` makes the effect available as an arbitrary content wrapper. Consumers therefore remain responsible for using it within the intended hierarchy.

### Flutter delegation retains mature behaviors

Using `CupertinoTextField`, `TextField`, standard pickers, and standard route classes is valuable even when those widgets are not platform views. Flutter already adapts text-selection menus, cursor gestures, scrolling physics, overscroll, momentum, status-bar tap-to-top, route direction under right-to-left locales, icons, and selected haptics ([Flutter platform adaptations](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations)). Reimplementing these interactions to get a different surface treatment would create a large hidden compatibility burden.

The package's fixed toolbar follows this principle for transition timing: it observes the navigator's route animation rather than recreating a nominal iOS duration. By contrast, the custom checkbox, radio, tooltip, list tile, and snackbar stop at tap behavior and drawing. They do not inherit keyboard navigation, hover, focus rings, semantic actions, or screen-reader announcements merely because their visual styling resembles iOS.

### Public APIs leak renderer differences

The same logical action may require an `iosSymbol`, a fallback `IconData`, an optional `iconWidget`, and a text label. `AdaptiveNavigationDestination.icon` and context-menu icons are typed as `dynamic` so the caller can pass platform-specific representations. This shifts renderer knowledge into application code and weakens compile-time guarantees.

`AdaptiveAppBarAction.label` is a good counterexample. One semantic name is reused for Duo overflow text, an iOS accessibility label, and an Android tooltip ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_app_bar_action.dart#L56-L73)). The Swift [toolbar](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/ios/adaptive_platform_ui/Sources/adaptive_platform_ui/iOS26ToolbarPlatformView.swift#L232-L243) and [glass capsule](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/ios/adaptive_platform_ui/Sources/adaptive_platform_ui/iOS26GlassCapsuleView.swift#L191-L203) both apply this value as the native accessibility label. A renderer-independent intent model can therefore improve several platforms at once.

There is a concrete update hazard in this same type. Its equality and hash code omit `onPressed` and `spacerAfter`, even though `spacerAfter` is serialized to native code ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_app_bar_action.dart#L75-L139)). Code that suppresses native updates using this equality can miss a grouping-only change.

`AdaptiveAppBar.useNativeToolbar` also has contradictory documentation. The constructor default is `true`, while its field comment says false is the default and warns about router compatibility ([source](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/lib/src/widgets/adaptive_app_bar.dart#L17-L55)). The newer toolbar-host architecture is explicitly designed for routers, so the stale comment is likely documentation debt.

## Accessibility, localization, and alternate input

The accessibility story differs by renderer:

- Native UIKit controls can expose their native accessibility objects through the platform-view semantics bridge. Toolbar action labels are explicitly serialized for VoiceOver.
- Standard Material and Cupertino widgets bring Flutter's semantics, focus, keyboard, hover, and state handling.
- Custom Flutter branches must provide these capabilities themselves. The iOS checkbox and radio do not. The custom tooltip does not expose its message as a tooltip semantic. The iOS snackbar does not mark its message as a live region. The custom list tile and expansion affordances rely primarily on gesture detection.

The repository contains 287 `test` or `testWidgets` declarations at the pinned commit. The suite has substantial route, transition, fold geometry, widget rendering, and callback coverage. For example, the toolbar tests simulate deep stacks, nested tabs, dialogs, back swipes, canceled gestures, and Duo geometry ([toolbar registry tests](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/test/toolbar_registry_test.dart#L46-L100), [chrome tests](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/test/toolbar_host_chrome_test.dart#L11-L78)). However, no test asserts a semantics tree, screen-reader label, focus traversal, keyboard activation, text scaling result, reduced-motion response, or increased-contrast result. There is also no integration-test directory exercising UIKit and Flutter together.

Localization requires Material, Cupertino, and Widgets delegates even on an `AdaptiveApp`. The README explicitly documents all three because pickers and buttons cross those library boundaries ([README](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/README.md#L78-L101)). This is correct for the current implementation, but it also shows that the facade has not isolated its renderer-specific dependencies.

Right-to-left support is uneven. The changelog records explicit RTL mirroring for the native tab bar in 0.1.105, but no equivalent package-level test matrix covers all custom controls ([changelog](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/CHANGELOG.md#L61-L68)). Apple expects directional navigation icons and layout to mirror while icons that represent physical direction remain unchanged ([Apple right-to-left guidance](https://developer.apple.com/design/human-interface-guidelines/right-to-left)). A complete adaptive layer needs semantic direction rules, not blanket mirroring.

## Maintenance and verification signals

The project is active. Version 1.0.1 shipped on the research date, the tagged commit is a documentation asset correction layered on the release implementation, and the changelog records frequent contributions from multiple authors. Recent releases fixed cold-launch layout, dynamic labels and titles, dark mode, modal bleed-through, keyboard interaction, iPad window positioning, RTL, router chrome, and several width constraints. That history is evidence that platform-view composition and cross-platform parity need ongoing maintenance even when the public API is small ([changelog](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/CHANGELOG.md#L24-L116)).

The CI workflow is narrower than the feature surface. It runs analysis and Flutter widget tests on Ubuntu with Flutter 3.35.6, then builds only the Android example ([workflow](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/.github/workflows/ci.yml#L9-L83)). It does not compile the Swift package on macOS, build the iOS example, run an iOS simulator, exercise native method channels, inspect VoiceOver output, or test Apple appearance settings. The [tagged CI run](https://github.com/berkaycatak/adaptive_platform_ui/actions/runs/35462874062) passed, but it cannot validate the package's principal iOS-native differentiator.

The minimum versions are also not expressed consistently. Dart claims compatibility with any Flutter release from 1.17.0, while the code and CI use APIs and language constraints associated with a much newer toolchain, and CI tests only Flutter 3.35.6. Consumers should use the Dart SDK lower bound as the meaningful practical constraint rather than the broad Flutter lower bound.

## License

The project is MIT licensed, copyright 2025 Berkay Catak ([license](https://github.com/berkaycatak/adaptive_platform_ui/blob/11fc9e5228f7af1c454009d92b2459c6ae4cd563/LICENSE#L1-L20)). The license permits use, copying, modification, merging, publication, distribution, sublicensing, and sale. Copies or substantial portions must retain the copyright and permission notice. The software is provided without warranty.

This permits skribble to reimplement patterns or incorporate source, subject to notice retention for copied substantial portions. It does not remove obligations attached to Apple assets, SF Symbols, Flutter, or other dependencies. The upstream repository itself does not bundle an additional design-resource license in the package root.

## Factual constraints for skribble

These constraints follow from the code above. They are not a proposed skribble roadmap.

1. A direct dependency conflicts with skribble's standalone target. `AdaptiveApp` owns a Material or Cupertino app, and nearly every facade imports `package:flutter/material.dart`, `package:flutter/cupertino.dart`, or both.
2. The native iOS renderer requires plugin registration, a platform-view lifecycle, method-channel state synchronization, iOS 15 or later, and Swift/CocoaPods or Swift Package Manager maintenance. It is not a widgets-only implementation.
3. UIKit platform views should be reserved for behavior or material Flutter cannot reproduce faithfully. Flutter documents their asynchronous creation, gesture arbitration, clipping, and composition cost.
4. Platform identity, OS capability, window posture, input mode, and design policy need separate representations. Upstream's static `dart:io` branch makes testing and explicit policy overrides difficult.
5. An adaptive public API should describe intent once. Parallel icon fields and `dynamic` icon values expose renderer choice to every caller. The toolbar `label` demonstrates a better cross-renderer semantic contract.
6. Native expected interaction includes semantics, focus, keyboard, hover, text scaling, contrast, reduced motion, localization, safe areas, and gesture behavior. Visual substitution alone does not cover it.
7. Navigation chrome is cross-widget state, not a leaf-widget concern. The upstream registry and route-animation binding cannot be replicated reliably inside an app-bar painter alone.
8. Responsive navigation is distinct from OS theming. Android's guidance requires navigation bar, rail, or drawer selection based on current window size, while Apple's Duo guidance introduces posture and reserved-region changes during the session.
9. Native integration needs native verification. A Linux widget-test suite cannot establish that Swift compiles, UIKit responds correctly, platform-view semantics merge properly, or VoiceOver can operate the controls.
10. Reused upstream code must preserve the MIT notice. A clean reimplementation can still cite this study as design provenance without importing the upstream package's Material/Cupertino architecture.

## What is worth carrying forward as knowledge

The strongest transferable lessons are precise:

- Keep platform policy separate from widget state so tests can select every renderer.
- Delegate mature operating-system behavior to native or framework controls where possible.
- Put semantics and interaction intent in shared models, then let each renderer express them.
- Treat navigation chrome as persistent app state tied to the actual route animation.
- Adapt to live window geometry and posture, not to a guessed device category.
- Test the native bridge on the native platform, including accessibility and appearance settings.
- Label each feature honestly as native control, framework control, or visual approximation.

Those lessons are more durable than the package's current iOS 26 styling. They address the interaction contracts that users notice when an interface looks native but does not behave as expected.

## Current skribble baseline

This audit uses skribble commit `99f1eaf436a566836af13e4bcc5bf9b990105b32`. The dependency audit at [`docs/material-dependency-audit.txt`](../material-dependency-audit.txt) records 82 core files that import Material or Cupertino: 67 skin dependencies and 15 helper-only dependencies, plus four sanctioned compatibility files. This is a useful migration map because much of skribble's native-feeling behavior currently comes from the Material control hidden under the hand-drawn paint.

The codebase already has strong foundations:

- [`SkribbleApp`](../../packages/skribble/lib/src/skribble_app.dart) is a `WidgetsApp`, supports app-level `Shortcuts` and `Actions`, responds to brightness and high contrast, and does not require a Material or Cupertino ancestor.
- `WiredMotion` centralizes reduced-motion policy, respects `TickerMode`, and keeps animation lifecycle separate from painters.
- `WiredInkResponse` already translates `WidgetState` into visual pressure and redraw state.
- `WiredSelectionArea` builds on Flutter's widgets-layer selection system instead of implementing text selection from raw pointer events.
- The library has deterministic painters, semantics helpers, mirrored widget tests, and a documented Material-debt ratchet.

The missing piece is ownership. `WiredInkResponse` says that the underlying control retains gesture, focus, and semantics ownership. That works while `WiredButton` wraps a Material control. It leaves no owner when a control is rewritten as a widgets-only composition. The library needs a behavioral primitive before it removes those wrappers.

The current source also shows an input imbalance. The audit found 37 `GestureDetector` uses across 33 core files, but no `FocusableActionDetector`, no `MouseRegion`, no secondary-tap handler, no `HapticFeedback`, no `SystemSound`, and no `TapRegion`. Only one core file mentions `ScrollBehavior`, and the default `SkribbleApp` route is a fade-only `PageRouteBuilder`. Existing tests are much stronger for touch callbacks and rendered geometry than for keyboard, focus traversal, alternate pointer input, or native navigation gestures.

These counts are not a quality score. They show that touch is usually implemented locally while non-touch behavior has no shared home.

## What “native expected interaction” should mean

Flutter's [platform adaptation guidance](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations) separates operating-system behavior from app design conventions. Scrolling physics, text editing, selection, route gestures, icon direction, and feedback should feel at home on the operating system. App bars, typography, color, and information architecture can retain a product identity. This is the right boundary for skribble.

Every interactive component should answer four independent questions:

1. **What is the component's semantic contract?** A button activates, a switch toggles, a slider exposes a range, a tab selects a peer destination, and a menu item executes an action. This determines semantics, keyboard commands, focus behavior, and disabled state.
2. **What input is active?** Touch, stylus, mouse, trackpad, and keyboard can coexist on one device. Hover and visible focus should follow actual modality, not an operating-system guess. Flutter's [input guidance](https://docs.flutter.dev/ui/adaptive-responsive/input) explicitly calls out scroll wheels, secondary click, hover, tab traversal, and shortcuts.
3. **Which platform convention applies?** `TargetPlatform` should select interaction conventions that Flutter emulates, such as scroll physics and page transitions. The ambient platform must be overrideable for tests, previews, and intentionally cross-platform products.
4. **What can this window and host do now?** Safe areas, display features, window size, accessibility settings, and native capabilities can change during a session. They should be observed, not reduced to a device name or parsed OS string.

Do not compress these into one `isIOS` flag. An iPad with a trackpad still needs hover and keyboard behavior. A web app on macOS needs browser-aware menus as well as macOS-like shortcuts. A foldable Android window needs responsive navigation without becoming an iOS or Android visual clone.

The resulting product rule is simple: **adapt behavior automatically; adapt layout deliberately; keep the hand-drawn visual language.**

## Integration opportunities

| Area                                      | Current behavior or dependency                                                                                                                                                              | Expected interaction                                                                                                                                                                                                  | Recommendation                                                                                                                                                                                                      | Priority      |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| App shell and scrolling                   | `SkribbleApp` exposes shortcuts/actions but no core scroll policy.                                                                                                                          | Platform-appropriate physics, drag devices, scrollbars, overscroll, keyboard dismissal, and wheel/trackpad behavior.                                                                                                  | Install a widgets-only `WiredScrollBehavior` at the app boundary and allow an override. Start from Flutter's `ScrollBehavior` instead of hard-coding physics per widget.                                            | P0            |
| Shared press behavior                     | `WiredInkResponse` observes states supplied by another control. Many custom controls use raw `GestureDetector`.                                                                             | Focus traversal, Enter/Space activation, pointer cancellation, hover, mouse cursor, disabled behavior, semantics, and stable visual states.                                                                           | Add an internal pressable primitive based on `FocusableActionDetector`, `Actions`, `ActivateIntent`, `GestureDetector`, `Semantics`, and `WidgetStatesController`. Make it the owner that feeds `WiredInkResponse`. | P0            |
| Buttons, icon buttons, chips, list tiles  | Several implementations inherit behavior from Material; custom variants do not expose a consistent focus API. `WiredButton` does not enlarge its 42 px ink to the recommended 48 px target. | At least 48 logical pixels for touch targets, keyboard activation, visible focus, hover, semantic button role, disabled state, and optional long press.                                                               | Migrate onto the shared pressable. Separate visual bounds from hit bounds. Add `focusNode`, `autofocus`, `statesController`, `onLongPress`, and semantic label only where the contract needs them.                  | P0            |
| Switch, checkbox, radio                   | `WiredSwitch` is semantics plus tap; custom controls lack drag, keyboard, hover, and focus. Some controls duplicate controlled values in hook state.                                        | Tap and keyboard toggle, switch drag where expected, grouped radio arrow navigation, toggle/check semantics, RTL, and restrained feedback.                                                                            | Use controlled values as the only committed source of truth. Keep only ephemeral press/drag state internally. Build component-specific interaction delegates over the shared primitive.                             | P1            |
| Slider and range slider                   | The widgets-only Cupertino slider handles tap and horizontal drag but not semantics, keyboard, focus, hover, or RTL. The main slider still gets these behaviors from Material.              | Adjustable semantics, arrow/Page Up/Page Down/Home/End commands, drag lifecycle, divisions, RTL, focus, larger hit target, and value announcements.                                                                   | Build one render/interaction core for `WiredSlider` and range selection. Directionally map pointer positions. Expose semantic formatter and focus APIs. Do not emit haptics on every drag update.                   | P1            |
| Tabs and navigation destinations          | Gesture-driven selection; route behavior and keyboard traversal are not centralized.                                                                                                        | Per-item tab/button semantics, selected state, arrow-key traversal, activation, roving focus, destination state retention, and responsive bar/rail layout.                                                            | Add a selection-group controller and use `SemanticsRole.tab`, `tabBar`, and `tabPanel` where applicable. Keep responsive navigation an app-level layout choice.                                                     | P1            |
| Text input                                | `WiredTextField` and related widgets still rely on Material for the hardest editing behaviors.                                                                                              | IME composition, autofill, spellcheck, cursor and floating cursor, drag selection, magnifier, platform shortcuts, accessibility, and restoration.                                                                     | Treat the widgets-only rewrite as its own project around `EditableText` and `TextSelectionGestureDetectorBuilder`. Preserve platform behavior before restyling handles and menus.                                   | P2, high risk |
| Selection menu                            | `WiredSelectionArea` uses `SelectableRegion` but discards every context action except copy and select all.                                                                                  | Platform-provided actions such as share, search, live text, lookup, cut, and paste where the editable context permits them.                                                                                           | Render all supported `contextMenuButtonItems` by semantic item type and retain their callbacks. Unknown future item types need a safe representation rather than silent removal.                                    | P1            |
| Context and popup menus                   | `WiredContextMenu` opens only on long press although its docs promise right-click. Its overlay uses Material, does not manage focus, and dismisses only through pointer taps.               | Long press on touch, secondary click or control-click where expected, keyboard menu key or Shift+F10, arrow navigation, Escape dismissal, outside-click grouping, focus restoration, and anchored collision handling. | Build a widgets-only menu foundation with `RawMenuAnchor` where suitable, `TapRegion` for outside interactions, and explicit focus traversal. Reuse it for popup and context menus.                                 | P1            |
| Tooltips                                  | Current behavior is Material-backed or a custom overlay, depending on widget.                                                                                                               | Hover and keyboard-focus reveal on pointer platforms, long-press reveal on touch, semantic tooltip text, placement collision handling, and dismiss timing.                                                            | Share anchor and overlay positioning with menus but keep tooltip semantics and timing separate.                                                                                                                     | P2            |
| Dialogs, sheets, and pickers              | These rely on Material route helpers and dialogs.                                                                                                                                           | Modal barrier semantics, focus trapping and restoration, Escape/back dismissal, action ordering, safe-area and keyboard-inset handling, drag-to-dismiss where appropriate, and predictable restoration.               | Create widgets-layer modal routes and focus scopes. Apply platform policy to arrangement and transition, not to the domain result type.                                                                             | P2            |
| Routes and back navigation                | The default route is a fade. There is no interactive iOS edge swipe or explicit Android predictive-back contract.                                                                           | Platform-appropriate transition, gesture progress and cancellation, back-button/keyboard behavior, nested navigator correctness, and `PopScope` participation.                                                        | Add `WiredPageRoute` after defining a route behavior test suite. Follow the route's animation as the source of truth. Support Android predictive back without sacrificing iOS interactive pop.                      | P2            |
| Scaffold, app bar, and persistent chrome  | Bars live with pages or Material scaffolds; transition ownership is local.                                                                                                                  | Chrome that responds coherently to pushes, pops, back-swipe cancellation, nested navigators, sheets, dialogs, safe areas, and responsive layouts.                                                                     | Adapt upstream's registry/host concept as a Flutter-drawn `WiredChromeHost`; do not copy its Material/Cupertino app shell or native platform views.                                                                 | P3            |
| Refresh, dismiss, reorder, and scrollbars | Several widgets inherit behavior from Material. The custom refresh indicator reacts to a threshold notification rather than a complete gesture lifecycle.                                   | Direction-aware drag, cancellation, velocity, accessibility actions, keyboard alternatives, pointer scrolling, and correct nested-scroll ownership.                                                                   | Define behavior contracts before removing each wrapper. Prefer framework widgets-layer primitives such as `Dismissible` where they already own the hard interaction.                                                | P3            |
| Feedback                                  | No shared haptic or sound policy exists.                                                                                                                                                    | Feedback attached to semantic milestones, subject to platform conventions and accessibility/user preference.                                                                                                          | Add a semantic feedback service with opt-out and per-action categories. Avoid frame-level or every-value-change feedback.                                                                                           | P2            |

The context-menu mismatch is immediately actionable: [`feedback.md`](../site/content/widgets/feedback.md) promises long-press or right-click, while [`wired_context_menu.dart`](../../packages/skribble/lib/src/wired_context_menu.dart) only registers `onLongPress`. That should become a regression test before the implementation changes.

## Proposed interaction architecture

The new layer should sit alongside motion and painting, not inside either one:

```text
SkribbleApp
  └─ WiredInteractionScope
      ├─ platform convention
      ├─ feedback policy
      ├─ scroll behavior
      └─ modality/focus visibility
          └─ component behavior
              ├─ actions, shortcuts, focus, semantics
              ├─ pointer and drag recognizers
              └─ WidgetStatesController
                  └─ WiredInkResponse and painters
```

This preserves a one-way dependency. Component semantics produce interaction state; painting consumes it. A painter must never decide that a tap means “toggle” or that a key means “increment.”

### Interaction scope

Add a small inherited configuration rather than a platform singleton. A possible shape is:

```dart
@immutable
class WiredInteractionData {
  const WiredInteractionData({
    required this.platform,
    required this.feedback,
  });

  final TargetPlatform platform;
  final WiredFeedbackPolicy feedback;
}
```

`SkribbleApp` can default `platform` to `defaultTargetPlatform` and install a `WiredScrollBehavior`. A subtree override makes every branch deterministic in widget tests and Storybook. `kIsWeb` remains an environment capability; it must not replace the platform convention. Actual native API availability, if ever needed, should come from a native capability handshake using `#available`, not from parsing `Platform.operatingSystemVersion`.

Do not put window size or current pointer kind in this immutable policy. Read `MediaQuery`, `View`, `DisplayFeature`, and current input/focus state from their live sources so changes rebuild the appropriate layer.

### Shared pressable

The pressable should be internal at first. It should own:

- `FocusNode` lifecycle or a caller-owned node;
- `FocusableActionDetector` for focus, hover, highlight mode, mouse cursor, and actions;
- `ActivateIntent` and `ButtonActivateIntent` mapping for Enter and Space behavior;
- pointer down, up, cancel, tap, and optional long-press handling;
- semantic role, label, enabled state, and tap/long-press actions;
- one `WidgetStatesController` containing disabled, hovered, focused, and pressed state;
- a stable hit region independent of the painter's visible ink bounds.

The component wrapper still supplies the semantic role. A generic pressable must not label a checkbox as a button or invent a toggle state. Sliders, switches, menus, and selection groups should reuse its focus/state plumbing while owning their specialized actions.

`WiredInkResponse` can then become the visual observer of this owned controller. This retains its pressure and redraw animation without making paint responsible for interaction.

### Scroll behavior

Start from Flutter's widgets-layer `ScrollBehavior`, whose default physics already branch on `TargetPlatform`. Override only deliberate skribble policy, such as hand-drawn scrollbar decoration. Preserve `dragDevices`, overscroll, keyboard dismissal, and future framework defaults unless there is a tested reason to change them.

Installing the behavior at `SkribbleApp` prevents every list, picker, and sheet from choosing physics independently. A public `scrollBehavior` override should mirror `WidgetsApp` conventions without introducing a second scroll configuration system.

### Menus and overlays

Create one anchor and dismissal foundation, then specialize its semantics for menus, tooltips, selection toolbars, autocomplete, and transient surfaces. The foundation needs:

- collision-aware placement against the current view and insets;
- `TapRegion` grouping so inside clicks do not dismiss and outside clicks do;
- a focus scope with initial focus, traversal, Escape dismissal, and focus restoration;
- route and lifecycle cleanup;
- pointer-specific entry points without assuming that a platform has only one input device.

`RawMenuAnchor` is preferable to a custom stack where its contract fits because it already lives in `flutter/widgets`. Browser context-menu suppression on web should be explicit and local to a component that replaces the browser menu; it should not be a global application side effect.

### Text editing and selection

Text editing is the place to resist a “small rewrite.” A styled rectangle around `EditableText` is not yet a text field. The behavior inventory must include:

- text input connection and composing regions;
- keyboard shortcuts and selection modification;
- tap, double-tap, long-press, drag, and floating-cursor gestures;
- selection handles, magnifier, and toolbar anchors;
- autofill, spellcheck, smart dashes/quotes, suggestions, and restoration;
- obscured text and reveal behavior;
- accessibility value, hint, selection, and actions;
- scroll-to-caret behavior under the software keyboard.

Use `EditableText` for editing and `TextSelectionGestureDetectorBuilder` for established gesture behavior. Style the cursor, selection, handles, and toolbar through skribble-owned delegates. The existing `WiredSelectionArea` should stop filtering the framework's `contextMenuButtonItems`; those items encode platform-specific actions and callbacks that skribble should render, not reinterpret.

### Routes and persistent chrome

Define `WiredPageRoute` in the widgets layer. Its policy can select a platform-appropriate transition while keeping the transition visibly hand-drawn. It must expose real route animation progress so back gestures, hero-like effects, and persistent chrome reverse correctly when a gesture is canceled.

Android predictive back and iOS interactive pop are different contracts. Both should integrate with `PopScope`, nested navigators, and application vetoes. A generic horizontal drag on the page is not a substitute for either platform's route machinery.

After that route exists, adapt the upstream toolbar pattern:

1. A page publishes a typed chrome entry associated with its `ModalRoute` and `NavigatorState`.
2. A host above the navigator selects the visible entry, including nested navigators and covered routes.
3. Registry changes are coalesced after the frame.
4. The host blends outgoing and incoming content from the route's animation, including interactive reversals.
5. The host draws `Wired*` chrome in Flutter. Platform views are not required.

Avoid upstream's type-name inspection for router shells. Nested navigation support needs an explicit adapter or a route/entry contract, not `runtimeType.toString()` matching.

## Public API direction

Keep the public surface smaller than the implementation. A reasonable first addition is:

```dart
SkribbleApp(
  interactionPlatform: TargetPlatform.iOS, // optional override
  feedbackPolicy: const WiredFeedbackPolicy.platformDefault(),
  scrollBehavior: const WiredScrollBehavior(),
  // ...
)
```

The exact names should be settled during implementation, but the constraints matter:

- Primary APIs remain `WiredButton`, `WiredSwitch`, `WiredSlider`, and so on. Do not create a parallel `AdaptiveWiredButton` catalog.
- Existing `WiredCupertino*` names can remain migration or visual-variant APIs temporarily. They should eventually share the same behavioral core rather than maintaining a second interaction implementation.
- Use typed intent and item models. Do not expose `dynamic` icons or require callers to provide a separate icon field for every renderer.
- Keep controlled values controlled. `value` plus `onChanged` is the committed state; internal state is only for an active press, drag, pending route transition, or another ephemeral interaction.
- Expose component-specific options only when applications genuinely need them. A single giant “adaptive policy” object would hide which guarantees each widget supports.

## Native code boundary

Broad UIKit embedding is a poor fit for skribble. Ordinary native buttons, switches, sliders, and tab bars would replace the library's visual identity, add asynchronous platform-view composition, complicate gesture arbitration and clipping, and require an iOS-native test matrix. They would also do nothing for Android, desktop, or web.

Native integration is justified only when the operating system owns the experience and Flutter cannot provide the behavior faithfully. Examples may include system share/file/contact surfaces or a future opt-in latest-OS chrome effect. Such work should live in a separate optional package or the sanctioned compatibility layer, never in core. The boundary should expose a capability and semantic result, not an OS version string or a native view type.

If source is copied from `adaptive_platform_ui`, the MIT notice must be retained. A clean implementation of the registry idea can cite this study as provenance without importing its Material/Cupertino architecture.

## Rollout plan

### Phase 0: define and prove the substrate

1. Add an interaction contract document and reusable test harness.
2. Add the interaction scope with an overrideable `TargetPlatform`.
3. Add `WiredScrollBehavior` and install it in `SkribbleApp`.
4. Add the internal pressable and connect it to `WiredInkResponse`.
5. Migrate one button and one icon button as vertical slices. Verify touch, mouse, keyboard, focus, semantics, disabled state, RTL, high contrast, and reduced motion before scaling out.

This phase should land before more Material skin wrappers are removed. It prevents every leaf control from inventing its own incomplete behavior.

### Phase 1: leaf controls and selection

Migrate buttons, chips, list tiles, checkbox, radio, switch, slider, range slider, segmented control, tabs, and navigation destinations. Add secondary-click behavior to `WiredContextMenu` and preserve all selection context-menu actions. Remove duplicated committed state while touching each controlled widget.

### Phase 2: overlays, editing, and routes

Build the menu/overlay foundation, then tooltips, popup menus, dialogs, sheets, pickers, and snackbars. Run the text-field work as a separately reviewed stream with IME and native-device acceptance tests. Add `WiredPageRoute`, interactive back behavior, and Android predictive-back coverage.

### Phase 3: chrome and complex gestures

Add the route-aware chrome host once route animation ownership is stable. Then migrate refresh, dismiss, reorder, scrollbar, and responsive navigation behavior. Remove Material dependencies only when the replacement meets the behavior contract; the debt ratchet should record real reductions, not visual rewrites that discard interaction features.

Each phase should update the relevant widget catalog, core concept page, API overview, and examples in the same pull request. Public behavioral additions also need dartdoc and migration notes.

## Verification matrix

Widget tests can establish deterministic behavior, but they cannot prove native integration. Use both layers.

| Dimension            | Automated checks                                                                                                                                                                         |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Touch and stylus     | Tap, press cancel, long press, drag start/update/end, rapid repeated interaction, gesture-arena conflicts, minimum target size.                                                          |
| Mouse and trackpad   | Primary and secondary click, control-click where applicable, hover enter/exit, cursor, wheel and trackpad scrolling, outside-click dismissal.                                            |
| Keyboard             | Tab and reverse-Tab traversal; Enter/Space activation; arrows, Home/End, and Page Up/Page Down for ranged or grouped controls; Escape dismissal; menu key and Shift+F10 where supported. |
| Semantics            | Correct role, label, value, enabled/disabled, selected/toggled/checked state, increase/decrease actions, tap action, live-region behavior, and traversal order.                          |
| Direction and layout | RTL pointer/value mapping, directional icons, text scale, high contrast, narrow windows, split/fold display features, safe areas, and software-keyboard insets.                          |
| Motion and feedback  | Reduced motion, `TickerMode`, canceled animations, focus visibility, haptic category and frequency, and feedback opt-out.                                                                |
| Navigation           | Push, pop, system back, keyboard back, predictive-back progress/cancel, iOS edge-swipe progress/cancel, nested navigators, dialogs, sheets, and restoration.                             |
| Text editing         | IME composition, hardware keyboard, autofill, spellcheck, selection gestures, magnifier, context actions, obscured text, cursor visibility, and restoration.                             |
| Lifecycle            | App background/foreground, window resize, input modality changes, route disposal, overlay cleanup, and focus restoration.                                                                |

Run the widget matrix under Android, iOS, macOS, Windows, and Linux `TargetPlatform` overrides, plus LTR and RTL. Add browser integration tests for context menus and focus behavior. Add real-device or simulator tests for VoiceOver, TalkBack, iOS interactive pop, Android predictive back, software keyboards, autofill, haptics, and any native bridge. The upstream project's Ubuntu-only tests are a warning: a passing Dart suite does not verify Swift, platform-view semantics, or assistive technology.

For every migrated control, require these acceptance criteria:

- its visual treatment is still unmistakably skribble;
- touch behavior is no worse than the wrapper it replaces;
- keyboard, mouse, focus, and semantics have explicit tests;
- platform differences can be selected in a widget test;
- controlled state has one source of truth;
- reduced motion and high contrast remain legible;
- no new Material or Cupertino core import is introduced;
- documentation states which behavior is native, framework-provided, or approximated.

## Decisions

| Question                                       | Decision                                | Reason                                                                                                                        |
| ---------------------------------------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Depend on `adaptive_platform_ui`?              | No.                                     | Its app shell, imports, platform detection, and platform views conflict with skribble's standalone core.                      |
| Copy its widget catalog?                       | No.                                     | Several branches copy appearance without complete interaction behavior, and a parallel catalog would duplicate skribble APIs. |
| Reuse its toolbar idea?                        | Yes, as a clean Flutter implementation. | Route-associated entries and route-animation-driven blending solve a real cross-widget problem.                               |
| Use UIKit views for everyday controls?         | No by default.                          | They erase skribble's visual identity and add composition, testing, and maintenance costs.                                    |
| Automatically restyle by platform?             | No.                                     | skribble's design language should remain stable; only behavioral conventions should adapt automatically.                      |
| Use `dart:io Platform` for interaction policy? | No.                                     | `TargetPlatform` is testable and overrideable. Native capability checks belong behind a bridge.                               |
| Build one universal interaction delegate?      | No.                                     | Shared focus/state plumbing is useful, but a button, slider, text field, and menu have different semantic contracts.          |

The outcome should feel like skribble everywhere and feel wrong nowhere. That is a more durable goal than reproducing the current native surface of one operating-system release.
