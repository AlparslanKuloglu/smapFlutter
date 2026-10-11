import 'package:dio/dio.dart';

import 'package:smap/core/network/log_masker.dart';
import 'package:smap/core/services/app_logger.dart';

/// Logs requests and responses through [AppLogger] with credentials masked
/// (see [LogMasker]). `NetworkService` adds it only in debug builds; it does
/// nothing useful in release because the logger is silent there.
final class MaskingLogInterceptor extends Interceptor {
  MaskingLogInterceptor(this._logger, {LogMasker masker = const LogMasker()})
    : _masker = masker;

  static const _startKey = 'log.startedAt';
  static const _name = 'Network';

  final AppLogger _logger;
  final LogMasker _masker;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    _logger.debug(
      '--> ${options.method} ${_masker.maskUri(options.uri)}\n'
      'headers: ${_masker.maskHeaders(options.headers)}\n'
      'body: ${_masker.maskBody(options.data)}',
      name: _name,
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      '<-- ${response.statusCode} ${response.requestOptions.method} '
      '${_masker.maskUri(response.requestOptions.uri)} (${_elapsed(response.requestOptions)})\n'
      'body: ${_masker.maskBody(response.data)}',
      name: _name,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    _logger.warning(
      '<-- ${err.type.name} ${response?.statusCode ?? ''} '
      '${err.requestOptions.method} ${_masker.maskUri(err.requestOptions.uri)} '
      '(${_elapsed(err.requestOptions)})\n'
      'body: ${_masker.maskBody(response?.data)}',
      name: _name,
    );
    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final started = options.extra[_startKey];
    if (started is! int) return '?';
    return '${DateTime.now().millisecondsSinceEpoch - started} ms';
  }
}
