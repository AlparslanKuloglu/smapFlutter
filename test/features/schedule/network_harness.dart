import 'package:cookie_jar/cookie_jar.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';

import '../../core/network/fake_adapter.dart';

/// A [NetworkService] on a scripted adapter, for the repository tests of the
/// schedule, account and coach data layers.
NetworkService buildNetwork(HttpClientAdapter adapter) => NetworkService(
  config: AppConfig.resolve(),
  cookieJar: CookieJar(),
  logTraffic: false,
  httpClientAdapter: adapter,
);

/// A backend that answers by `METHOD path`: [routes] maps it to a body
/// (`Object?` is JSON-encoded) or to a [ResponseBody] for full control.
FakeAdapter routedBackend(Map<String, Object?> routes, {int status = 200}) =>
    FakeAdapter((options) {
      final key = '${options.method} ${options.path}';
      final answer = routes[key];
      if (answer is ResponseBody) return answer;
      return jsonResponse(answer, status: status);
    });

/// The failure of [result]; fails the test when it is a value.
AppException failureOf<T>(Either<AppException, T> result) =>
    result.leftOrNull ?? fail('expected a failure, got $result');
