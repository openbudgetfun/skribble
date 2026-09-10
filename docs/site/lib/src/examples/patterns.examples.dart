part of 'catalog.dart';

/// @docs-example app-pattern
Widget _appPattern(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final tab = useState(0);
    return SizedBox(
      height: 320,
      child: WiredScaffold(
        appBar: const WiredAppBar(title: Text('My sketchbook')),
        body: Center(
          child: Text(tab.value == 0 ? 'A fresh page' : 'Your saved ideas'),
        ),
        bottomNavigationBar: WiredBottomNavigationBar(
          currentIndex: tab.value,
          onTap: (value) => tab.value = value,
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
        ),
      ),
    );
  },
);

/// @docs-example validated-form
Widget _validatedForm(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final key = useMemoized(GlobalKey<FormState>.new);
    final accepted = useState(false);
    return WiredForm(
      formKey: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormField<String>(
            validator: (value) => value != null && value.contains('@')
                ? null
                : 'Enter an email address.',
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WiredInput(labelText: 'Email', onChanged: field.didChange),
                if (field.errorText case final String error)
                  Semantics(liveRegion: true, child: Text(error)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WiredFilledButton(
            onPressed: () => accepted.value = key.currentState!.validate(),
            child: const Text('Check the form'),
          ),
          if (accepted.value)
            const Text('The sample form is valid. Nothing was sent.'),
        ],
      ),
    );
  },
);

/// @docs-example task-list-pattern
Widget _taskListPattern(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    const initial = [
      (title: 'Buy paper', done: false),
      (title: 'Walk the dog', done: true),
      (title: 'Sketch an idea', done: false),
    ];
    final tasks = useState(initial);
    return Column(
      children: [
        for (final task in tasks.value)
          WiredDismissible(
            dismissKey: ValueKey(task.title),
            onDismissed: (_) => tasks.value = tasks.value
                .where((item) => item.title != task.title)
                .toList(),
            child: WiredCheckboxListTile(
              title: Text(task.title),
              value: task.done,
              showDivider: false,
              onChanged: (value) => tasks.value = [
                for (final item in tasks.value)
                  if (item.title == task.title)
                    (title: item.title, done: value ?? false)
                  else
                    item,
              ],
            ),
          ),
        WiredOutlinedButton(
          onPressed: () => tasks.value = initial,
          child: const Text('Reset the sample list'),
        ),
      ],
    );
  },
);

/// @docs-example settings-pattern
Widget _settingsPattern(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final notifications = useState(true);
    final language = useState('English');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WiredSwitchListTile(
          title: const Text('Notifications'),
          value: notifications.value,
          onChanged: (value) => notifications.value = value,
          showDivider: false,
        ),
        const SizedBox(height: 16),
        const Text('Language'),
        for (final option in ['English', 'Spanish', 'French'])
          WiredRadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: language.value,
            onChanged: (value) {
              language.value = value!;
              return true;
            },
            showDivider: false,
          ),
        Text(
          'Sample preferences: ${language.value}, notifications ${notifications.value ? 'on' : 'off'}.',
        ),
      ],
    );
  },
);

/// @docs-example loading-pattern
Widget _loadingPattern(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final request = useState<Future<List<String>>?>(null);
    final result = useFuture(request.value);
    return Column(
      children: [
        WiredOutlinedButton(
          onPressed: result.connectionState == ConnectionState.waiting
              ? null
              : () {
                  request.value = Future.delayed(
                    const Duration(milliseconds: 350),
                    () => ['Paper', 'Ink', 'Possibility'],
                  );
                },
          child: const Text('Load sample notes'),
        ),
        const SizedBox(height: 16),
        if (result.connectionState == ConnectionState.waiting)
          const WiredCircularProgress()
        else if (result.hasError)
          const Text('The sample could not load. Try again.')
        else if (result.data case final List<String> notes)
          for (final note in notes)
            WiredListTile(title: Text(note), showDivider: false),
      ],
    );
  },
);

/// @docs-example search-pattern
Widget _searchPattern(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final query = useState('');
    final category = useState('All');
    const items = [
      (title: 'Write a proposal', category: 'Work'),
      (title: 'Buy sketchbooks', category: 'Shopping'),
      (title: 'Draw with friends', category: 'Personal'),
    ];
    final filtered = items
        .where(
          (item) =>
              item.title.toLowerCase().contains(query.value.toLowerCase()) &&
              (category.value == 'All' || item.category == category.value),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WiredInput(
          labelText: 'Search sample tasks',
          onChanged: (value) => query.value = value,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in ['All', 'Work', 'Shopping', 'Personal'])
              WiredChoiceChip(
                label: Text(option),
                selected: category.value == option,
                onSelected: (selected) {
                  if (selected) category.value = option;
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty) const Text('No matching sample tasks.'),
        for (final item in filtered)
          WiredListTile(
            title: Text(item.title),
            subtitle: Text(item.category),
            showDivider: false,
          ),
      ],
    );
  },
);

