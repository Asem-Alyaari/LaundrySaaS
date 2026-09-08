import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../catalog/data/models/service_item_model.dart';
import '../controllers/create_order_controller.dart';
import '../widgets/invoice_receipt_dialog.dart';

class CreateOrderScreen extends StatelessWidget {
  final String tenant;
  final String accessToken;
  final String laundryId;
  final String laundryName;

  const CreateOrderScreen({
    super.key,
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
    required this.laundryName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateOrderController(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
      ),
      child: _CreateOrderContent(laundryName: laundryName),
    );
  }
}

class _CreateOrderContent extends StatelessWidget {
  final String laundryName;

  const _CreateOrderContent({required this.laundryName});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CreateOrderController>();

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
              'إنشاء فاتورة جديدة (POS)',
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
            tooltip: 'إفراغ البيانات',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: () {
              controller.resetForm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تفريغ الحقول وإعادة التعيين'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0284C7)),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Color(0xFFDC2626), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ─── 1. قسم بيانات العميل ───
                      _buildCustomerSection(context, controller),

                      const SizedBox(height: 18),

                      // ─── 2. قسم كتالوج خدمات المغسلة ───
                      _buildServicesSection(context, controller),

                      const SizedBox(height: 18),

                      // ─── 3. خيارات الدفع والملاحظات ───
                      _buildPaymentAndNotesSection(context, controller),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // ─── 4. الشريط السفلي للمجموع والإصدار ───
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomSummaryBar(context, controller),
                ),
              ],
            ),
    );
  }

  // ──────────────────────────────────────────
  // 1. قسم بيانات العميل (مسجل أو حضوري)
  // ──────────────────────────────────────────
  Widget _buildCustomerSection(
      BuildContext context, CreateOrderController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
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
              const Row(
                children: [
                  Icon(Icons.person_pin_rounded,
                      color: Color(0xFF0284C7), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'بيانات العميل',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildModeTab(
                      label: 'حضوري بالمغسلة',
                      isSelected: controller.isWalkIn,
                      onTap: () => controller.setCustomerMode(true),
                    ),
                    _buildModeTab(
                      label: 'عميل مسجل',
                      isSelected: !controller.isWalkIn,
                      onTap: () => controller.setCustomerMode(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // سيناريو عميل حضوري
          if (controller.isWalkIn) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: controller.customerNameController,
                    decoration: InputDecoration(
                      labelText: 'اسم العميل *',
                      hintText: 'مثال: أحمد عبد الله',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controller.customerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الجوال',
                      hintText: '05xxxxxxxx',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // سيناريو عميل مسجل في النظام
            if (controller.selectedCustomer != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0284C7)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF0284C7),
                      radius: 18,
                      child: Icon(Icons.person_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.selectedCustomer!.fullName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            controller.selectedCustomer!.phoneNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showCustomerSearchDialog(context, controller),
                      child: const Text('تغيير'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.search_rounded),
                label: const Text('البحث واختيار عميل مسجل من النظام'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF0284C7)),
                  foregroundColor: const Color(0xFF0284C7),
                ),
                onPressed: () => _showCustomerSearchDialog(context, controller),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypeTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 2. قسم كتالوج خدمات المغسلة واختيار الكميات
  // ──────────────────────────────────────────
  Widget _buildServicesSection(
      BuildContext context, CreateOrderController controller) {
    final services = controller.filteredServices;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
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
              const Row(
                children: [
                  Icon(Icons.dry_cleaning_rounded,
                      color: Color(0xFF0284C7), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'خدمات المغسلة',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${controller.selectedItems.length} خدمات مختارة',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // حقل البحث السريع
          TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'ابحث عن خدمة (ثوب، شماغ، بدلة، سجاد...)',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ),

          const SizedBox(height: 12),

          // فلاتر الأقسام (Categories)
          if (controller.categories.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryFilterChip(
                    label: 'جميع الخدمات',
                    isSelected: controller.selectedCategoryId == null ||
                        controller.selectedCategoryId!.isEmpty,
                    onTap: () => controller.selectCategory(null),
                  ),
                  ...controller.categories.map(
                    (cat) => _buildCategoryFilterChip(
                      label: cat.name,
                      isSelected: controller.selectedCategoryId == cat.id,
                      onTap: () => controller.selectCategory(cat.id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // قائمة الخدمات
          if (services.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 42, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 8),
                  const Text(
                    'لا توجد خدمات مطابقة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final service = services[i];
                final isSelected = controller.isServiceSelected(service.id);
                final quantity = controller.getQuantity(service.id);

                return _buildServiceCard(
                  service: service,
                  isSelected: isSelected,
                  quantity: quantity,
                  controller: controller,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0284C7)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required ServiceItemModel service,
    required bool isSelected,
    required int quantity,
    required CreateOrderController controller,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF0284C7).withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // مربع التأشير Checkbox
          InkWell(
            onTap: () => controller.toggleService(service),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0284C7) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0284C7)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // اسم الخدمة وتفاصيل السعر
          Expanded(
            child: InkWell(
              onTap: () => controller.toggleService(service),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${service.price.toStringAsFixed(2)} ر.س / ${service.unit}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // عداد الكمية عند التأشير على الخدمة
          if (isSelected) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_rounded, size: 18),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    color: const Color(0xFFDC2626),
                    onPressed: () => controller.decreaseQuantity(service),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 30),
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    color: const Color(0xFF0284C7),
                    onPressed: () => controller.increaseQuantity(service),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // إجمالي سطر الخدمة
            Container(
              constraints: const BoxConstraints(minWidth: 60),
              alignment: Alignment.centerRight,
              child: Text(
                '${(service.price * quantity).toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ] else ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(60, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFF0284C7)),
              ),
              onPressed: () => controller.toggleService(service),
              child: const Text(
                'اختيار',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // 3. قسم خيارات الدفع والملاحظات
  // ──────────────────────────────────────────
  Widget _buildPaymentAndNotesSection(
      BuildContext context, CreateOrderController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: Color(0xFF0284C7), size: 20),
              SizedBox(width: 8),
              Text(
                'طريقة الدفع والملاحظات',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ─── اختيار نوع السداد (كامل / جزئي / آجل) ───
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPaymentTypeTab(
                    label: 'مدفوع بالكامل',
                    isSelected: controller.paymentType == 1,
                    onTap: () => controller.setPaymentType(1),
                  ),
                ),
                Expanded(
                  child: _buildPaymentTypeTab(
                    label: 'دفع جزئي',
                    isSelected: controller.paymentType == 2,
                    onTap: () => controller.setPaymentType(2),
                  ),
                ),
                Expanded(
                  child: _buildPaymentTypeTab(
                    label: 'آجل / غير مدفوع',
                    isSelected: controller.paymentType == 3,
                    onTap: () => controller.setPaymentType(3),
                  ),
                ),
              ],
            ),
          ),

          // ─── تفاصيل الدفع الجزئي إن تم اختياره ───
          if (controller.paymentType == 2) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.incomplete_circle_rounded,
                          color: Color(0xFFD97706), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'تفاصيل الدفع الجزئي',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'الإجمالي: ${controller.totalAmount.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.paidAmountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                          ],
                          decoration: InputDecoration(
                            labelText: 'المبلغ المدفوع حالياً (ر.س) *',
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          onChanged: (_) => controller.onPaidAmountChanged(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المتبقي للتحصيل',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF991B1B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${controller.currentRemainingAmount.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // طرق الدفع (تظهر فقط عند السداد الكامل أو الدفع الجزئي، وتختفي عند اختيار آجل)
          if (controller.paymentType != 3) ...[
            const SizedBox(height: 14),
            const Text(
              'طريقة الدفع للمبلغ المدفوع:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPaymentChip(
                  label: 'نقداً (كاش)',
                  icon: Icons.money_rounded,
                  isSelected: controller.paymentMethod == 1,
                  onTap: () => controller.setPaymentMethod(1),
                ),
                _buildPaymentChip(
                  label: 'شبكة (مدى / بطاقة)',
                  icon: Icons.credit_card_rounded,
                  isSelected: controller.paymentMethod == 2,
                  onTap: () => controller.setPaymentMethod(2),
                ),
                _buildPaymentChip(
                  label: 'تحويل بنكي',
                  icon: Icons.account_balance_rounded,
                  isSelected: controller.paymentMethod == 3,
                  onTap: () => controller.setPaymentMethod(3),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule_rounded, color: Color(0xFF64748B), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'فاتورة مستحقة بالكامل آجلاً (يتم استلام المبلغ عند تسليم الملابس للعميل)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // حقل الخصم والملاحظات
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller.discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: InputDecoration(
                    labelText: 'خصم (ر.س)',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.discount_outlined, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                  ),
                  onChanged: (_) => controller.updateDiscount(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: controller.notesController,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات الفاتورة',
                    hintText: 'مثال: نشا خفيف، كي سريع...',
                    prefixIcon: const Icon(Icons.note_alt_outlined, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0284C7).withValues(alpha: 0.1)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 4. الشريط السفلي للمجموع وزر الإصدار
  // ──────────────────────────────────────────
  Widget _buildBottomSummaryBar(
      BuildContext context, CreateOrderController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // تفاصيل المجموع
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المجموع (${controller.totalItemCount} قطع):',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${controller.totalAmount.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),

            // زر إصدار الفاتورة
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: controller.isSubmitting
                    ? null
                    : () async {
                        final order = await controller.submitInvoice();
                        if (order != null && context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => InvoiceReceiptDialog(
                              order: order,
                              laundryName: laundryName,
                              onNewOrder: () {
                                Navigator.pop(ctx);
                                controller.resetForm();
                              },
                              onFinish: () {
                                Navigator.pop(ctx);
                                Navigator.pop(context, true); // Return to Dashboard
                              },
                            ),
                          );
                        }
                      },
                child: controller.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'إصدار الفاتورة والحفظ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // نافذة البحث عن العملاء المسجلين
  // ──────────────────────────────────────────
  void _showCustomerSearchDialog(
      BuildContext context, CreateOrderController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'اختيار عميل مسجل في النظام',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث بالاسم أو رقم الجوال...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        onChanged: (val) {
                          controller.searchCustomers(val).then((_) {
                            setModalState(() {});
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: controller.isSearchingCustomers
                            ? const Center(
                                child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                              )
                            : controller.registeredCustomers.isEmpty
                                ? const Center(
                                    child: Text(
                                      'لا يوجد عملاء مسجلين بهذا الاسم أو الرقم',
                                      style: TextStyle(color: Color(0xFF64748B)),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    itemCount: controller.registeredCustomers.length,
                                    separatorBuilder: (_, __) => const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    itemBuilder: (_, i) {
                                      final cust = controller.registeredCustomers[i];
                                      return ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: Color(0xFFE0F2FE),
                                          child: Icon(Icons.person_rounded,
                                              color: Color(0xFF0284C7)),
                                        ),
                                        title: Text(
                                          cust.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        subtitle: Text(
                                          cust.phoneNumber,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                          ),
                                        ),
                                        onTap: () {
                                          controller.selectCustomer(cust);
                                          Navigator.pop(ctx);
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
