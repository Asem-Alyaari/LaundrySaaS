class AddressDto {
  final String city;
  final String district;
  final String street;
  final String buildingNumber;

  AddressDto({
    required this.city,
    required this.district,
    required this.street,
    required this.buildingNumber,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      street: json['street'] as String? ?? '',
      buildingNumber: json['buildingNumber'] as String? ?? '',
    );
  }
}

class LaundryDto {
  final String id;
  final String name;
  final String phoneNumber;
  final AddressDto address;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  LaundryDto({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isActive,
  });

  factory LaundryDto.fromJson(Map<String, dynamic> json) {
    return LaundryDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: AddressDto.fromJson(
          json['address'] as Map<String, dynamic>? ?? {}),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class CreateUpdateLaundryDto {
  final String name;
  final String phoneNumber;
  final CreateUpdateAddressDto address;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  CreateUpdateLaundryDto({
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.latitude,
    this.longitude,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
    };
  }
}

class CreateUpdateAddressDto {
  final String city;
  final String district;
  final String street;
  final String buildingNumber;

  CreateUpdateAddressDto({
    required this.city,
    required this.district,
    required this.street,
    required this.buildingNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'district': district,
      'street': street,
      'buildingNumber': buildingNumber,
    };
  }
}
