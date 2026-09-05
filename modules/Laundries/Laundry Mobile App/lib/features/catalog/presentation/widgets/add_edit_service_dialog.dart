import 'package:flutter/material.dart';
import '../../data/models/service_item_model.dart';
import '../controllers/catalog_controller.dart';
import 'add_category_sheet.dart';

class AddEditServiceSheet extends StatefulWidget {
  final CatalogController controller;
  final ServiceItemModel? itemToEdit;

  const AddEditServiceSheet({
    super.key,
    required this.controller,
    this.itemToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required CatalogController controller,
    ServiceItemModel? itemToEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditServiceSheet(
        controller: controller,
        itemToEdit: itemToEdit,
      ),
    );
  }

  @override
  State<AddEditServiceSheet> createState() => _AddEditServiceSheetState();
}

class _AddEditServiceSheetState extends State<AddEditServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;

  String? _selectedCategoryId;
  String _selectedUnit = 'قطعة';
  bool _isActive = true;
  bool _isSaving = false;

  final List<String> _unitOptions = ['قطعة', 'كيلو', 'طقم', 'متر', 'زوج'];

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(
        text: item != null ? item.price.toStringAsFixed(1) : '');
    _durationController = TextEditingController(
        text: item != null && item.durationHours > 0
            ? item.durationHours.toInt().toString()
            : '24');
    _descriptionController =
        TextEditingController(text: item?.description ?? '');

    if (item != null) {
      _selectedCategoryId = item.categoryId;
      _selectedUnit = item.unit.isNotEmpty ? item.unit : 'قطعة';
      _isActive = item.isActive;
    } else if (widget.controller.categories.isNotEmpty) {
      _selectedCategoryId = widget.controller.selectedCategoryId ??
          widget.controller.categories.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار تصنيف الخدمة')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await widget.controller.saveItem(
      id: widget.itemToEdit?.id,
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      categoryId: _selectedCategoryId!,
      unit: _selectedUnit,
      durationHours: double.tryParse(_durationController.text.trim()) ?? 24.0,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      isActive: _isActive,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(widget.itemToEdit != null
                ? 'تم تحديث بيانات الخدمة بنجاح'
                : 'تمت إضافة الخدمة بنجاح'),
          ),
        );
      } else if (widget.controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(widget.controller.errorMessage!),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isEditing
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEditing
                      ? Icons.edit_note_rounded
                      : Icons.add_circle_outline_rounded,
                  color: isEditing
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEditing ? 'تعديل الخدمة والسعر' : 'إضافة خدمة جديدة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Color(0xFF94A3B8), size: 20),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Form fields
          Flexible(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Service Name
                    _buildLabel('اسم الخدمة', isRequired: true),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      textDirection: TextDirection.rtl,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'يرجى إدخال اسم الخدمة'
                          : null,
                      decoration: _buildInputDecoration(
                        hint: 'مثال: ثوب رجالي (غسيل وكي بخار)',
                        icon: Icons.dry_cleaning_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('التصنيف', isRequired: true),
                        InkWell(
                          onTap: () async {
                            final newCat = await AddCategorySheet.show(
                              context,
                              controller: widget.controller,
                            );
                            if (newCat != null && mounted) {
                              setState(() => _selectedCategoryId = newCat.id);
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.add_rounded,
                                    size: 15, color: Color(0xFF0284C7)),
                                SizedBox(width: 2),
                                Text(
                                  'قسم جديد',
                                  style: TextStyle(
                                    color: Color(0xFF0284C7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      isExpanded: true,
                      items: widget.controller.categories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(
                            c.name,
                            style: const TextStyle(
                                fontSize: 13.5, color: Color(0xFF0F172A)),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCategoryId = val);
                      },
                      decoration: _buildInputDecoration(
                        hint: 'اختر التصنيف',
                        icon: Icons.category_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Price & Duration
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('السعر (ر.س)', isRequired: true),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'مطلوب';
                                  }
                                  if (double.tryParse(v.trim()) == null) {
                                    return 'رقم غير صحيح';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  hint: '0.00',
                                  icon: Icons.payments_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('التجهيز (ساعات)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _durationController,
                                keyboardType: TextInputType.number,
                                decoration: _buildInputDecoration(
                                  hint: '24',
                                  icon: Icons.timer_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Unit Chips
                    _buildLabel('الوحدة'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: _unitOptions.map((unit) {
                        final isSelected = _selectedUnit == unit;
                        return ChoiceChip(
                          label: Text(unit),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedUnit = unit);
                            }
                          },
                          selectedColor: const Color(0xFF0F172A),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    _buildLabel('وصف الخدمة (اختياري)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      textDirection: TextDirection.rtl,
                      decoration: _buildInputDecoration(
                        hint: 'درجة النشا، المعطرات، تفاصيل الغسيل...',
                        icon: Icons.notes_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Active Switch
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الخدمة متاحة للطلب',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Switch.adaptive(
                            value: _isActive,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEditing ? 'حفظ التعديلات' : 'إضافة الخدمة',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        if (isRequired)
          const Text(' *',
              style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
