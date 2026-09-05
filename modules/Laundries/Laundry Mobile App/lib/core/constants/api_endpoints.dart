/// Centralized API endpoint constants matching LaundrySaaS ABP Backend
class ApiEndpoints {
  // Base URLs
  static const String devBaseUrl = 'https://localhost:44328';
  static const String emulatorBaseUrl = 'http://10.0.2.2:44328';

  // Multi-Tenancy Headers
  static const String tenantHeader = '__tenant';

  // Auth & Token
  static const String login = '/connect/token';
  static const String profile = '/api/account/my-profile';

  // Orders
  static const String orders = '/api/orders/orders';

  // Laundries & Services Catalog
  static const String laundries = '/api/laundries/laundries';
  static const String categories = '/api/laundries/categories';
  static const String serviceItems = '/api/laundries/items';

  // Customers
  static const String customers = '/api/customers/customers';

  // Drivers
  static const String drivers = '/api/drivers/drivers';
}
