import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_client.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/customer_user.dart';
import '../models/customer_auth_model.dart';

class CustomerAuthRepository {
  /// Authenticate customer using phone number and password
  Future<AuthResult> login(CustomerLoginDto dto) async {
    try {
      final url = Uri.parse('${ApiClient.authServerUrl}/connect/token');

      final body = {
        'grant_type': 'password',
        'client_id': 'LaundrySaaS_App',
        'username': dto.identifier.trim(),
        'password': dto.password,
        'scope': 'openid profile email offline_access LaundrySaaS',
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
              'Accept-Language': 'ar',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final token = data['access_token'] as String;

        // Fetch user profile using the token
        final userProfile = await _fetchUserProfile(token);

        await SessionStorage.saveToken(token);
        await SessionStorage.saveUserProfile(userProfile.toJson());
        await SessionStorage.setGuestMode(false);

        return AuthResult.success(token: token, user: userProfile);
      } else {
        final errorMsg = _extractErrorMessage(
          response.body,
          'رقم الجوال أو كلمة المرور غير صحيحة',
        );
        return AuthResult.failure(errorMsg);
      }
    } catch (e) {
      return AuthResult.failure(
        'تعذر الاتصال بالخادم. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
      );
    }
  }

  /// Register a new customer (creates Identity user + Customer entity)
  Future<AuthResult> register(CustomerRegisterDto dto) async {
    try {
      final url = Uri.parse('${ApiClient.apiHostUrl}/api/customers/customers/register');

      final body = json.encode({
        'fullName': dto.fullName.trim(),
        'phoneNumber': dto.phoneNumber.trim(),
        'email': dto.email.trim(),
        'password': dto.password,
      });

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Accept-Language': 'ar',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      final responseData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Registration succeeded, now auto-login to get a token
        final loginResult = await login(
          CustomerLoginDto(
            identifier: dto.phoneNumber.trim(),
            password: dto.password,
          ),
        );
        return loginResult;
      } else {
        final errorMsg = responseData['errorMessage'] as String?
            ?? _extractErrorMessage(response.body, 'فشل إنشاء الحساب. حاول مرة أخرى.');
        return AuthResult.failure(errorMsg);
      }
    } catch (e) {
      return AuthResult.failure(
        'تعذر الاتصال بالخادم. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
      );
    }
  }

  /// Fetch user profile from the API using the access token
  Future<CustomerUser> _fetchUserProfile(String token) async {
    try {
      final url = Uri.parse('${ApiClient.authServerUrl}/connect/userinfo');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return CustomerUser(
          id: data['sub'] as String? ?? '',
          fullName: data['name'] as String? ?? data['preferred_username'] as String? ?? '',
          phoneNumber: data['phone_number'] as String? ?? data['preferred_username'] as String? ?? '',
          email: data['email'] as String? ?? '',
          isGoogleLinked: false,
          creationTime: DateTime.now(),
        );
      }
    } catch (_) {}

    // Fallback if userinfo endpoint doesn't return full data
    return CustomerUser(
      id: '',
      fullName: '',
      phoneNumber: '',
      email: '',
      isGoogleLinked: false,
      creationTime: DateTime.now(),
    );
  }

  /// Read current session from local storage
  Future<CustomerUser?> getSavedSession() async {
    final isGuest = await SessionStorage.isGuestMode();
    if (isGuest) return null;

    final token = await SessionStorage.getToken();
    if (token == null || token.isEmpty) return null;

    final userMap = await SessionStorage.getUserProfile();
    if (userMap != null) {
      return CustomerUser.fromJson(userMap);
    }
    return null;
  }

  /// Sign out
  Future<void> logout() async {
    await SessionStorage.clearSession();
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final jsonMap = json.decode(body) as Map<String, dynamic>;
      if (jsonMap.containsKey('error_description')) {
        return jsonMap['error_description'] as String;
      }
      if (jsonMap.containsKey('error')) {
        final error = jsonMap['error'];
        if (error is Map && error.containsKey('message')) {
          return error['message'] as String;
        }
        return error.toString();
      }
      if (jsonMap.containsKey('message')) {
        return jsonMap['message'] as String;
      }
    } catch (_) {}
    return fallback;
  }
}
