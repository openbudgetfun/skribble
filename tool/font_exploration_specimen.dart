import 'dart:convert';
import 'dart:io';

/// Writes a portable, interactive comparison using embedded real font files.
/// Pass --serve to also serve the specimen on http://127.0.0.1:8765.
Future<void> main(List<String> arguments) async {
  const output = '.screenshots/font-exploration';
  const sources = 'packages/skribble/tool/font';
  const bundled = 'packages/skribble/assets/fonts';
  final fonts = {
    'Original': '$sources/RecursiveSansCslSt',
    'Current': '$bundled/Skribble',
    'Petal': '$output/SkribblePetal',
    'CodeOriginal': '$sources/RecMonoCasual',
    'CodeCurrent': '$bundled/SkribbleMonoExpressive',
    'Code': '$output/SkribbleCode',
  };
  final css = StringBuffer();

  for (final entry in fonts.entries) {
    for (final style in ['Regular', 'Bold', 'Italic', 'BoldItalic']) {
      final bytes = await File('${entry.value}-$style.ttf').readAsBytes();
      css.writeln(
        '@font-face{font-family:${entry.key};'
        'font-weight:${style.contains('Bold') ? 700 : 400};'
        'font-style:${style.contains('Italic') ? 'italic' : 'normal'};'
        'src:url(data:font/ttf;base64,${base64Encode(bytes)})}',
      );
    }
  }

  final html =
      '''
<!doctype html>
<html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Skribble lettering workshop</title><style>
$css
*{box-sizing:border-box}body{margin:0;background:#f7f4ed;color:#293629;font:15px/1.5 system-ui}
main{max-width:1600px;margin:auto;padding:40px}header{display:flex;justify-content:space-between;gap:40px;align-items:end}
h1{font-size:42px;letter-spacing:-1.6px;line-height:1.1;margin:8px 0 18px}h2{font-size:26px;margin:0 0 4px;letter-spacing:-.5px}
p{margin:0 0 16px}.eyebrow{font-size:11px;letter-spacing:2px;text-transform:uppercase;color:#61765d;font-weight:700}
.intro{max-width:660px;color:#62705f}.badge{padding:7px 12px;border:1px solid #bdcbb4;border-radius:100px;font-size:12px;white-space:nowrap}
.controls{display:flex;flex-wrap:wrap;gap:22px;align-items:center;margin:22px 0 34px;padding:17px 20px;background:#e9eee3;border-radius:12px}
label{display:flex;flex-wrap:wrap;max-width:100%;gap:8px;align-items:center}input[type=checkbox]{accent-color:#496743}input[type=text]{padding:10px;border:1px solid #c2cabb;border-radius:6px;min-width:0;width:300px;max-width:100%}
select{padding:7px;border:1px solid #c2cabb;background:white;border-radius:5px}
.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px;margin:20px 0 30px}
.card{background:#fffefa;border:1px solid #d9dfd2;border-radius:16px;padding:24px;min-width:0}.card.new{background:#eef3e8;border-color:#99b18c}
.card h3{font:600 16px system-ui;margin:6px 0 5px}.note{font-size:12px;color:#697465;min-height:36px;margin-bottom:24px}
.sample{font-size:36px;line-height:1.3;min-height:108px;overflow-wrap:anywhere;margin:0 0 20px}
.alphabet{font-size:25px;line-height:1.6;overflow-wrap:anywhere;margin-bottom:20px}.small{font-size:16px;line-height:1.6}
.ligatures{font-size:33px;line-height:1.8;white-space:pre-wrap;overflow-wrap:anywhere;border-top:1px solid #dbe2d3;padding-top:18px;margin-top:20px}
.font{font-synthesis:none}.original{font-family:Original}.current{font-family:Current}.petal{font-family:Petal}
.codeOriginal{font-family:CodeOriginal}.codeCurrent{font-family:CodeCurrent}.code{font-family:Code}
section{scroll-margin-top:20px}.section-intro{color:#6b7566;max-width:900px;font-size:14px}
pre{font-size:17px;line-height:1.7;white-space:pre;overflow-x:auto;margin:0}.operator{font-size:22px;white-space:pre;overflow-x:auto;margin-top:20px}
.mini{padding:18px 24px;border:1px solid #d9dfd2;border-radius:12px;background:#fffefa;display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:40px}
.mini .font{font-size:34px;overflow-wrap:anywhere}.label{font:11px system-ui;text-transform:uppercase;letter-spacing:1px;color:#697465;display:block;margin-bottom:9px}
footer{font-size:12px;color:#65715f;margin:30px 0}a{color:#355733}button{cursor:pointer}code{font-family:Code,monospace}
@media(max-width:1000px){main{padding:24px}.grid{grid-template-columns:1fr}.mini{grid-template-columns:1fr}header{display:block}.badge{display:inline-block}.sample{min-height:0}}
</style><main>
<header><div><div class="eyebrow">Skribble / type exploration / 01</div><h1>A little more handwritten.</h1>
<p class="intro">Real font outlines, real OpenType ligatures. Compare the upstream source, today's shipped lettering, and two new experimental families.</p></div>
<div class="badge">8 new faces · Regular / Bold / Italic / Bold italic</div></header>
<div class="controls">
<label>Style <select id="style"><option value="regular">Regular</option><option value="bold">Bold</option><option value="italic">Italic</option><option value="bolditalic">Bold italic</option></select></label>
<label><input id="liga" type="checkbox" checked>Text ligatures</label>
<label><input id="swash" type="checkbox">Casual swashes</label>
<label><input id="calt" type="checkbox" checked>Code ligatures</label>
<label>Your text <input id="text" type="text" value="Little things, lovely days."></label></div>
<section id="casual"><h2>01 / Casual lettering</h2><p class="section-intro">Same text, size, weight and color. Petal uses single-storey a/g, a new looped l, gentle bounce and new joined text ligatures. Swashes are optional.</p>
<div class="grid">
${_casualCard('original', 'Upstream', 'Recursive Sans Casual', 'Untouched source · no standard text ligatures in Regular.')}
${_casualCard('current', 'Currently shipped', 'Skribble Expressive', 'Existing outline treatment · roughness 36.')}
${_casualCard('petal', 'New experiment', 'Skribble Petal', 'New letterforms + five standard and three decorative text joins.', fresh: true)}
</div>
<div class="mini"><div><span class="label">Petal / plain letters</span><div class="font petal" style="font-feature-settings:'liga' 0,'dlig' 0,'swsh' 0">affinity · fluffy · little · stay</div></div>
<div><span class="label">Petal / ligatures and swashes on</span><div class="font petal" style="font-feature-settings:'liga' 1,'dlig' 1,'swsh' 1">affinity · fluffy · little · stay</div></div></div></section>
<section id="coding"><h2>02 / A handwritten coding font</h2><p class="section-intro">Skribble Code derives from Recursive's dedicated Code Casual release. Its original cell widths, code substitutions and fixed-pitch metadata are preserved. The currently shipped Mono is Linear.</p>
<div class="grid">
${_codeCard('codeOriginal', 'Upstream code font', 'Rec Mono Casual', 'Untouched Code Casual · contextual operator ligatures.')}
${_codeCard('codeCurrent', 'Currently shipped', 'Skribble Mono Expressive', 'Linear source · optional dlig operators enabled here for fairness.')}
${_codeCard('code', 'New experiment', 'Skribble Code', 'Casual source · drawn outline waves · editor calt ligatures.', fresh: true)}
</div>
<div class="mini"><div><span class="label">Skribble Code / ligatures off</span><div class="font code" style="font-size:26px;font-feature-settings:'calt' 0,'dlig' 0">-&gt; =&gt; == === != &lt;= &gt;= &lt;-</div></div>
<div><span class="label">Skribble Code / ligatures on</span><div class="font code" style="font-size:26px;font-feature-settings:'calt' 1">-&gt; =&gt; == === != &lt;= &gt;= &lt;-</div></div></div></section>
<footer>Exploratory fonts, not a replacement for the shipped defaults. Custom swashes currently cover a e h k m n r t u; other source characters retain coverage with transformed outlines. Browser rendering is not a substitute for testing each editor. Recursive by Arrow Type, derivatives under SIL OFL 1.1. This file embeds all fonts and works offline.</footer>
</main><script>
const styles = document.getElementById('style');
const text = document.getElementById('text');
const liga = document.getElementById('liga');
const swash = document.getElementById('swash');
const calt = document.getElementById('calt');
function update() {
  document.querySelectorAll('.font').forEach(el => {
    el.style.fontWeight = styles.value.includes('bold') ? '700' : '400';
    el.style.fontStyle = styles.value.includes('italic') ? 'italic' : 'normal';
  });
  document.querySelectorAll('#casual .card .font').forEach(el => {
    el.style.fontFeatureSettings = '"liga" '+Number(liga.checked)+', "dlig" '+Number(liga.checked)+', "swsh" '+Number(swash.checked);
  });
  document.querySelectorAll('#coding .card .font').forEach(el => {
    el.style.fontFeatureSettings = '"calt" '+Number(calt.checked)+', "dlig" '+Number(calt.checked);
  });
  document.querySelectorAll('.sample').forEach(el => el.textContent = text.value);
}
[styles,text,liga,swash,calt].forEach(el => el.addEventListener('input',update));
update();
</script></html>''';
  final file = File('$output/comparison.html');
  await file.writeAsString(html);
  stdout.writeln(file.absolute.path);

  if (arguments.contains('--serve')) {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8765);
    stdout.writeln('http://127.0.0.1:8765');

    await for (final request in server) {
      request.response.headers.contentType = ContentType.html;
      request.response.write(await file.readAsString());
      await request.response.close();
    }
  }
}

