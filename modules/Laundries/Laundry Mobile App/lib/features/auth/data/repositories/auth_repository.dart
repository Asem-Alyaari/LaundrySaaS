import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_client.dart';
import '../models/login_response.dart';

class AuthRepository {
  /// Authenticate against ABP AuthServer OpenIddict endpoint.
  ///
  /// The tenant name is sent via query string (?__tenant=...) instead of
  /// an HTTP header because browsers enforce ISO-8859-1 on header values
  /// and reject Arabic / non-Latin characters.
  Future<LoginResponse> login({
    required String tenant,
    required String username,
    required String password,
  }) async {
    // Pass tenant via query string — ABP resolves it automatically
    final url = Uri.parse('${ApiClient.authServerUrl}/connect/token')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final body = {
      'grant_type': 'password',
      'client_id': 'LaundrySaaS_App',
      'username': username.trim(),
      'password': password,
      'scope': 'openid profile email offline_access LaundrySaaS',
    };

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept-Language': 'ar',
    };

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      } else {
        final dynamic responseData = _tryParseJson(response.body);
        final errorMsg = _extractErrorMessage(responseData ?? response.body);
        throw Exception(errorMsg);
      }
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('المغسلة') ||
          msg.contains('المستخدم') ||
          msg.contains('خطأ أثناء')) {
        rethrow;
      }
      throw Exception(
          'تعذر الاتصال بالخادم المركزي، تأكد من تشغيل السيرفر والاتصال بالشبكة');
    }
  }

  dynamic _tryParseJson(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map) {
      if (responseData['error_description'] != null) {
        final desc = responseData['error_description'].toString();
        if (desc.contains('Invalid username or password')) {
          return 'اسم المستخدم أو كلمة المرور غير صحيحة لهذه المغسلة';
        }
        if (desc.contains('Tenant not found')) {
          return 'اسم المغسلة غير مسجل في المنظومة، يرجى كتابة اسم المغسلة بشكل صحيح';
        }
        return desc;
      }
      if (responseData['error'] != null) {
        return responseData['error'].toString();
      }
    } else if (responseData is String) {
      if (responseData.contains('Tenant not found')) {
        return 'اسم المغسلة غير مسجل في المنظومة، يرجى كتابة اسم المغسلة بشكل صحيح';
      }
      if (responseData.contains('Invalid username or password')) {
        return 'اسم المستخدم أو كلمة المرور غير صحيحة لهذه المغسلة';
      }
    }
    return 'حدث خطأ أثناء محاولة تسجيل الدخول، يرجى مراجعة البيانات';
  }
}
