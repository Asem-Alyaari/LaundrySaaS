import '../../domain/entities/customer_user.dart';

class CustomerLoginDto {
  final String identifier; // Phone number
  final String password;

  const CustomerLoginDto({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
    };
  }
}

class CustomerRegisterDto {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;

  const CustomerRegisterDto({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
    };
  }
}


class AuthResult {
  final bool isSuccess;
  final String? token;
  final CustomerUser? user;
  final String? errorMessage;

  const AuthResult({
    required this.isSuccess,
    this.token,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success({required String token, required CustomerUser user}) {
    return AuthResult(
      isSuccess: true,
      token: token,
      user: user,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult(
      isSuccess: false,
      errorMessage: error,
    );
  }
}
