import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/customer_auth_controller.dart';
import '../widgets/custom_auth_text_field.dart';
import '../widgets/saudi_phone_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login Controllers
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  bool _rememberMe = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<CustomerAuthController>();
      await auth.checkSavedSession();
      if (mounted && auth.isAuthenticated) {
        _navigateToHome();
      }
    });
  }

  @override
  void dispose() {
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _showWelcomeToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'أهلاً بك في تطبيقنا',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ThemeShowcaseScreen(),
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      final controller = context.read<CustomerAuthController>();
      
      final success = await controller.login(
        identifier: _loginPhoneController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (success && mounted) {
        _showWelcomeToast();
        _navigateToHome();
      }
    }
  }

  Future<void> _submitRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يجب الموافقة على الشروط والأحكام أولاً',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_registerFormKey.currentState!.validate()) {
      final controller = context.read<CustomerAuthController>();
      
      final success = await controller.register(
        fullName: _regNameController.text.trim(),
        phoneNumber: _regPhoneController.text.trim(),
        email: _regEmailController.text.trim(),
        password: _regPasswordController.text,
      );

      if (success && mounted) {
        _showWelcomeToast();
        _navigateToHome();
      }
    }
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.primaryLight, width: 2),
            boxShadow: AppColors.primaryGlow,
          ),
          child: const Icon(
            Icons.local_laundry_service_rounded,
            size: 45,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'تطبيق الغسيل الذكي',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'نعتني بملابسك وكأنها لنا',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSegmentedTabBar(CustomerAuthController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'تسجيل الدخول',
              isSelected: controller.authMode == AuthMode.login,
              onTap: () => controller.switchMode(AuthMode.login),
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              title: 'حساب جديد',
              isSelected: controller.authMode == AuthMode.register,
              onTap: () => controller.switchMode(AuthMode.register),
              activeColor: AppColors.emerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? activeColor : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(CustomerAuthController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تسجيل الدخول برقم الجوال',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SaudiPhoneField(
              controller: _loginPhoneController,
              label: 'رقم الجوال',
            ),
            const SizedBox(height: 16),
            CustomAuthTextField(
              controller: _loginPasswordController,
              label: 'كلمة المرور',
              hintText: 'أدخل كلمة المرور',
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? true;
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'تذكرني',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.isLoading ? null : _submitLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(CustomerAuthController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAuthTextField(
              controller: _regNameController,
              label: 'الاسم الكامل',
              hintText: 'أدخل اسمك الكامل',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SaudiPhoneField(
              controller: _regPhoneController,
              label: 'رقم الجوال',
            ),
            const SizedBox(height: 16),
            CustomAuthTextField(
              controller: _regEmailController,
              label: 'البريد الإلكتروني (اختياري)',
              hintText: 'example@domain.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'الرجاء إدخال بريد إلكتروني صحيح';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomAuthTextField(
              controller: _regPasswordController,
              label: 'كلمة المرور',
              hintText: 'أدخل كلمة المرور',
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                if (value.length < 8) {
                  return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomAuthTextField(
              controller: _regConfirmPasswordController,
              label: 'تأكيد كلمة المرور',
              hintText: 'أعد إدخال كلمة المرور',
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != _regPasswordController.text) {
                  return 'كلمات المرور غير متطابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.emerald,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    children: [
                      const Text(
                        'أوافق على ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Show terms
                        },
                        child: const Text(
                          'الشروط والأحكام',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                      const Text(
                        ' و ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Show privacy policy
                        },
                        child: const Text(
                          'سياسة الخصوصية',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.isLoading ? null : _submitRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Consumer<CustomerAuthController>(
        builder: (context, controller, child) {
          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildBrandHeader(),
                        _buildSegmentedTabBar(controller),
                        
                        // Error Message
                        if (controller.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorSoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        AnimatedCrossFade(
                          firstChild: _buildLoginForm(controller),
                          secondChild: _buildRegisterForm(controller),
                          crossFadeState: controller.authMode == AuthMode.login
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 400),
                          sizeCurve: Curves.fastOutSlowIn,
                          firstCurve: Curves.easeIn,
                          secondCurve: Curves.easeIn,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Guest Mode Button
                        TextButton.icon(
                          onPressed: () async {
                            await controller.continueAsGuest();
                            if (mounted) {
                              _navigateToHome();
                            }
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                          label: const Text(
                            'المتابعة كزائر',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
