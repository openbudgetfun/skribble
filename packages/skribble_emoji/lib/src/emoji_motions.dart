import 'package:flutter/painting.dart' show Alignment;
import 'package:flutter/widgets.dart' show Axis;
import 'package:skribble_emoji/skribble_emoji.dart' show WiredAnimatedEmoji;

import 'package:skribble_emoji/src/emoji_catalog.dart';
import 'package:skribble_emoji/src/emoji_motion.dart';
import 'package:skribble_emoji/src/wired_animated_emoji.dart'
    show WiredAnimatedEmoji;

/// The motions skribble gives its emoji.
///
/// The most-used emoji have their own choreography, keyed by art so every
/// skin tone and gendered variant shares it. Every other emoji moves with
/// its family: faces blink, hearts beat, hands wave, flowers sway, and
/// weather floats. Flags, symbols, and objects without a natural motion have
/// none, and [WiredAnimatedEmoji] boils their lines instead.
abstract final class EmojiMotions {
  /// The motion for [entry], or null when it has none.
  static EmojiMotion? of(EmojiEntry entry) =>
      choreographed[entry.art] ?? _family(entry);

  /// Hand-made motions, by art key.
  static const Map<String, EmojiMotion> choreographed = {
    // Faces.
    'grinning-face': _happy,
    'grinning-face-with-big-eyes': _happy,
    'grinning-face-with-smiling-eyes': _happy,
    'beaming-face-with-smiling-eyes': _happy,
    'grinning-squinting-face': _giggle,
    'grinning-face-with-sweat': EmojiMotion([
      EmojiTrack('sweat', EmojiMove.drip(distance: 3)),
      EmojiTrack(null, EmojiMove.bob(height: .8)),
    ]),
    'rolling-on-the-floor-laughing': EmojiMotion([
      EmojiTrack(null, EmojiMove.sway(angle: .3)),
      EmojiTrack('tears', EmojiMove.drip(distance: 2)),
    ], duration: Duration(milliseconds: 1200)),
    'face-with-tears-of-joy': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(axis: Axis.vertical, times: 5)),
      EmojiTrack('tears', EmojiMove.drip(distance: 3)),
    ], duration: Duration(milliseconds: 1400)),
    'slightly-smiling-face': _calm,
    'upside-down-face': EmojiMotion([
      EmojiTrack(null, EmojiMove.sway(angle: .18)),
    ], duration: Duration(milliseconds: 2400)),
    'melting-face': EmojiMotion([
      EmojiTrack(
        null,
        EmojiMove.breathe(scale: 1.04),
        pivot: Alignment.bottomCenter,
      ),
      EmojiTrack('eyes', EmojiMove.blink()),
    ], duration: Duration(milliseconds: 2600)),
    'winking-face': EmojiMotion([
      EmojiTrack('mouth', EmojiMove.breathe(scale: 1.1)),
      EmojiTrack(null, EmojiMove.sway(angle: .1)),
    ]),
    'smiling-face-with-smiling-eyes': _calm,
    'smiling-face-with-halo': EmojiMotion([
      EmojiTrack('halo', EmojiMove.float(height: 1.2)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ], duration: Duration(milliseconds: 2400)),
    'smiling-face-with-hearts': EmojiMotion([
      EmojiTrack('hearts', EmojiMove.beat(scale: 1.25)),
      EmojiTrack(null, EmojiMove.sway(angle: .08)),
    ]),
    'smiling-face-with-heart-eyes': EmojiMotion([
      EmojiTrack('eyes', EmojiMove.beat(scale: 1.3)),
      EmojiTrack(null, EmojiMove.bob(height: .6)),
    ], duration: Duration(milliseconds: 1200)),
    'star-struck': EmojiMotion([
      EmojiTrack('eyes', EmojiMove.spin()),
      EmojiTrack(null, EmojiMove.hop(height: 1.5)),
    ]),
    'face-blowing-a-kiss': EmojiMotion([
      EmojiTrack('heart', EmojiMove.float(height: 2)),
      EmojiTrack('heart', EmojiMove.beat(scale: 1.2)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ]),
    'smiling-face': _calm,
    'kissing-face-with-closed-eyes': EmojiMotion([
      EmojiTrack('mouth', EmojiMove.beat(scale: 1.25)),
      EmojiTrack(null, EmojiMove.sway(angle: .06)),
    ]),
    'face-savoring-food': EmojiMotion([
      EmojiTrack('mouth', EmojiMove.wave(angle: .12)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ]),
    'winking-face-with-tongue': EmojiMotion([
      EmojiTrack('mouth', EmojiMove.wave(angle: .12, swings: 3)),
      EmojiTrack(null, EmojiMove.sway(angle: .1)),
    ]),
    'zany-face': EmojiMotion([
      EmojiTrack(null, EmojiMove.wave(angle: .2, swings: 3)),
      EmojiTrack('mouth', EmojiMove.wave(angle: .15, swings: 4)),
    ], duration: Duration(milliseconds: 1400)),
    'smiling-face-with-open-hands': EmojiMotion([
      EmojiTrack('hands', EmojiMove.breathe(scale: 1.12)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ]),
    'face-with-hand-over-mouth': _giggle,
    'thinking-face': EmojiMotion([
      EmojiTrack('hand', EmojiMove.wave(angle: .1, swings: 3)),
      EmojiTrack('brows', EmojiMove.bob(height: .8)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ], duration: Duration(milliseconds: 2400)),
    'neutral-face': _blinkOnly,
    'expressionless-face': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(distance: .4, times: 2)),
    ], duration: Duration(milliseconds: 2600)),
    'smirking-face': EmojiMotion([
      EmojiTrack('brows', EmojiMove.bob(height: .8)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ]),
    'unamused-face': _blinkOnly,
    'face-with-rolling-eyes': EmojiMotion([
      EmojiTrack('eyes', EmojiMove.bob(height: 1)),
      EmojiTrack(null, EmojiMove.sway(angle: .08)),
    ], duration: Duration(milliseconds: 2000)),
    'grimacing-face': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(distance: .5, times: 6)),
    ]),
    'relieved-face': _breathing,
    'pensive-face': _breathing,
    'drooling-face': EmojiMotion([
      EmojiTrack('drool', EmojiMove.drip(distance: 2.5)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ]),
    'sleeping-face': EmojiMotion([
      EmojiTrack('zzz', EmojiMove.float(height: 2)),
      EmojiTrack(null, EmojiMove.breathe(scale: 1.04)),
    ], duration: Duration(milliseconds: 2800)),
    'hot-face': EmojiMotion([
      EmojiTrack('sweat', EmojiMove.drip(distance: 3)),
      EmojiTrack('mouth', EmojiMove.wave(angle: .1, swings: 4)),
      EmojiTrack(null, EmojiMove.breathe(scale: 1.05)),
    ]),
    'woozy-face': EmojiMotion([
      EmojiTrack(null, EmojiMove.sway(angle: .2)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ], duration: Duration(milliseconds: 2400)),
    'partying-face': EmojiMotion([
      EmojiTrack('blower', EmojiMove.wave(angle: .25, swings: 3)),
      EmojiTrack('hat', EmojiMove.wave(angle: .12)),
      EmojiTrack('confetti', EmojiMove.burst()),
      EmojiTrack(null, EmojiMove.hop(height: 1.5)),
    ]),
    'smiling-face-with-sunglasses': EmojiMotion([
      EmojiTrack('sunglasses', EmojiMove.bob(height: .8)),
      EmojiTrack(null, EmojiMove.sway(angle: .08)),
    ], duration: Duration(milliseconds: 2000)),
    'frowning-face': _blinkOnly,
    'flushed-face': EmojiMotion([
      EmojiTrack('cheeks', EmojiMove.breathe(scale: 1.2)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ]),
    'pleading-face': EmojiMotion([
      EmojiTrack('eyes', EmojiMove.breathe(scale: 1.1)),
      EmojiTrack(null, EmojiMove.sway(angle: .05)),
    ], duration: Duration(milliseconds: 2000)),
    'face-holding-back-tears': EmojiMotion([
      EmojiTrack('eyes', EmojiMove.breathe(scale: 1.1)),
      EmojiTrack('mouth', EmojiMove.shake(distance: .3, times: 6)),
    ]),
    'crying-face': _crying,
    'loudly-crying-face': EmojiMotion([
      EmojiTrack('tears', EmojiMove.drip(distance: 2)),
      EmojiTrack(null, EmojiMove.shake(axis: Axis.vertical, times: 6)),
    ], duration: Duration(milliseconds: 1200)),
    'face-screaming-in-fear': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(distance: .7, times: 8)),
      EmojiTrack('hands', EmojiMove.breathe()),
    ], duration: Duration(milliseconds: 1200)),
    'disappointed-face': _breathing,
    'weary-face': EmojiMotion([
      EmojiTrack(null, EmojiMove.sway(angle: .1)),
      EmojiTrack('mouth', EmojiMove.breathe(scale: 1.1)),
    ], duration: Duration(milliseconds: 2400)),
    'enraged-face': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(distance: .8, times: 8)),
      EmojiTrack(null, EmojiMove.breathe(scale: 1.05)),
    ], duration: Duration(milliseconds: 1000)),
    'smiling-face-with-horns': EmojiMotion([
      EmojiTrack('brows', EmojiMove.bob(height: .8)),
      EmojiTrack('horns', EmojiMove.wave(angle: .08)),
    ]),
    'skull': EmojiMotion([
      EmojiTrack('mouth', EmojiMove.shake(axis: Axis.vertical, distance: .6)),
      EmojiTrack(null, EmojiMove.sway(angle: .06)),
    ]),
    'pile-of-poo': _wobble,
    'ghost': EmojiMotion([
      EmojiTrack(null, EmojiMove.float(height: 2)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ], duration: Duration(milliseconds: 2400)),
    'robot': EmojiMotion([
      EmojiTrack('antenna', EmojiMove.wave(angle: .3, swings: 3)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ]),
    'see-no-evil-monkey': EmojiMotion([
      EmojiTrack('hands', EmojiMove.bob(height: 1)),
      EmojiTrack(null, EmojiMove.sway(angle: .1)),
    ]),
    // Hearts and feelings.
    'love-letter': _heartbeat,
    'sparkling-heart': EmojiMotion([
      EmojiTrack('heart', EmojiMove.beat()),
      EmojiTrack('sparkles', EmojiMove.burst()),
    ]),
    'growing-heart': EmojiMotion([
      EmojiTrack(null, EmojiMove.breathe(scale: 1.15)),
      EmojiTrack('growth', EmojiMove.burst()),
    ], duration: Duration(milliseconds: 1400)),
    'beating-heart': _heartbeat,
    'revolving-hearts': EmojiMotion([
      EmojiTrack(null, EmojiMove.spin()),
    ], duration: Duration(milliseconds: 3200)),
    'two-hearts': EmojiMotion([
      EmojiTrack('hearts', EmojiMove.beat()),
      EmojiTrack(null, EmojiMove.sway(angle: .08)),
    ]),
    'heart-exclamation': _heartbeat,
    'broken-heart': EmojiMotion([
      EmojiTrack('left', EmojiMove.wave(angle: .12)),
      EmojiTrack('right', EmojiMove.wave(angle: -.12)),
    ], duration: Duration(milliseconds: 2000)),
    'red-heart': _heartbeat,
    'pink-heart': _heartbeat,
    'orange-heart': _heartbeat,
    'green-heart': _heartbeat,
    'blue-heart': _heartbeat,
    'light-blue-heart': _heartbeat,
    'purple-heart': _heartbeat,
    'brown-heart': _heartbeat,
    'black-heart': _heartbeat,
    'grey-heart': _heartbeat,
    'white-heart': _heartbeat,
    'heart-suit': _heartbeat,
    'kiss-mark': EmojiMotion([EmojiTrack(null, EmojiMove.beat(scale: 1.1))]),
    'hundred-points': EmojiMotion([
      EmojiTrack(null, EmojiMove.wave(angle: .12, swings: 3)),
      EmojiTrack(null, EmojiMove.breathe(scale: 1.08)),
    ], duration: Duration(milliseconds: 1200)),
    'collision': _burst,
    'dizzy': EmojiMotion([
      EmojiTrack(null, EmojiMove.spin()),
    ], duration: Duration(milliseconds: 2400)),
    'sweat-droplets': EmojiMotion([
      EmojiTrack(null, EmojiMove.drip(distance: 2)),
    ], duration: Duration(milliseconds: 1400)),
    'dashing-away': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(distance: 1.4, times: 2)),
    ], duration: Duration(milliseconds: 1200)),
    'zzz': EmojiMotion([
      EmojiTrack(null, EmojiMove.float(height: 2)),
    ], duration: Duration(milliseconds: 2800)),
    // Hands.
    'waving-hand': EmojiMotion([
      EmojiTrack('hand', EmojiMove.wave(swings: 3), pivot: _wrist),
      EmojiTrack('motion', EmojiMove.breathe(scale: 1.15)),
    ], duration: Duration(milliseconds: 1400)),
    'ok-hand': _handNod,
    'victory-hand': _handNod,
    'crossed-fingers': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(distance: .4, times: 6), pivot: _wrist),
    ]),
    'backhand-index-pointing-left': _pointingAcross,
    'backhand-index-pointing-right': _pointingAcross,
    'backhand-index-pointing-down': _pointingDown,
    'thumbs-up': EmojiMotion([
      EmojiTrack(null, EmojiMove.hop(height: 2), pivot: Alignment.bottomCenter),
    ], duration: Duration(milliseconds: 1400)),
    'clapping-hands': EmojiMotion([
      EmojiTrack(
        'left-hand',
        EmojiMove.wave(angle: .2, swings: 4),
        pivot: _wrist,
      ),
      EmojiTrack(
        'right-hand',
        EmojiMove.wave(angle: -.2, swings: 4),
        pivot: _wrist,
      ),
      EmojiTrack('clap', EmojiMove.burst()),
    ], duration: Duration(milliseconds: 1200)),
    'raising-hands': EmojiMotion([
      EmojiTrack('left-hand', EmojiMove.hop(height: 1.5)),
      EmojiTrack('right-hand', EmojiMove.hop(height: 1.5)),
      EmojiTrack('joy', EmojiMove.burst()),
    ], duration: Duration(milliseconds: 1200)),
    'heart-hands': EmojiMotion([
      EmojiTrack(null, EmojiMove.beat(scale: 1.08)),
    ], duration: Duration(milliseconds: 1200)),
    'handshake': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(axis: Axis.vertical, times: 3)),
    ], duration: Duration(milliseconds: 1400)),
    'folded-hands': EmojiMotion([
      EmojiTrack(null, EmojiMove.breathe(scale: 1.04)),
      EmojiTrack('glow', EmojiMove.breathe(scale: 1.2)),
    ], duration: Duration(milliseconds: 2400)),
    'flexed-biceps': EmojiMotion([
      EmojiTrack(
        'arm',
        EmojiMove.wave(angle: .12),
        pivot: Alignment.bottomLeft,
      ),
      EmojiTrack(null, EmojiMove.breathe(scale: 1.05)),
    ], duration: Duration(milliseconds: 1400)),
    'eyes': EmojiMotion([
      EmojiTrack('pupils', EmojiMove.shake(distance: 1.4, times: 2)),
    ], duration: Duration(milliseconds: 2400)),
    'raising-hand': EmojiMotion([
      EmojiTrack('hand', EmojiMove.wave(angle: .2, swings: 3), pivot: _wrist),
    ]),
    'facepalming': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(distance: .4, times: 3)),
    ], duration: Duration(milliseconds: 2000)),
    'shrugging': EmojiMotion([
      EmojiTrack('arm-left', EmojiMove.bob(height: 1.4)),
      EmojiTrack('arm-right', EmojiMove.bob(height: 1.4)),
      EmojiTrack('head', EmojiMove.sway(angle: .08)),
    ]),
    // Animals and plants.
    'dog-face': EmojiMotion([
      EmojiTrack('ears', EmojiMove.wave(angle: .1, swings: 3)),
      EmojiTrack('mouth', EmojiMove.bob(height: .5)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ]),
    'cat-face': EmojiMotion([
      EmojiTrack('ears', EmojiMove.wave(angle: .06)),
      EmojiTrack('whiskers', EmojiMove.wave(angle: .05, swings: 3)),
      EmojiTrack('eyes', EmojiMove.blink()),
    ], duration: Duration(milliseconds: 2000)),
    'unicorn': EmojiMotion([
      EmojiTrack('mane', EmojiMove.sway(angle: .06)),
      EmojiTrack('eyes', EmojiMove.blink()),
      EmojiTrack(null, EmojiMove.bob(height: .8)),
    ], duration: Duration(milliseconds: 2000)),
    'butterfly': EmojiMotion([
      EmojiTrack(
        'wing-left',
        EmojiMove.breathe(scale: .75),
        pivot: Alignment.centerRight,
      ),
      EmojiTrack(
        'wing-right',
        EmojiMove.breathe(scale: .75),
        pivot: Alignment.centerLeft,
      ),
      EmojiTrack(null, EmojiMove.float()),
    ], duration: Duration(milliseconds: 1200)),
    'honeybee': EmojiMotion([
      EmojiTrack('wings', EmojiMove.shake(axis: Axis.vertical, times: 8)),
      EmojiTrack(null, EmojiMove.float()),
    ], duration: Duration(milliseconds: 1200)),
    'bouquet': _swaying,
    'cherry-blossom': EmojiMotion([
      EmojiTrack(null, EmojiMove.spin()),
    ], duration: Duration(milliseconds: 6000)),
    'rose': _swaying,
    'sunflower': _swaying,
    'four-leaf-clover': _swaying,
    // Food.
    'pizza': EmojiMotion([
      EmojiTrack(null, EmojiMove.hop(height: 1.2)),
    ], duration: Duration(milliseconds: 1800)),
    'birthday-cake': _candles,
    'shortcake': EmojiMotion([
      EmojiTrack('strawberry', EmojiMove.hop(height: 1.5)),
    ]),
    'hot-beverage': EmojiMotion([
      EmojiTrack('steam', EmojiMove.float()),
      EmojiTrack('steam', EmojiMove.flicker()),
    ], duration: Duration(milliseconds: 2400)),
    // Travel, sky, and weather.
    'rocket': EmojiMotion([
      EmojiTrack('flame', EmojiMove.flicker(amount: 1.4), pivot: _top),
      EmojiTrack('rocket', EmojiMove.shake(distance: .35, times: 10)),
      EmojiTrack(null, EmojiMove.float(height: 1)),
    ]),
    'crescent-moon': _floating,
    'sun': EmojiMotion([
      EmojiTrack('rays', EmojiMove.spin()),
      EmojiTrack(null, EmojiMove.breathe(scale: 1.04)),
    ], duration: Duration(milliseconds: 6000)),
    'sun-with-face': _sunny,
    'star': _twinkle,
    'glowing-star': _twinkle,
    'rainbow': EmojiMotion([
      EmojiTrack(null, EmojiMove.breathe(scale: 1.04)),
      EmojiTrack('clouds', EmojiMove.float(height: .8)),
    ], duration: Duration(milliseconds: 2400)),
    'high-voltage': EmojiMotion([
      EmojiTrack(null, EmojiMove.shake(distance: .8, times: 3)),
      EmojiTrack(null, EmojiMove.burst(scale: 1.1)),
    ], duration: Duration(milliseconds: 1400)),
    'snowflake': EmojiMotion([
      EmojiTrack(null, EmojiMove.spin()),
      EmojiTrack(null, EmojiMove.float(height: 1)),
    ], duration: Duration(milliseconds: 4000)),
    'fire': EmojiMotion([
      EmojiTrack('flame', EmojiMove.flicker(), pivot: Alignment.bottomCenter),
      EmojiTrack(
        'core',
        EmojiMove.flicker(amount: 1.5),
        pivot: Alignment.bottomCenter,
      ),
    ], duration: Duration(milliseconds: 1400)),
    'water-wave': EmojiMotion([
      EmojiTrack(null, EmojiMove.sway(angle: .08), pivot: Alignment.bottomLeft),
    ], duration: Duration(milliseconds: 2000)),
    // Activities and objects.
    'jack-o-lantern': EmojiMotion([
      EmojiTrack('eyes', EmojiMove.flicker(amount: 1.5)),
      EmojiTrack('mouth', EmojiMove.flicker(amount: 1.5)),
      EmojiTrack(null, EmojiMove.sway(angle: .05)),
    ], duration: Duration(milliseconds: 1400)),
    'christmas-tree': EmojiMotion([
      EmojiTrack('star', EmojiMove.breathe(scale: 1.2)),
      EmojiTrack('baubles', EmojiMove.breathe(scale: 1.15)),
    ]),
    'sparkles': _twinkle,
    'balloon': EmojiMotion([
      EmojiTrack(
        null,
        EmojiMove.float(height: 2),
        pivot: Alignment.bottomCenter,
      ),
      EmojiTrack(
        null,
        EmojiMove.sway(angle: .08),
        pivot: Alignment.bottomCenter,
      ),
    ], duration: Duration(milliseconds: 2400)),
    'party-popper': EmojiMotion([
      EmojiTrack('confetti', EmojiMove.burst(scale: 1.35)),
      EmojiTrack(
        'cone',
        EmojiMove.shake(distance: .5, times: 2),
        pivot: Alignment.bottomLeft,
      ),
    ], duration: Duration(milliseconds: 1400)),
    'confetti-ball': EmojiMotion([
      EmojiTrack('confetti', EmojiMove.drip(distance: 3)),
      EmojiTrack('ball', EmojiMove.sway(angle: .1), pivot: Alignment.topCenter),
    ], duration: Duration(milliseconds: 1800)),
    'wrapped-gift': EmojiMotion([
      EmojiTrack('lid', EmojiMove.hop(height: 1.5)),
      EmojiTrack(null, EmojiMove.shake(distance: .4)),
    ]),
    'trophy': EmojiMotion([
      EmojiTrack('cup', EmojiMove.wave(angle: .08)),
      EmojiTrack(null, EmojiMove.hop(height: 1.5)),
    ], duration: Duration(milliseconds: 1800)),
    'soccer-ball': EmojiMotion([
      EmojiTrack(null, EmojiMove.hop()),
      EmojiTrack(null, EmojiMove.spin()),
    ], duration: Duration(milliseconds: 1400)),
    'video-game': EmojiMotion([
      EmojiTrack('buttons', EmojiMove.bob(height: .5)),
      EmojiTrack(null, EmojiMove.shake(distance: .3, times: 6)),
    ], duration: Duration(milliseconds: 1400)),
    'crown': EmojiMotion([
      EmojiTrack('gems', EmojiMove.beat(scale: 1.2)),
      EmojiTrack(null, EmojiMove.bob(height: .8)),
    ], duration: Duration(milliseconds: 2000)),
    'musical-note': _musical,
    'musical-notes': _musical,
    'guitar': EmojiMotion([
      EmojiTrack(null, EmojiMove.sway(), pivot: Alignment.bottomLeft),
    ]),
    'camera-with-flash': EmojiMotion([
      EmojiTrack('flash', EmojiMove.burst(scale: 1.4)),
    ], duration: Duration(milliseconds: 1800)),
    'light-bulb': EmojiMotion([
      EmojiTrack('glow', EmojiMove.breathe(scale: 1.2)),
      EmojiTrack(null, EmojiMove.sway(angle: .06), pivot: Alignment.topCenter),
    ], duration: Duration(milliseconds: 1800)),
    'money-bag': EmojiMotion([
      EmojiTrack(null, EmojiMove.hop(height: 1.5)),
    ]),
    'check-mark-button': EmojiMotion([
      EmojiTrack('tick', EmojiMove.beat(scale: 1.15)),
    ]),
  };

  static EmojiMotion? _family(EmojiEntry entry) {
    final subgroup = entry.subgroup;
    if (subgroup.startsWith('face-') || subgroup == 'cat-face') return _calm;
    if (subgroup == 'heart') return _heartbeat;
    if (subgroup.startsWith('hand') || subgroup == 'hands') return _handNod;
    if (subgroup.startsWith('animal-')) return _animal;
    if (subgroup.startsWith('plant-')) return _swaying;
    if (subgroup == 'sky & weather') return _floating;
    if (subgroup.startsWith('person') || subgroup == 'family') return _person;
    if (subgroup == 'transport-air') return _floating;
    if (subgroup.startsWith('transport-')) return _idling;
    if (subgroup == 'event') return _wobble;
    if (subgroup == 'sport' || subgroup == 'game') return _bouncing;
    if (subgroup == 'music' || subgroup == 'musical-instrument') {
      return _musical;
    }
    return null;
  }
}

