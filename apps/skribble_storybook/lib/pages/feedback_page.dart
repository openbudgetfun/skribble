import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';

class FeedbackPage extends HookWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final progressController = useAnimationController(
      duration: const Duration(seconds: 3),
    );

    return Scaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Feedback'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShowcaseSection(
            title: 'WiredAnimatedIcon',
            children: [
              ComponentShowcase(
                title: 'Animated Icon',
                description: 'Morphing icon with hand-drawn styling.',
                child: _AnimatedIconDemo(),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredMaterialBanner',
            children: [
              ComponentShowcase(
                title: 'Banner',
                description: 'Persistent top-of-screen message.',
                child: WiredMaterialBanner(
                  leading: const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                  ),
                  content: const Text('Your account is about to expire.'),
                  actions: [
                    TextButton(onPressed: () {}, child: const Text('DISMISS')),
                    TextButton(onPressed: () {}, child: const Text('RENEW')),
                  ],
                ),
              ),
              ComponentShowcase(
                title: 'Actions Below',
                child: WiredMaterialBanner(
                  forceActionsBelow: true,
                  leading: const Icon(Icons.info_outline),
                  content: const Text('A new update is available.'),
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('UPDATE NOW'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredProgress',
            children: [
              ComponentShowcase(
                title: 'Linear Progress',
                description: 'Hand-drawn progress bar with hachure fill.',
                child: Column(
                  children: [
                    WiredProgress(controller: progressController, value: 0.3),
                    const SizedBox(height: 12),
                    WiredButton(
                      onPressed: () {
                        progressController.reset();
                        unawaited(progressController.forward());
                      },
                      child: const Text('Animate'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCircularProgress',
            children: [
              ComponentShowcase(
                title: 'Circular Progress',
                description: 'Hand-drawn arc animation.',
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WiredCircularProgress(value: 0.25, size: 60),
                    WiredCircularProgress(value: 0.5, size: 60),
                    WiredCircularProgress(value: 0.75, size: 60),
                    WiredCircularProgress(value: 1, size: 60),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredDialog',
            children: [
              ComponentShowcase(
                title: 'Dialog',
                description: 'Hand-drawn rectangle dialog.',
                child: WiredButton(
                  onPressed: () {
                    unawaited(
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => WiredDialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Hello!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('This is a hand-drawn dialog.'),
                              const SizedBox(height: 16),
                              WiredButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredSnackBar',
            children: [
              ComponentShowcase(
                title: 'Snack Bar',
                description: 'Hand-drawn snack bar content.',
                child: WiredButton(
                  onPressed: () {
                    showWiredSnackBar(
                      context,
                      content: const Text('This is a wired snack bar!'),
                    );
                  },
                  child: const Text('Show Snack Bar'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredBottomSheet',
            children: [
              ComponentShowcase(
                title: 'Bottom Sheet',
                description: 'Hand-drawn top border bottom sheet.',
                child: WiredButton(
                  onPressed: () {
                    unawaited(
                      showWiredBottomSheet<void>(
                        context: context,
                        builder: (ctx) => SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Bottom Sheet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                WiredButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Bottom Sheet'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredTooltip',
            children: [
              ComponentShowcase(
                title: 'Tooltip',
                description: 'Tooltip with hand-drawn decoration.',
                child: const WiredTooltip(
                  message: 'This is a tooltip!',
                  child: Text('Hover or long-press me'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredBadge',
            children: [
              ComponentShowcase(
                title: 'Badge',
                description: 'Small circle overlay on child.',
                child: const Row(
                  children: [
                    WiredBadge(label: '3', child: Icon(Icons.mail, size: 32)),
                    SizedBox(width: 24),
                    WiredBadge(child: Icon(Icons.notifications, size: 32)),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoAlertDialog',
            children: [
              ComponentShowcase(
                title: 'Cupertino Alert Dialog',
                description: 'iOS-style alert with sketchy borders.',
                child: WiredButton(
                  onPressed: () {
                    unawaited(
                      showWiredCupertinoDialog<void>(
                        context: context,
                        title: const Text('Delete Photo'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          WiredCupertinoDialogAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          WiredCupertinoDialogAction(
                            onPressed: () => Navigator.pop(context),
                            isDestructiveAction: true,
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Alert Dialog'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoActionSheet',
            children: [
              ComponentShowcase(
                title: 'Cupertino Action Sheet',
                description: 'iOS-style action sheet with sketchy borders.',
                child: WiredButton(
                  onPressed: () {
                    unawaited(
                      showWiredCupertinoActionSheet<void>(
                        context: context,
                        title: const Text('Share Photo'),
                        message: const Text('Choose how to share'),
                        actions: [
                          WiredCupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('AirDrop'),
                          ),
                          WiredCupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Messages'),
                          ),
                          WiredCupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            isDestructiveAction: true,
                            child: const Text('Delete'),
                          ),
                        ],
                        cancelButton: WiredCupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          isDefaultAction: true,
                          child: const Text('Cancel'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Action Sheet'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredContextMenu',
            children: [
              ComponentShowcase(
                title: 'Context Menu',
                description: 'Long press to show hand-drawn menu overlay.',
                child: WiredContextMenu(
                  actions: const [
                    WiredContextMenuAction(label: 'Copy', icon: Icons.copy),
                    WiredContextMenuAction(label: 'Share', icon: Icons.share),
                    WiredContextMenuAction(
                      label: 'Delete',
                      icon: Icons.delete,
                      isDestructive: true,
                    ),
                  ],
                  child: WiredCard(
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Long press this card'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredScrollbar',
            children: [
              ComponentShowcase(
                title: 'Scrollbar',
                description: 'Styled scrollbar with sketchy thumb.',
                child: SizedBox(
                  height: 120,
                  child: WiredScrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Text('Scrollbar item $i'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredAboutDialog',
            children: [
              ComponentShowcase(
                title: 'About Dialog',
                description: 'Hand-drawn about dialog with app info.',
                child: WiredButton(
                  onPressed: () {
                    unawaited(
                      showWiredAboutDialog(
                        context: context,
                        applicationName: 'Skribble',
                        applicationVersion: '1.0.0',
                        applicationIcon: const FlutterLogo(size: 48),
                        applicationLegalese: '© 2026 OpenBudget',
                      ),
                    );
                  },
                  child: const Text('Show About'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedIconDemo extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final isForward = useState(false);

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (isForward.value) {
              unawaited(controller.reverse());
            } else {
              unawaited(controller.forward());
            }
            isForward.value = !isForward.value;
          },
          child: WiredAnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: controller,
            size: 36,
          ),
        ),
        const SizedBox(width: 16),
        const Text('Tap to animate'),
      ],
    );
  }
}
