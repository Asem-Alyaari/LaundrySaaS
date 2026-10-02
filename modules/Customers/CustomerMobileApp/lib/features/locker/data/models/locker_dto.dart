/// Represents a laundry (معسلة) returned from the backend.
class LockerDto {
  final String id;
  final String name;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final String address;
  final bool isActive;

  LockerDto({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isActive,
  });

  factory LockerDto.fromJson(Map<String, dynamic> json) {
    // Build a readable address from the nested Address object
    final addressObj = json['address'] as Map<String, dynamic>?;
    String addressStr = '';
    if (addressObj != null) {
      final parts = [
        addressObj['city'] as String? ?? '',
        addressObj['district'] as String? ?? '',
        addressObj['street'] as String? ?? '',
      ].where((s) => s.isNotEmpty && s != 'غير محدد');
      addressStr = parts.join(', ');
    }

    return LockerDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: addressStr,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'isActive': isActive,
      };
}
