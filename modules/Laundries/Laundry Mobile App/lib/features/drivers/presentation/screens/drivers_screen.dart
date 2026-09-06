import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/driver_model.dart';
import '../controllers/drivers_controller.dart';
import '../widgets/add_edit_driver_dialog.dart';
import '../widgets/driver_card.dart';

class DriversScreen extends StatelessWidget {
  final String tenant;
  final String accessToken;
  final String? laundryId;

  const DriversScreen({
    super.key,
    required this.tenant,
    required this.accessToken,
    this.laundryId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriversController(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      )..init(),
      child: const _DriversScreenContent(),
    );
  }
}

class _DriversScreenContent extends StatefulWidget {
  const _DriversScreenContent();

  @override
  State<_DriversScreenContent> createState() => _DriversScreenContentState();
}

class _DriversScreenContentState extends State<_DriversScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, DriversController controller, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            const Text('تأكيد الحذف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text('هل أنت متأكد من حذف المندوب "${driver.fullName}"؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await controller.deleteDriver(driver.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف المندوب "${driver.fullName}"'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DriversController>();
    final stats = controller.stats;
    final drivers = controller.filteredDrivers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مناديب التوصيل',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'إدارة وتتبع مناديب استلام وتسليم الغسيل',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0284C7).withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0284C7)),
            tooltip: 'تحديث القائمة',
            onPressed: controller.isLoading ? null : () => controller.init(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── 1. بطاقات المؤشرات والإحصائيات السريعة ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildKpiCard(
                  title: 'إجمالي المناديب',
                  value: stats.total.toString(),
                  icon: Icons.groups_rounded,
                  color: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFE0F2FE),
                ),
                const SizedBox(width: 10),
                _buildKpiCard(
                  title: 'متاح للطلب الآن',
                  value: stats.available.toString(),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFD1FAE5),
                ),
                const SizedBox(width: 10),
                _buildKpiCard(
                  title: 'غير متوفر',
                  value: stats.unavailable.toString(),
                  icon: Icons.pause_circle_filled_rounded,
                  color: const Color(0xFF64748B),
                  bgColor: const Color(0xFFF1F5F9),
                ),
              ],
            ),
          ),

          // ─── 2. حقل البحث والفلترة ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم المندوب أو رقم الجوال أو المركبة...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0284C7), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // أزرار الفلترة السريعة
                Row(
                  children: [
                    _buildFilterChip('الكل (${stats.total})', 0, controller),
                    const SizedBox(width: 8),
                    _buildFilterChip('متاح (${stats.available})', 1, controller),
                    const SizedBox(width: 8),
                    _buildFilterChip('غير متوفر (${stats.unavailable})', 2, controller),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ─── 3. قائمة المناديب ───
          Expanded(
            child: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                  )
                : RefreshIndicator(
                    onRefresh: controller.init,
                    color: const Color(0xFF0284C7),
                    child: drivers.isEmpty
                        ? _buildEmptyState(context, controller)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: drivers.length,
                            itemBuilder: (ctx, index) {
                              final driver = drivers[index];
                              return DriverCard(
                                driver: driver,
                                onToggleAvailability: (val) =>
                                    controller.toggleAvailability(driver),
                                onEdit: () {
                                  AddEditDriverDialog.show(
                                    context,
                                    driver: driver,
                                    getErrorMessage: () => controller.errorMessage,
                                    onSave: controller.saveDriver,
                                  );
                                },
                                onDelete: () => _confirmDelete(context, controller, driver),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),

      // ─── زر الإضافة العائم (FAB) ───
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddEditDriverDialog.show(
            context,
            getErrorMessage: () => controller.errorMessage,
            onSave: controller.saveDriver,
          );
        },
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'إضافة مندوب',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.85),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, DriversController controller) {
    final isSelected = controller.selectedFilterIndex == index;
    return InkWell(
      onTap: () => controller.setFilterIndex(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DriversController controller) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delivery_dining_outlined,
                  size: 40,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'لا يوجد مناديب مسجلين حالياً',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'أضف أول مندوب توصيل لمغسلتك لتبدأ في إسناد واستلام الطلبات بسلاسة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  AddEditDriverDialog.show(
                    context,
                    getErrorMessage: () => controller.errorMessage,
                    onSave: controller.saveDriver,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'إضافة مندوب جديد',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
