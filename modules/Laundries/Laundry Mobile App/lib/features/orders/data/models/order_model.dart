class OrderItemModel {
  final String id;
  final String orderId;
  final String serviceItemId;
  final String itemName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? notes;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.serviceItemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      serviceItemId: json['serviceItemId'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'serviceItemId': serviceItemId,
      'itemName': itemName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }
}

class CreateOrderItemDto {
  final String serviceItemId;
  final String itemName;
  final double unitPrice;
  int quantity;
  String? notes;

  CreateOrderItemDto({
    required this.serviceItemId,
    required this.itemName,
    required this.unitPrice,
    this.quantity = 1,
    this.notes,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'serviceItemId': serviceItemId,
      'itemName': itemName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'notes': notes,
    };
  }
}

class CreateOrderDto {
  final String laundryId;
  final bool isWalkIn;
  final String? customerId;
  final String customerName;
  final String? customerPhoneNumber;
  final int deliveryType;
  final int paymentStatus;
  final int paymentMethod;
  final double discountAmount;
  final double taxAmount;
  final String? notes;
  final List<CreateOrderItemDto> items;

  CreateOrderDto({
    required this.laundryId,
    required this.isWalkIn,
    this.customerId,
    required this.customerName,
    this.customerPhoneNumber,
    this.deliveryType = 1,
    this.paymentStatus = 1,
    this.paymentMethod = 1,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'laundryId': laundryId,
      'isWalkIn': isWalkIn,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'deliveryType': deliveryType,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'notes': notes,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderModel {
  final String id;
  final String? tenantId;
  final String laundryId;
  final String orderNumber;
  final bool isWalkIn;
  final String? customerId;
  final String customerName;
  final String? customerPhoneNumber;
  final int deliveryType;
  final String? driverId;
  final int status;
  final int paymentStatus;
  final int paymentMethod;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String? notes;
  final DateTime creationTime;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    this.tenantId,
    required this.laundryId,
    required this.orderNumber,
    required this.isWalkIn,
    this.customerId,
    required this.customerName,
    this.customerPhoneNumber,
    required this.deliveryType,
    this.driverId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    this.notes,
    required this.creationTime,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String?,
      laundryId: json['laundryId'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      isWalkIn: json['isWalkIn'] as bool? ?? true,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String? ?? '',
      customerPhoneNumber: json['customerPhoneNumber'] as String?,
      deliveryType: (json['deliveryType'] as num?)?.toInt() ?? 1,
      driverId: json['driverId'] as String?,
      status: (json['status'] as num?)?.toInt() ?? 1,
      paymentStatus: (json['paymentStatus'] as num?)?.toInt() ?? 1,
      paymentMethod: (json['paymentMethod'] as num?)?.toInt() ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: rawItems
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  String get statusArabic {
    switch (status) {
      case 1:
        return 'قيد الانتظار';
      case 2:
        return 'مؤكد';
      case 3:
        return 'تم الاستلام';
      case 4:
        return 'قيد الغسيل والمعالجة';
      case 5:
        return 'جاهز للتسليم';
      case 6:
        return 'مكتمل ومسلّم';
      case 7:
        return 'ملغي';
      default:
        return 'قيد المعالجة';
    }
  }

  String get paymentMethodArabic {
    switch (paymentMethod) {
      case 1:
        return 'نقداً (كاش)';
      case 2:
        return 'شبكة (مدى / بطاقة)';
      case 3:
        return 'تحويل بنكي';
      case 4:
        return 'دفع عند الاستلام';
      case 5:
        return 'آجل';
      default:
        return 'نقداً';
    }
  }

  String get paymentStatusArabic {
    switch (paymentStatus) {
      case 1:
        return 'غير مدفوع';
      case 2:
        return 'مدفوع بالكامل';
      case 3:
        return 'مدفوع جزئياً';
      default:
        return 'غير مدفوع';
    }
  }
}

class RegisteredCustomerModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? address;

  RegisteredCustomerModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.address,
  });

  factory RegisteredCustomerModel.fromJson(Map<String, dynamic> json) {
    String? addrStr;
    if (json['address'] is Map) {
      final addrMap = json['address'] as Map<String, dynamic>;
      final city = addrMap['city'] as String? ?? '';
      final district = addrMap['district'] as String? ?? '';
      addrStr = '$city - $district'.trim();
      if (addrStr == '-') addrStr = null;
    }
    return RegisteredCustomerModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: addrStr,
    );
  }
}