/// A hand's wrist, near the bottom of its bounds.
const Alignment _wrist = Alignment(0, .8);

/// The top of a downward flame, such as a rocket's exhaust.
const Alignment _top = Alignment.topCenter;

const EmojiMotion _calm = EmojiMotion([
  EmojiTrack('eyes', EmojiMove.blink()),
  EmojiTrack(null, EmojiMove.bob(height: .6)),
], duration: Duration(milliseconds: 2400));

const EmojiMotion _happy = EmojiMotion([
  EmojiTrack('eyes', EmojiMove.blink()),
  EmojiTrack(null, EmojiMove.hop(height: 1.4)),
], duration: Duration(milliseconds: 1800));

const EmojiMotion _giggle = EmojiMotion([
  EmojiTrack(null, EmojiMove.shake(axis: Axis.vertical, distance: .6)),
  EmojiTrack('eyes', EmojiMove.blink()),
]);

const EmojiMotion _blinkOnly = EmojiMotion([
  EmojiTrack('eyes', EmojiMove.blink()),
], duration: Duration(milliseconds: 2800));

const EmojiMotion _breathing = EmojiMotion([
  EmojiTrack(null, EmojiMove.breathe(scale: 1.04)),
  EmojiTrack('eyes', EmojiMove.blink()),
], duration: Duration(milliseconds: 3000));

