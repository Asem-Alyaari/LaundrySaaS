import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/customer_address.dart';

class AddressTypeSelector extends StatelessWidget {
  final AddressType selectedType;
  final ValueChanged<AddressType> onTypeChanged;

  const AddressTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeItem(
            type: AddressType.home,
            label: 'المنزل',
            icon: Icons.home_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTypeItem(
            type: AddressType.work,
            label: 'العمل',
            icon: Icons.business_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTypeItem(
            type: AddressType.other,
            label: 'أخرى',
            icon: Icons.location_on_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeItem({
    required AddressType type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected ? AppColors.primaryGlow : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