/// @docs-example responsive-pattern
Widget _responsivePattern(ExampleSettings settings) => LayoutBuilder(
  builder: (context, constraints) {
    final cards = [
      for (final title in ['Ideas', 'In progress', 'Finished'])
        WiredCard(
          child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),
        ),
    ];
    return constraints.maxWidth < 600
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards,
          )
        : Row(children: [for (final card in cards) Expanded(child: card)]);
  },
);

/// @docs-example snackbar-pattern
Widget _snackbarPattern(ExampleSettings settings) => Builder(
  builder: (context) => WiredOutlinedButton(
    onPressed: () => showWiredSnackBar(
      context,
      content: const WiredSnackBarContent(
        child: Text('The sample could not save. Please try again.'),
      ),
      duration: const Duration(seconds: 3),
    ),
    child: const Text('Show a sample error'),
  ),
);

/// @docs-example signup-pattern
Widget _signupPattern(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final name = useTextEditingController();
    final email = useTextEditingController();
    final agreed = useState(false);
    final status = useState<String?>(null);
    return WiredCard(
      height: null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WiredInput(controller: name, labelText: 'Name'),
            const SizedBox(height: 16),
            WiredInput(controller: email, labelText: 'Email'),
            const SizedBox(height: 16),
            WiredCheckboxListTile(
              value: agreed.value,
              onChanged: (value) => agreed.value = value ?? false,
              title: const Text('I agree to the sample terms'),
              showDivider: false,
            ),
            const SizedBox(height: 16),
            WiredButton(
              onPressed: () {
                status.value =
                    name.text.trim().isEmpty || !email.text.contains('@')
                    ? 'Enter your name and email.'
                    : !agreed.value
                    ? 'Please agree to the sample terms.'
                    : 'Your sample is ready. Nothing was sent.';
              },
              child: const Text('Check the details'),
            ),
            if (status.value case final String message)
              Semantics(liveRegion: true, child: Text(message)),
          ],
        ),
      ),
    );
  },
);

/// @docs-example selection-pattern
Widget _selectionPattern(ExampleSettings settings) => const WiredSelectionArea(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('A small beginning.\n'),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Make something '),
            TextSpan(
              text: 'delightful.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ],
  ),
);

/// @docs-example lettering-pattern
Widget _letteringPattern(ExampleSettings settings) => Text(
  settings.label,
  style: const TextStyle(
    fontFamily: skribbleFontFamily,
    package: 'skribble',
    fontSize: 24,
  ),
);

/// @docs-example accessible-inputs
Widget _accessibleInputs(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final checked = useState(false);
    return Column(
      children: [
        WiredCheckbox(
          value: checked.value,
          onChanged: (value) => checked.value = value ?? false,
          semanticLabel: 'Accept terms and conditions',
        ),
        const SizedBox(height: 16),
        WiredSlider(
          value: settings.amount,
          onChanged: (value) => true,
          semanticLabel: 'Volume control',
        ),
      ],
    );
  },
);

/// @docs-example expanding-decoration
Widget _expandingDecoration(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final expanded = useState(false);
    return Column(
      children: [
        WiredButton(
          onPressed: () => expanded.value = !expanded.value,
          child: Text(expanded.value ? 'Make it smaller' : 'Make room'),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration:
              MediaQuery.disableAnimationsOf(context) ||
                  !WiredTheme.of(context).motionEnabled
              ? Duration.zero
              : const Duration(milliseconds: 300),
          width: expanded.value ? 260 : 150,
          height: expanded.value ? 180 : 100,
          alignment: Alignment.center,
          decoration: RoughBoxDecoration(
            shape: RoughBoxShape.roundedRectangle,
            drawConfig: WiredTheme.of(context).drawConfig,
            borderStyle: RoughDrawingStyle(
              width: 2.4,
              color: WiredTheme.of(context).borderColor,
            ),
            borderRadius: BorderRadius.circular(settings.radius),
          ),
          child: const Text('Room for ideas'),
        ),
      ],
    );
  },
);
