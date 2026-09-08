import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/laundry_report_model.dart';

class ReportsRepository {
  /// Fetch aggregated report for a laundry
  Future<LaundryReportModel> fetchReport({
    required String tenant,
    required String accessToken,
    required String laundryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{
      '__tenant': tenant.trim(),
      'LaundryId': laundryId,
    };

    if (startDate != null) {
      queryParams['StartDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['EndDate'] = endDate.toIso8601String();
    }

    final url = Uri.parse('${ApiClient.apiHostUrl}${ApiEndpoints.orderReport}')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return LaundryReportModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في تحميل بيانات التقارير'));
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final jsonMap = json.decode(body) as Map<String, dynamic>;
      if (jsonMap.containsKey('error')) {
        final error = jsonMap['error'];
        if (error is Map && error.containsKey('message')) {
          return error['message'] as String;
        }
      }
      if (jsonMap.containsKey('message')) {
        return jsonMap['message'] as String;
      }
    } catch (_) {}
    return fallback;
  }
}
