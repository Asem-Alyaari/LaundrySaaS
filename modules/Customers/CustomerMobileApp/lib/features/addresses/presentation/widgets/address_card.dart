import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/customer_address.dart';

class AddressCard extends StatelessWidget {
  final CustomerAddress address;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (address.isDefault ? AppColors.primaryLight.withValues(alpha: 0.5) : AppColors.cardBorder),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected ? AppColors.primaryGlow : AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── السطر العلوي: نوع العنوان، الاسم، شارة الافتراضي، وزر الإجراءات ───
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getTypeColor(address.type).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        address.typeIcon,
                        size: 22,
                        color: _getTypeColor(address.type),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                address.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              if (address.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.emeraldSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 12, color: AppColors.emerald),
                                      SizedBox(width: 4),
                                      Text(
                                        'افتراضي',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.emerald,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            address.typeLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // قائمة الخيارات (تعديل، حذف، تعيين كافتراضي)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'default':
                            onSetDefault?.call();
                            break;
                          case 'delete':
                            _showDeleteDialog(context);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (!address.isDefault && onSetDefault != null)
                          const PopupMenuItem(
                            value: 'default',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.primary),
                                SizedBox(width: 10),
                                Text('تعيين كافتراضي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                                SizedBox(width: 10),
                                Text('تعديل العنوان', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                SizedBox(width: 10),
                                Text('حذف العنوان', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),

                // ─── تفاصيل العنوان ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.fullAddress,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          if (address.latitude != 0.0 && address.longitude != 0.0) ...[
                            const SizedBox(height: 3),
                            Text(
                              '📍 إحداثيات GPS: ${address.latitude.toStringAsFixed(4)}°, ${address.longitude.toStringAsFixed(4)}°',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // ملاحظات التوصيل إن وجدت
                if (address.deliveryNotes != null && address.deliveryNotes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ملاحظة: ${address.deliveryNotes}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(AddressType type) {
    switch (type) {
      case AddressType.home:
        return AppColors.primary;
      case AddressType.work:
        return AppColors.indigo;
      case AddressType.other:
        return AppColors.emerald;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تأكيد الحذف', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من رغبتك في حذف "${address.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete?.call();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
