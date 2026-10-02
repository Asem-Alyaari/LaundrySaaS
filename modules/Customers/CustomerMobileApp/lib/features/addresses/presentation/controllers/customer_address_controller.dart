import 'package:flutter/foundation.dart';
import '../../data/repositories/customer_address_repository_impl.dart';
import '../../domain/entities/customer_address.dart';
import '../../domain/repositories/customer_address_repository.dart';

class CustomerAddressController extends ChangeNotifier {
  final CustomerAddressRepository _repository;

  List<CustomerAddress> _addresses = [];
  CustomerAddress? _selectedAddress;
  bool _isLoading = false;
  String? _errorMessage;

  CustomerAddressController({CustomerAddressRepository? repository})
      : _repository = repository ?? CustomerAddressRepositoryImpl() {
    loadAddresses();
  }

  List<CustomerAddress> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// العنوان الافتراضي المحدد كعنوان رئيسي
  CustomerAddress? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  /// العنوان النشط المحدد للطلب الحالي
  CustomerAddress? get selectedAddress => _selectedAddress ?? defaultAddress;

  /// تحميل العناوين من المستودع
  Future<void> loadAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addresses = await _repository.getAddresses();
      // تحديث العنوان المحدد
      if (_addresses.isNotEmpty) {
        if (_selectedAddress != null) {
          final exists = _addresses.any((a) => a.id == _selectedAddress!.id);
          if (!exists) {
            _selectedAddress = defaultAddress;
          } else {
            _selectedAddress = _addresses.firstWhere((a) => a.id == _selectedAddress!.id);
          }
        } else {
          _selectedAddress = defaultAddress;
        }
      } else {
        _selectedAddress = null;
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل العناوين';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة أو تحديث عنوان
  Future<bool> saveAddress(CustomerAddress address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final saved = await _repository.saveAddress(address);
      await loadAddresses();
      _selectedAddress = saved;
      return true;
    } catch (e) {
      _errorMessage = 'فشل حفظ العنوان';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف عنوان
  Future<bool> deleteAddress(String id) async {
    try {
      final success = await _repository.deleteAddress(id);
      if (success) {
        if (_selectedAddress?.id == id) {
          _selectedAddress = null;
        }
        await loadAddresses();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'فشل حذف العنوان';
      notifyListeners();
      return false;
    }
  }

  /// تعيين عنوان كافتراضي
  Future<bool> setDefault(String id) async {
    try {
      final success = await _repository.setDefaultAddress(id);
      if (success) {
        await loadAddresses();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'فشل تعيين العنوان كافتراضي';
      notifyListeners();
      return false;
    }
  }

  /// اختيار عنوان محدد لعملية التوصيل الحالية
  void selectAddress(CustomerAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }
}
