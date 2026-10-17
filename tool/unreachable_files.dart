// Lists the Dart files under lib/ that no entry point reaches.
//
//   dart run tool/unreachable_files.dart
//
// Starts from the app and gallery entry points (lib/main.dart,
// lib/main_gallery.dart), follows `import`, `export` and `part` directives
// inside this package, and prints every lib/ file it never reached, skipping
// generated code (*.g.dart, *.gr.dart, *.mapper.dart, lib/gen, the generated
// localizations) and the vendored scanner (lib/vendor).
//
// Use it before deleting code: an unreachable file is dead for the app, but
// check `test/` (grep its path) before removing it, and remember that a file
// can be reached only through a conditional import this script does not
// resolve. Exit code 0 always; the list is the output.
import 'dart:io';

const _package = 'smap';
const _entryPoints = ['lib/main.dart', 'lib/main_gallery.dart'];

final _directive = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main() {
  final root = Directory.current.path;
  final seen = <String>{};
  final queue = <String>[
    for (final entry in _entryPoints)
      if (File('$root/$entry').existsSync()) entry,
  ];
  while (queue.isNotEmpty) {
    final path = queue.removeLast();
    if (!seen.add(path)) continue;
    final file = File('$root/$path');
    if (!file.existsSync()) continue;
    for (final match in _directive.allMatches(file.readAsStringSync())) {
      final target = _resolve(path, match.group(1)!);
      if (target != null && !seen.contains(target)) queue.add(target);
    }
  }

  final unreachable =
      Directory('$root/lib')
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => file.path.substring(root.length + 1))
          .where((path) => path.endsWith('.dart'))
          .where((path) => !_ignored(path))
          .where((path) => !seen.contains(path))
          .toList()
        ..sort();

  if (unreachable.isEmpty) {
    stdout.writeln(
      'Every lib/ file is reachable from ${_entryPoints.join(', ')}.',
    );
    return;
  }
  stdout.writeln('${unreachable.length} file(s) under lib/ are unreachable:');
  unreachable.forEach(stdout.writeln);
}

/// The repo-relative path [uri] points at from [from]; `null` for SDK and
/// other packages.
String? _resolve(String from, String uri) {
  if (uri.startsWith('dart:')) return null;
  if (uri.startsWith('package:')) {
    const prefix = 'package:$_package/';
    return uri.startsWith(prefix)
        ? 'lib/${uri.substring(prefix.length)}'
        : null;
  }
  final segments = from.split('/')..removeLast();
  for (final part in uri.split('/')) {
    if (part == '..') {
      if (segments.isNotEmpty) segments.removeLast();
    } else if (part != '.') {
      segments.add(part);
    }
  }
  return segments.join('/');
}

bool _ignored(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('.gr.dart') ||
    path.endsWith('.mapper.dart') ||
    path.startsWith('lib/gen/') ||
    path.startsWith('lib/vendor/') ||
    path.startsWith('lib/l10n/app_localizations');
