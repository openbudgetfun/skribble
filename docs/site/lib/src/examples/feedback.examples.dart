part of 'catalog.dart';

/// @docs-example circular-progress
Widget _progress(ExampleSettings settings) =>
    WiredCircularProgress(value: settings.amount);

/// @docs-example badge
Widget _badge(ExampleSettings settings) => WiredBadge(
  label: '3',
  isVisible: settings.enabled,
  child: const Padding(padding: EdgeInsets.all(16), child: Text('New ideas')),
);

/// @docs-example tooltip
Widget _tooltip(ExampleSettings settings) => WiredTooltip(
  message: settings.label,
  child: const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Hover or long press here'),
  ),
);

/// @docs-example snack-bar-content
Widget _snackBar(ExampleSettings settings) => WiredSnackBarContent(
  action: WiredTextButton(onPressed: () {}, child: const Text('Undo')),
  child: Text(settings.label),
);

/// @docs-example bottom-sheet
Widget _bottomSheet(ExampleSettings settings) => Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(settings.label),
            WiredTextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    ),
    child: const Text('Open the sheet'),
  ),
);

/// @docs-example about-dialog
Widget _aboutDialog(ExampleSettings settings) => Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredAboutDialog(
      context: context,
      applicationName: settings.label,
      applicationVersion: '1.0',
    ),
    child: const Text('About this sketchbook'),
  ),
);

/// @docs-example license-page
Widget _licensePage(ExampleSettings settings) => Builder(
  builder: (context) => WiredButton(
    onPressed: () =>
        showWiredLicensePage(context: context, applicationName: settings.label),
    child: const Text('Read the licenses'),
  ),
);

/// @docs-example context-menu
Widget _contextMenu(ExampleSettings settings) => WiredContextMenu(
  actions: [
    WiredContextMenuAction(label: 'Save', onPressed: () {}),
    WiredContextMenuAction(label: 'Share', onPressed: () {}),
  ],
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Text(settings.label),
  ),
);

/// @docs-example material-banner
Widget _materialBanner(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final visible = useState(true);
    return visible.value
        ? WiredMaterialBanner(
            content: Text(settings.label),
            backgroundColor: const Color(0xffdde4c9),
            actions: [
              WiredTextButton(
                onPressed: () => visible.value = false,
                child: const Text('Got it'),
              ),
            ],
          )
        : WiredTextButton(
            onPressed: () => visible.value = true,
            child: const Text('Show banner'),
          );
  },
);

/// @docs-example dialog
Widget _dialog(ExampleSettings settings) => Builder(
  builder: (context) => WiredButton(
    child: const Text('Open a little dialog'),
    onPressed: () => showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close dialog',
      pageBuilder: (context, animation, secondaryAnimation) => WiredDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(settings.label),
            WiredTextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Lovely'),
            ),
          ],
        ),
      ),
    ),
  ),
);

/// @docs-example cupertino-alert-dialog
Widget _cupertinoAlertDialog(ExampleSettings settings) => Builder(
  builder: (context) => WiredButton(
    child: const Text('Show an alert'),
    onPressed: () => showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close alert',
      pageBuilder: (context, animation, secondaryAnimation) =>
          WiredCupertinoAlertDialog(
            title: Text(settings.label),
            content: const Text('Your sketch is ready to keep.'),
            actions: [
              WiredCupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keep it'),
              ),
            ],
          ),
    ),
  ),
);

/// @docs-example cupertino-action-sheet
Widget _cupertinoActionSheet(ExampleSettings settings) => Builder(
  builder: (context) => WiredButton(
    child: const Text('Choose what happens next'),
    onPressed: () => showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close actions',
      pageBuilder: (context, animation, secondaryAnimation) => Align(
        alignment: Alignment.bottomCenter,
        child: WiredCupertinoActionSheet(
          title: Text(settings.label),
          actions: [
            WiredCupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save the sketch'),
            ),
          ],
          cancelButton: WiredCupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
      ),
    ),
  ),
);

/// @docs-example progress
Widget _linearProgress(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 600),
      initialValue: 1,
    );
    return WiredProgress(controller: controller, value: settings.amount);
  },
);

/// @docs-example animated-icon
Widget _animatedIcon(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 350),
    );
    final open = useState(false);
    return WiredButton(
      onPressed: () {
        open.value = !open.value;
        if (MediaQuery.disableAnimationsOf(context)) {
          controller.value = open.value ? 1 : 0;
        } else if (open.value) {
          controller.forward();
        } else {
          controller.reverse();
        }
      },
      child: WiredAnimatedIcon.menuClose(
        progress: controller,
        semanticLabel: open.value ? 'Close' : 'Open menu',
      ),
    );
  },
);
