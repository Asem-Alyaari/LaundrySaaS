import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/orders_list_controller.dart';
import '../widgets/order_history_card.dart';
import '../widgets/invoice_receipt_dialog.dart';
import 'create_order_screen.dart';

class OrdersListScreen extends StatelessWidget {
  final String tenant;
  final String accessToken;
  final String laundryId;
  final String laundryName;

  const OrdersListScreen({
    super.key,
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
    required this.laundryName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrdersListController(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      ),
      child: _OrdersListContent(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
        laundryName: laundryName,
      ),
    );
  }
}

class _OrdersListContent extends StatelessWidget {
  final String tenant;
  final String accessToken;
  final String laundryId;
  final String laundryName;

  const _OrdersListContent({
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
    required this.laundryName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdersListController>();

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
              'سجل الفواتير والطلبات',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              laundryName,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث السجل',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: controller.loadOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadOrders,
        color: const Color(0xFF0284C7),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. بطاقة إحصائيات المبيعات والفواتير ───
              _buildStatsCard(controller),

              const SizedBox(height: 14),

              // ─── 2. شريط البحث ───
              TextField(
                onChanged: controller.searchOrders,
                decoration: InputDecoration(
                  hintText: 'ابحث برقم الفاتورة، اسم العميل، أو الجوال...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),

              const SizedBox(height: 12),

              // ─── 3. أشرطة تصفية الحالات (Status Tabs) ───
              _buildStatusTabs(controller),

              const SizedBox(height: 16),

              // رسالة الخطأ إن وجدت
              if (controller.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Text(
                    controller.errorMessage!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ─── 4. قائمة الفواتير ───
              if (controller.isLoading) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                  ),
                ),
              ] else if (controller.orders.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'لا توجد فواتير مسجلة في هذا القسم',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'يمكنك إصدار فاتورة جديدة بالضغط على الزر أدناه',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('إصدار فاتورة جديدة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _openCreateOrder(context, controller),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final order = controller.orders[i];
                    return OrderHistoryCard(
                      order: order,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => InvoiceReceiptDialog(
                            order: order,
                            laundryName: laundryName,
                            onNewOrder: () {
                              Navigator.pop(dialogCtx);
                              _openCreateOrder(context, controller);
                            },
                            onFinish: () => Navigator.pop(dialogCtx),
                          ),
                        );
                      },
                      onStatusChange: (newStatus) async {
                        final ok = await controller.changeStatus(order.id, newStatus);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تحديث حالة الفاتورة بنجاح'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateOrder(context, controller),
        backgroundColor: const Color(0xFF0284C7),
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
        label: const Text(
          'فاتورة جديدة',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatsCard(OrdersListController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0369A1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('إجمالي الفواتير', '${controller.totalCount}'),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
          _buildStatColumn('قيد المعالجة', '${controller.pendingCount + controller.processingCount}'),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
          _buildStatColumn('جاهز ومكتمل', '${controller.readyCount + controller.completedCount}'),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
          _buildStatColumn('إجمالي الدخل', '${controller.totalSales.toStringAsFixed(0)} ر.س'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTabs(OrdersListController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('الكل', null, controller),
          _buildFilterChip('قيد الانتظار', 1, controller),
          _buildFilterChip('قيد الغسيل', 4, controller),
          _buildFilterChip('جاهز للتسليم', 5, controller),
          _buildFilterChip('مكتمل', 6, controller),
          _buildFilterChip('ملغي', 7, controller),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, int? status, OrdersListController controller) {
    final isSelected = controller.selectedStatus == status;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: () => controller.filterByStatus(status),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0284C7) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0284C7)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateOrder(
      BuildContext context, OrdersListController controller) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateOrderScreen(
          tenant: tenant,
          accessToken: accessToken,
          laundryId: laundryId,
          laundryName: laundryName,
        ),
      ),
    );
    if (result == true) {
      controller.loadOrders();
    }
  }
}
