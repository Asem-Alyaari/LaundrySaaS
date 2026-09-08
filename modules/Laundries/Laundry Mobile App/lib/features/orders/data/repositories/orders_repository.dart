import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/order_model.dart';

class OrdersRepository {
  /// Create / Issue a new invoice/order
  Future<OrderModel> createOrder({
    required String tenant,
    required String accessToken,
    required CreateOrderDto dto,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}${ApiEndpoints.orders}')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(dto.toJson()),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في إنشاء الفاتورة'));
    }
  }

  /// Fetch orders for a specific laundry
  Future<List<OrderModel>> fetchOrders({
    required String tenant,
    required String accessToken,
    required String laundryId,
    int? status,
    String? filter,
  }) async {
    final queryParams = <String, String>{
      '__tenant': tenant.trim(),
      'LaundryId': laundryId,
      'MaxResultCount': '50',
    };

    if (status != null) {
      queryParams['Status'] = status.toString();
    }
    if (filter != null && filter.trim().isNotEmpty) {
      queryParams['Filter'] = filter.trim();
    }

    final url = Uri.parse('${ApiClient.apiHostUrl}${ApiEndpoints.orders}')
        .replace(queryParameters: queryParams);

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Search registered customers in the system
  Future<List<RegisteredCustomerModel>> searchCustomers({
    required String tenant,
    required String accessToken,
    String? filter,
  }) async {
    final queryParams = <String, String>{
      '__tenant': tenant.trim(),
    };
    if (filter != null && filter.trim().isNotEmpty) {
      queryParams['filter'] = filter.trim();
    }

    final url = Uri.parse('${ApiClient.apiHostUrl}${ApiEndpoints.customers}/search')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic body = json.decode(utf8.decode(response.bodyBytes));
        if (body is List) {
          return body
              .map((e) => RegisteredCustomerModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Update order / invoice status
  Future<OrderModel> updateOrderStatus({
    required String tenant,
    required String accessToken,
    required String orderId,
    required int status,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}${ApiEndpoints.orders}/$orderId/status')
        .replace(queryParameters: {
      '__tenant': tenant.trim(),
      'status': status.toString(),
    });

    final response = await http.put(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في تحديث حالة الفاتورة'));
    }
  }

  /// Record payment on order and optionally deliver
  Future<OrderModel> recordPayment({
    required String tenant,
    required String accessToken,
    required String orderId,
    required double amount,
    required int paymentMethod,
    bool markAsDelivered = false,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}${ApiEndpoints.orders}/$orderId/pay')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final dto = RecordOrderPaymentDto(
      amount: amount,
      paymentMethod: paymentMethod,
      markAsDelivered: markAsDelivered,
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(dto.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في تسجيل الدفعة والتسليم'));
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final errData = json.decode(utf8.decode(utf8.encode(body)));
      if (errData is Map && errData['error'] is Map) {
        return errData['error']['message']?.toString() ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }
}
