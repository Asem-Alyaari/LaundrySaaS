class LaundryReportSummaryModel {
  final int totalOrdersCount;
  final int totalItemsCount;
  final double totalSales;
  final double totalPaid;
  final double totalRemaining;
  final double totalDiscount;
  final double totalTax;

  LaundryReportSummaryModel({
    required this.totalOrdersCount,
    required this.totalItemsCount,
    required this.totalSales,
    required this.totalPaid,
    required this.totalRemaining,
    required this.totalDiscount,
    required this.totalTax,
  });

  factory LaundryReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return LaundryReportSummaryModel(
      totalOrdersCount: (json['totalOrdersCount'] as num?)?.toInt() ?? 0,
      totalItemsCount: (json['totalItemsCount'] as num?)?.toInt() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      totalRemaining: (json['totalRemaining'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['totalTax'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentBreakdownModel {
  final double cashAmount;
  final double cardAmount;
  final double transferAmount;
  final double laterAmount;

  PaymentBreakdownModel({
    required this.cashAmount,
    required this.cardAmount,
    required this.transferAmount,
    required this.laterAmount,
  });

  factory PaymentBreakdownModel.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdownModel(
      cashAmount: (json['cashAmount'] as num?)?.toDouble() ?? 0.0,
      cardAmount: (json['cardAmount'] as num?)?.toDouble() ?? 0.0,
      transferAmount: (json['transferAmount'] as num?)?.toDouble() ?? 0.0,
      laterAmount: (json['laterAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get totalCollected => cashAmount + cardAmount + transferAmount;
}

class StatusBreakdownModel {
  final int pendingCount;
  final int processingCount;
  final int readyCount;
  final int deliveredCount;
  final int cancelledCount;

  StatusBreakdownModel({
    required this.pendingCount,
    required this.processingCount,
    required this.readyCount,
    required this.deliveredCount,
    required this.cancelledCount,
  });

  factory StatusBreakdownModel.fromJson(Map<String, dynamic> json) {
    return StatusBreakdownModel(
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      processingCount: (json['processingCount'] as num?)?.toInt() ?? 0,
      readyCount: (json['readyCount'] as num?)?.toInt() ?? 0,
      deliveredCount: (json['deliveredCount'] as num?)?.toInt() ?? 0,
      cancelledCount: (json['cancelledCount'] as num?)?.toInt() ?? 0,
    );
  }

  int get totalActive => pendingCount + processingCount + readyCount;
}

class TopServiceItemModel {
  final String serviceName;
  final int quantity;
  final double totalAmount;
  final double percentage;

  TopServiceItemModel({
    required this.serviceName,
    required this.quantity,
    required this.totalAmount,
    required this.percentage,
  });

  factory TopServiceItemModel.fromJson(Map<String, dynamic> json) {
    return TopServiceItemModel(
      serviceName: json['serviceName'] as String? ?? 'خدمة',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OutstandingDebtModel {
  final String orderId;
  final String orderNumber;
  final String customerName;
  final String? customerPhoneNumber;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? creationTime;
  final int daysPending;

  OutstandingDebtModel({
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    this.customerPhoneNumber,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    this.creationTime,
    required this.daysPending,
  });

  factory OutstandingDebtModel.fromJson(Map<String, dynamic> json) {
    DateTime? createdDate;
    if (json['creationTime'] != null) {
      createdDate = DateTime.tryParse(json['creationTime'].toString());
    }

    return OutstandingDebtModel(
      orderId: json['orderId'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: json['customerName'] as String? ?? 'عميل',
      customerPhoneNumber: json['customerPhoneNumber'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      creationTime: createdDate,
      daysPending: (json['daysPending'] as num?)?.toInt() ?? 0,
    );
  }
}

class LaundryReportModel {
  final LaundryReportSummaryModel summary;
  final PaymentBreakdownModel paymentBreakdown;
  final StatusBreakdownModel statusBreakdown;
  final List<TopServiceItemModel> topServices;
  final List<OutstandingDebtModel> outstandingDebts;

  LaundryReportModel({
    required this.summary,
    required this.paymentBreakdown,
    required this.statusBreakdown,
    required this.topServices,
    required this.outstandingDebts,
  });

  factory LaundryReportModel.fromJson(Map<String, dynamic> json) {
    return LaundryReportModel(
      summary: json['summary'] != null
          ? LaundryReportSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : LaundryReportSummaryModel(
              totalOrdersCount: 0,
              totalItemsCount: 0,
              totalSales: 0.0,
              totalPaid: 0.0,
              totalRemaining: 0.0,
              totalDiscount: 0.0,
              totalTax: 0.0,
            ),
      paymentBreakdown: json['paymentBreakdown'] != null
          ? PaymentBreakdownModel.fromJson(json['paymentBreakdown'] as Map<String, dynamic>)
          : PaymentBreakdownModel(
              cashAmount: 0.0,
              cardAmount: 0.0,
              transferAmount: 0.0,
              laterAmount: 0.0,
            ),
      statusBreakdown: json['statusBreakdown'] != null
          ? StatusBreakdownModel.fromJson(json['statusBreakdown'] as Map<String, dynamic>)
          : StatusBreakdownModel(
              pendingCount: 0,
              processingCount: 0,
              readyCount: 0,
              deliveredCount: 0,
              cancelledCount: 0,
            ),
      topServices: (json['topServices'] as List<dynamic>?)
              ?.map((e) => TopServiceItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      outstandingDebts: (json['outstandingDebts'] as List<dynamic>?)
              ?.map((e) => OutstandingDebtModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
