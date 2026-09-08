import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/reports_controller.dart';
import '../../data/models/laundry_report_model.dart';

class ReportsScreen extends StatelessWidget {
  final String tenant;
  final String accessToken;
  final String laundryId;
  final String laundryName;

  const ReportsScreen({
    super.key,
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
    required this.laundryName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsController(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
        laundryName: laundryName,
      )..loadReport(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التقارير المالية والتشغيلية',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              controller.laundryName,
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
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0284C7)),
            tooltip: 'تحديث التقارير',
            onPressed: controller.isLoading ? null : () => controller.loadReport(),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF10B981)),
            tooltip: 'مشاركة التقرير اليومي',
            onPressed: controller.report == null
                ? null
                : () => _copyClosureReport(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── 1. فلتر الفترات الزمنية ───
          _buildFilterBar(controller),

          // ─── المحتوى الرئيسي ───
          Expanded(
            child: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0284C7),
                    ),
                  )
                : controller.errorMessage != null
                    ? _buildErrorView(controller)
                    : controller.report == null
                        ? const Center(child: Text('لا توجد بيانات متاحة'))
                        : _buildReportContent(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ReportsController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'اليوم',
              icon: Icons.today_rounded,
              selected: controller.selectedFilter == DateFilterType.today,
              onTap: () => controller.setFilter(DateFilterType.today),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'هذا الأسبوع',
              icon: Icons.date_range_rounded,
              selected: controller.selectedFilter == DateFilterType.thisWeek,
              onTap: () => controller.setFilter(DateFilterType.thisWeek),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'هذا الشهر',
              icon: Icons.calendar_month_rounded,
              selected: controller.selectedFilter == DateFilterType.thisMonth,
              onTap: () => controller.setFilter(DateFilterType.thisMonth),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'فترة مخصصة',
              icon: Icons.tune_rounded,
              selected: controller.selectedFilter == DateFilterType.custom,
              onTap: () => _pickCustomDateRange(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomDateRange(ReportsController controller) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: controller.customStartDate ?? now.subtract(const Duration(days: 7)),
        end: controller.customEndDate ?? now,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0284C7),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start = DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0, 0);
      final end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      controller.setFilter(DateFilterType.custom, customStart: start, customEnd: end);
    }
  }

  Widget _buildReportContent(ReportsController controller) {
    final report = controller.report!;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 4 بطاقات إحصائيات KPI ───
                  _buildKpiGrid(report.summary),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF0284C7),
                indicatorWeight: 3,
                labelColor: const Color(0xFF0284C7),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                tabs: [
                  const Tab(
                    icon: Icon(Icons.point_of_sale_rounded, size: 20),
                    text: 'الصندوق والإقفال',
                  ),
                  Tab(
                    icon: Badge(
                      isLabelVisible: report.outstandingDebts.isNotEmpty,
                      label: Text('${report.outstandingDebts.length}'),
                      backgroundColor: const Color(0xFFEF4444),
                      child: const Icon(Icons.pending_actions_rounded, size: 20),
                    ),
                    text: 'ديون العملاء',
                  ),
                  const Tab(
                    icon: Icon(Icons.insights_rounded, size: 20),
                    text: 'الأكثر طلباً',
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCashClosureTab(report, controller),
          _buildDebtsTab(report),
          _buildTopServicesTab(report),
        ],
      ),
    );
  }

  // ─── بطاقات المؤشرات الرئيسية (KPIs) ───
  Widget _buildKpiGrid(LaundryReportSummaryModel summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'إجمالي المبيعات',
                value: '${summary.totalSales.toStringAsFixed(2)} ر.س',
                icon: Icons.payments_rounded,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
                subtext: '${summary.totalOrdersCount} فاتورة طلب',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'المحصل الفعلي',
                value: '${summary.totalPaid.toStringAsFixed(2)} ر.س',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFDCFCE7),
                subtext: 'مقبوضات مسددة',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'المتبقي والآجل',
                value: '${summary.totalRemaining.toStringAsFixed(2)} ر.س',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFEF3C7),
                subtext: 'ديون ومستحقات',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'إجمالي القطع',
                value: '${summary.totalItemsCount}',
                icon: Icons.dry_cleaning_rounded,
                color: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
                subtext: 'قطع تم استلامها',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // ─── تبويب 1: حركة الصندوق والإقفال اليومي ───
  Widget _buildCashClosureTab(LaundryReportModel report, ReportsController controller) {
    final p = report.paymentBreakdown;
    final totalCollected = p.totalCollected;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة الكاش في الدرج البارزة
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'النقد في الصندوق (الدرج)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.inventory_2_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'كاش جاهز للعد',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${p.cashAmount.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'إجمالي المقبوضات الفعلية: ${totalCollected.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // تفاصيل طرق الدفع والتحصيل
          const Text(
            'تفاصيل قنوات الدفع والتسديد',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          _buildPaymentRow(
            label: 'نقداً (كاش)',
            amount: p.cashAmount,
            total: totalCollected,
            icon: Icons.money_rounded,
            color: const Color(0xFF10B981),
          ),
          _buildPaymentRow(
            label: 'شبكة (مدى / بطاقة)',
            amount: p.cardAmount,
            total: totalCollected,
            icon: Icons.credit_card_rounded,
            color: const Color(0xFF0284C7),
          ),
          _buildPaymentRow(
            label: 'تحويل بنكي',
            amount: p.transferAmount,
            total: totalCollected,
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF6366F1),
          ),
          _buildPaymentRow(
            label: 'مبيعات آجلة ومتبقيات',
            amount: p.laterAmount,
            total: report.summary.totalSales,
            icon: Icons.history_rounded,
            color: const Color(0xFFF59E0B),
            isLater: true,
          ),

          const SizedBox(height: 24),

          // زر مشاركة تقرير الإقفال
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () => _copyClosureReport(context, controller),
            icon: const Icon(Icons.content_copy_rounded, size: 20),
            label: const Text(
              'نسخ تقرير الإقفال للمشاركة (واتساب / بريد)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required double amount,
    required double total,
    required IconData icon,
    required Color color,
    bool isLater = false,
  }) {
    final double pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      isLater ? 'غير مدفوع بعد' : '${(pct * 100).toStringAsFixed(1)}% من المحصل',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isLater ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${amount.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── تبويب 2: ديون العملاء والمتبقيات ───
  Widget _buildDebtsTab(LaundryReportModel report) {
    final debts = report.outstandingDebts;

    if (debts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF10B981),
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'رائع! لا توجد ديون معلقة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'جميع الفواتير لهذه الفترة مسددة بالكامل',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final totalRemaining = debts.fold<double>(0.0, (sum, d) => sum + d.remainingAmount);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي المتبقي: ${totalRemaining.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      Text(
                        'على ${debts.length} عميل بانتظار التحصيل',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final debt = debts[index - 1];
        return _buildDebtCard(debt);
      },
    );
  }

  Widget _buildDebtCard(OutstandingDebtModel debt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF1F5F9),
                child: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (debt.customerPhoneNumber != null && debt.customerPhoneNumber!.isNotEmpty)
                      Text(
                        debt.customerPhoneNumber!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${debt.remainingAmount.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'فاتورة: #${debt.orderNumber}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                'المسدد: ${debt.paidAmount.toStringAsFixed(2)} من ${debt.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (debt.customerPhoneNumber != null && debt.customerPhoneNumber!.isNotEmpty) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: debt.customerPhoneNumber!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ رقم هاتف العميل'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF0284C7)),
                    label: const Text(
                      'نسخ الرقم',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0FDF4),
                    foregroundColor: const Color(0xFF16A34A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFBBF7D0)),
                    ),
                  ),
                  onPressed: () {
                    final msg = 'مرحباً ${debt.customerName}، نود تذكيركم بمتبقي فاتورة مغسلة بقيمة ${debt.remainingAmount.toStringAsFixed(2)} ر.س للفاتورة رقم #${debt.orderNumber}. شكراً لتعاملكم معنا!';
                    Clipboard.setData(ClipboardData(text: msg));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ نص رسالة المطالبة (واتساب/رسالة قصيرة)'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message_outlined, size: 16),
                  label: const Text(
                    'رسالة تذكير',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── تبويب 3: الأكثر طلباً والتشغيل ───
  Widget _buildTopServicesTab(LaundryReportModel report) {
    final services = report.topServices;
    final st = report.statusBreakdown;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ملخص دورة الإنتاج
          const Text(
            'حالة الطلبات والإنتاجية',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatusMiniCard(
                  title: 'قيد الانتظار',
                  count: st.pendingCount,
                  color: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusMiniCard(
                  title: 'قيد الغسيل',
                  count: st.processingCount,
                  color: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFE0F2FE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusMiniCard(
                  title: 'جاهز للتسليم',
                  count: st.readyCount,
                  color: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFEDE9FE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusMiniCard(
                  title: 'مسلّم',
                  count: st.deliveredCount,
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFDCFCE7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // قائمة الخدمات الأكثر مبيعاً
          const Text(
            'الخدمات والأصناف الأكثر طلباً',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          if (services.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'لا توجد عناصر مباعة خلال هذه الفترة',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            )
          else
            ...services.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: idx == 1
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$idx',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: idx == 1 ? const Color(0xFFD97706) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.serviceName,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                '${item.quantity} قطعة مباعة',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.totalAmount.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            Text(
                              '${item.percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (item.percentage / 100).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusMiniCard({
    required String title,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _copyClosureReport(BuildContext context, ReportsController controller) {
    final text = controller.getFormattedClosureText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 تم نسخ تقرير الإقفال اليومي الشامل! يمكنك لصقه ومشاركته عبر واتساب'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF0D9488),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildErrorView(ReportsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage ?? 'حدث خطأ غير متوقع',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadReport(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
