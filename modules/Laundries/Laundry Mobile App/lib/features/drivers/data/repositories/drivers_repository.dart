import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_client.dart';
import '../models/driver_model.dart';

class DriversRepository {
  /// Fetch list of drivers with optional search filter and availability filter
  Future<List<DriverModel>> fetchDrivers({
    required String tenant,
    required String accessToken,
    String? laundryId,
    String? filter,
    bool? isAvailable,
  }) async {
    final queryParams = <String, String>{
      '__tenant': tenant.trim(),
      'MaxResultCount': '100',
    };

    if (laundryId != null && laundryId.isNotEmpty) {
      queryParams['LaundryId'] = laundryId;
    }
    if (filter != null && filter.trim().isNotEmpty) {
      queryParams['Filter'] = filter.trim();
    }
    if (isAvailable != null) {
      queryParams['IsAvailable'] = isAvailable.toString();
    }

    final url = Uri.parse('${ApiClient.apiHostUrl}/api/drivers/drivers')
        .replace(queryParameters: queryParams);

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Create a new driver
  Future<DriverModel> createDriver({
    required String tenant,
    required String accessToken,
    required CreateUpdateDriverDto dto,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/drivers/drivers')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(dto.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return DriverModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في حفظ بيانات المندوب'));
    }
  }

  /// Update an existing driver
  Future<DriverModel> updateDriver({
    required String tenant,
    required String accessToken,
    required String id,
    required CreateUpdateDriverDto dto,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/drivers/drivers/$id')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(dto.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return DriverModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في تحديث بيانات المندوب'));
    }
  }

  /// Toggle availability of a driver
  Future<void> toggleAvailability({
    required String tenant,
    required String accessToken,
    required String id,
    required bool isAvailable,
  }) async {
    final url = Uri.parse(
      '${ApiClient.apiHostUrl}/api/drivers/drivers/$id/toggle-availability',
    ).replace(queryParameters: {
      '__tenant': tenant.trim(),
      'isAvailable': isAvailable.toString(),
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          _extractErrorMessage(response.body, 'فشل في تغيير حالة توفر المندوب'));
    }
  }

  /// Delete a driver
  Future<void> deleteDriver({
    required String tenant,
    required String accessToken,
    required String id,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/drivers/drivers/$id')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractErrorMessage(response.body, 'فشل في حذف المندوب'));
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final errData = json.decode(body);
      if (errData is Map && errData['error'] is Map) {
        return errData['error']['message']?.toString() ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }
}
