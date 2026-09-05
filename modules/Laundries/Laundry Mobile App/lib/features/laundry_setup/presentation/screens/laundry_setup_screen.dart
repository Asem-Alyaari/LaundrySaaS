import 'package:flutter/material.dart';
import 'laundry_location_screen.dart';

class LaundrySetupScreen extends StatefulWidget {
  final String tenant;
  final String accessToken;

  const LaundrySetupScreen({
    super.key,
    required this.tenant,
    required this.accessToken,
  });

  @override
  State<LaundrySetupScreen> createState() => _LaundrySetupScreenState();
}

class _LaundrySetupScreenState extends State<LaundrySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    super.dispose();
  }

  void _goToLocation() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _errorMessage = 'يرجى استكمال جميع الحقول المطلوبة قبل المتابعة';
      });
      return;
    }

    setState(() => _errorMessage = null);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LaundryLocationScreen(
          tenant: widget.tenant,
          accessToken: widget.accessToken,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          street: _streetController.text.trim(),
          buildingNumber: _buildingController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  // Header Icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFBFDBFE), width: 1),
                    ),
                    child: const Icon(
                      Icons.store_mall_directory_rounded,
                      color: Color(0xFF0284C7),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'إعداد بيانات المغسلة',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'أدخل المعلومات الأساسية لمغسلتك للبدء في استخدام النظام',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFFDC2626), size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Section: معلومات المغسلة
                          _buildSectionHeader(
                            icon: Icons.local_laundry_service_rounded,
                            title: 'معلومات المغسلة',
                          ),
                          const SizedBox(height: 14),

                          _buildTextField(
                            controller: _nameController,
                            label: 'اسم المغسلة',
                            hint: 'مثال: مغسلة النظافة',
                            icon: Icons.store_rounded,
                            maxLength: 128,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'يرجى إدخال اسم المغسلة'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          _buildTextField(
                            controller: _phoneController,
                            label: 'رقم الهاتف',
                            hint: '05XXXXXXXX',
                            icon: Icons.phone_rounded,
                            maxLength: 32,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'يرجى إدخال رقم الهاتف'
                                : null,
                          ),

                          const SizedBox(height: 24),

                          // Section: العنوان
                          _buildSectionHeader(
                            icon: Icons.location_on_rounded,
                            title: 'العنوان',
                          ),
                          const SizedBox(height: 14),

                          _buildTextField(
                            controller: _cityController,
                            label: 'المدينة',
                            hint: 'مثال: الرياض',
                            icon: Icons.location_city_rounded,
                            maxLength: 64,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'يرجى إدخال المدينة'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _districtController,
                                  label: 'الحي',
                                  hint: 'مثال: العليا',
                                  icon: Icons.holiday_village_rounded,
                                  maxLength: 64,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'مطلوب'
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _buildingController,
                                  label: 'رقم المبنى',
                                  hint: '123',
                                  icon: Icons.numbers_rounded,
                                  maxLength: 16,
                                  keyboardType: TextInputType.text,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'مطلوب'
                                          : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _buildTextField(
                            controller: _streetController,
                            label: 'الشارع',
                            hint: 'مثال: شارع الملك فهد',
                            icon: Icons.signpost_rounded,
                            maxLength: 128,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'يرجى إدخال اسم الشارع'
                                : null,
                          ),

                          const SizedBox(height: 28),

                          // Next Button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _goToLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text(
                                'التالي',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    '© ${DateTime.now().year} LaundrySaaS • جميع الحقوق محفوظة',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0284C7)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            hintStyle: const TextStyle(
                color: Color(0xFFCBD5E1), fontSize: 13.5),
            prefixIcon:
                Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF0284C7), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
