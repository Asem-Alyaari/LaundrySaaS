import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/customer_address.dart';
import '../../domain/repositories/customer_address_repository.dart';
import '../models/customer_address_model.dart';

class CustomerAddressRepositoryImpl implements CustomerAddressRepository {
  static const String _storageKey = 'customer_saved_addresses_v1';

  @override
  Future<List<CustomerAddress>> getAddresses() async {
    // 1. محاولة جلب العناوين من السيرفر وقاعدة البيانات أولاً
    final userProfile = await SessionStorage.getUserProfile();
    final customerId = userProfile?['id'] as String?;
    final token = await SessionStorage.getToken();

    if (customerId != null && customerId.isNotEmpty && _isValidGuid(customerId)) {
      try {
        final url = Uri.parse('${ApiClient.apiHostUrl}/api/customers/customers/$customerId/addresses');
        final response = await http.get(
          url,
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final list = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
          final remoteAddresses = list
              .map((item) => CustomerAddressModel.fromJson(item as Map<String, dynamic>))
              .toList();

          // تحديث التخزين المؤقت المحلي
          await _saveToLocalCache(remoteAddresses);
          return remoteAddresses;
        }
      } catch (_) {
        // في حال انقطاع الشبكة، ننتقل للتخزين المحلي
      }
    }

    // 2. الرجوع للتخزين المحلي (Offline Cache)
    return _getFromLocalCache();
  }

  @override
  Future<CustomerAddress> saveAddress(CustomerAddress address) async {
    final userProfile = await SessionStorage.getUserProfile();
    final customerId = userProfile?['id'] as String?;
    final token = await SessionStorage.getToken();

    CustomerAddress savedEntity = address;

    // 1. إرسال الحفظ للباك اند إذا كان العميل مسجلاً
    if (customerId != null && customerId.isNotEmpty && _isValidGuid(customerId)) {
      try {
        final isUpdating = address.id.isNotEmpty && _isValidGuid(address.id);
        final url = isUpdating
            ? Uri.parse('${ApiClient.apiHostUrl}/api/customers/customers/addresses/${address.id}')
            : Uri.parse('${ApiClient.apiHostUrl}/api/customers/customers/$customerId/addresses');

        final dto = CustomerAddressModel.fromEntity(address).toCreateUpdateDto();

        final response = await (isUpdating
            ? http.put(
                url,
                headers: {
                  if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: json.encode(dto),
              )
            : http.post(
                url,
                headers: {
                  if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: json.encode(dto),
              )).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
          savedEntity = CustomerAddressModel.fromJson(data);
        }
      } catch (_) {}
    }

    // 2. تحديث التخزين المحلي فوراً
    final existing = await _getFromLocalCache();
    final isNew = savedEntity.id.isEmpty;
    final finalId = isNew ? 'addr_${DateTime.now().millisecondsSinceEpoch}' : savedEntity.id;
    final shouldBeDefault = savedEntity.isDefault || existing.isEmpty;

    final updatedEntity = savedEntity.copyWith(
      id: finalId,
      isDefault: shouldBeDefault,
    );

    final updatedList = <CustomerAddress>[];

    if (shouldBeDefault) {
      for (final item in existing) {
        if (item.id != finalId) {
          updatedList.add(item.copyWith(isDefault: false));
        }
      }
    } else {
      for (final item in existing) {
        if (item.id != finalId) {
          updatedList.add(item);
        }
      }
    }

    updatedList.insert(0, updatedEntity);
    await _saveToLocalCache(updatedList);

    return updatedEntity;
  }

  @override
  Future<bool> deleteAddress(String id) async {
    // حذف من السيرفر
    if (_isValidGuid(id)) {
      try {
        final token = await SessionStorage.getToken();
        final url = Uri.parse('${ApiClient.apiHostUrl}/api/customers/customers/addresses/$id');
        await http.delete(
          url,
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 8));
      } catch (_) {}
    }

    // حذف من التخزين المحلي
    final existing = await _getFromLocalCache();
    final filtered = existing.where((item) => item.id != id).toList();

    if (filtered.isNotEmpty && !filtered.any((item) => item.isDefault)) {
      filtered[0] = filtered.first.copyWith(isDefault: true);
    }

    await _saveToLocalCache(filtered);
    return true;
  }

  @override
  Future<bool> setDefaultAddress(String id) async {
    // تعيين في السيرفر
    if (_isValidGuid(id)) {
      try {
        final token = await SessionStorage.getToken();
        final url = Uri.parse('${ApiClient.apiHostUrl}/api/customers/customers/addresses/$id/set-default');
        await http.post(
          url,
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 8));
      } catch (_) {}
    }

    // تعيين في التخزين المحلي
    final existing = await _getFromLocalCache();
    final updatedList = existing.map((item) {
      return item.copyWith(isDefault: item.id == id);
    }).toList();

    await _saveToLocalCache(updatedList);
    return true;
  }

  Future<List<CustomerAddress>> _getFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson == null || rawJson.trim().isEmpty) return [];

      final list = json.decode(rawJson) as List<dynamic>;
      return list
          .map((item) => CustomerAddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveToLocalCache(List<CustomerAddress> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = addresses
        .map((e) => CustomerAddressModel.fromEntity(e).toJson())
        .toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  bool _isValidGuid(String str) {
    final guidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return guidRegex.hasMatch(str);
  }
}
