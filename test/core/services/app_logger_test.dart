import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:smap/core/services/app_logger.dart';

void main() {
  Logger capture(MemoryOutput output) => Logger(
    filter: ProductionFilter(),
    printer: SimplePrinter(colors: false),
    output: output,
  );

  test('an enabled logger prints the message with its name', () {
    final output = MemoryOutput();
    AppLogger(enabled: true, logger: capture(output))
      ..debug('hello', name: 'Test')
      ..info('info')
      ..warning('warn')
      ..error('bad', error: StateError('boom'));

    final lines = output.buffer.expand((e) => e.lines).join('\n');
    expect(lines, contains('[Test] hello'));
    expect(lines, contains('info'));
    expect(lines, contains('warn'));
    expect(lines, contains('bad'));
    expect(output.buffer, hasLength(4));
  });

  test('a disabled logger prints nothing and never builds the sink', () {
    final output = MemoryOutput();
    final logger = AppLogger(enabled: false, logger: capture(output))
      ..debug('secret token')
      ..error('secret token');

    expect(output.buffer, isEmpty);
    expect(logger.isEnabled, isFalse);
  });

  test('silent() is disabled', () {
    final logger = AppLogger.silent()..info('nothing');

    expect(logger.isEnabled, isFalse);
  });

  test('debug builds are enabled by default', () {
    expect(AppLogger().isEnabled, isTrue);
  });
}
