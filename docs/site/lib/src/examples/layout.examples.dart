part of 'catalog.dart';

/// @docs-example card
Widget _card(ExampleSettings settings) => WiredCard(
  fill: settings.enabled,
  child: Center(child: Text(settings.label)),
);

/// @docs-example list-tile
Widget _listTile(ExampleSettings settings) => WiredListTile(
  title: Text(settings.label),
  subtitle: const Text('A little note for later'),
  showDivider: false,
  onTap: settings.enabled ? () {} : null,
);

/// @docs-example expansion-tile
Widget _expansionTile(ExampleSettings settings) => WiredExpansionTile(
  title: Text(settings.label),
  children: const [
    Padding(
      padding: EdgeInsets.all(20),
      child: Text('A small surprise tucked inside.'),
    ),
  ],
);

/// @docs-example divider
Widget _divider(ExampleSettings settings) => const WiredDivider();

/// @docs-example avatar
Widget _avatar(ExampleSettings settings) => const WiredAvatar(
  radius: 32,
  backgroundColor: Color(0xffe8b59e),
  child: Text('SK'),
);

/// @docs-example grid-tile
Widget _gridTile(ExampleSettings settings) => SizedBox(
  height: 180,
  child: WiredGridTile(
    footer: WiredGridTileBar(title: Text(settings.label)),
    onTap: () {},
    child: const ColoredBox(color: Color(0xffdde4c9)),
  ),
);

/// @docs-example selectable-text
Widget _selectableText(ExampleSettings settings) =>
    WiredSelectableText(settings.label);

/// @docs-example carousel-view
Widget _carousel(ExampleSettings settings) => WiredCarouselView(
  borderRadius: BorderRadius.circular(settings.radius),
  children: [
    for (final label in ['Little plans', 'Bright ideas', 'Happy accidents'])
      Center(child: Text(label)),
  ],
);

/// @docs-example data-table
Widget _dataTable(ExampleSettings settings) => const WiredDataTable(
  columns: [
    WiredDataColumn(label: Text('Sketch')),
    WiredDataColumn(label: Text('Status')),
  ],
  rows: [
    WiredDataRow(cells: [Text('Paper boats'), Text('Ready')]),
    WiredDataRow(cells: [Text('Tiny gardens'), Text('Growing')]),
  ],
);

/// @docs-example stepper
Widget _stepper(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final current = useState(0);
    return WiredStepper(
      currentStep: current.value,
      onStepTapped: (index) => current.value = index,
      steps: const [
        WiredStep(
          title: Text('Imagine'),
          content: Text('Start with a small idea.'),
        ),
        WiredStep(title: Text('Make'), content: Text('Give it a little ink.')),
        WiredStep(title: Text('Share'), content: Text('Let someone try it.')),
      ],
    );
  },
);

/// @docs-example calendar
Widget _calendar(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState('2026-09-09');
    return SizedBox(
      height: 360,
      child: WiredCalendar(
        selected: selected.value,
        onSelected: (date) => selected.value = date,
      ),
    );
  },
);

/// @docs-example scrollbar
Widget _scrollbar(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final controller = useScrollController();
    return SizedBox(
      height: 180,
      child: WiredScrollbar(
        controller: controller,
        thumbVisibility: true,
        child: ListView(
          controller: controller,
          children: [
            for (var index = 0; index < 15; index++)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Little idea ${index + 1}'),
              ),
          ],
        ),
      ),
    );
  },
);

/// @docs-example scaffold
Widget _scaffold(ExampleSettings settings) => SizedBox(
  height: 240,
  child: WiredScaffold(
    backgroundColor: const Color(0xffeef1df),
    appBar: const WiredAppBar(title: Text('A little sketchbook')),
    body: Center(child: Text(settings.label)),
  ),
);

/// @docs-example reorderable-list-view
Widget _reorderable(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final items = useState(['Paper', 'Ink', 'Possibility']);
    return SizedBox(
      height: 220,
      child: WiredReorderableListView(
        onReorder: (from, to) {
          final next = List<String>.of(items.value);
          next.insert(to > from ? to - 1 : to, next.removeAt(from));
          items.value = next;
        },
        children: [
          for (final item in items.value) Text(item, key: ValueKey(item)),
        ],
      ),
    );
  },
);

/// @docs-example dismissible
Widget _dismissible(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final visible = useState(true);
    return visible.value
        ? WiredDismissible(
            dismissKey: const ValueKey('sketch'),
            onDismissed: (direction) => visible.value = false,
            child: WiredListTile(
              title: Text(settings.label),
              subtitle: const Text('Swipe to put this away'),
              showDivider: false,
            ),
          )
        : WiredTextButton(
            onPressed: () => visible.value = true,
            child: const Text('Bring it back'),
          );
  },
);

/// @docs-example drawer-header
Widget _drawerHeader(ExampleSettings settings) => SizedBox(
  height: 180,
  child: WiredDrawerHeader(child: Text(settings.label)),
);

/// @docs-example user-accounts-drawer-header
Widget _userAccounts(ExampleSettings settings) => WiredUserAccountsDrawerHeader(
  accountName: Text(settings.label),
  accountEmail: const Text('hello@example.com'),
  currentAccountPicture: const WiredAvatar(child: Text('SK')),
);

/// @docs-example grid-tile-bar
Widget _gridTileBar(ExampleSettings settings) => WiredGridTileBar(
  title: Text(settings.label),
  subtitle: const Text('A small caption'),
);

/// @docs-example mergeable-material
Widget _mergeable(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final open = useState(false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredButton(
          onPressed: () => open.value = !open.value,
          child: const Text('Separate the notes'),
        ),
        const SizedBox(height: 12),
        WiredMergeableMaterial(
          children: [
            const WiredMaterialSlice(
              key: ValueKey('first'),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('A bright idea'),
              ),
            ),
            if (open.value) const WiredMaterialGap(key: ValueKey('gap')),
            const WiredMaterialSlice(
              key: ValueKey('second'),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('A happy accident'),
              ),
            ),
          ],
        ),
      ],
    );
  },
);

/// @docs-example page-scaffold
Widget _pageScaffold(ExampleSettings settings) => SizedBox(
  height: 240,
  child: WiredPageScaffold(
    navigationBar: const WiredCupertinoNavigationBar(
      middle: Text('Little notes'),
    ),
    child: Center(child: Text(settings.label)),
  ),
);

/// @docs-example tab-scaffold
Widget _tabScaffold(ExampleSettings settings) => SizedBox(
  height: 240,
  child: WiredTabScaffold(
    tabs: const [
      WiredTabItem(
        icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
        label: 'Home',
      ),
      WiredTabItem(
        icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
        label: 'Saved',
      ),
    ],
    tabBuilder: (context, index) => Center(
      child: Text(index == 0 ? 'A fresh page' : 'Your favourite sketches'),
    ),
  ),
);
