import 'package:flutter/material.dart';

/// لوحة الألوان المركزية لتطبيق العميل (Customer Mobile App)
/// مصممة لتعكس النظافة، الانتعاش، والراحة البصرية العالية بأعلى معايير التباين والوضوح
class AppColors {
  // ─── 1. الألوان الأساسية (Primary & Ocean Brand) ───
  static const Color primary = Color(0xFF0284C7);       // Sky 600 - أزرق منعش يوحي بالنظافة والحيوية
  static const Color primaryDark = Color(0xFF0369A1);   // Sky 700 - أزرق عميق للحالات المركزة
  static const Color primaryLight = Color(0xFF38BDF8);  // Sky 400 - أزرق فاتح لامع
  static const Color primarySoft = Color(0xFFE0F2FE);   // Sky 100 - خلفية ناعمة للشارات والأيقونات
  static const Color primaryUltraSoft = Color(0xFFF0F9FF); // Sky 50

  // ─── 2. الألوان الثانوية والتعزيزية (Secondary & Fresh Mint) ───
  static const Color secondary = Color(0xFF0EA5E9);     // سماوي حيوي
  static const Color emerald = Color(0xFF10B981);       // أخضر زمردي للنجاح والتوفير والتأكيد
  static const Color emeraldSoft = Color(0xFFD1FAE5);   // أخضر ناعم للبطاقات وشارات الإنجاز
  static const Color indigo = Color(0xFF6366F1);        // نيلي للمميزات الخاصة والنقاط

  // ─── 3. ألوان الحالات والنظام (Status & Alerts) ───
  static const Color success = Color(0xFF10B981);       // تم التسليم / الدفع ناجح
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);       // قيد الغسيل / قيد الانتظار
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);         // ملغي / خطأ
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);          // تنبيهات معلوماتية
  static const Color infoSoft = Color(0xFFDBEAFE);

  // ─── 4. الخلفيات والأسطح (Surfaces & Backgrounds) ───
  static const Color background = Color(0xFFF8FAFC);    // رمادي فاتح مريح للعين يقلل الإجهاد
  static const Color surface = Color(0xFFFFFFFF);       // أبيض نقي للبطاقات والحاويات
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);    // حواف ناعمة ودقيقة تفصل العناصر بأناقة
  static const Color divider = Color(0xFFF1F5F9);       // خطوط التقسيم الخفيفة

  // ─── 5. النصوص والتباين (Typography & Contrast) ───
  static const Color textPrimary = Color(0xFF0F172A);   // كحلي فحمي داكن بنسبة تباين مثالية 100%
  static const Color textSecondary = Color(0xFF475569); // رمادي معتدل للأوصاف والتفاصيل
  static const Color textMuted = Color(0xFF94A3B8);     // رمادي خافت للنصوص التوضيحية والـ Placeholders
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ─── 6. التدرجات اللونية الفاخرة (Gradients) ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
  );

  static const LinearGradient freshGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  // ─── 7. الظلال العصرية (Soft Natural Shadows) ───
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}
