import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rest_api_package/rest_api_package.dart';
import 'package:studentmap/core/constants/api_constants.dart';

@immutable
final class RestApiHttpServiceClass {
  factory RestApiHttpServiceClass() => _instance;

  const RestApiHttpServiceClass._internal();

  static const RestApiHttpServiceClass _instance =
      RestApiHttpServiceClass._internal();

  static final RestApiHttpService _restApiHttpService = RestApiHttpService(
    Dio(),
    APIConstants.instance.apiBaseUrl,
  );

  static RestApiHttpService get restApiHttpService => _restApiHttpService;
}
