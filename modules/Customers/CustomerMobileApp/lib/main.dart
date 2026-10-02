import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';

/// تجاوز فحص شهادات SSL في بيئة التطوير المحلية للاتصال بـ ASP.NET Core Kestrel
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    HttpOverrides.global = DevHttpOverrides();
  }
  runApp(const CustomerApp());
}
