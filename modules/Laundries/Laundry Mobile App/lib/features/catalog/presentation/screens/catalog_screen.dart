import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/add_edit_service_dialog.dart';
import '../widgets/add_category_sheet.dart';
import '../../data/models/service_item_model.dart';

class CatalogScreen extends StatefulWidget {
  final String tenant;
  final String accessToken;
  final String laundryId;

  const CatalogScreen({
    super.key,
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final CatalogController _controller;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = CatalogController(
      tenant: widget.tenant,
      accessToken: widget.accessToken,
      laundryId: widget.laundryId,
    );
    _controller.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<CatalogController>(
        builder: (context, controller, _) {
          final totalCount = controller.items.length;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              centerTitle: false,
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                      onChanged: (val) => controller.setSearchQuery(val),
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن خدمة...',
                        hintStyle: TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 14),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF0F172A)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'كتالوج الخدمات والأسعار',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '$totalCount خدمة مسجلة',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close_rounded : Icons.search_rounded,
                    color: const Color(0xFF0F172A),
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        controller.setSearchQuery('');
                      }
                    });
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => AddEditServiceSheet.show(
                context,
                controller: controller,
              ),
              backgroundColor: const Color(0xFF0F172A),
              elevation: 3,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: const Text(
                'إضافة خدمة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => controller.init(),
              color: const Color(0xFF0284C7),
              child: Column(
                children: [
                  // Horizontal Categories Bar
                  _buildCategoriesBar(controller),

                  // Services List
                  Expanded(
                    child: _buildList(controller),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesBar(CatalogController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildCategoryChip(
              label: 'الكل',
              count: controller.items.length,
              isSelected: controller.selectedCategoryId == null,
              onTap: () => controller.selectCategory(null),
            ),
            ...controller.categories.map((cat) {
              final isSelected = controller.selectedCategoryId == cat.id;
              final count =
                  controller.items.where((i) => i.categoryId == cat.id).length;
              return _buildCategoryChip(
                label: cat.name,
                count: count,
                isSelected: isSelected,
                onTap: () => controller.selectCategory(cat.id),
              );
            }),
            _buildAddCategoryChip(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryChip(
      BuildContext context, CatalogController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: () => AddCategorySheet.show(context, controller: controller),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16, color: Color(0xFF0284C7)),
              SizedBox(width: 4),
              Text(
                'قسم جديد',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(CatalogController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0284C7)),
      );
    }

    final items = controller.filteredItems;

    // Empty state
    if (items.isEmpty) {
      final isFiltered = controller.searchQuery.isNotEmpty ||
          controller.selectedCategoryId != null;
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                ),
                child: const Icon(
                  Icons.dry_cleaning_rounded,
                  size: 40,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isFiltered
                    ? 'لا توجد خدمات مطابقة لبحثك'
                    : 'كتالوج الخدمات فارغ حالياً',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isFiltered
                    ? 'جرب البحث باسم آخر أو اختيار تصنيف مختلف'
                    : 'يمكنك استيراد باقة الخدمات الأساسية الجاهزة للمغاسل بنقرة واحدة',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (!isFiltered) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final ok = await controller.importTemplate();
                      if (!mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            content: const Text(
                                'تم استيراد باقة الخدمات الأساسية بنجاح!'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_awesome_rounded,
                        size: 18, color: Colors.white),
                    label: const Text(
                      'استيراد باقة الخدمات الجاهزة (10 خدمات)',
                      style: TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => AddEditServiceSheet.show(
                    context,
                    controller: controller,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    'إضافة خدمة جديدة',
                    style:
                        TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Native Mobile List
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final category = controller.categories
            .where((c) => c.id == item.categoryId)
            .firstOrNull;

        return _buildMobileServiceCard(
          item: item,
          categoryName: category?.name ?? 'خدمة',
          controller: controller,
        );
      },
    );
  }

  Widget _buildMobileServiceCard({
    required ServiceItemModel item,
    required String categoryName,
    required CatalogController controller,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => AddEditServiceSheet.show(
          context,
          controller: controller,
          itemToEdit: item,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isActive
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFFF1F5F9),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.isActive
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: item.isActive
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Icon(
                  Icons.dry_cleaning_rounded,
                  color: item.isActive
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF94A3B8),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: item.isActive
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            categoryName,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.durationHours > 0) ...[
                          const SizedBox(width: 6),
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 12, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 3),
                              Text(
                                '${item.durationHours.toInt()} س',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Price and Options Menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.price.toStringAsFixed(1)} ر.س',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: item.isActive
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    'لكل ${item.unit}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),

              // Menu Button (Edit / Delete / Toggle)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 18, color: Color(0xFF94A3B8)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.zero,
                onSelected: (val) {
                  if (val == 'edit') {
                    AddEditServiceSheet.show(
                      context,
                      controller: controller,
                      itemToEdit: item,
                    );
                  } else if (val == 'toggle') {
                    controller.toggleItemActive(item);
                  } else if (val == 'delete') {
                    _confirmDelete(item, controller);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: const Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: Color(0xFF0284C7)),
                        SizedBox(width: 8),
                        Text('تعديل البيانات والسعر',
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          item.isActive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: item.isActive
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                        ),
                        SizedBox(width: 8),
                        Text(
                          item.isActive ? 'تعطيل الخدمة' : 'تفعيل الخدمة',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text('حذف الخدمة',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(ServiceItemModel item, CatalogController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'حذف الخدمة',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Text('هل أنت متأكد من رغبتك في حذف خدمة "${item.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await controller.deleteItem(item.id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    content: const Text('تم حذف الخدمة بنجاح'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );
  }
}
