import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

// Conditional import: uses the stub (no-op) on web,
// and the native adapter (with dart:io SSL bypass) on native platforms.
import 'api_client_adapter_stub.dart'
    if (dart.library.io) 'api_client_adapter_native.dart' as adapter;

class ApiClient {
  /// Web ➜ http://localhost:44385 (avoids browser self-signed SSL block)
  /// Native ➜ https://localhost:44384
  static String get authServerUrl {
    if (kIsWeb) {
      return 'http://localhost:44385';
    }
    return 'https://localhost:44384';
  }

  static String get apiHostUrl {
    if (kIsWeb) {
      return 'http://localhost:44329';
    }
    return 'https://localhost:44328';
  }

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