const EmojiMotion _crying = EmojiMotion([
  EmojiTrack('tears', EmojiMove.drip(distance: 3)),
  EmojiTrack(null, EmojiMove.breathe(scale: 1.03)),
], duration: Duration(milliseconds: 2000));

const EmojiMotion _wobble = EmojiMotion([
  EmojiTrack(null, EmojiMove.sway(angle: .1), pivot: Alignment.bottomCenter),
]);

const EmojiMotion _heartbeat = EmojiMotion([
  EmojiTrack(null, EmojiMove.beat()),
], duration: Duration(milliseconds: 1200));

const EmojiMotion _burst = EmojiMotion([
  EmojiTrack(null, EmojiMove.burst()),
], duration: Duration(milliseconds: 1400));

const EmojiMotion _handNod = EmojiMotion([
  EmojiTrack(null, EmojiMove.wave(angle: .12), pivot: _wrist),
]);

const EmojiMotion _pointingAcross = EmojiMotion([
  EmojiTrack(null, EmojiMove.shake(distance: 1.4, times: 2)),
], duration: Duration(milliseconds: 1400));

const EmojiMotion _pointingDown = EmojiMotion([
  EmojiTrack(
    null,
    EmojiMove.shake(distance: 1.4, axis: Axis.vertical, times: 2),
  ),
], duration: Duration(milliseconds: 1400));

