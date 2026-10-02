import '../entities/customer_address.dart';

abstract class CustomerAddressRepository {
  /// جلب جميع عناوين العميل المحفوظة
  Future<List<CustomerAddress>> getAddresses();

  /// حفظ عنوان جديد أو تحديث عنوان قائم
  Future<CustomerAddress> saveAddress(CustomerAddress address);

  /// حذف عنوان محدد
  Future<bool> deleteAddress(String id);

  /// تعيين عنوان محدد كعنوان افتراضي
  Future<bool> setDefaultAddress(String id);
}
