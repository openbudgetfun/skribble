import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// The link-preview image for skribble.dev and its docs, 1200 by 630
/// logical pixels, the size Open Graph and Twitter cards expect.
///
/// `tool/share_card_test.dart` renders it to `share-card.png` when the docs
/// are built, so the image always shows the current lettering and ink. It
/// draws in the theme's own typeface, Noto Sketch by default.
class ShareCard extends StatelessWidget {
  /// Creates the share card.
  const ShareCard({super.key});

  /// The card's size in logical pixels.
  static const Size size = Size(1200, 630);

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return SizedBox.fromSize(
      size: size,
      child: ColoredBox(
        color: theme.fillColor,
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: theme.qualifiedFontFamily,
            fontFamilyFallback: theme.fontFamilyFallback,
            color: theme.textColor,
            decoration: TextDecoration.none,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(80, 64, 72, 56),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const WiredLogo(size: 96, semanticLabel: 'skribble'),
                          const SizedBox(width: 24),
                          Text(
                            'skribble',
                            style: TextStyle(
                              fontSize: 104,
                              color: theme.textColor,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'Hand-drawn widgets\nfor Flutter',
                        style: TextStyle(
                          fontSize: 56,
                          color: theme.textColor,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'skribble.dev',
                        style: TextStyle(
                          fontSize: 32,
                          color: theme.disabledTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                SizedBox(
                  width: 400,
                  child: WiredCard(
                    height: null,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              WiredEmoji('🎨', size: 64),
                              SizedBox(width: 16),
                              WiredEmoji('✏️', size: 64),
                              SizedBox(width: 16),
                              WiredEmoji('🎉', size: 64),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              WiredCheckbox(value: true, onChanged: (_) {}),
                              const SizedBox(width: 12),
                              Text(
                                'Sketch it',
                                style: TextStyle(
                                  fontSize: 26,
                                  color: theme.textColor,
                                ),
                              ),
                              const Spacer(),
                              WiredSwitch(value: true, onChanged: (_) {}),
                            ],
                          ),
                          const SizedBox(height: 24),
                          WiredSlider(value: .65, onChanged: (_) => true),
                          const SizedBox(height: 24),
                          WiredButton(
                            onPressed: () {},
                            child: const Text(
                              'Start sketching',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
