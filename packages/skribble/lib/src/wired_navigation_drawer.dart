import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn M3-style navigation drawer with destination items.
///
/// Corresponds to Flutter's [NavigationDrawer]. Provides a list of
/// selectable destinations with hand-drawn selection indicators.
class WiredNavigationDrawer extends HookWidget {
  /// The list of destinations to show.
  final List<WiredNavigationDrawerDestination> destinations;

  /// The currently selected destination index.
  final int selectedIndex;

  /// Called when a destination is tapped.
  final ValueChanged<int>? onDestinationSelected;

  /// Optional header widget shown above the destinations.
  final Widget? header;

  /// Width of the drawer.
  final double width;

  const WiredNavigationDrawer({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.header,
    this.width = 304,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: Drawer(
        width: width,
        child: Stack(
          children: [
            // Hand-drawn right border
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 2,
                child: WiredCanvas(
                  painter: WiredLineBase(
                    x1: 0,
                    y1: 0,
                    x2: 0,
                    y2: double.infinity,
                    strokeWidth: 2,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (header case final h?) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: h,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      itemCount: destinations.length,
                      itemBuilder: (context, index) {
                        final dest = destinations[index];
                        final isSelected = index == selectedIndex;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: _WiredDrawerItem(
                            icon: dest.icon,
                            selectedIcon: dest.selectedIcon,
                            label: dest.label,
                            isSelected: isSelected,
                            onTap: () => onDestinationSelected?.call(index),
                          ),
                        );
                      },
                    ),
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

/// A destination item for [WiredNavigationDrawer].
class WiredNavigationDrawerDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const WiredNavigationDrawerDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

class _WiredDrawerItem extends HookWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WiredDrawerItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            if (isSelected)
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  fillerType: RoughFilter.hachureFiller,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    isSelected ? (selectedIcon ?? icon) : icon,
                    size: 22,
                    color: isSelected ? Colors.white : theme.textColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : theme.textColor,
                      ),
                    ),
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
