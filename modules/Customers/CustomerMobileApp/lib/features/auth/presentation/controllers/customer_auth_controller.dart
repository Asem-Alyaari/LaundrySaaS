import 'package:flutter/foundation.dart';
import '../../../../core/storage/session_storage.dart';
import '../../data/models/customer_auth_model.dart';
import '../../data/repositories/customer_auth_repository.dart';
import '../../domain/entities/customer_user.dart';

enum AuthMode {
  login,
  register,
}

class CustomerAuthController extends ChangeNotifier {
  final CustomerAuthRepository _repository = CustomerAuthRepository();

  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;
  String? _errorMessage;
  CustomerUser? _currentUser;
  bool _isGuest = false;

  AuthMode get authMode => _authMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CustomerUser? get currentUser => _currentUser;
  bool get isGuest => _isGuest;
  bool get isAuthenticated => _currentUser != null || _isGuest;

  CustomerAuthController() {
    checkSavedSession();
  }

  void switchMode(AuthMode mode) {
    if (_authMode != mode) {
      _authMode = mode;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Check if user has an existing saved session
  Future<void> checkSavedSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedUser = await _repository.getSavedSession();
      if (savedUser != null) {
        _currentUser = savedUser;
        _isGuest = false;
      } else {
        _isGuest = await SessionStorage.isGuestMode();
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign In with phone/email and password
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.login(
        CustomerLoginDto(
          identifier: identifier,
          password: password,
        ),
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _isGuest = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage ?? 'فشل تسجيل الدخول';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new customer
  Future<bool> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.register(
        CustomerRegisterDto(
          fullName: fullName,
          phoneNumber: phoneNumber,
          email: email,
          password: password,
        ),
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _isGuest = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage ?? 'فشل إنشاء الحساب';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Continue as a guest
  Future<void> continueAsGuest() async {
    _isGuest = true;
    _currentUser = null;
    await SessionStorage.setGuestMode(true);
    notifyListeners();
  }

  /// Sign out
  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _isGuest = false;
    _errorMessage = null;
    notifyListeners();
  }
}
