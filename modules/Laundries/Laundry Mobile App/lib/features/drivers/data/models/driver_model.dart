class DriverModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String vehicleInfo;
  final bool isAvailable;
  final String? laundryId;
  final DateTime? creationTime;

  DriverModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.vehicleInfo,
    this.isAvailable = true,
    this.laundryId,
    this.creationTime,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      vehicleInfo: json['vehicleInfo'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      laundryId: json['laundryId'] as String?,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'vehicleInfo': vehicleInfo,
      'isAvailable': isAvailable,
      'laundryId': laundryId,
      'creationTime': creationTime?.toIso8601String(),
    };
  }

  DriverModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? vehicleInfo,
    bool? isAvailable,
    String? laundryId,
    DateTime? creationTime,
  }) {
    return DriverModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      isAvailable: isAvailable ?? this.isAvailable,
      laundryId: laundryId ?? this.laundryId,
      creationTime: creationTime ?? this.creationTime,
    );
  }
}

class CreateUpdateDriverDto {
  final String fullName;
  final String phoneNumber;
  final String vehicleInfo;
  final bool isAvailable;
  final String? laundryId;

  CreateUpdateDriverDto({
    required this.fullName,
    required this.phoneNumber,
    required this.vehicleInfo,
    this.isAvailable = true,
    this.laundryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'vehicleInfo': vehicleInfo,
      'isAvailable': isAvailable,
      if (laundryId != null && laundryId!.isNotEmpty) 'laundryId': laundryId,
    };
  }
}

class DriverStats {
  final int total;
  final int available;
  final int unavailable;

  DriverStats({
    required this.total,
    required this.available,
    required this.unavailable,
  });
}
