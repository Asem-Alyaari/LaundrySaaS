import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_client.dart';
import '../models/locker_dto.dart';

class LockerRepository {
  /// Fetch nearby laundries (معاسل) based on given latitude, longitude and optional radius (km).
  Future<List<LockerDto>> fetchNearby({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    final url = Uri.parse(
      '${ApiClient.apiHostUrl}/api/app/laundry/nearby',
    ).replace(queryParameters: {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'radiusKm': radius.toString(),
    });

    final response = await http
        .get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // ABP may wrap in { items: [...] } or return a bare list
      List<dynamic> data;
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded.containsKey('items')) {
        data = decoded['items'] as List<dynamic>;
      } else {
        data = [];
      }
      return data.map((e) => LockerDto.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      // Return empty list on error – UI will handle graceful fallback.
      return [];
    }
  }
}
