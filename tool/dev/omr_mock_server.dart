// A local stand-in for the optical reading service, for debug runs only.
//
// The real OMR host is still an open backend question (spec §6.3 #1), and a
// simulator has no camera. With this server and the debug gallery pick the
// whole scan flow can be walked on a simulator (or a device on the same
// network) without sending a photo anywhere:
//
//   dart run tool/dev/omr_mock_server.dart --scenario=notfound
//   flutter run -d <simulator> \
//     --dart-define=SHELL_PREVIEW=student \
//     --dart-define=SCAN_GALLERY=true \
//     --dart-define=OMR_BASE_URL=http://127.0.0.1:8787 \
//     --dart-define=CDN_BASE_URL=http://127.0.0.1:8787
//
// Scenarios (`--scenario=`):
//   notfound     the form is read, the exam is not in the system:
//                Gönderim → Form Kontrol → Deneme Bulunamadı → Talep (default)
//   found        the exam is recognised: Form Kontrol → Sonuç Anı (the result
//                itself is read from the real API, so it needs a signed-in
//                student whose list has that exam; in the preview it errors)
//   noform       no answer area on the photo: "Formu bulamadık"
//   error        the reading fails (HTTP 500): "Formun gönderilemedi"
//   maintenance  the reading service is down (HTTP 503)
//
// Other flags: `--port=8787`, `--lan` (listen on all interfaces, for a real
// iPhone on the same Wi-Fi: use `http://<mac-ip>:8787` in the defines),
// `--delay=1500` (ms before each answer, to see the upload steps).
//
// Every request is printed with its body (the image as its size only), so the
// wire format can be checked against the legacy one.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _scenarios = {'notfound', 'found', 'noform', 'error', 'maintenance'};

Future<void> main(List<String> args) async {
  final options = _Options.parse(args);
  if (options == null) {
    stderr.writeln(
      'usage: dart run tool/dev/omr_mock_server.dart '
      '[--scenario=${_scenarios.join('|')}] [--port=8787] [--lan] '
      '[--delay=ms]',
    );
    exitCode = 64;
    return;
  }
  final server = await HttpServer.bind(
    options.lan ? InternetAddress.anyIPv4 : InternetAddress.loopbackIPv4,
    options.port,
  );
  final state = _State();
  stdout.writeln(
    'OMR mock on http://${options.lan ? '0.0.0.0' : '127.0.0.1'}:'
    '${options.port} · scenario "${options.scenario}" · Ctrl+C to stop',
  );
  await for (final request in server) {
    unawaited(_handle(request, options, state));
  }
}

Future<void> _handle(
  HttpRequest request,
  _Options options,
  _State state,
) async {
  final path = request.uri.path;
  final body = await utf8.decoder.bind(request).join();
  _log(request.method, path, body);
  if (options.delay > Duration.zero && request.method == 'POST') {
    await Future<void>.delayed(options.delay);
  }
  try {
    if (request.method == 'GET' && path.startsWith('/uploads/')) {
      return _sendImage(request.response, state.image);
    }
    if (request.method != 'POST') {
      return _sendJson(request.response, 404, {'error': 'not found'});
    }
    switch (options.scenario) {
      case 'error':
        return _sendJson(request.response, 500, {'error': 'mock failure'});
      case 'maintenance':
        return _sendJson(request.response, 503, {'error': 'maintenance'});
    }
    switch (path) {
      case '/opticimage':
        state.image = _imageOf(body);
        return _sendJson(request.response, 200, _reading(options.scenario));
      case '/answerArray':
        return _sendJson(request.response, 200, _answer(options.scenario));
      case '/examrequest':
        return _sendJson(request.response, 200, {'success': true});
    }
    return _sendJson(request.response, 404, {'error': 'unknown path $path'});
  } on Object catch (error) {
    stderr.writeln('  ! $error');
    return _sendJson(request.response, 500, {'error': '$error'});
  }
}

