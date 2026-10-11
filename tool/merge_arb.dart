// Merges every `lib/l10n/arb/*.arb` fragment into `lib/l10n/app_tr.arb`.
//
// Usage: `dart run tool/merge_arb.dart`, then `flutter gen-l10n`.
//
// Rules:
// - Exactly one `@@locale` survives (the first fragment's, alphabetically).
// - The same key in two fragments is an error (exit code 1).
// - Keys are sorted alphabetically; each `@key` metadata entry stays
//   directly after its key.
import 'dart:convert';
import 'dart:io';

const _srcDir = 'lib/l10n/arb';
const _outFile = 'lib/l10n/app_tr.arb';

void main() {
  final dir = Directory(_srcDir);
  if (!dir.existsSync()) {
    stderr.writeln(
      'merge_arb: $_srcDir not found (run from the project root).',
    );
    exit(1);
  }

  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) {
    stderr.writeln('merge_arb: no .arb fragments in $_srcDir.');
    exit(1);
  }

  String? locale;
  final messages = <String, Object?>{};
  final metadata = <String, Object?>{};
  final origin = <String, String>{};
  var hasError = false;

  void fail(String message) {
    stderr.writeln('merge_arb: $message');
    hasError = true;
  }

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final Object? decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException catch (e) {
      fail('$name is not valid JSON: ${e.message}');
      continue;
    }
    if (decoded is! Map<String, Object?>) {
      fail('$name must contain a JSON object.');
      continue;
    }

    for (final entry in decoded.entries) {
      final key = entry.key;
      if (key == '@@locale') {
        locale ??= entry.value as String?;
        continue;
      }
      if (key.startsWith('@@')) continue;

      final isMeta = key.startsWith('@');
      final target = isMeta ? metadata : messages;
      final id = isMeta ? key.substring(1) : key;
      final slot = isMeta ? '@$id' : id;
      final previous = origin[slot];
      if (previous != null) {
        fail('duplicate key "$slot" in $name (already defined in $previous).');
        continue;
      }
      origin[slot] = name;
      target[id] = entry.value;
    }
  }

  for (final id in metadata.keys) {
    if (!messages.containsKey(id)) {
      fail('metadata "@$id" (${origin['@$id']}) has no matching message.');
    }
  }
  if (hasError) exit(1);

  final out = <String, Object?>{'@@locale': locale ?? 'tr'};
  for (final id in messages.keys.toList()..sort()) {
    out[id] = messages[id];
    if (metadata.containsKey(id)) out['@$id'] = metadata[id];
  }

  File(
    _outFile,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  stdout.writeln(
    'merge_arb: ${messages.length} keys from ${files.length} fragment(s) -> $_outFile',
  );
}
