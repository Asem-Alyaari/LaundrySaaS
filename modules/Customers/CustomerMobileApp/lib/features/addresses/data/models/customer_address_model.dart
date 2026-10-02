import '../../domain/entities/customer_address.dart';

class CustomerAddressModel extends CustomerAddress {
  const CustomerAddressModel({
    required super.id,
    required super.title,
    required super.type,
    required super.latitude,
    required super.longitude,
    super.description,
    super.buildingOrFloor,
    super.deliveryNotes,
    super.isDefault,
    required super.createdAt,
  });

  factory CustomerAddressModel.fromEntity(CustomerAddress entity) {
    return CustomerAddressModel(
      id: entity.id,
      title: entity.title,
      type: entity.type,
      latitude: entity.latitude,
      longitude: entity.longitude,
      description: entity.description,
      buildingOrFloor: entity.buildingOrFloor,
      deliveryNotes: entity.deliveryNotes,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
    );
  }

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    AddressType parseType(String? val) {
      switch (val?.toLowerCase()) {
        case 'home':
          return AddressType.home;
        case 'work':
          return AddressType.work;
        default:
          return AddressType.other;
      }
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final rawType = json['addressType'] ?? json['type'];

    return CustomerAddressModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'العنوان',
      type: parseType(rawType as String?),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      description: json['description'] as String? ?? '',
      buildingOrFloor: json['buildingOrFloor'] as String?,
      deliveryNotes: json['deliveryNotes'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    String typeToString(AddressType t) {
      switch (t) {
        case AddressType.home:
          return 'home';
        case AddressType.work:
          return 'work';
        case AddressType.other:
          return 'other';
      }
    }

    return {
      'id': id,
      'title': title,
      'addressType': typeToString(type),
      'type': typeToString(type),
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'buildingOrFloor': buildingOrFloor,
      'deliveryNotes': deliveryNotes,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateUpdateDto() {
    String typeToString(AddressType t) {
      switch (t) {
        case AddressType.home:
          return 'home';
        case AddressType.work:
          return 'work';
        case AddressType.other:
          return 'other';
      }
    }

    return {
      'title': title,
      'addressType': typeToString(type),
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'buildingOrFloor': buildingOrFloor,
      'deliveryNotes': deliveryNotes,
      'isDefault': isDefault,
    };
  }
}
