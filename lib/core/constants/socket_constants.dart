import 'package:flutter/foundation.dart';

@immutable
final class SocketConstants {
  factory SocketConstants() => instance;

  const SocketConstants._internal();

  static const SocketConstants instance = SocketConstants._internal();

  final String webSocketAddress = 'ws://192.168.1.164:5000';
}
