import 'package:flutter/foundation.dart';
import '../../data/models/laundry_report_model.dart';
import '../../data/repositories/reports_repository.dart';

enum DateFilterType {
  today,
  thisWeek,
  thisMonth,
  custom,
}

class ReportsController extends ChangeNotifier {
  final ReportsRepository _repository = ReportsRepository();

  final String tenant;
  final String accessToken;
  final String laundryId;
  final String laundryName;

  ReportsController({
    required this.tenant,
    required this.accessToken,
    required this.laundryId,
    required this.laundryName,
  });

  bool _isLoading = false;
  String? _errorMessage;
  LaundryReportModel? _report;
  DateFilterType _selectedFilter = DateFilterType.today;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LaundryReportModel? get report => _report;
  DateFilterType get selectedFilter => _selectedFilter;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;

  Future<void> loadReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      DateTime? start;
      DateTime? end;
      final now = DateTime.now();

      switch (_selectedFilter) {
        case DateFilterType.today:
          start = DateTime(now.year, now.month, now.day, 0, 0, 0);
          end = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case DateFilterType.thisWeek:
          // Saturday is start of week in Saudi / Middle East (weekday 6)
          final daysToSubtract = (now.weekday % 7 + 1) % 7;
          final startOfWeek = now.subtract(Duration(days: daysToSubtract));
          start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0);
          end = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case DateFilterType.thisMonth:
          start = DateTime(now.year, now.month, 1, 0, 0, 0);
          end = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case DateFilterType.custom:
          start = _customStartDate;
          end = _customEndDate;
          break;
      }

      _report = await _repository.fetchReport(
        tenant: tenant,
        accessToken: accessToken,
        laundryId: laundryId,
        startDate: start,
        endDate: end,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(DateFilterType filter, {DateTime? customStart, DateTime? customEnd}) {
    _selectedFilter = filter;
    if (filter == DateFilterType.custom) {
      _customStartDate = customStart;
      _customEndDate = customEnd;
    }
    loadReport();
  }

  /// Generates a structured Arabic text summary of the daily closure
  String getFormattedClosureText() {
    if (_report == null) return '';

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final s = _report!.summary;
    final p = _report!.paymentBreakdown;
    final st = _report!.statusBreakdown;

    String periodLabel;
    switch (_selectedFilter) {
      case DateFilterType.today:
        periodLabel = 'اليوم ($dateStr)';
        break;
      case DateFilterType.thisWeek:
        periodLabel = 'هذا الأسبوع';
        break;
      case DateFilterType.thisMonth:
        periodLabel = 'هذا الشهر';
        break;
      case DateFilterType.custom:
        periodLabel = 'فترة مخصصة';
        break;
    }

    final buffer = StringBuffer();
    buffer.writeln('📋 *تقرير إقفال الصندوق والمبيعات*');
    buffer.writeln('🏢 *المغسلة:* $laundryName');
    buffer.writeln('📅 *الفترة:* $periodLabel');
    buffer.writeln('⏰ *تاريخ التصدير:* $dateStr ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    buffer.writeln('───────────────────');
    buffer.writeln('💰 *ملخص المبيعات والتحصيل:*');
    buffer.writeln('• إجمالي المبيعات: ${s.totalSales.toStringAsFixed(2)} ر.س');
    buffer.writeln('• إجمالي المحصل: ${s.totalPaid.toStringAsFixed(2)} ر.س');
    buffer.writeln('• إجمالي المتبقي والآجل: ${s.totalRemaining.toStringAsFixed(2)} ر.س');
    buffer.writeln('• إجمالي الطلبات: ${s.totalOrdersCount} طلب');
    buffer.writeln('• إجمالي القطع: ${s.totalItemsCount} قطعة');
    buffer.writeln('───────────────────');
    buffer.writeln('💵 *حركة الصندوق وطرق الدفع:*');
    buffer.writeln('• نقد (كاش في الدرج): ${p.cashAmount.toStringAsFixed(2)} ر.س');
    buffer.writeln('• شبكة (مدى/بطاقة): ${p.cardAmount.toStringAsFixed(2)} ر.س');
    buffer.writeln('• تحويل بنكي: ${p.transferAmount.toStringAsFixed(2)} ر.س');
    buffer.writeln('• مبيعات آجلة: ${p.laterAmount.toStringAsFixed(2)} ر.س');
    buffer.writeln('• إجمالي المقبوضات: ${(p.cashAmount + p.cardAmount + p.transferAmount).toStringAsFixed(2)} ر.س');
    buffer.writeln('───────────────────');
    buffer.writeln('🧺 *حالات الطلبات:*');
    buffer.writeln('• قيد الانتظار: ${st.pendingCount}');
    buffer.writeln('• قيد الغسيل والمعالجة: ${st.processingCount}');
    buffer.writeln('• جاهز للتسليم: ${st.readyCount}');
    buffer.writeln('• مسلّم ومكتمل: ${st.deliveredCount}');
    if (st.cancelledCount > 0) {
      buffer.writeln('• ملغي: ${st.cancelledCount}');
    }

    if (_report!.outstandingDebts.isNotEmpty) {
      buffer.writeln('───────────────────');
      buffer.writeln('⚠️ *الديون المعلقة (${_report!.outstandingDebts.length} فواتير):*');
      for (final debt in _report!.outstandingDebts.take(5)) {
        buffer.writeln('• ${debt.customerName}: ${debt.remainingAmount.toStringAsFixed(2)} ر.س (فاتورة #${debt.orderNumber})');
      }
      if (_report!.outstandingDebts.length > 5) {
        buffer.writeln('  ... بالإضافة إلى ${_report!.outstandingDebts.length - 5} عملاء آخرين');
      }
    }

    buffer.writeln('───────────────────');
    buffer.writeln('تم التوليد آلياً عبر نظام إدارة المغاسل الذكي SaaS');

    return buffer.toString();
  }
}
