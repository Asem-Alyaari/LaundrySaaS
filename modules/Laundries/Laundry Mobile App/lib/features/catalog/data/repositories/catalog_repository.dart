import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_client.dart';
import '../models/service_item_model.dart';

class CatalogRepository {
  /// Fetch all categories (default ones and laundry-specific ones)
  Future<List<ServiceCategoryModel>> fetchCategories({
    required String tenant,
    required String accessToken,
    String? laundryId,
  }) async {
    final queryParams = <String, String>{'__tenant': tenant.trim()};
    if (laundryId != null && laundryId.isNotEmpty) {
      queryParams['laundryId'] = laundryId;
    }

    final url = Uri.parse('${ApiClient.apiHostUrl}/api/laundries/categories/all')
        .replace(queryParameters: queryParams);

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch service items with optional category filter and search term
  Future<List<ServiceItemModel>> fetchItems({
    required String tenant,
    required String accessToken,
    required String laundryId,
    String? categoryId,
    String? filter,
  }) async {
    final queryParams = <String, String>{
      '__tenant': tenant.trim(),
      'LaundryId': laundryId,
      'MaxResultCount': '100',
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['CategoryId'] = categoryId;
    }
    if (filter != null && filter.trim().isNotEmpty) {
      queryParams['Filter'] = filter.trim();
    }

    final url = Uri.parse('${ApiClient.apiHostUrl}/api/laundries/items')
        .replace(queryParameters: queryParams);

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map((e) => ServiceItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Create a new service item
  Future<ServiceItemModel> createItem({
    required String tenant,
    required String accessToken,
    required CreateUpdateServiceItemDto dto,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/laundries/items')
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
      return ServiceItemModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في حفظ الخدمة'));
    }
  }

  /// Update an existing service item
  Future<ServiceItemModel> updateItem({
    required String tenant,
    required String accessToken,
    required String id,
    required CreateUpdateServiceItemDto dto,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/laundries/items/$id')
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
      return ServiceItemModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في تحديث الخدمة'));
    }
  }

  /// Delete a service item
  Future<void> deleteItem({
    required String tenant,
    required String accessToken,
    required String id,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/laundries/items/$id')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractErrorMessage(response.body, 'فشل في حذف الخدمة'));
    }
  }

  /// Import ready-made default template catalog for the laundry
  Future<List<ServiceItemModel>> importTemplateCatalog({
    required String tenant,
    required String accessToken,
    required String laundryId,
  }) async {
    final url = Uri.parse(
            '${ApiClient.apiHostUrl}/api/laundries/items/import-template/$laundryId')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic body = json.decode(response.body);
      if (body is List) {
        return body
            .map((e) => ServiceItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception(
          _extractErrorMessage(response.body, 'فشل في استيراد الخدمات الجاهزة'));
    }
  }

  /// Create a new category / department
  Future<ServiceCategoryModel> createCategory({
    required String tenant,
    required String accessToken,
    required String name,
    required String laundryId,
    String? icon,
    String? color,
  }) async {
    final url = Uri.parse('${ApiClient.apiHostUrl}/api/laundries/categories')
        .replace(queryParameters: {'__tenant': tenant.trim()});

    final body = {
      'name': name.trim(),
      'laundryId': laundryId,
      'icon': icon,
      'color': color,
      'displayOrder': 0,
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(body),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return ServiceCategoryModel.fromJson(data);
    } else {
      throw Exception(_extractErrorMessage(response.body, 'فشل في إضافة القسم'));
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
