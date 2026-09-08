import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

// Conditional import: uses the stub (no-op) on web,
// and the native adapter (with dart:io SSL bypass) on native platforms.
import 'api_client_adapter_stub.dart'
    if (dart.library.io) 'api_client_adapter_native.dart' as adapter;

import 'dart:io' show Platform;

class ApiClient {
  /// Base host: localhost on Web, 127.0.0.1 on Native (matching adb reverse forwarding)
  static String get _host => kIsWeb ? 'localhost' : '127.0.0.1';

  /// AuthServer URL
  static String get authServerUrl => 'http://$_host:44385';

  /// API Host URL
  static String get apiHostUrl => 'http://$_host:44329';

  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            validateStatus: (status) => status != null && status < 500,
          ),
        ) {
    // Configure platform-specific HTTP adapter (SSL bypass on native, no-op on web)
    adapter.configureHttpClient(_dio);
  }

  Dio get dio => _dio;
}
