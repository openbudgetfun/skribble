part of 'catalog.dart';

/// @docs-example app-bar
Widget _appBar(ExampleSettings settings) =>
    WiredAppBar(title: Text(settings.label));

/// @docs-example navigation-bar
Widget _navigationBar(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredNavigationBar(
      selectedIndex: selected.value,
      onDestinationSelected: (index) => selected.value = index,
      destinations: const [
        WiredNavigationDestination(
          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
          label: 'Home',
        ),
        WiredNavigationDestination(
          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
          label: 'Saved',
        ),
      ],
    );
  },
);

/// @docs-example navigation-rail
Widget _navigationRail(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return SizedBox(
      height: 240,
      child: WiredNavigationRail(
        selectedIndex: selected.value,
        onDestinationSelected: (index) => selected.value = index,
        destinations: const [
          WiredNavigationRailDestination(
            icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
            label: 'Home',
          ),
          WiredNavigationRailDestination(
            icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
            label: 'Saved',
          ),
        ],
      ),
    );
  },
);

/// @docs-example navigation-drawer
Widget _navigationDrawer(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return SizedBox(
      height: 220,
      child: WiredNavigationDrawer(
        selectedIndex: selected.value,
        onDestinationSelected: (index) => selected.value = index,
        destinations: const [
          WiredNavigationDrawerDestination(
            icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
            label: 'Home',
          ),
          WiredNavigationDrawerDestination(
            icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
            label: 'Saved',
          ),
        ],
      ),
    );
  },
);

/// @docs-example tab-bar
Widget _tabBar(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredTabBar(
      tabs: const ['Ideas', 'Sketches', 'Notes'],
      selectedIndex: selected.value,
      onTap: (index) => selected.value = index,
    );
  },
);

/// @docs-example drawer
Widget _drawer(ExampleSettings settings) => SizedBox(
  height: 180,
  child: WiredDrawer(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(settings.label),
    ),
  ),
);

/// @docs-example popup-menu-button
Widget _popupMenu(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState('Choose an action');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredPopupMenuButton<String>(
          items: const [
            WiredPopupMenuItem(value: 'Saved', child: Text('Save')),
            WiredPopupMenuItem(value: 'Shared', child: Text('Share')),
          ],
          onSelected: (value) => selected.value = value,
        ),
        Text(selected.value),
      ],
    );
  },
);

/// @docs-example menu-bar
Widget _menuBar(ExampleSettings settings) => WiredMenuBar(
  children: [
    WiredSubmenuButton(
      menuChildren: [
        WiredMenuItemButton(onPressed: () {}, child: const Text('New sketch')),
        WiredMenuItemButton(onPressed: () {}, child: const Text('Save sketch')),
      ],
      child: Text(settings.label),
    ),
  ],
);

/// @docs-example bottom-app-bar
Widget _bottomAppBar(ExampleSettings settings) =>
    WiredBottomAppBar(child: Text(settings.label));

/// @docs-example sliver-app-bar
Widget _sliverAppBar(ExampleSettings settings) => SizedBox(
  height: 240,
  child: CustomScrollView(
    slivers: [
      WiredSliverAppBar(
        title: Text(settings.label),
        expandedHeight: 120,
        pinned: true,
      ),
      SliverList.list(
        children: [
          for (var index = 0; index < 8; index++)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Sketch ${index + 1}'),
            ),
        ],
      ),
    ],
  ),
);

/// @docs-example cupertino-navigation-bar
Widget _cupertinoNavigationBar(ExampleSettings settings) =>
    WiredCupertinoNavigationBar(middle: Text(settings.label));

/// @docs-example checkbox-menu-button
Widget _checkboxMenuButton(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final checked = useState(true);
    return WiredMenuBar(
      children: [
        WiredSubmenuButton(
          menuChildren: [
            WiredCheckboxMenuButton(
              value: checked.value,
              onChanged: (value) => checked.value = value ?? false,
              child: Text(settings.label),
            ),
          ],
          child: const Text('Options'),
        ),
      ],
    );
  },
);

/// @docs-example radio-menu-button
Widget _radioMenuButton(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState('paper');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in ['paper', 'ink'])
          WiredRadioMenuButton<String>(
            value: value,
            groupValue: selected.value,
            onChanged: (value) => selected.value = value!,
            child: Text(value),
          ),
      ],
    );
  },
);

/// @docs-example about-list-tile
Widget _aboutListTile(ExampleSettings settings) => WiredAboutListTile(
  applicationName: 'A little sketchbook',
  applicationVersion: '1.0',
  child: Text(settings.label),
);

/// @docs-example bottom-navigation-bar
Widget _bottomNavigationBar(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredBottomNavigationBar(
      currentIndex: selected.value,
      onTap: (index) => selected.value = index,
      items: const [
        WiredBottomNavItem(
          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
          label: 'Home',
        ),
        WiredBottomNavItem(
          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
          label: 'Saved',
        ),
      ],
    );
  },
);

/// @docs-example cupertino-tab-bar
Widget _cupertinoTabBar(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredCupertinoTabBar.destinations(
      currentIndex: selected.value,
      onTap: (index) => selected.value = index,
      items: const [
        WiredBottomNavItem(
          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
          label: 'Home',
        ),
        WiredBottomNavItem(
          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
          label: 'Saved',
        ),
      ],
    );
  },
);