/// Shows identical alphabet, reading and text-ligature specimens for a family.
String _casualCard(
  String family,
  String label,
  String title,
  String note, {
  bool fresh = false,
}) =>
    '''
<article class="card ${fresh ? 'new' : ''}"><div class="eyebrow">$label</div><h3>$title</h3><p class="note">$note</p>
<div class="font $family sample">Little things, lovely days.</div>
<div class="font $family alphabet">ABCDEFGHIJKLMNOPQRSTUVWXYZ<br>abcdefghijklmnopqrstuvwxyz<br>0123456789 &amp; @ # £ € ? !<br>Café, piñata, naïve, über.</div>
<p class="font $family small">A small note for your day: make something lovely, take a little break, and keep going. £12.50 / 16px text.</p>
<div class="font $family ligatures">fi fl ff ffi ffl<br>ct st tt · affinity · fluffy</div></article>''';

/// Makes spacing and common operator groups visible without syntax coloring.
String _codeCard(
  String family,
  String label,
  String title,
  String note, {
  bool fresh = false,
}) =>
    '''
<article class="card ${fresh ? 'new' : ''}"><div class="eyebrow">$label</div><h3>$title</h3><p class="note">$note</p>
<pre class="font $family">// little things, precise columns
final ready = count &gt;= 10;
if (ready &amp;&amp; value != null) {
  items.map((x) =&gt; x + 1);
}

fn draw(x: i32) -&gt; bool {
  x &lt;= 42 &amp;&amp; x != 0
}

0000000000 | 1111111111
iiiiiiiiii | WWWWWWWWWW
[] {} ()   | 0O 1lI</pre>
<pre class="font $family operator">-&gt; =&gt; == === != !==
&lt;= &gt;= &amp;&amp; || :: ++ --</pre></article>''';
