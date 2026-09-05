import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_client.dart';
import '../models/laundry_dto.dart';

class LaundryRepository {
  /// Fetch the list of laundries for the current tenant.
  /// Returns the first laundry if exists, or null if no laundry is set up yet.
  Future<LaundryDto?> fetchCurrentLaundry({
    required String tenant,
    required String accessToken,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/app/laundry')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        if (items.isNotEmpty) {
          return LaundryDto.fromJson(items.first as Map<String, dynamic>);
        }
        return null; // No laundry set up yet
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Create a new laundry profile for the current tenant.
  Future<LaundryDto> createLaundry({
    required String tenant,
    required String accessToken,
    required CreateUpdateLaundryDto dto,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/app/laundry')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http
        .post(url, headers: headers, body: json.encode(dto.toJson()))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return LaundryDto.fromJson(data);
    } else {
      final errorBody = response.body;
      String msg = 'حدث خطأ أثناء حفظ بيانات المغسلة';
      try {
        final errData = json.decode(errorBody);
        if (errData is Map && errData['error'] is Map) {
          msg = errData['error']['message']?.toString() ?? msg;
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
