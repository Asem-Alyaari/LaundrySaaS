import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class SaudiPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const SaudiPhoneField({
    super.key,
    required this.controller,
    this.label = 'رقم الجوال',
    this.hintText = '05XXXXXXXX',
    this.validator,
    this.onChanged,
  });

  @override
  State<SaudiPhoneField> createState() => _SaudiPhoneFieldState();
}

class _SaudiPhoneFieldState extends State<SaudiPhoneField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (focused) {
            setState(() {
              _isFocused = focused;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isFocused ? AppColors.primaryGlow : AppColors.softShadow,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: widget.validator ??
                    (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال رقم الجوال';
                      }
                      final clean = value.trim();
                      if (!clean.startsWith('05') && !clean.startsWith('5')) {
                        return 'يجب أن يبدأ رقم الجوال بـ 05 أو 5';
                      }
                      if (clean.startsWith('05') && clean.length != 10) {
                        return 'رقم الجوال يجب أن يتكون من 10 أرقام';
                      }
                      if (clean.startsWith('5') && clean.length != 9) {
                        return 'رقم الجوال يجب أن يتكون من 9 أرقام بعد الـ 5';
                      }
                      return null;
                    },
                onChanged: widget.onChanged,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    margin: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🇸🇦',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '+966',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1.2,
                          height: 24,
                          color: AppColors.cardBorder,
                        ),
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 90, minHeight: 44),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.error, width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.error, width: 1.8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
