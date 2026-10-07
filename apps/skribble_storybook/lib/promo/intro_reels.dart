import 'package:flutter/widgets.dart';

import 'reels/drawn_by_a_pen_reel.dart';
import 'reels/emoji_party_reel.dart';
import 'reels/fun_again_reel.dart';
import 'reels/make_it_yours_reel.dart';

/// skribble's intro reels, each drawn for portrait and landscape screens.
///
/// Every reel is a pure function of time, so it renders identically frame
/// by frame (`tool/render_reel_test.dart`, then `scripts/render_reel.sh`).
enum IntroReel {
  /// A grey app scribbled out and redrawn by hand.
  funAgain('fun-again', FunAgainReel.duration),

  /// A pencil draws an app outline by outline.
  drawnByAPen('drawn-by-a-pen', DrawnByAPenReel.duration),

  /// Emoji on the beat, a wall of thousands, and every skin tone.
  emojiParty('emoji-party', EmojiPartyReel.duration),

  /// One app restyled live by its theme.
  makeItYours('make-it-yours', MakeItYoursReel.duration);

  const IntroReel(this.slug, this.duration);

  /// The reel's file name.
  final String slug;

  /// How long the reel runs.
  final Duration duration;

  /// The reel at [time] seconds.
  Widget build(double time) => switch (this) {
    IntroReel.funAgain => FunAgainReel(time: time),
    IntroReel.drawnByAPen => DrawnByAPenReel(time: time),
    IntroReel.emojiParty => EmojiPartyReel(time: time),
    IntroReel.makeItYours => MakeItYoursReel(time: time),
  };
}
