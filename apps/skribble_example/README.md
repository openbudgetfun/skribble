# skribble_example

Sketch Notes, a small notes app built with [skribble](../../packages/skribble). Read it when you want a skribble app that does real work. The [storybook](../skribble_storybook) shows every widget on its own.

It shows how to:

- theme a whole app with one `WiredThemeData`, with separate day and night parchment and a roughness the reader chooses (`lib/app.dart`);
- share app-wide settings through an `InheritedNotifier` and redraw every page when they change (`lib/models/sketch_settings.dart`);
- scale text on top of the system text size, so every control grows with it (`NoteTextSizeScope` in `lib/app.dart`);
- pass a note to a page as a route argument and get the edited note back when the page pops (`lib/pages/edit_page.dart`);
- search, swipe to delete, and undo from a snack bar (`lib/pages/home_page.dart`);
- draw Material `Icons.*` with the pen by calling `registerSkribbleIcons()` before `runApp` (`lib/main.dart`).

## Run it

The repository does not include the platform folders (`android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/`). Generate the ones you need once. They are ignored by Git:

```bash
cd apps/skribble_example
flutter create --empty --org fun.openbudget --project-name skribble_example \
  --platforms=android,ios,macos,web,windows,linux .
```

`--empty` writes only the platform folders. It leaves `lib/` and `test/` as they are. Leave out any platform you don't build for.

Then run it from `apps/skribble_example`. Inside the repository, run `devenv shell` first. It pins the Flutter version in `.fvmrc`.

| Platform | Command                      | You need                                          |
| -------- | ---------------------------- | ------------------------------------------------- |
| Web      | `flutter run -d chrome`      | Chrome                                            |
| macOS    | `flutter run -d macos`       | Xcode                                             |
| iOS      | `flutter run -d <simulator>` | Xcode, and a booted simulator or a device         |
| Android  | `flutter run -d <emulator>`  | The Android SDK, and a running emulator or device |
| Windows  | `flutter run -d windows`     | Visual Studio with "Desktop development with C++" |
| Linux    | `flutter run -d linux`       | GTK 3 development headers, CMake, and Ninja       |

`flutter devices` lists the IDs to pass to `-d`. The app needs no network access and no extra permissions on any platform.

## Test it

```bash
cd apps/skribble_example
flutter test
```

- `test/app_test.dart` drives every page: writing, editing, searching, deleting and undoing, and each setting.
- `test/breathing_room_test.dart` checks every page with `crampedText` and `squeezedText` from `package:skribble/testing.dart` at 360, 768, and 1280 pixels and at 1.3× text.
- `test/skribble_app_test.dart` runs the app under `SkribbleApp`, the Material-free shell, to track what it still needs before it can leave `WiredMaterialApp`. Each skipped test there says what breaks.

## Why `WiredMaterialApp`?

New skribble apps use `SkribbleApp`, which is built on `WidgetsApp` and has no Material ancestor. Sketch Notes still uses the `WiredMaterialApp` bridge because some of its widgets wrap Material ones: `WiredInput` and `WiredSearchBar` use a Material text field, and `showWiredSnackBar` needs a `ScaffoldMessenger`. Both shells take the same themes and the same `sketchNotesRoutes`. Swapping them is a one-line change once `test/skribble_app_test.dart` passes without skips.
