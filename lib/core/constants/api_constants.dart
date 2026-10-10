import 'package:flutter/foundation.dart';

@immutable
final class APIConstants {
  factory APIConstants() => instance;

  const APIConstants._internal();

  static const APIConstants instance = APIConstants._internal();

  /// TODO : API BASE URL Sonunda '/' olacak
  /// It must be end with '/'
  ///
  final String apiBaseUrl = 'https://wfdsvfsdg.com/';
}
