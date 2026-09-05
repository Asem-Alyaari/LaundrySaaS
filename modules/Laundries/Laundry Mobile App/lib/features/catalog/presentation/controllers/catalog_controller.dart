import 'package:flutter/material.dart';
import '../../data/models/service_item_model.dart';
import '../../data/repositories/catalog_repository.dart';

class CatalogController extends ChangeNotifier {
  final CatalogRepository _repository;
  final String tenant;
  final String accessToken;
  final String laundryId;

  CatalogController({
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
    CatalogRepository? repository,
  }) : _repository = repository ?? CatalogRepository();

  List<ServiceCategoryModel> _categories = [];
  List<ServiceItemModel> _items = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<ServiceCategoryModel> get categories => _categories;
  List<ServiceItemModel> get items => _items;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// Filtered items based on local search query if needed, or by category
  List<ServiceItemModel> get filteredItems {
    var result = _items;
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      result = result.where((i) => i.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize and load both categories and items
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cats = await _repository.fetchCategories(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      );
      _categories = cats;

      final fetchedItems = await _repository.fetchItems(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      );
      _items = fetchedItems;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh items
  Future<void> reloadItems() async {
    try {
      final fetchedItems = await _repository.fetchItems(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
        categoryId: _selectedCategoryId,
        filter: _searchQuery,
      );
      _items = fetchedItems;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Create or Update item
  Future<bool> saveItem({
    String? id,
    required String name,
    required double price,
    required String categoryId,
    required String unit,
    required double durationHours,
    String? description,
    bool isActive = true,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final dto = CreateUpdateServiceItemDto(
      name: name,
      price: price,
      categoryId: categoryId,
      laundryId: laundryId,
      unit: unit,
      durationHours: durationHours,
      description: description,
      isActive: isActive,
    );

    try {
      if (id != null && id.isNotEmpty) {
        final updated = await _repository.updateItem(
          tenant: tenant,
          accessToken: accessToken,
          id: id,
          dto: dto,
        );
        final index = _items.indexWhere((i) => i.id == id);
        if (index != -1) {
          _items[index] = updated;
        }
      } else {
        final created = await _repository.createItem(
          tenant: tenant,
          accessToken: accessToken,
          dto: dto,
        );
        _items.insert(0, created);
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

  /// Toggle item active status
  Future<void> toggleItemActive(ServiceItemModel item) async {
    final updatedDto = CreateUpdateServiceItemDto(
      name: item.name,
      price: item.price,
      categoryId: item.categoryId,
      laundryId: item.laundryId,
      unit: item.unit,
      durationHours: item.durationHours,
      description: item.description,
      icon: item.icon,
      isActive: !item.isActive,
    );

    try {
      final updated = await _repository.updateItem(
        tenant: tenant,
        accessToken: accessToken,
        id: item.id,
        dto: updatedDto,
      );
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
    }
  }

  /// Delete item
  Future<bool> deleteItem(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteItem(
        tenant: tenant,
        accessToken: accessToken,
        id: id,
      );
      _items.removeWhere((i) => i.id == id);
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

  /// Import ready-made laundry template
  Future<bool> importTemplate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.importTemplateCatalog(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      );
      // Reload categories and items to get full synchronized list
      await init();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add a new service category / department
  Future<ServiceCategoryModel?> addCategory(String name, {String? icon, String? color}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createCategory(
        tenant: tenant,
        accessToken: accessToken,
        name: name,
        laundryId: laundryId,
        icon: icon,
        color: color,
      );
      _categories.add(created);
      _selectedCategoryId = created.id;
      _isSubmitting = false;
      notifyListeners();
      return created;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return null;
    }
  }
}
