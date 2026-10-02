class CustomerUser {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String? avatarUrl;
  final bool isGoogleLinked;
  final DateTime creationTime;

  const CustomerUser({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    this.avatarUrl,
    this.isGoogleLinked = false,
    required this.creationTime,
  });

  CustomerUser copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    bool? isGoogleLinked,
    DateTime? creationTime,
  }) {
    return CustomerUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGoogleLinked: isGoogleLinked ?? this.isGoogleLinked,
      creationTime: creationTime ?? this.creationTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarUrl': avatarUrl,
      'isGoogleLinked': isGoogleLinked,
      'creationTime': creationTime.toIso8601String(),
    };
  }

  factory CustomerUser.fromJson(Map<String, dynamic> json) {
    return CustomerUser(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      isGoogleLinked: json['isGoogleLinked'] as bool? ?? false,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
