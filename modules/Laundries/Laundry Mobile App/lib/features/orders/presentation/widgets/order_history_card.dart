import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final Function(int newStatus) onStatusChange;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onStatusChange,
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
                      Text(
                        '${order.paymentMethodArabic} • ${order.paymentStatusArabic}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: order.paymentStatus == 2
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
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
                      // قائمة تغيير الحالة السريعة
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
                        onSelected: onStatusChange,
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
}
