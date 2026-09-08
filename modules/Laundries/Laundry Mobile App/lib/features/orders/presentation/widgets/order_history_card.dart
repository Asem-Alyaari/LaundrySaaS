import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final Function(int newStatus) onStatusChange;
  final Future<void> Function(String orderId, double amount, int paymentMethod)? onCollectAndDeliver;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onStatusChange,
    this.onCollectAndDeliver,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusBg = _getStatusBg(order.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. رقم الفاتورة وحالة الطلب ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Color(0xFF0284C7),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.statusArabic,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),

              // ─── 2. بيانات العميل ونوع الحضور ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isWalkIn
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.isWalkIn ? 'حضوري' : 'مسجل',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: order.isWalkIn
                                ? const Color(0xFFB45309)
                                : const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (order.customerPhoneNumber != null &&
                      order.customerPhoneNumber!.isNotEmpty)
                    Text(
                      order.customerPhoneNumber!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // ─── 3. ملخص الخدمات المختارة ───
              if (order.items.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.items.map((i) => '${i.quantity}x ${i.itemName}').join(' • '),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF475569),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ─── 4. التفاصيل المالية وتحديث الحالة ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${order.paymentMethodArabic} • ${order.paymentStatusArabic}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: order.paymentStatus == 2
                                  ? const Color(0xFF059669)
                                  : (order.paymentStatus == 3
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFFDC2626)),
                            ),
                          ),
                          if (order.remainingAmount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'متبقي: ${order.remainingAmount.toStringAsFixed(2)} ر.س',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.creationTime.year}/${order.creationTime.month.toString().padLeft(2, '0')}/${order.creationTime.day.toString().padLeft(2, '0')} ${order.creationTime.hour.toString().padLeft(2, '0')}:${order.creationTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${order.totalAmount.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // ─── قفل الحالة إذا كانت الفاتورة مسلّمة (6) ───
                      if (order.status == 6)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded, size: 13, color: Color(0xFF15803D)),
                              SizedBox(width: 4),
                              Text(
                                'مسلّمة ومقفلة',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // قائمة تغيير الحالة السريعة للفواتير غير المسلمة
                        PopupMenuButton<int>(
                          tooltip: 'تغيير حالة الفاتورة',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.more_vert_rounded,
                                size: 16, color: Color(0xFF64748B)),
                          ),
                          onSelected: (val) {
                            if (val == 6 && order.remainingAmount > 0) {
                              // إذا كان هناك متبقي، نفتح نافذة التحصيل والتسليم
                              _showCollectAndDeliverDialog(context);
                            } else {
                              onStatusChange(val);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.hourglass_empty_rounded, size: 16, color: Color(0xFFF59E0B)),
                                  SizedBox(width: 8),
                                  Text('قيد الانتظار'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 4,
                              child: Row(
                                children: [
                                  Icon(Icons.local_laundry_service_rounded, size: 16, color: Color(0xFF0284C7)),
                                  SizedBox(width: 8),
                                  Text('قيد الغسيل والمعالجة'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 5,
                              child: Row(
                                children: [
                                  Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF10B981)),
                                  SizedBox(width: 8),
                                  Text('جاهز للتسليم'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 6,
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF6366F1)),
                                  SizedBox(width: 8),
                                  Text('مكتمل ومسلّم'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 7,
                              child: Row(
                                children: [
                                  Icon(Icons.cancel_rounded, size: 16, color: Color(0xFFEF4444)),
                                  SizedBox(width: 8),
                                  Text('إلغاء الفاتورة'),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),

              // ─── زر تسليم وتحصيل المتبقي إذا كانت الفاتورة عليها متبقي ولم تسلّم بعد ───
              if (order.status != 6 && order.remainingAmount > 0) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _showCollectAndDeliverDialog(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.handshake_rounded, size: 16, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Text(
                          'تحصيل المتبقي (${order.remainingAmount.toStringAsFixed(2)} ر.س) والتسليم',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return const Color(0xFFD97706); // Amber
      case 2:
      case 3:
      case 4:
        return const Color(0xFF0284C7); // Sky / Blue
      case 5:
        return const Color(0xFF059669); // Emerald / Ready
      case 6:
        return const Color(0xFF6366F1); // Indigo / Completed
      case 7:
        return const Color(0xFFDC2626); // Red / Cancelled
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusBg(int status) {
    switch (status) {
      case 1:
        return const Color(0xFFFEF3C7);
      case 2:
      case 3:
      case 4:
        return const Color(0xFFE0F2FE);
      case 5:
        return const Color(0xFFD1FAE5);
      case 6:
        return const Color(0xFFE0E7FF);
      case 7:
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  void _showCollectAndDeliverDialog(BuildContext context) {
    if (onCollectAndDeliver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'لا يمكن تسليم الفاتورة لأن هناك متبقي قدره ${order.remainingAmount.toStringAsFixed(2)} ر.س يجب تحصيله أولاً.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int selectedMethod = 1; // 1: Cash, 2: Card
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.handshake_rounded,
                            color: Color(0xFF0284C7), size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تحصيل المتبقي وتسليم الفاتورة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'سيتم تسجيل القيد المحاسبي وإقفال الفاتورة نهائياً',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('رقم الفاتورة والعميل:',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                            Text(
                              '${order.orderNumber} • ${order.customerName}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('إجمالي الفاتورة:',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                            Text(
                              '${order.totalAmount.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المدفوع سابقاً:',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF059669))),
                            Text(
                              '${order.paidAmount.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16, color: Color(0xFFE2E8F0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المبلغ المطلوب تحصيله الآن:',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '${order.remainingAmount.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'طريقة تحصيل المتبقي:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => selectedMethod = 1),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedMethod == 1
                                  ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedMethod == 1
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFFCBD5E1),
                                width: selectedMethod == 1 ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.money_rounded,
                                    size: 18,
                                    color: selectedMethod == 1
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(
                                  'نقداً (كاش)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selectedMethod == 1
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: selectedMethod == 1
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => selectedMethod = 2),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedMethod == 2
                                  ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedMethod == 2
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFFCBD5E1),
                                width: selectedMethod == 2 ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.credit_card_rounded,
                                    size: 18,
                                    color: selectedMethod == 2
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(
                                  'شبكة / بطاقة',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selectedMethod == 2
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: selectedMethod == 2
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            setModalState(() => isSubmitting = true);
                            Navigator.pop(sheetCtx);
                            await onCollectAndDeliver!(
                              order.id,
                              order.remainingAmount,
                              selectedMethod,
                            );
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'تحصيل ${order.remainingAmount.toStringAsFixed(2)} ر.س وتسليم الفاتورة',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
