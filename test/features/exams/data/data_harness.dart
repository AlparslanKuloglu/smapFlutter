import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/network/network_service.dart';

import '../../../core/network/fake_adapter.dart';

/// A [NetworkService] over [adapter] with an in-memory cookie jar. Shared by
/// the data-layer tests of exams, analytics, lessons and cards.
NetworkService networkOver(FakeAdapter adapter) => NetworkService(
  config: AppConfig.resolve(),
  cookieJar: CookieJar(),
  logTraffic: false,
  httpClientAdapter: adapter,
);

/// An adapter answering by path: [routes] maps a request path to the JSON
/// body (or a function building the whole response). Unknown paths answer 404.
FakeAdapter routedAdapter(
  Map<String, Object? Function(RequestOptions options)> routes,
) => FakeAdapter((options) {
  final route = routes[options.path];
  if (route == null) return jsonResponse({'error': 'no route'}, status: 404);
  final body = route(options);
  return body is ResponseBody ? body : jsonResponse(body);
});

/// An adapter that fails like a phone without a connection.
FakeAdapter offlineAdapter() => FakeAdapter.failing(
  (options) => DioException.connectionError(
    requestOptions: options,
    reason: 'offline',
    error: const SocketException('Failed host lookup'),
  ),
);
