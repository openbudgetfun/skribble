import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_search_bar.dart';
import 'wired_theme.dart';

/// Builds the collapsed search trigger shown when the search view is closed.
///
/// Mirrors Material's `SearchAnchor` builder: it receives the current
/// [BuildContext] and a [WiredSearchController] whose `openView()` opens the
/// search view. Typically returns a `WiredSearchBar` with
/// `onTap: controller.openView`.
typedef WiredSearchAnchorBuilder = Widget Function(
  BuildContext context,
  WiredSearchController controller,
);

/// Builds the suggestion list rendered inside the open search view.
///
/// Called on every rebuild of the search view (including while the user
/// types), so implementations can filter live using `controller.text`.
typedef WiredSuggestionsBuilder = List<Widget> Function(
  BuildContext context,
  WiredSearchController controller,
);

/// A [TextEditingController] that additionally tracks whether the Skribble
/// search view is open, mirroring Material's `SearchController` API surface.
///
/// ```dart
/// final controller = WiredSearchController();
/// controller.openView();               // show the search view
/// controller.closeView('Selected tip'); // populate the field and close
/// ```
class WiredSearchController extends TextEditingController {
  WiredSearchController({super.text});

  bool _isOpen = false;

  /// Whether the search view is currently open.
  bool get isOpen => _isOpen;

  /// Opens the suggestions view.
  void openView() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Closes the suggestions view, optionally replacing the query text with
  /// [selectedText].
  void closeView([String? selectedText]) {
    if (selectedText != null) {
      text = selectedText;
    }
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }
}

/// A hand-drawn search anchor that pairs a collapsed search field with an
/// in-place suggestions view, analogous to Material 3's `SearchAnchor`.
///
/// The collapsed state is rendered by [builder] (which receives the
/// controller so it can call `openView()`); the open state replaces it with a
/// rough-bordered view containing a wired search bar and the widgets returned
/// by [suggestionsBuilder].
///
/// Example:
///
/// ```dart
/// WiredSearchAnchor(
///   searchController: controller,
///   builder: (context, controller) => WiredSearchBar(
///     onTap: controller.openView,
///     controller: controller,
///   ),
///   suggestionsBuilder: (context, controller) => [
///     for (final option in _filterOptions(controller.text))
///       WiredListTile(
///         title: Text(option),
///         onTap: () => controller.closeView(option),
///       ),
///   ],
/// )
/// ```
///
/// See also:
///  * `WiredSearchBar`, the collapsed field rendered by the default builder.
class WiredSearchAnchor extends HookWidget {
  /// Optional controller used as the source of truth for the query text and
  /// the open view state. When omitted, an internal
  /// [WiredSearchController] is created and disposed with the widget.
  final WiredSearchController? searchController;

  /// Builds the collapsed search field. Call `controller.openView()` from the
  /// built widget (e.g. via `WiredSearchBar.onTap`) to open the view.
  final WiredSearchAnchorBuilder builder;

  /// Builds the suggestion widgets shown below the search view's bar.
  final WiredSuggestionsBuilder suggestionsBuilder;

  /// Hint text for the search bar shown inside the open view.
  final String? viewHintText;

  /// Leading widget for the search view's bar. Defaults to a hand-drawn back
  /// arrow that closes the view.
  final Widget? viewLeading;

  /// Trailing widget for the search view's bar.
  final Widget? viewTrailing;

  /// Widget shown when [suggestionsBuilder] returns an empty list.
  final Widget? viewEmptyWidget;

  const WiredSearchAnchor({
    super.key,
    this.searchController,
    required this.builder,
    required this.suggestionsBuilder,
    this.viewHintText,
    this.viewLeading,
    this.viewTrailing,
    this.viewEmptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    final controller = useMemoized(() {
      return searchController ?? WiredSearchController();
    }, [searchController]);

    // Dispose the controller only when the anchor created it.
    final ownsController = searchController == null;
    useEffect(() {
      if (ownsController) {
        return controller.dispose;
      }
      return null;
    }, [controller, ownsController]);

    // Subscribe to the controller so open/close transitions and live typing
    // both rebuild the anchor (and thus re-run suggestionsBuilder).
    useListenable(controller);

    if (!controller.isOpen) {
      return builder(context, controller);
    }

    return _WiredSearchView(
      controller: controller,
      theme: theme,
      suggestionsBuilder: suggestionsBuilder,
      hintText: viewHintText,
      leading: viewLeading,
      trailing: viewTrailing,
      emptyWidget: viewEmptyWidget,
    );
  }
}

class _WiredSearchView extends HookWidget {
  final WiredSearchController controller;
  final WiredThemeData theme;
  final WiredSuggestionsBuilder suggestionsBuilder;
  final String? hintText;
  final Widget? leading;
  final Widget? trailing;
  final Widget? emptyWidget;

  const _WiredSearchView({
    required this.controller,
    required this.theme,
    required this.suggestionsBuilder,
    required this.hintText,
    required this.leading,
    required this.trailing,
    required this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = suggestionsBuilder(context, controller);

    return buildWiredElement(
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  fillColor: theme.fillColor,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WiredSearchBar(
                    controller: controller,
                    autoFocus: true,
                    hintText: hintText ?? 'Search...',
                    leading:
                        leading ??
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: controller.closeView,
                          child: WiredIcon(
                            icon: Icons.arrow_back,
                            color: theme.disabledTextColor,
                            size: 20,
                            fillStyle: WiredIconFillStyle.solid,
                            strokeWidth: 1.2,
                          ),
                        ),
                    trailing: trailing,
                  ),
                  const SizedBox(height: 8),
                  if (suggestions.isEmpty && emptyWidget != null)
                    emptyWidget!
                  else
                    ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: suggestions,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
