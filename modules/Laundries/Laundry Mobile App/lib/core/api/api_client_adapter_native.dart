import 'dart:io' show HttpClient;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Native (Android / iOS / Windows): allow self-signed dev certificates
void configureHttpClient(Dio dio) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );
}
