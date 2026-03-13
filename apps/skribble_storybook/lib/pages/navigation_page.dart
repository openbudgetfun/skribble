import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';

class NavigationPage extends HookWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavIndex = useState(0);
    final tabIndex = useState(0);
    final navBarIndex = useState(0);
    final railIndex = useState(0);
    final popupSelection = useState<String>('None');
    final cupertinoTabIndex = useState(0);

    return Scaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Navigation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShowcaseSection(
            title: 'WiredAppBar',
            children: [
              ComponentShowcase(
                title: 'App Bar',
                description: 'Hand-drawn bottom border.',
                child: SizedBox(
                  height: 60,
                  child: WiredAppBar(
                    title: const Text('Sample Title'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredBottomNavigationBar',
            children: [
              ComponentShowcase(
                title: 'Bottom Nav',
                description: 'Hand-drawn selection indicator.',
                child: WiredBottomNavigationBar(
                  currentIndex: bottomNavIndex.value,
                  onTap: (i) => bottomNavIndex.value = i,
                  items: const [
                    WiredBottomNavItem(icon: Icons.home, label: 'Home'),
                    WiredBottomNavItem(icon: Icons.search, label: 'Search'),
                    WiredBottomNavItem(icon: Icons.person, label: 'Profile'),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredTabBar',
            children: [
              ComponentShowcase(
                title: 'Tab Bar',
                description: 'Hand-drawn underline indicator.',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WiredTabBar(
                      tabs: const ['Tab 1', 'Tab 2', 'Tab 3'],
                      selectedIndex: tabIndex.value,
                      onTap: (i) => tabIndex.value = i,
                    ),
                    SizedBox(
                      height: 60,
                      child: Center(
                        child: Text('Tab ${tabIndex.value + 1} content'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredNavigationBar',
            children: [
              ComponentShowcase(
                title: 'Navigation Bar (M3)',
                description: 'Material 3 style with rounded rect indicators.',
                child: WiredNavigationBar(
                  selectedIndex: navBarIndex.value,
                  onDestinationSelected: (i) => navBarIndex.value = i,
                  destinations: const [
                    WiredNavigationDestination(icon: Icons.home, label: 'Home'),
                    WiredNavigationDestination(
                      icon: Icons.explore,
                      label: 'Explore',
                    ),
                    WiredNavigationDestination(
                      icon: Icons.bookmark,
                      label: 'Saved',
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredNavigationRail',
            children: [
              ComponentShowcase(
                title: 'Navigation Rail',
                description: 'Vertical navigation.',
                child: SizedBox(
                  height: 200,
                  child: WiredNavigationRail(
                    selectedIndex: railIndex.value,
                    onDestinationSelected: (i) => railIndex.value = i,
                    destinations: const [
                      WiredNavigationRailDestination(
                        icon: Icons.inbox,
                        label: 'Inbox',
                      ),
                      WiredNavigationRailDestination(
                        icon: Icons.send,
                        label: 'Sent',
                      ),
                      WiredNavigationRailDestination(
                        icon: Icons.drafts,
                        label: 'Drafts',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredPopupMenuButton',
            children: [
              ComponentShowcase(
                title: 'Popup Menu',
                description: 'Anchored menu with hand-drawn container.',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Selected: ${popupSelection.value}'),
                    WiredPopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) => popupSelection.value = value,
                      items: const [
                        WiredPopupMenuItem(
                          value: 'Profile',
                          child: Text('Profile'),
                        ),
                        WiredPopupMenuItem(
                          value: 'Settings',
                          child: Text('Settings'),
                        ),
                        WiredPopupMenuItem(
                          value: 'Sign out',
                          child: Text('Sign out'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoNavigationBar',
            children: [
              ComponentShowcase(
                title: 'Cupertino Navigation Bar',
                description:
                    'iOS-style nav bar with sketchy bottom border.',
                child: SizedBox(
                  height: 44,
                  child: WiredCupertinoNavigationBar(
                    leading: const Icon(Icons.arrow_back_ios, size: 18),
                    middle: const Text('Settings'),
                    trailing: const Text('Done'),
                    automaticallyImplyLeading: false,
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoTabBar',
            children: [
              ComponentShowcase(
                title: 'Cupertino Tab Bar',
                description:
                    'iOS-style bottom tab bar with sketchy top border.',
                child: WiredCupertinoTabBar(
                  currentIndex: cupertinoTabIndex.value,
                  onTap: (i) => cupertinoTabIndex.value = i,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredMenuBar',
            children: [
              ComponentShowcase(
                title: 'Menu Bar',
                description: 'Hand-drawn menu bar with submenus.',
                child: WiredMenuBar(
                  children: [
                    WiredSubmenuButton(
                      child: const Text('File'),
                      menuChildren: [
                        WiredMenuItemButton(
                          leadingIcon: const Icon(Icons.note_add, size: 18),
                          onPressed: () {},
                          child: const Text('New'),
                        ),
                        WiredMenuItemButton(
                          leadingIcon: const Icon(Icons.folder_open, size: 18),
                          onPressed: () {},
                          child: const Text('Open'),
                        ),
                        WiredMenuItemButton(
                          leadingIcon: const Icon(Icons.save, size: 18),
                          onPressed: () {},
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                    WiredSubmenuButton(
                      child: const Text('Edit'),
                      menuChildren: [
                        WiredMenuItemButton(
                          onPressed: () {},
                          child: const Text('Cut'),
                        ),
                        WiredMenuItemButton(
                          onPressed: () {},
                          child: const Text('Copy'),
                        ),
                        WiredMenuItemButton(
                          onPressed: () {},
                          child: const Text('Paste'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredDropdownMenu',
            children: [
              ComponentShowcase(
                title: 'Dropdown Menu',
                description: 'M3-style dropdown with hand-drawn border.',
                child: WiredDropdownMenu<String>(
                  width: 280,
                  hintText: 'Choose a color',
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'red', label: 'Red'),
                    DropdownMenuEntry(value: 'green', label: 'Green'),
                    DropdownMenuEntry(value: 'blue', label: 'Blue'),
                  ],
                  onSelected: (v) {},
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredDrawerHeader',
            children: [
              ComponentShowcase(
                title: 'Drawer Header',
                description: 'Hand-drawn header for drawers.',
                child: SizedBox(
                  height: 120,
                  child: WiredDrawerHeader(
                    child: const Text(
                      'Skribble App',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              ComponentShowcase(
                title: 'User Accounts Header',
                child: WiredUserAccountsDrawerHeader(
                  currentAccountPicture: const WiredAvatar(
                    radius: 30,
                    child: Text('SK'),
                  ),
                  accountName: const Text('Skribble User'),
                  accountEmail: const Text('user@skribble.dev'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredDrawer',
            children: [
              ComponentShowcase(
                title: 'Drawer',
                description: 'Hand-drawn border drawer.',
                child: WiredButton(
                  onPressed: () {
                    unawaited(
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => Dialog(
                          child: SizedBox(
                            width: 280,
                            height: 400,
                            child: WiredDrawer(
                              child: ListView(
                                children: [
                                  WiredListTile(
                                    leading: const Icon(Icons.home),
                                    title: const Text('Home'),
                                    onTap: () => Navigator.pop(ctx),
                                  ),
                                  WiredListTile(
                                    leading: const Icon(Icons.settings),
                                    title: const Text('Settings'),
                                    onTap: () => Navigator.pop(ctx),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Drawer Preview'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredNavigationDrawer',
            children: [
              ComponentShowcase(
                title: 'Navigation Drawer (M3)',
                description: 'M3-style drawer with selectable destinations.',
                child: WiredButton(
                  onPressed: () {
                    unawaited(
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => Dialog(
                          child: SizedBox(
                            width: 300,
                            height: 420,
                            child: WiredNavigationDrawer(
                              selectedIndex: 0,
                              header: const Text(
                                'Skribble',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              destinations: const [
                                WiredNavigationDrawerDestination(
                                  icon: Icons.inbox_outlined,
                                  selectedIcon: Icons.inbox,
                                  label: 'Inbox',
                                ),
                                WiredNavigationDrawerDestination(
                                  icon: Icons.send_outlined,
                                  selectedIcon: Icons.send,
                                  label: 'Sent',
                                ),
                                WiredNavigationDrawerDestination(
                                  icon: Icons.drafts_outlined,
                                  selectedIcon: Icons.drafts,
                                  label: 'Drafts',
                                ),
                                WiredNavigationDrawerDestination(
                                  icon: Icons.delete_outline,
                                  selectedIcon: Icons.delete,
                                  label: 'Trash',
                                ),
                              ],
                              onDestinationSelected: (_) => Navigator.pop(ctx),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Navigation Drawer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
