import 'dart:io';

import 'package:skribble_site/skribble_site.dart';

const _usage = '''
Builds the skribble.dev landing page into a static folder.

Usage: dart run skribble_site:build [options]

  --output=<dir>      Where to write the site (default: build/web).
  --base-path=<path>  The path the site is served under (default: /).
  --site-url=<url>    The public URL, for canonical links
                      (default: https://skribble.dev).
''';

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.write(_usage);
    return;
  }

  String option(String name, String fallback) {
    final prefix = '--$name=';
    final value = args.where((arg) => arg.startsWith(prefix)).lastOrNull;

    return value == null ? fallback : value.substring(prefix.length);
  }

  final config = SiteConfig.normalized(
    basePath: option('base-path', '/'),
    siteUrl: option('site-url', 'https://skribble.dev'),
  );
  final output = Directory(option('output', 'build/web')).absolute;

  await buildSite(config: config, root: findWorkspaceRoot(), output: output);

  stdout.writeln(
    'Built the site for ${config.siteUrl} (base ${config.basePath}) '
    'into ${output.path}',
  );
}
