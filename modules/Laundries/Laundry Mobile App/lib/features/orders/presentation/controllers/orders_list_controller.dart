import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/orders_repository.dart';

class OrdersListController extends ChangeNotifier {
  final OrdersRepository _ordersRepository = OrdersRepository();

  final String tenant;
  final String accessToken;
  final String laundryId;

  OrdersListController({
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
  }) {
    loadOrders();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdatingStatus = false;
  bool get isUpdatingStatus => _isUpdatingStatus;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  int? _selectedStatus; // null means 'All'
  int? get selectedStatus => _selectedStatus;

  String _searchFilter = '';
  String get searchFilter => _searchFilter;

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _ordersRepository.fetchOrders(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
        status: _selectedStatus,
        filter: _searchFilter.isNotEmpty ? _searchFilter : null,
      );
      _orders = list;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByStatus(int? status) {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    loadOrders();
  }

  void searchOrders(String query) {
    _searchFilter = query.trim();
    loadOrders();
  }

  Future<bool> changeStatus(String orderId, int newStatus) async {
    _isUpdatingStatus = true;
    notifyListeners();

    try {
      final updated = await _ordersRepository.updateOrderStatus(
        tenant: tenant,
        accessToken: accessToken,
        orderId: orderId,
        status: newStatus,
      );

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updated;
      }
      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordPayment({
    required String orderId,
    required double amount,
    required int paymentMethod,
    bool markAsDelivered = false,
  }) async {
    _isUpdatingStatus = true;
    notifyListeners();

    try {
      final updated = await _ordersRepository.recordPayment(
        tenant: tenant,
        accessToken: accessToken,
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
        markAsDelivered: markAsDelivered,
      );

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updated;
      }
      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  int get totalCount => _orders.length;
  int get pendingCount => _orders.where((o) => o.status == 1).length;
  int get processingCount => _orders.where((o) => o.status == 4).length;
  int get readyCount => _orders.where((o) => o.status == 5).length;
  int get completedCount => _orders.where((o) => o.status == 6).length;
  double get totalSales => _orders.fold(0.0, (sum, o) => sum + o.totalAmount);
}
