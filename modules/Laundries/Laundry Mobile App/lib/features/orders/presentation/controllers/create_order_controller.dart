import 'dart:math';
import 'package:flutter/material.dart';
import '../../../catalog/data/models/service_item_model.dart';
import '../../../catalog/data/repositories/catalog_repository.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/orders_repository.dart';

class CreateOrderController extends ChangeNotifier {
  final CatalogRepository _catalogRepository = CatalogRepository();
  final OrdersRepository _ordersRepository = OrdersRepository();

  final String tenant;
  final String accessToken;
  final String laundryId;

  CreateOrderController({
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
  }) {
    _init();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ServiceCategoryModel> _categories = [];
  List<ServiceCategoryModel> get categories => _categories;

  List<ServiceItemModel> _allServices = [];
  List<ServiceItemModel> get allServices => _allServices;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Selected invoice items: Map<ServiceItemId, CreateOrderItemDto>
  final Map<String, CreateOrderItemDto> _selectedItems = {};
  Map<String, CreateOrderItemDto> get selectedItems => _selectedItems;

  // Customer selection
  bool _isWalkIn = true;
  bool get isWalkIn => _isWalkIn;

  RegisteredCustomerModel? _selectedCustomer;
  RegisteredCustomerModel? get selectedCustomer => _selectedCustomer;

  List<RegisteredCustomerModel> _registeredCustomers = [];
  List<RegisteredCustomerModel> get registeredCustomers => _registeredCustomers;

  bool _isSearchingCustomers = false;
  bool get isSearchingCustomers => _isSearchingCustomers;

  // Form controllers
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController discountController = TextEditingController(text: '0');
  final TextEditingController paidAmountController = TextEditingController();

  // Payment configuration
  int _paymentMethod = 1; // 1: Cash, 2: Card (Mada), 3: Transfer, 5: Later
  int get paymentMethod => _paymentMethod;

  int _paymentType = 1; // 1: Fully Paid, 2: Partial Payment, 3: Later / Unpaid
  int get paymentType => _paymentType;

  int _paymentStatus = 2; // 2: Paid, 3: PartiallyPaid, 1: Unpaid
  int get paymentStatus => _paymentStatus;

  Future<void> _init() async {
    await loadData();
    await loadInitialCustomers();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cats = await _catalogRepository.fetchCategories(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      );

      final items = await _catalogRepository.fetchItems(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      );

      _categories = cats;
      _allServices = items.where((i) => i.isActive).toList();
    } catch (e) {
      _errorMessage = 'فشل في تحميل خدمات المغسلة: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitialCustomers() async {
    try {
      _isSearchingCustomers = true;
      notifyListeners();
      final customers = await _ordersRepository.searchCustomers(
        tenant: tenant,
        accessToken: accessToken,
      );
      _registeredCustomers = customers;
    } catch (_) {
    } finally {
      _isSearchingCustomers = false;
      notifyListeners();
    }
  }

  Future<void> searchCustomers(String filter) async {
    try {
      _isSearchingCustomers = true;
      notifyListeners();
      final customers = await _ordersRepository.searchCustomers(
        tenant: tenant,
        accessToken: accessToken,
        filter: filter,
      );
      _registeredCustomers = customers;
    } catch (_) {
    } finally {
      _isSearchingCustomers = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ServiceItemModel> get filteredServices {
    return _allServices.where((item) {
      final matchesCategory = _selectedCategoryId == null ||
          _selectedCategoryId!.isEmpty ||
          item.categoryId == _selectedCategoryId;

      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.description != null &&
              item.description!.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();
  }

  bool isServiceSelected(String serviceId) {
    return _selectedItems.containsKey(serviceId);
  }

  int getQuantity(String serviceId) {
    return _selectedItems[serviceId]?.quantity ?? 0;
  }

  void toggleService(ServiceItemModel service) {
    if (_selectedItems.containsKey(service.id)) {
      _selectedItems.remove(service.id);
    } else {
      _selectedItems[service.id] = CreateOrderItemDto(
        serviceItemId: service.id,
        itemName: service.name,
        unitPrice: service.price,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void increaseQuantity(ServiceItemModel service) {
    if (_selectedItems.containsKey(service.id)) {
      _selectedItems[service.id]!.quantity += 1;
    } else {
      _selectedItems[service.id] = CreateOrderItemDto(
        serviceItemId: service.id,
        itemName: service.name,
        unitPrice: service.price,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void decreaseQuantity(ServiceItemModel service) {
    if (!_selectedItems.containsKey(service.id)) return;

    if (_selectedItems[service.id]!.quantity > 1) {
      _selectedItems[service.id]!.quantity -= 1;
    } else {
      _selectedItems.remove(service.id);
    }
    notifyListeners();
  }

  void setItemQuantity(String serviceId, int qty) {
    if (!_selectedItems.containsKey(serviceId)) return;
    if (qty <= 0) {
      _selectedItems.remove(serviceId);
    } else {
      _selectedItems[serviceId]!.quantity = qty;
    }
    notifyListeners();
  }

  void setCustomerMode(bool walkIn) {
    _isWalkIn = walkIn;
    if (walkIn) {
      _selectedCustomer = null;
    } else {
      if (_selectedCustomer != null) {
        customerNameController.text = _selectedCustomer!.fullName;
        customerPhoneController.text = _selectedCustomer!.phoneNumber;
      }
    }
    notifyListeners();
  }

  void selectCustomer(RegisteredCustomerModel customer) {
    _selectedCustomer = customer;
    customerNameController.text = customer.fullName;
    customerPhoneController.text = customer.phoneNumber;
    notifyListeners();
  }

  void setPaymentType(int type) {
    _paymentType = type;
    if (type == 1) {
      _paymentStatus = 2; // Paid
      if (_paymentMethod == 5) _paymentMethod = 1; // Default to Cash if was Later
      paidAmountController.text = totalAmount.toStringAsFixed(2);
    } else if (type == 2) {
      _paymentStatus = 3; // PartiallyPaid
      if (_paymentMethod == 5) _paymentMethod = 1; // Default to Cash if was Later
      if (paidAmountController.text.isEmpty || paidAmountController.text == '0') {
        paidAmountController.text = (totalAmount / 2).toStringAsFixed(2);
      }
    } else {
      _paymentStatus = 1; // Unpaid / Later
      _paymentMethod = 5; // Later (آجل)
      paidAmountController.text = '0';
    }
    notifyListeners();
  }

  void onPaidAmountChanged() {
    notifyListeners();
  }

  double get currentPaidAmount {
    if (_paymentType == 1) return totalAmount;
    if (_paymentType == 3) return 0.0;
    final val = double.tryParse(paidAmountController.text.trim()) ?? 0.0;
    return val.clamp(0.0, totalAmount);
  }

  double get currentRemainingAmount {
    return max(0.0, totalAmount - currentPaidAmount);
  }

  void setPaymentMethod(int method) {
    _paymentMethod = method;
    if (method == 5) {
      // If "آجل", switch type to Later
      setPaymentType(3);
    }
    notifyListeners();
  }

  void setPaymentStatus(int status) {
    _paymentStatus = status;
    notifyListeners();
  }

  double get subtotal {
    return _selectedItems.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get discountAmount {
    return double.tryParse(discountController.text.trim()) ?? 0.0;
  }

  double get totalAmount {
    return max(0.0, subtotal - discountAmount);
  }

  int get totalItemCount {
    return _selectedItems.values.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<OrderModel?> submitInvoice() async {
    _errorMessage = null;

    if (_selectedItems.isEmpty) {
      _errorMessage = 'يرجى اختيار خدمة واحدة على الأقل لإصدار الفاتورة';
      notifyListeners();
      return null;
    }

    final name = customerNameController.text.trim();
    if (name.isEmpty) {
      _errorMessage = 'يرجى إدخال اسم العميل';
      notifyListeners();
      return null;
    }

    final effectivePaid = currentPaidAmount;
    final effectiveStatus = _paymentType == 1
        ? 2 // Paid
        : (_paymentType == 2
            ? (effectivePaid >= totalAmount && totalAmount > 0 ? 2 : (effectivePaid > 0 ? 3 : 1))
            : 1); // Unpaid
    final effectiveMethod = _paymentType == 3 ? 5 : _paymentMethod;

    _isSubmitting = true;
    notifyListeners();

    try {
      final dto = CreateOrderDto(
        laundryId: laundryId,
        isWalkIn: _isWalkIn,
        customerId: _isWalkIn ? null : _selectedCustomer?.id,
        customerName: name,
        customerPhoneNumber: customerPhoneController.text.trim().isNotEmpty
            ? customerPhoneController.text.trim()
            : null,
        deliveryType: 1, // InStore
        paymentStatus: effectiveStatus,
        paymentMethod: effectiveMethod,
        discountAmount: discountAmount,
        taxAmount: 0,
        paidAmount: effectivePaid,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
        items: _selectedItems.values.toList(),
      );

      final order = await _ordersRepository.createOrder(
        tenant: tenant,
        accessToken: accessToken,
        dto: dto,
      );

      _isSubmitting = false;
      notifyListeners();
      return order;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  void resetForm() {
    _selectedItems.clear();
    customerNameController.clear();
    customerPhoneController.clear();
    notesController.clear();
    discountController.text = '0';
    paidAmountController.clear();
    _selectedCustomer = null;
    _isWalkIn = true;
    _paymentMethod = 1;
    _paymentType = 1;
    _paymentStatus = 2;
    _errorMessage = null;
    notifyListeners();
  }

  void updateDiscount() {
    if (_paymentType == 1) {
      paidAmountController.text = totalAmount.toStringAsFixed(2);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    notesController.dispose();
    discountController.dispose();
    paidAmountController.dispose();
    super.dispose();
  }
}
