import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';

class AddEditDriverDialog extends StatefulWidget {
  final DriverModel? driver;
  final ValueGetter<String?>? getErrorMessage;
  final Future<bool> Function({
    String? id,
    required String fullName,
    required String phoneNumber,
    required String vehicleInfo,
    bool isAvailable,
  }) onSave;

  const AddEditDriverDialog({
    super.key,
    this.driver,
    this.getErrorMessage,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    DriverModel? driver,
    ValueGetter<String?>? getErrorMessage,
    required Future<bool> Function({
      String? id,
      required String fullName,
      required String phoneNumber,
      required String vehicleInfo,
      bool isAvailable,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddEditDriverDialog(
        driver: driver,
        getErrorMessage: getErrorMessage,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditDriverDialog> createState() => _AddEditDriverDialogState();
}

class _AddEditDriverDialogState extends State<AddEditDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _vehicleController;
  late bool _isAvailable;
  bool _isSaving = false;

  bool get isEditing => widget.driver != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.driver?.phoneNumber ?? '');
    _vehicleController = TextEditingController(text: widget.driver?.vehicleInfo ?? '');
    _isAvailable = widget.driver?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await widget.onSave(
      id: widget.driver?.id,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      vehicleInfo: _vehicleController.text.trim(),
      isAvailable: _isAvailable,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'تم تحديث بيانات المندوب بنجاح'
                : 'تمت إضافة المندوب الجديد بنجاح'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final err = widget.getErrorMessage?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err != null && err.isNotEmpty
                ? err
                : 'فشل في حفظ بيانات المندوب، يرجى المحاولة مرة أخرى'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note_rounded : Icons.person_add_rounded,
                      color: const Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? 'تعديل بيانات المندوب' : 'إضافة مندوب توصيل جديد',
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Full Name
              _buildLabel('الاسم الكامل للمندوب', isRequired: true),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hintText: 'مثال: أحمد عبد الله',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى إدخال اسم المندوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone Number
              _buildLabel('رقم الجوال', isRequired: true),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hintText: 'مثال: 0551234567',
                  prefixIcon: Icons.phone_outlined,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى إدخال رقم الجوال';
                  }
                  if (val.trim().length < 9) {
                    return 'رقم الجوال غير مكتمل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Vehicle Info
              _buildLabel('بيانات وسيلة النقل / المركبة', isRequired: false),
              TextFormField(
                controller: _vehicleController,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration(
                  hintText: 'مثال: دباب ياماها / سيارة يارس - أ ب ج 1234',
                  prefixIcon: Icons.two_wheeler_rounded,
                ),
              ),
              const SizedBox(height: 14),

              // Initial Availability Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isAvailable
                              ? Icons.check_circle_outline_rounded
                              : Icons.do_not_disturb_on_outlined,
                          color: _isAvailable
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'متاح فوراً لاستقبال المهام',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (val) => setState(() => _isAvailable = val),
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF10B981),
                      inactiveTrackColor: const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        isEditing ? 'حفظ التعديلات' : 'إضافة المندوب',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF0284C7), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }
}
