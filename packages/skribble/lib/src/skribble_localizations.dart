import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Minimal, widgets-only [WidgetsLocalizations] with a right-to-left aware
/// [textDirection].
///
/// `WidgetsApp` always installs `DefaultWidgetsLocalizations`, whose
/// `textDirection` is hard-coded to [TextDirection.ltr]. That is enough for an
/// English-only prototype but leaves an Arabic, Hebrew, or Persian app
/// mirrored incorrectly, because [Localizations] derives the ambient
/// [Directionality] from the resolved [WidgetsLocalizations].
///
/// `flutter_localizations` solves this with `GlobalWidgetsLocalizations`, but
/// Skribble's core does not depend on that package: depending on it would
/// make the design system carry a localization package for every consumer.
/// [SkribbleLocalizations] fills exactly the gap the widgets layer leaves --
/// text direction -- using a packaged script table, and keeps the English
/// semantics labels from [DefaultWidgetsLocalizations] for everything else.
///
/// `SkribbleApp` installs [SkribbleLocalizationsDelegate] after any delegates
/// the caller supplies, so a caller-provided `WidgetsLocalizations` delegate
/// (for example `GlobalWidgetsLocalizations.delegate`) takes precedence.
///
/// This is deliberately not a full localization implementation: it provides no
/// translated strings. Apps that need localized Material or Cupertino strings
/// should add `flutter_localizations` delegates themselves, or use the
/// compatibility layer, which installs the English Material defaults.
class SkribbleLocalizations implements WidgetsLocalizations {
  /// Creates localization resources for [locale].
  const SkribbleLocalizations(this.locale);

  /// The locale these resources were resolved for.
  final Locale locale;

  /// Whether [locale] is written right to left.
  ///
  /// Recognizes the languages that use a right-to-left script as their
  /// default, plus any locale that explicitly selects a right-to-left
  /// [Locale.scriptCode].
  bool get isRightToLeft {
    final scriptCode = locale.scriptCode;
    if (scriptCode != null) {
      return _rightToLeftScripts.contains(scriptCode);
    }
    return _rightToLeftLanguages.contains(locale.languageCode.toLowerCase());
  }

  @override
  TextDirection get textDirection =>
      isRightToLeft ? TextDirection.rtl : TextDirection.ltr;

  @override
  String get reorderItemToStart => 'Move to the start';

  @override
  String get reorderItemToEnd => 'Move to the end';

  @override
  String get reorderItemUp => 'Move up';

  @override
  String get reorderItemDown => 'Move down';

  @override
  String get reorderItemLeft => 'Move left';

  @override
  String get reorderItemRight => 'Move right';

  @override
  String get copyButtonLabel => 'Copy';

  @override
  String get cutButtonLabel => 'Cut';

  @override
  String get pasteButtonLabel => 'Paste';

  @override
  String get selectAllButtonLabel => 'Select all';

  @override
  String get lookUpButtonLabel => 'Look up';

  @override
  String get searchWebButtonLabel => 'Search web';

  @override
  String get shareButtonLabel => 'Share';

  @override
  String get radioButtonUnselectedLabel => 'Not selected';

  @override
  String get searchResultsFound => 'Search results found';

  @override
  String get noResultsFound => 'No results found';
}

/// Installs [SkribbleLocalizations] through a [WidgetsApp].
///
/// The delegate's resource type is [WidgetsLocalizations] (not
/// [SkribbleLocalizations]) on purpose: [Localizations] loads only the first
/// delegate per resource type, and [Localizations] reads the ambient
/// [Directionality] from that same type, so matching the widgets-layer type is
/// what lets this delegate replace `DefaultWidgetsLocalizations`.
class SkribbleLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  /// Creates the delegate. It is const and stateless, so one instance can be
  /// shared by every `SkribbleApp`.
  const SkribbleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      SynchronousFuture<WidgetsLocalizations>(SkribbleLocalizations(locale));

  @override
  bool shouldReload(SkribbleLocalizationsDelegate old) => false;
}

/// Languages whose default script is right to left.
///
/// Mirrors the language list used by `GlobalWidgetsLocalizations`, minus the
/// language/script combinations that are normally written left to right.
const Set<String> _rightToLeftLanguages = <String>{
  'ar', // Arabic
  'arc', // Aramaic
  'ckb', // Central Kurdish
  'dv', // Dhivehi
  'fa', // Persian
  'he', // Hebrew
  'ks', // Kashmiri
  'ku', // Kurdish
  'nqo', // N'Ko
  'pnb', // Western Punjabi
  'ps', // Pashto
  'sd', // Sindhi
  'ug', // Uyghur
  'ur', // Urdu
  'yi', // Yiddish
};

/// Script codes that are written right to left.
const Set<String> _rightToLeftScripts = <String>{
  'Adlm', // Adlam
  'Arab', // Arabic
  'Hebr', // Hebrew
  'Mand', // Mandaic
  'Mend', // Mende Kikakui
  'Nkoo', // N'Ko
  'Ougr', // Old Uyghur
  'Rohg', // Hanifi Rohingya
  'Samr', // Samaritan
  'Syrc', // Syriac
  'Thaa', // Thaana
  'Yezi', // Yezidi
};
