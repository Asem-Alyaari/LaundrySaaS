import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'features/addresses/presentation/controllers/customer_address_controller.dart';
import 'features/addresses/presentation/screens/customer_addresses_screen.dart';
import 'features/auth/presentation/controllers/customer_auth_controller.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/locker/presentation/screens/locker_map_screen.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerAuthController()),
        ChangeNotifierProvider(create: (_) => CustomerAddressController()),
      ],
      child: MaterialApp(
        title: 'تطبيق العميل | LaundrySaaS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // اللغة والاتجاه: العربية كخيار افتراضي أساسي (RTL)
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthScreen(),
      ),
    );
  }
}

/// شاشة استعراض الثيم القياسي (Showcase Screen)
/// تعرض بوضوح الخط العربي (Cairo)، الألوان، الأزرار، حقول الإدخال، والبطاقات العصرية
class ThemeShowcaseScreen extends StatefulWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  State<ThemeShowcaseScreen> createState() => _ThemeShowcaseScreenState();
}

class _ThemeShowcaseScreenState extends State<ThemeShowcaseScreen> {
  int _selectedCategoryIndex = 0;
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _sampleCategories = [
    {'name': 'الكل', 'icon': Icons.apps_rounded},
    {'name': 'غسيل وكوي', 'icon': Icons.local_laundry_service_rounded},
    {'name': 'تنظيف جاف', 'icon': Icons.dry_cleaning_rounded},
    {'name': 'كوي فقط', 'icon': Icons.iron_rounded},
    {'name': 'مستعجل ⚡', 'icon': Icons.flash_on_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية | خدمات الغسيل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          Consumer<CustomerAuthController>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle_outlined),
                  tooltip: 'الملف الشخصي',
                  onSelected: (value) async {
                    if (value == 'addresses') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CustomerAddressesScreen()),
                      );
                    } else if (value == 'logout') {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.fullName ?? (auth.isGuest ? 'تصفح كزائر 🧺' : 'حسابي'),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          if (auth.currentUser?.email != null && auth.currentUser!.email.isNotEmpty)
                            Text(
                              auth.currentUser!.email,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          if (auth.currentUser?.phoneNumber != null && auth.currentUser!.phoneNumber.isNotEmpty)
                            Text(
                              auth.currentUser!.phoneNumber,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'addresses',
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'عناويني والتوصيل',
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(auth.isGuest ? Icons.login_rounded : Icons.logout_rounded, color: AppColors.error, size: 20),
                          SizedBox(width: 8),
                          Text(
                            auth.isGuest ? 'تسجيل الدخول / إنشاء حساب' : 'تسجيل الخروج',
                            style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. ترويسة ترحيبية بالخط العربي ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppColors.primaryGlow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.clean_hands_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Consumer<CustomerAuthController>(
                            builder: (context, auth, _) {
                              final name = auth.currentUser?.fullName ?? (auth.isGuest ? 'ضيفنا العزيز' : 'العميل');
                              final subtitle = auth.isGuest
                                  ? 'أنت تتصفح كزائر • سجّل حسابك لتأكيد وتتبع الطلبات'
                                  : (auth.currentUser?.email != null && auth.currentUser!.email.isNotEmpty
                                      ? 'حساب موثّق: ${auth.currentUser!.email}'
                                      : 'أهلاً بعودتك لتجربة غسيل استثنائية');
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'أهلاً بك يا $name ✨',
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ─── شريط عنوان التوصيل المحدد ───
              Consumer<CustomerAddressController>(
                builder: (context, addrCtrl, _) {
                  final activeAddress = addrCtrl.selectedAddress;
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CustomerAddressesScreen(isSelectMode: true),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: activeAddress != null ? AppColors.primaryLight : AppColors.cardBorder,
                          width: 1.2,
                        ),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              activeAddress?.typeIcon ?? Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 22,
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
                                      activeAddress != null ? 'التوصيل إلى: ${activeAddress.title}' : 'عنوان التوصيل',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (activeAddress != null && activeAddress.isDefault) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.emeraldSoft,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'رئيسي',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emerald),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeAddress != null
                                      ? activeAddress.shortSummary
                                      : 'اضغط لتحديد أو إضافة عنوان استلام وتسليم الملابس 📍',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ─── 2. حقل البحث والإدخال العصري ───
              Text('حقول الإدخال والبحث', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن مغسلة، خدمة، أو نوع ملابس...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 24),

              // ─── 3. الفلاتر والتصنيفات (Chips) ───
              Text('التصنيفات والخيارات (Chips)', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _sampleCategories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            width: 1.2,
                          ),
                          boxShadow: isSelected ? AppColors.primaryGlow : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 18,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['name'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ─── 4. بطاقات العرض العصرية (Modern Cards) ───
              Text('البطاقات ومؤشرات الحالات', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.local_laundry_service_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'مغسلة النقاء الحديثة',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.warningSoft,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                                          const SizedBox(width: 4),
                                          Text(
                                            '4.9',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: AppColors.warning,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'توصيل سريع • غسيل جاف ومعقم • أسعار تبدأ من 5 ر.س',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'مفتوح الآن للتوصيل',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                            label: const Text('عرض الخدمات'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── 5. شارات الحالات المتوافقة مع دورة حياة الغسيل ───
              Text('شارات الحالات (Status Badges)', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBadge('تم الاستلام', AppColors.infoSoft, AppColors.info),
                  _buildBadge('قيد الغسيل والكي', AppColors.warningSoft, AppColors.warning),
                  _buildBadge('جاهز للتسليم', AppColors.emeraldSoft, AppColors.emerald),
                  _buildBadge('تم التوصيل بنجاح', AppColors.successSoft, AppColors.success),
                  _buildBadge('ملغي', AppColors.errorSoft, AppColors.error),
                ],
              ),

              const SizedBox(height: 28),

              // ─── 6. الأزرار القياسية ───
              Text('الأزرار التفاعلية (Buttons)', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: const Text('زر أساسي (54px) - تأكيد الطلب والدفع'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CustomerAddressesScreen()),
                  );
                },
                icon: const Icon(Icons.location_on_outlined, size: 20),
                label: const Text('إدارة عناويني والتوصيل 📍'),
              ),

              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LockerMapScreen()),
                  );
                },
                icon: const Icon(Icons.lock_outlined, size: 20),
                label: const Text('المعاسل القريبة'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 3) {
            // حسابي -> فتح شاشة العناوين
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomerAddressesScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'طلباتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart_rounded),
            label: 'السلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
