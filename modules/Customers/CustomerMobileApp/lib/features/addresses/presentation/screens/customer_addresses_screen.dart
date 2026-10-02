import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/customer_address.dart';
import '../controllers/customer_address_controller.dart';
import '../widgets/address_card.dart';
import 'map_address_picker_screen.dart';

class CustomerAddressesScreen extends StatelessWidget {
  /// إذا كانت الشاشة مفتوحة لاختيار عنوان لطلب جاري
  final bool isSelectMode;

  const CustomerAddressesScreen({
    super.key,
    this.isSelectMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectMode ? 'اختيار عنوان التوصيل' : 'عناويني المسجلة'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'إضافة عنوان جديد',
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () => _openAddAddress(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<CustomerAddressController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final addresses = controller.addresses;

            if (addresses.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadAddresses(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // شريط توجيهي أنيق
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isSelectMode
                                ? 'اضغط على أي عنوان لاختياره لطلبك الحالي'
                                : 'حدد عنوانك الافتراضي لاستلام وتسليم الغسيل تلقائياً',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // قائمة العناوين
                  ...addresses.map((address) {
                    final isSelected = isSelectMode && (controller.selectedAddress?.id == address.id);
                    return AddressCard(
                      address: address,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelectMode) {
                          controller.selectAddress(address);
                          Navigator.of(context).pop(address);
                        } else {
                          _openEditAddress(context, address);
                        }
                      },
                      onEdit: () => _openEditAddress(context, address),
                      onDelete: () async {
                        final success = await controller.deleteAddress(address.id);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حذف العنوان بنجاح'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      onSetDefault: () async {
                        final success = await controller.setDefault(address.id);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.emerald,
                              behavior: SnackBarBehavior.floating,
                              content: Text('تم تعيين "${address.title}" كعنوان افتراضي ✨'),
                            ),
                          );
                        }
                      },
                    );
                  }),

                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.cardBorder)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _openAddAddress(context),
              icon: const Icon(Icons.add_location_alt_rounded, size: 22),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              label: const Text(
                'إضافة عنوان جديد 📍',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد عناوين محفوظة بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف عنوان منزلك أو عملك الآن لتسهيل وصول المندوب لاستلام وتسليم ملابسك في الموعد المحدد.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _openAddAddress(context),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('إضافة أول عنوان الآن'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddAddress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MapAddressPickerScreen(),
      ),
    );
  }

  void _openEditAddress(BuildContext context, CustomerAddress address) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapAddressPickerScreen(addressToEdit: address),
      ),
    );
  }
}
