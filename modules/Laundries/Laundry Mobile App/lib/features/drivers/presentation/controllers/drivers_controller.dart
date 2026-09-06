import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import '../../data/repositories/drivers_repository.dart';

class DriversController extends ChangeNotifier {
  final DriversRepository _repository;
  final String tenant;
  final String accessToken;
  final String? laundryId;

  DriversController({
    required this.tenant,
    required this.accessToken,
    this.laundryId,
    DriversRepository? repository,
  }) : _repository = repository ?? DriversRepository();

  List<DriverModel> _drivers = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: الكل, 1: متاح, 2: غير متاح

  List<DriverModel> get drivers => _drivers;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get selectedFilterIndex => _selectedFilterIndex;

  DriverStats get stats {
    final total = _drivers.length;
    final available = _drivers.where((d) => d.isAvailable).length;
    final unavailable = total - available;
    return DriverStats(
      total: total,
      available: available,
      unavailable: unavailable,
    );
  }

  List<DriverModel> get filteredDrivers {
    var result = _drivers;

    // Filter by availability tab
    if (_selectedFilterIndex == 1) {
      result = result.where((d) => d.isAvailable).toList();
    } else if (_selectedFilterIndex == 2) {
      result = result.where((d) => !d.isAvailable).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((d) {
        return d.fullName.toLowerCase().contains(q) ||
            d.phoneNumber.contains(q) ||
            d.vehicleInfo.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterIndex(int index) {
    if (_selectedFilterIndex == index) return;
    _selectedFilterIndex = index;
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _repository.fetchDrivers(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      );
      _drivers = list;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveDriver({
    String? id,
    required String fullName,
    required String phoneNumber,
    required String vehicleInfo,
    bool isAvailable = true,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final dto = CreateUpdateDriverDto(
      fullName: fullName.trim(),
      phoneNumber: phoneNumber.trim(),
      vehicleInfo: vehicleInfo.trim(),
      isAvailable: isAvailable,
      laundryId: laundryId,
    );

    try {
      if (id != null && id.isNotEmpty) {
        final updated = await _repository.updateDriver(
          tenant: tenant,
          accessToken: accessToken,
          id: id,
          dto: dto,
        );
        final index = _drivers.indexWhere((d) => d.id == id);
        if (index != -1) {
          _drivers[index] = updated;
        }
      } else {
        final created = await _repository.createDriver(
          tenant: tenant,
          accessToken: accessToken,
          dto: dto,
        );
        _drivers.insert(0, created);
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleAvailability(DriverModel driver) async {
    final originalState = driver.isAvailable;
    final newState = !originalState;

    // Optimistic UI update
    final index = _drivers.indexWhere((d) => d.id == driver.id);
    if (index != -1) {
      _drivers[index] = driver.copyWith(isAvailable: newState);
      notifyListeners();
    }

    try {
      await _repository.toggleAvailability(
        tenant: tenant,
        accessToken: accessToken,
        id: driver.id,
        isAvailable: newState,
      );
    } catch (e) {
      // Revert if error
      if (index != -1) {
        _drivers[index] = driver.copyWith(isAvailable: originalState);
      }
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
    }
  }

  Future<bool> deleteDriver(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteDriver(
        tenant: tenant,
        accessToken: accessToken,
        id: id,
      );
      _drivers.removeWhere((d) => d.id == id);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }
}
