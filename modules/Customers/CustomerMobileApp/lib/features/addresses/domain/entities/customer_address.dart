import 'package:flutter/material.dart';

enum AddressType {
  home,
  work,
  other,
}

class CustomerAddress {
  final String id;
  final String title;
  final AddressType type;
  final double latitude;
  final double longitude;
  final String description;
  final String? buildingOrFloor;
  final String? deliveryNotes;
  final bool isDefault;
  final DateTime createdAt;

  const CustomerAddress({
    required this.id,
    required this.title,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.description = '',
    this.buildingOrFloor,
    this.deliveryNotes,
    this.isDefault = false,
    required this.createdAt,
  });

  /// ملخص العنوان للقراءة السريعة
  String get shortSummary {
    if (description.trim().isNotEmpty) {
      return description;
    }
    return 'موقع على الخريطة (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
  }

  /// العنوان الكامل المفصل للتوصيل
  String get fullAddress {
    final buffer = StringBuffer();
    if (description.trim().isNotEmpty) {
      buffer.write(description.trim());
    } else {
      buffer.write('إحداثيات: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}');
    }
    if (buildingOrFloor != null && buildingOrFloor!.trim().isNotEmpty) {
      buffer.write(' - $buildingOrFloor');
    }
    return buffer.toString();
  }

  /// اسم نوع العنوان بالعربية
  String get typeLabel {
    switch (type) {
      case AddressType.home:
        return 'المنزل';
      case AddressType.work:
        return 'العمل';
      case AddressType.other:
        return 'أخرى';
    }
  }

  /// الأيقونة المناسبة لنوع العنوان
  IconData get typeIcon {
    switch (type) {
      case AddressType.home:
        return Icons.home_rounded;
      case AddressType.work:
        return Icons.business_rounded;
      case AddressType.other:
        return Icons.location_on_rounded;
    }
  }

  CustomerAddress copyWith({
    String? id,
    String? title,
    AddressType? type,
    double? latitude,
    double? longitude,
    String? description,
    String? buildingOrFloor,
    String? deliveryNotes,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      buildingOrFloor: buildingOrFloor ?? this.buildingOrFloor,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