const EmojiMotion _animal = EmojiMotion([
  EmojiTrack('eyes', EmojiMove.blink()),
  EmojiTrack('tail', EmojiMove.wave(angle: .2)),
  EmojiTrack('wings', EmojiMove.breathe(scale: .85)),
  EmojiTrack(null, EmojiMove.bob(height: .8)),
], duration: Duration(milliseconds: 2000));

const EmojiMotion _swaying = EmojiMotion([
  EmojiTrack(null, EmojiMove.sway(), pivot: Alignment.bottomCenter),
], duration: Duration(milliseconds: 2800));

const EmojiMotion _floating = EmojiMotion([
  EmojiTrack(null, EmojiMove.float()),
], duration: Duration(milliseconds: 2800));

const EmojiMotion _sunny = EmojiMotion([
  EmojiTrack('rays', EmojiMove.spin()),
  EmojiTrack('eyes', EmojiMove.blink()),
  EmojiTrack(null, EmojiMove.breathe(scale: 1.04)),
], duration: Duration(milliseconds: 6000));

const EmojiMotion _twinkle = EmojiMotion([
  EmojiTrack(null, EmojiMove.beat(scale: 1.18)),
  EmojiTrack(null, EmojiMove.wave(angle: .15)),
]);

const EmojiMotion _person = EmojiMotion([
  EmojiTrack('eyes', EmojiMove.blink()),
  EmojiTrack(null, EmojiMove.bob(height: .6)),
], duration: Duration(milliseconds: 2400));

const EmojiMotion _idling = EmojiMotion([
  EmojiTrack(
    null,
    EmojiMove.shake(distance: .3, axis: Axis.vertical, times: 8),
  ),
]);

const EmojiMotion _bouncing = EmojiMotion([
  EmojiTrack(null, EmojiMove.hop(height: 2)),
]);

const EmojiMotion _musical = EmojiMotion([
  EmojiTrack(null, EmojiMove.wave(angle: .15)),
  EmojiTrack(null, EmojiMove.bob(height: 1)),
]);

const EmojiMotion _candles = EmojiMotion([
  EmojiTrack(
    'flames',
    EmojiMove.flicker(amount: 1.5),
    pivot: Alignment.bottomCenter,
  ),
], duration: Duration(milliseconds: 1400));
