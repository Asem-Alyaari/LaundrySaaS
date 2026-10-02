import 'dart:io';
import 'package:flutter/foundation.dart';
class ApiClient {
  /// Base host: localhost on Web, 10.0.2.2 on Android emulator, 127.0.0.1 on other native platforms
  static String get _host => kIsWeb
      ? 'localhost'
      : Platform.isAndroid
          ? '10.0.2.2'
          : '127.0.0.1';

  /// AuthServer URL
  static String get authServerUrl => 'http://$_host:44385';

  /// API Host URL
  static String get apiHostUrl => 'http://$_host:44329';
}
