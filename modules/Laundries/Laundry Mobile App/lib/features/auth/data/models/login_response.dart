class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String? idToken;
  final String? refreshToken;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.idToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int? ?? 3600,
      idToken: json['id_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
  }
}
