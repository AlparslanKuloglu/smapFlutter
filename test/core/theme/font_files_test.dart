import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// The bundled Plus Jakarta Sans files must have what the design needs:
/// the Turkish letters (spec §1.11 glyph test "İı Şş Ğğ Çç Öö Üü") and the
/// `tnum` OpenType feature behind `FontFeature.tabularFigures()`. Without
/// `tnum` the tabular figures setting would silently do nothing.
void main() {
  final dir = Directory('assets/fonts/plus_jakarta_sans');
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.ttf'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('all five weights are bundled', () {
    expect(files.length, 5);
  });

  for (final file in files) {
    final name = file.path.split('/').last;
    group(name, () {
      final font = _Font(file.readAsBytesSync());

      test('has the Turkish letters', () {
        const needed = 'İıŞşĞğÇçÖöÜü·';
        final missing = [
          for (final rune in needed.runes)
            if (!font.codePoints.contains(rune)) String.fromCharCode(rune),
        ];
        expect(missing, isEmpty);
      });

      test('has the tnum feature', () {
        expect(font.gsubFeatures, contains('tnum'));
      });
    });
  }
}

/// Just enough of an OpenType reader for the two checks above.
class _Font {
  _Font(Uint8List bytes) : _data = ByteData.sublistView(bytes) {
    final count = _data.getUint16(4);
    for (var i = 0; i < count; i++) {
      final record = 12 + 16 * i;
      final tag = String.fromCharCodes(bytes.sublist(record, record + 4));
      _tables[tag] = _data.getUint32(record + 8);
    }
  }

  final ByteData _data;
  final Map<String, int> _tables = {};

  /// Code points of the best Unicode `cmap` subtable (format 4 or 12).
  late final Set<int> codePoints = _readCmap();

  /// Feature tags of the `GSUB` table.
  late final Set<String> gsubFeatures = _readGsubFeatures();

  Set<int> _readCmap() {
    final cmap = _tables['cmap']!;
    final subtables = _data.getUint16(cmap + 2);
    int? best;
    var bestFormat = 0;
    for (var i = 0; i < subtables; i++) {
      final platform = _data.getUint16(cmap + 4 + 8 * i);
      final encoding = _data.getUint16(cmap + 6 + 8 * i);
      final offset = cmap + _data.getUint32(cmap + 8 + 8 * i);
      final format = _data.getUint16(offset);
      final unicode =
          (platform == 3 && (encoding == 1 || encoding == 10)) || platform == 0;
      if (unicode && (format == 4 || format == 12) && format > bestFormat) {
        best = offset;
        bestFormat = format;
      }
    }
    final start = best!;
    final points = <int>{};
    if (bestFormat == 12) {
      final groups = _data.getUint32(start + 12);
      for (var g = 0; g < groups; g++) {
        final from = _data.getUint32(start + 16 + 12 * g);
        final to = _data.getUint32(start + 20 + 12 * g);
        for (var c = from; c <= to; c++) {
          points.add(c);
        }
      }
    } else {
      final segments = _data.getUint16(start + 6) ~/ 2;
      final ends = start + 14;
      final starts = ends + segments * 2 + 2;
      for (var s = 0; s < segments; s++) {
        final from = _data.getUint16(starts + 2 * s);
        final to = _data.getUint16(ends + 2 * s);
        for (var c = from; c <= to; c++) {
          points.add(c);
        }
      }
    }
    return points;
  }

  Set<String> _readGsubFeatures() {
    final gsub = _tables['GSUB'];
    if (gsub == null) return {};
    final list = gsub + _data.getUint16(gsub + 6);
    final count = _data.getUint16(list);
    return {
      for (var i = 0; i < count; i++)
        String.fromCharCodes([
          for (var k = 0; k < 4; k++) _data.getUint8(list + 2 + 6 * i + k),
        ]),
    };
  }
}
