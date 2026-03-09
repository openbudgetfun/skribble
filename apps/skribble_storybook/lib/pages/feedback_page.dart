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
                    unawaited(showDialog<void>(
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
                    ));
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
                    unawaited(showWiredBottomSheet<void>(
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
                    ));
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
                    WiredBadge(
                      label: '3',
                      child: Icon(Icons.mail, size: 32),
                    ),
                    SizedBox(width: 24),
                    WiredBadge(
                      child: Icon(Icons.notifications, size: 32),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
