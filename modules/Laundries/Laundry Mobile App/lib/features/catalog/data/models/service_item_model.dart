class ServiceCategoryModel {
  final String id;
  final String name;
  final String laundryId;
  final String? icon;
  final String? color;
  final int displayOrder;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.laundryId,
    this.icon,
    this.color,
    this.displayOrder = 0,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      laundryId: json['laundryId'] as String? ?? '',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'laundryId': laundryId,
      'icon': icon,
      'color': color,
      'displayOrder': displayOrder,
    };
  }
}

class ServiceItemModel {
  final String id;
  final String name;
  final double price;
  final String categoryId;
  final String laundryId;
  final bool isActive;
  final String unit;
  final double durationHours;
  final String? description;
  final String? icon;

  ServiceItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.laundryId,
    this.isActive = true,
    this.unit = 'قطعة',
    this.durationHours = 0,
    this.description,
    this.icon,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] as String? ?? '',
      laundryId: json['laundryId'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      unit: json['unit'] as String? ?? 'قطعة',
      durationHours: (json['durationHours'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }

  ServiceItemModel copyWith({
    String? id,
    String? name,
    double? price,
    String? categoryId,
    String? laundryId,
    bool? isActive,
    String? unit,
    double? durationHours,
    String? description,
    String? icon,
  }) {
    return ServiceItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      laundryId: laundryId ?? this.laundryId,
      isActive: isActive ?? this.isActive,
      unit: unit ?? this.unit,
      durationHours: durationHours ?? this.durationHours,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }
}

class CreateUpdateServiceItemDto {
  final String name;
  final double price;
  final String categoryId;
  final String laundryId;
  final bool isActive;
  final String unit;
  final double durationHours;
  final String? description;
  final String? icon;

  CreateUpdateServiceItemDto({
    required this.name,
    required this.price,
    required this.categoryId,
    required this.laundryId,
    this.isActive = true,
    this.unit = 'قطعة',
    this.durationHours = 0,
    this.description,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'categoryId': categoryId,
      'laundryId': laundryId,
      'isActive': isActive,
      'unit': unit,
      'durationHours': durationHours,
      'description': description,
      'icon': icon,
    };
  }
}
