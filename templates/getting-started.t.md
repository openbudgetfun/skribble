<!-- Shared content for the getting-started docs pages, the READMEs, and
     the contributor guides. Run `mdt list` to see every consumer. -->

<!-- Version requirement read from packages/skribble/pubspec.yaml through
     mdt.toml `[data]`, so it changes when the manifest does. -->
<!-- {@docsRequirements} -->

skribble needs Flutter {{ skribble.environment.flutter | replace(">=", "") }} or later (Dart {{ skribble.environment.sdk | replace("^", "") }} or later). Run `flutter --version` to check yours.

<!-- {/docsRequirements} -->

<!-- {@docsQuickInstallSection} -->

```bash
flutter pub add skribble skribble_font_noto_sketch
```

`skribble` draws the widgets; `skribble_font_noto_sketch` adds the default hand-drawn lettering. Without the font package, borders still look sketchy but text falls back to the system font. Then import the library:

```dart
// Static example: setup
import 'package:skribble/skribble.dart';
```

<!-- {/docsQuickInstallSection} -->

<!-- {@docsInstallSection} -->

## Install in an app

From your Flutter app's directory, add the library and its default typeface in one step:

```bash
flutter pub add skribble skribble_font_noto_sketch
```

`skribble` paints the hand-drawn borders, fills, and icons. `skribble_font_noto_sketch` adds Skribble Noto Sketch, the default lettering: it is the step that makes text _look_ hand-drawn too. There is nothing else to set up: no font registration, no assets to copy, and no Material app.

Then import the library in your Dart files:

```dart
// Static example: setup
import 'package:skribble/skribble.dart';
```

<!-- {/docsInstallSection} -->

<!-- {@docsSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/skribble.git
cd skribble

# With devenv (recommended): provides flutter, melos, mdt, dprint, and the git hooks
devenv shell

# Without devenv: install the pinned Flutter {{ fvm.flutter }} with FVM
fvm install
fvm use --force

# Install dependencies for the whole workspace
flutter pub get
```

<!-- {/docsSetupSection} -->

<!-- Everyday workspace commands. `lint:*`, `fix:*`, `test:*`, `docs:*`,
     and `site:*` are devenv scripts (devenv.nix); `melos run <name>`
     scripts live in the root pubspec.yaml. -->
<!-- {@docsCommandsSection} -->

```bash
# Install dependencies
flutter pub get

# Run every lint check: dprint formatting, dart analyze, MDT docs sync, and monochange
lint:all

# Fix everything fixable: MDT docs sync, dprint formatting, then dart fix
fix:all

# Sync the shared MDT documentation blocks, or check that they are in sync
fix:docs
lint:docs

# Run dart analyze across all packages (infos are fatal)
melos run analyze

# Run the Flutter widget tests
melos run flutter-test

# Run every Flutter and pure-Dart test suite, or collect merged coverage
test:all
test:coverage

# Format all Dart code
melos run format

# Capture component screenshots
melos run screenshot

# Serve or build the documentation site
docs:site:serve
docs:site:build

# Build or serve the skribble.dev landing page (Jaspr)
site:build
site:serve

# Generate rough Material icon SVGs, or the icon font (TTF + Dart helpers)
melos run rough-icons
melos run rough-icons-font

# Run the CI rough icon checks, or verify every committed icon catalog
melos run rough-icons-ci-check
melos run icons-check

# Build, typecheck, and test the npm packages in js/
pnpm install && pnpm run check

# Format, lint, and test the Rust crates in rust/
cargo fmt --all && cargo clippy --workspace --all-targets --all-features -- -D warnings && cargo test --workspace --all-features
```

<!-- {/docsCommandsSection} -->

<!-- Release and cross-engine maintenance commands. -->
<!-- {@docsReleaseCommandsSection} -->

```bash
# Validate release configuration and changesets
monochange step validate
monochange check

# Preview release files without changing the workspace
monochange step prepare-release --dry-run --diff

# Attach the bundled font zips to a GitHub release (--dry-run to preview)
publish:fonts

# Publish the packages a release tag owns, then verify the registry
publish:owned v<version>

# Tag the merged release commit at HEAD and push its tags, watching each publish
publish:tags

# Regenerate the Dart parity fixtures for @skribble.dev/rough and the Rust skribble_rough
dart run packages/skribble_rough/tool/js_parity_fixtures.dart > js/rough/test/fixtures/dart-parity.json
```

<!-- {/docsReleaseCommandsSection} -->

<!-- {@docsMinimalAppSection} -->

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    SkribbleApp(
      title: 'My sketchy app',
      // Supplies the Material theme and localizations that some Wired
      // widgets, such as WiredInput, still need while they wrap Material.
      builder: (context, child) => WiredMaterialTheme(child: child!),
      home: WiredScaffold(
        appBar: WiredAppBar(title: Text('My sketchy app')),
        body: Center(
          child: WiredButton(
            onPressed: () {},
            child: Text('Press me'),
          ),
        ),
      ),
    ),
  );
}
```

<!-- {/docsMinimalAppSection} -->

<!-- {@docsThemeSetupSection} -->

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    SkribbleApp(
      // Plum ink on warm paper, with a vivid marker, accent, and washes.
      wiredTheme: WiredThemeData.colorway(WiredColorway.sunny),
      darkWiredTheme: WiredThemeData.colorway(
        WiredColorway.sunny,
        brightness: Brightness.dark,
      ),
      themeMode: SkribbleThemeMode.system,
      title: 'My sketchy app',
      builder: (context, child) => WiredMaterialTheme(child: child!),
      home: WiredScaffold(
        appBar: WiredAppBar(title: Text('Bright ink, day and night')),
        body: Center(
          child: WiredFilledButton(
            onPressed: () {},
            child: Text('Press me'),
          ),
        ),
      ),
    ),
  );
}
```

<!-- {/docsThemeSetupSection} -->

<!-- {@docsFirstWidgetButton} -->

```dart
// Live example: button
WiredButton(
  borderRadius: BorderRadius.circular(8),
  onPressed: () {},
  inkInteraction: WiredInkInteraction.pressure,
  child: Text('Make something lovely'),
)
```

<!-- {/docsFirstWidgetButton} -->

<!-- {@docsFirstWidgetInput} -->

```dart
// Live example: input
WiredInput(
  labelText: 'Make something lovely',
  hintText: 'A tiny spark of an idea…',
)
```

<!-- {/docsFirstWidgetInput} -->

<!-- {@docsFirstWidgetCard} -->

```dart
// Live example: card
WiredCard(
  color: const Color(0xffff6b4a),
  fill: true,
  child: Center(child: Text('Make something lovely')),
)
```

<!-- {/docsFirstWidgetCard} -->

<!-- {@docsFirstWidgetCheckbox} -->

```dart
// Live example: checkbox
HookBuilder(
  builder: (context) {
    final checked = useState(false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredCheckbox(
          value: checked.value,
          onChanged: (value) => checked.value = value ?? false,
          semanticLabel: 'Keep this idea',
        ),
        const SizedBox(width: 12),
        Flexible(child: Text('Make something lovely')),
      ],
    );
  },
)
```

<!-- {/docsFirstWidgetCheckbox} -->