/// The `opticimage` answer: four columns of 40 answers with two blanks
/// (column 3 question 12, column 4 question 40), the image names, no exam yet.
Map<String, dynamic> _reading(String scenario) => {
  'success': scenario != 'noform',
  'mexamFound': null,
  'answersArray': scenario == 'noform' ? <Object?>[] : _answers(),
  'opticImageFileName': 'mock_read.jpg',
  'originalImageFileName': 'mock_original.jpg',
};

/// The `answerArray` answer: the exam document when it is recognised,
/// `false` when it is not (the request screen).
Map<String, dynamic> _answer(String scenario) => {
  'success': true,
  'mexamFound': scenario == 'found'
      ? {
          '_id': 'mock-exam-1',
          'name': 'Türkiye Geneli Deneme 6',
          'type': 'AYT',
          'publisherName': 'Örnek Yayınları',
        }
      : false,
  'answersArray': _answers(),
  'opticImageFileName': 'mock_read.jpg',
};

List<List<String?>> _answers() {
  const letters = ['A', 'B', 'C', 'D', 'E'];
  return [
    for (var column = 0; column < 4; column++)
      [
        for (var question = 0; question < 40; question++)
          (column == 2 && question == 11) || (column == 3 && question == 39)
              ? null
              : letters[(question + column) % letters.length],
      ],
  ];
}

List<int>? _imageOf(String body) {
  try {
    final json = jsonDecode(body);
    final image = json is Map ? json['image'] : null;
    return image is String ? base64Decode(image) : null;
  } on FormatException {
    return null;
  }
}

Future<void> _sendJson(HttpResponse response, int status, Object body) async {
  response
    ..statusCode = status
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(body));
  stdout.writeln('  → $status');
  await response.close();
}

Future<void> _sendImage(HttpResponse response, List<int>? image) async {
  if (image == null) {
    response.statusCode = 404;
    stdout.writeln('  → 404 (no photo uploaded yet)');
  } else {
    response
      ..statusCode = 200
      ..headers.contentType = ContentType('image', 'jpeg')
      ..add(image);
    stdout.writeln('  → 200 (${image.length} bytes)');
  }
  await response.close();
}

void _log(String method, String path, String body) {
  stdout.writeln('$method $path');
  if (body.isEmpty) return;
  try {
    final json = jsonDecode(body);
    if (json is Map && json['image'] is String) {
      json['image'] = '<base64, ${(json['image'] as String).length} chars>';
    }
    // The app sends the signed-in user's whole document (the legacy body);
    // print its id and field names only, never the personal values.
    if (json is Map && json['user'] is Map) {
      final user = json['user'] as Map;
      json['user'] = {'_id': user['_id'], 'fields': user.keys.toList()};
    }
    final text = const JsonEncoder.withIndent('  ').convert(json);
    stdout.writeln(text.length > 1200 ? '${text.substring(0, 1200)} …' : text);
  } on FormatException {
    stdout.writeln('  (${body.length} chars, not JSON)');
  }
}

class _State {
  List<int>? image;
}

class _Options {
  const _Options(this.scenario, this.port, this.lan, this.delay);

  final String scenario;
  final int port;
  final bool lan;
  final Duration delay;

  static _Options? parse(List<String> args) {
    var scenario = 'notfound';
    var port = 8787;
    var lan = false;
    var delay = Duration.zero;
    for (final arg in args) {
      if (arg == '--lan') {
        lan = true;
      } else if (arg.startsWith('--scenario=')) {
        scenario = arg.substring('--scenario='.length);
        if (!_scenarios.contains(scenario)) return null;
      } else if (arg.startsWith('--port=')) {
        final value = int.tryParse(arg.substring('--port='.length));
        if (value == null) return null;
        port = value;
      } else if (arg.startsWith('--delay=')) {
        final value = int.tryParse(arg.substring('--delay='.length));
        if (value == null) return null;
        delay = Duration(milliseconds: value);
      } else {
        return null;
      }
    }
    return _Options(scenario, port, lan, delay);
  }
}
