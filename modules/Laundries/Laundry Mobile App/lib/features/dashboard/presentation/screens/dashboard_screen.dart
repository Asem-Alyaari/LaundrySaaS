import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../catalog/presentation/screens/catalog_screen.dart';
import '../../../drivers/presentation/screens/drivers_screen.dart';
import '../../../orders/presentation/screens/create_order_screen.dart';
import '../../../orders/presentation/screens/orders_list_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../laundry_setup/data/models/laundry_dto.dart';
import '../../../laundry_setup/data/repositories/laundry_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  bool _isOpenForOrders = true;
  bool _isLoading = false;
  LaundryDto? _laundry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLaundryProfile();
    });
  }

  Future<void> _loadLaundryProfile() async {
    final auth = context.read<AuthController>();
    setState(() => _isLoading = true);

    try {
      final laundryRepo = LaundryRepository();
      final currentLaundry = await laundryRepo.fetchCurrentLaundry(
        tenant: auth.tenantName ?? '',
        accessToken: auth.accessToken ?? '',
      );

      if (mounted) {
        setState(() {
          _laundry = currentLaundry;
          if (currentLaundry != null) {
            auth.setLaundryId(currentLaundry.id);
            _isOpenForOrders = currentLaundry.isActive;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCatalog() async {
    final auth = context.read<AuthController>();
    String? laundryId = auth.laundryId ?? _laundry?.id;

    if (laundryId == null || laundryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري جلب بيانات المغسلة... يرجى الانتظار'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadLaundryProfile();
      laundryId = auth.laundryId ?? _laundry?.id;
    }

    if (!mounted) return;

    if (laundryId != null && laundryId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CatalogScreen(
            tenant: auth.tenantName ?? '',
            accessToken: auth.accessToken ?? '',
            laundryId: laundryId!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر العثور على معرّف المغسلة، تأكد من استكمال البيانات'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  void _openDrivers() {
    final auth = context.read<AuthController>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriversScreen(
          tenant: auth.tenantName ?? '',
          accessToken: auth.accessToken ?? '',
          laundryId: auth.laundryId ?? _laundry?.id,
        ),
      ),
    );
  }

  Future<void> _openCreateOrder() async {
    final auth = context.read<AuthController>();
    String? laundryId = auth.laundryId ?? _laundry?.id;

    if (laundryId == null || laundryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري جلب بيانات المغسلة... يرجى الانتظار'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadLaundryProfile();
      laundryId = auth.laundryId ?? _laundry?.id;
    }

    if (!mounted) return;

    if (laundryId != null && laundryId.isNotEmpty) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CreateOrderScreen(
            tenant: auth.tenantName ?? '',
            accessToken: auth.accessToken ?? '',
            laundryId: laundryId!,
            laundryName: _laundry?.name ?? 'مغسلتي',
          ),
        ),
      );
      if (result == true && mounted) {
        _loadLaundryProfile();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر العثور على معرّف المغسلة، تأكد من استكمال البيانات'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _openOrdersList() async {
    final auth = context.read<AuthController>();
    String? laundryId = auth.laundryId ?? _laundry?.id;

    if (laundryId == null || laundryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري جلب بيانات المغسلة... يرجى الانتظار'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadLaundryProfile();
      laundryId = auth.laundryId ?? _laundry?.id;
    }

    if (!mounted) return;

    if (laundryId != null && laundryId.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrdersListScreen(
            tenant: auth.tenantName ?? '',
            accessToken: auth.accessToken ?? '',
            laundryId: laundryId!,
            laundryName: _laundry?.name ?? 'مغسلتي',
          ),
        ),
      );
      if (mounted) {
        _loadLaundryProfile();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر العثور على معرّف المغسلة، تأكد من استكمال البيانات'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _openReports() async {
    final auth = context.read<AuthController>();
    String? laundryId = auth.laundryId ?? _laundry?.id;

    if (laundryId == null || laundryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري جلب بيانات المغسلة... يرجى الانتظار'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadLaundryProfile();
      laundryId = auth.laundryId ?? _laundry?.id;
    }

    if (!mounted) return;

    if (laundryId != null && laundryId.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportsScreen(
            tenant: auth.tenantName ?? '',
            accessToken: auth.accessToken ?? '',
            laundryId: laundryId!,
            laundryName: _laundry?.name ?? 'مغسلتي',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر العثور على معرّف المغسلة، تأكد من استكمال البيانات'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'تسجيل الخروج من مغسلتي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'هل أنت متأكد من رغبتك في تسجيل الخروج من لوحة التحكم؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'تأكيد الخروج',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(auth),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0284C7)),
            )
          : RefreshIndicator(
              onRefresh: _loadLaundryProfile,
              color: const Color(0xFF0284C7),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── 1. بطاقة الهوية والترحيب العصرية ───
                    _buildWelcomeCard(auth),

                    const SizedBox(height: 18),

                    // ─── 2. ملخص مؤشرات ومبيعات اليوم ───
                    _buildTodayStatsRow(),

                    const SizedBox(height: 20),

                    // ─── 3. مسار مراحل دورة الغسيل (Orders Pipeline) ───
                    _buildPipelineSection(),

                    const SizedBox(height: 22),

                    // ─── 4. البطاقة البارزة: كتالوج الخدمات والأسعار ───
                    _buildCatalogHeroCard(),

                    const SizedBox(height: 20),

                    // ─── 5. شبكة العمليات السريعة للمغسلة ───
                    _buildOperationsGrid(),

                    const SizedBox(height: 24),

                    // ─── 6. أحدث الطلبات الواردة (Live Feed) ───
                    _buildRecentOrdersSection(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateOrder,
        backgroundColor: const Color(0xFF0284C7),
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
        label: const Text(
          'فاتورة جديدة (POS)',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ─── شريط التطبيق العلوي المنظم ───
  PreferredSizeWidget _buildAppBar(AuthController auth) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1.5,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_laundry_service_rounded,
              color: Color(0xFF0284C7),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مغسلتي',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                _laundry?.name ?? auth.tenantName ?? 'لوحة المشغل',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0284C7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
      actions: [
        // تبديل حالة استقبال الطلبات
        InkWell(
          onTap: () {
            setState(() {
              _isOpenForOrders = !_isOpenForOrders;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isOpenForOrders
                      ? 'تم فتح المغسلة لاستقبال طلبات العملاء'
                      : 'تم تعليق استقبال الطلبات مؤقتاً',
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isOpenForOrders
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOpenForOrders
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : const Color(0xFFEF4444).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _isOpenForOrders
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _isOpenForOrders ? 'مفتوح' : 'مغلق',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isOpenForOrders
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // تسجيل الخروج
        IconButton(
          tooltip: 'تسجيل الخروج',
          icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 22),
          onPressed: () => _showLogoutDialog(context, auth),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── 1. بطاقة الترحيب والهوية ───
  Widget _buildWelcomeCard(AuthController auth) {
    final laundryName = _laundry?.name ?? auth.tenantName ?? 'مغسلتي';
    final addressText = _laundry?.address.city.isNotEmpty == true
        ? '${_laundry!.address.city} - ${_laundry!.address.district}'
        : 'الفرع الرئيسي';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0369A1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      addressText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_rounded, color: Color(0xFF34D399), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'نظام متصل',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'مرحباً بك في $laundryName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'المشغل النشط: ${auth.userName ?? "admin"} • إدارة الطلبات والكتالوج المباشر',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. ملخص مبيعات ونشاط اليوم ───
  Widget _buildTodayStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            title: 'مبيعات اليوم',
            value: '1,420 ر.س',
            subtext: '+12% عن الأمس',
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFF10B981),
            iconBg: const Color(0xFFD1FAE5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            title: 'طلبات اليوم',
            value: '22 طلب',
            subtext: '4 طلبات جديدة',
            icon: Icons.shopping_basket_rounded,
            iconColor: const Color(0xFF0284C7),
            iconBg: const Color(0xFFE0F2FE),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. مسار مراحل دورة الغسيل ───
  Widget _buildPipelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'حالات دورة الغسيل الآن',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'المجموع: 22',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildPipelineBadge('جديدة', '4', const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
            const SizedBox(width: 8),
            _buildPipelineBadge('قيد الغسيل', '8', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
            const SizedBox(width: 8),
            _buildPipelineBadge('جاهزة', '7', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
            const SizedBox(width: 8),
            _buildPipelineBadge('مكتملة', '3', const Color(0xFF6366F1), const Color(0xFFE0E7FF)),
          ],
        ),
      ],
    );
  }

  Widget _buildPipelineBadge(String label, String count, Color color, Color bg) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openOrdersList,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 4. البطاقة البارزة للكتالوج والأسعار ───
  Widget _buildCatalogHeroCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openCatalog,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'كتالوج الخدمات والأسعار',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'مباشر',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'إدارة الأقسام، الخدمات، وتحديد الأسعار الخاصة بمغسلتك',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0284C7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 5. شبكة العمليات السريعة ───
  Widget _buildOperationsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'العمليات وخدمات التشغيل',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _buildOperationTile(
              title: 'مناديب التوصيل',
              subtitle: 'متابعة وتوفر المناديب',
              icon: Icons.delivery_dining_rounded,
              color: const Color(0xFF0284C7),
              onTap: _openDrivers,
            ),
            _buildOperationTile(
              title: 'نقطة البيع (POS)',
              subtitle: 'استقبال وفاتورة فورية',
              icon: Icons.point_of_sale_rounded,
              color: const Color(0xFF0D9488),
              onTap: _openCreateOrder,
            ),
            _buildOperationTile(
              title: 'سجل الفواتير والطلبات',
              subtitle: 'متابعة وحالات الفواتير',
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF6366F1),
              onTap: _openOrdersList,
            ),
            _buildOperationTile(
              title: 'بيانات المغسلة',
              subtitle: 'العنوان وأوقات العمل',
              icon: Icons.storefront_outlined,
              color: const Color(0xFFF59E0B),
              onTap: () {
                _showLaundryInfoDialog();
              },
            ),
            _buildOperationTile(
              title: 'التقارير اليومية',
              subtitle: 'الدخل وحركة الصندوق',
              icon: Icons.analytics_outlined,
              color: const Color(0xFF10B981),
              onTap: _openReports,
            ),
            _buildOperationTile(
              title: 'الطابعة والباركود',
              subtitle: 'إعدادات طباعة الفواتير',
              icon: Icons.print_outlined,
              color: const Color(0xFF8B5CF6),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('إعدادات الطابعة والباركود الحراري قيد التطوير'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 6. قائمة أحدث الطلبات ───
  Widget _buildRecentOrdersSection() {
    final recentOrders = [
      {
        'id': '#1042',
        'customer': 'أحمد الشمري',
        'items': '3 ثياب • 2 شماغ',
        'total': '45 ر.س',
        'status': 'جاهز للتسليم',
        'statusColor': const Color(0xFF10B981),
        'statusBg': const Color(0xFFD1FAE5),
      },
      {
        'id': '#1041',
        'customer': 'خالد العتيبي',
        'items': 'بطانية مزدوجة غسيل خاص',
        'total': '30 ر.س',
        'status': 'قيد الغسيل',
        'statusColor': const Color(0xFFF59E0B),
        'statusBg': const Color(0xFFFEF3C7),
      },
      {
        'id': '#1040',
        'customer': 'فيصل الدوسري',
        'items': '5 قمصان • 2 بنطال',
        'total': '60 ر.س',
        'status': 'طلب جديد',
        'statusColor': const Color(0xFF0284C7),
        'statusBg': const Color(0xFFE0F2FE),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'أحدث طلبات اليوم',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = recentOrders[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        order['id'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['customer'] as String,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order['items'] as String,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order['total'] as String,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: order['statusBg'] as Color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order['status'] as String,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: order['statusColor'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLaundryInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.store_rounded, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              const Text('بيانات المغسلة'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('اسم المغسلة:', _laundry?.name ?? 'غير محدد'),
              _buildInfoRow('رقم الهاتف:', _laundry?.phoneNumber ?? 'غير محدد'),
              _buildInfoRow('المدينة:', _laundry?.address.city ?? 'الرياض'),
              _buildInfoRow('الحي:', _laundry?.address.district ?? 'العروبة'),
              _buildInfoRow('الشارع:', _laundry?.address.street ?? 'الشارع العام'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'لتعديل هذه البيانات يمكنك التواصل مع الدعم الفني أو التحديث من شاشة الإعدادات.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  // ─── 7. شريط التنقل السفلي المخصص ───
  Widget _buildBottomNavBar() {
    return NavigationBar(
      selectedIndex: _currentNavIndex,
      backgroundColor: Colors.white,
      elevation: 8,
      indicatorColor: const Color(0xFF0284C7).withValues(alpha: 0.14),
      onDestinationSelected: (index) {
        if (index == 2) {
          // تبويب الكتالوج: انتقال مباشر
          _openCatalog();
          return;
        }
        setState(() {
          _currentNavIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF0284C7)),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded, color: Color(0xFF0284C7)),
          label: 'الطلبات',
        ),
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category_rounded, color: Color(0xFF0284C7)),
          label: 'الكتالوج',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFF0284C7)),
          label: 'الإعدادات',
        ),
      ],
    );
  }
}
