import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  bool _rememberMe = true;
  String? _tenantName;
  String? _userName;
  String? _accessToken;
  String? _laundryId;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get rememberMe => _rememberMe;
  String? get tenantName => _tenantName;
  String? get userName => _userName;
  String? get accessToken => _accessToken;
  String? get laundryId => _laundryId;

  void setLaundryId(String id) {
    _laundryId = id;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Perform real sign-in with tenant name / username / password against backend
  Future<bool> login({
    required String tenant,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(
        tenant: tenant,
        username: username,
        password: password,
      );

      _isAuthenticated = true;
      _tenantName = tenant.trim();
      _userName = username.trim();
      _accessToken = response.accessToken;

      // Persist session if remember me is active
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('laundry_saved_tenant', _tenantName!);
        await prefs.setString('laundry_saved_user', _userName!);
        await prefs.setString('laundry_access_token', _accessToken!);
        await prefs.setBool('laundry_is_logged_in', true);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }

  /// Logout and clear stored session
  Future<void> logout() async {
    _isAuthenticated = false;
    _tenantName = null;
    _userName = null;
    _accessToken = null;
    _laundryId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('laundry_is_logged_in');
    await prefs.remove('laundry_access_token');
    notifyListeners();
  }
}
