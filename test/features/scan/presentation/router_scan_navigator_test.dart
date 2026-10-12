import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_navigator.dart';

/// Records how the scan leaves its route.
class _RecordingRouter extends Fake implements StackRouter {
  final calls = <String>[];

  @override
  void pop<T extends Object?>([T? result]) => calls.add('pop');

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) async {
    calls.add('maybePop');
    return true;
  }
}

void main() {
  test('close pops the scan route without asking its PopScope again', () {
    // Every stage blocks Back with a PopScope that calls close(); asking it
    // again (maybePop) looped forever and froze the app on Kapat.
    final router = _RecordingRouter();
    RouterScanNavigator(router).close();
    expect(router.calls, ['pop']);
  });
}
