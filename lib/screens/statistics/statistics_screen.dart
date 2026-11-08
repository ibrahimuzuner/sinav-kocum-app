import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_profile_model.dart';
import '../../services/pdf_report_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/premium_upgrade_modal.dart';
import '../mock_exams/mock_exam_screen.dart';
import 'pdf_preview_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _chartTypeIndex = 0; // 0: Soru Sayısı, 1: Çalışma Süresi
  StatisticsPeriod _selectedPeriod = StatisticsPeriod.weekly;

  String get _periodLabel {
    switch (_selectedPeriod) {
      case StatisticsPeriod.weekly:
        return 'Son 7 Gün';
      case StatisticsPeriod.monthly:
        return 'Son 30 Gün';
      case StatisticsPeriod.allTime:
        return 'Tüm Zamanlar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filtrelenmiş veriler
    final periodLogs = studyProvider.getQuestionLogsForPeriod(_selectedPeriod);
    final periodSessions = studyProvider.getStudySessionsForPeriod(_selectedPeriod);

    final totalQuestions = periodLogs.fold(0, (sum, i) => sum + i.totalQuestions);
    final totalNet = periodLogs.fold(0.0, (sum, i) => sum + i.netScore);
    final totalStudyMinutes = periodSessions.fold(0, (sum, s) => sum + s.durationMinutes);

    // Grafik verileri
    final isWeekly = _selectedPeriod == StatisticsPeriod.weekly;
    final List<int> chartData = isWeekly
        ? (_chartTypeIndex == 0 ? studyProvider.getWeeklyQuestionsData() : studyProvider.getWeeklyMinutesData())
        : (_chartTypeIndex == 0 ? studyProvider.getMonthlyQuestionsByWeek() : studyProvider.getMonthlyMinutesByWeek());

    final barCount = isWeekly ? 7 : 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistik ve Analiz'),
        actions: [
          IconButton(
            tooltip: 'Deneme Sınavı Takibi',
            icon: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF4F46E5)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const MockExamScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'İstatistik Raporu Al',
            icon: const Icon(Icons.summarize_outlined, color: Color(0xFF4F46E5)),
            onPressed: () => _showReportModal(context, studyProvider, userProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DÖNEM SEÇİM BUTONLARI (Haftalık / Aylık / Tümü)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildPeriodFilterBtn('📅 Haftalık', StatisticsPeriod.weekly)),
                  Expanded(child: _buildPeriodFilterBtn('🗓️ Aylık', StatisticsPeriod.monthly)),
                  Expanded(child: _buildPeriodFilterBtn('🌐 Tümü', StatisticsPeriod.allTime)),
                ],
              ),
            ),

            // 2. RAPOR AL HIZLI AKSİYON BANNER'I
            InkWell(
              onTap: () => _showReportModal(context, studyProvider, userProvider),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPeriod == StatisticsPeriod.weekly
                                ? 'Haftalık İstatistik & PDF Raporu Al'
                                : (_selectedPeriod == StatisticsPeriod.monthly
                                    ? 'Aylık İstatistik & PDF Raporu Al'
                                    : 'Genel Başarı & PDF Raporu Al'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _selectedPeriod == StatisticsPeriod.weekly
                                ? 'PDF olarak kaydet, yazdır veya detaylı özeti paylaş'
                                : (_selectedPeriod == StatisticsPeriod.monthly
                                    ? 'Son 30 günün PDF karnesi ve ders analizi'
                                    : 'Tüm zamanların PDF ders karnesi'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),

            // 3. SEÇİLEN DÖNEMİN METRİK KARTLARI
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Toplam Soru',
                    value: '$totalQuestions',
                    subtitle: _periodLabel,
                    color: const Color(0xFF4F46E5),
                    icon: Icons.quiz_outlined,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Toplam Net',
                    value: totalNet.toStringAsFixed(1),
                    subtitle: _periodLabel,
                    color: const Color(0xFF10B981),
                    icon: Icons.auto_graph_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Çalışma',
                    value: Formatters.formatMinutesToDuration(totalStudyMinutes),
                    subtitle: _periodLabel,
                    color: const Color(0xFF0EA5E9),
                    icon: Icons.access_time_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. GRAFİK KARTI
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isWeekly ? 'Haftalık Performans' : 'Aylık Performans',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTabBtn('Soru', 0),
                            _buildTabBtn('Süre', 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(chartData),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final label = isWeekly
                                  ? _getDayLabel(group.x.toInt())
                                  : '${group.x.toInt() + 1}. Hafta';
                              final unit = _chartTypeIndex == 0 ? 'soru' : 'dk';
                              return BarTooltipItem(
                                '$label\n${rod.toY.toInt()} $unit',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final label = isWeekly
                                    ? _getDayLabel(value.toInt())
                                    : '${value.toInt() + 1}.H';
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    label,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                  ),
                                );
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(barCount, (index) {
                          final val = chartData[index].toDouble();
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: val,
                                color: _chartTypeIndex == 0
                                    ? const Color(0xFF4F46E5)
                                    : const Color(0xFF0EA5E9),
                                width: isWeekly ? 16 : 28,
                                borderRadius: BorderRadius.circular(6),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: _getMaxY(chartData),
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. DERS BAZLI BAŞARI ANALİZİ (Seçilen döneme göre)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ders Bazlı Başarı Analizi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _periodLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...studyProvider.courses.map((course) {
              final courseLogs = periodLogs.where((l) => l.courseId == course.id).toList();
              final totalQ = courseLogs.fold(0, (sum, l) => sum + l.totalQuestions);
              final correct = courseLogs.fold(0, (sum, l) => sum + l.correctCount);
              final wrong = courseLogs.fold(0, (sum, l) => sum + l.wrongCount);
              final net = courseLogs.fold(0.0, (sum, l) => sum + l.netScore);
              final accuracy = totalQ > 0 ? (correct / totalQ) * 100 : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(course.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            course.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$totalQ Soru',
                          style: TextStyle(
                            fontSize: 13,
                            color: totalQ > 0 ? null : const Color(0xFF94A3B8),
                            fontWeight: totalQ > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (totalQ > 0 ? const Color(0xFF10B981) : const Color(0xFF94A3B8))
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${net.toStringAsFixed(1)} Net',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: totalQ > 0 ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (totalQ > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Doğruluk Oranı: %${accuracy.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          Text(
                            'D: $correct | Y: $wrong',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: accuracy / 100,
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(course.colorValue)),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilterBtn(String label, StatisticsPeriod period) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () => setState(() => _selectedPeriod = period),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBtn(String label, int index) {
    final isSelected = _chartTypeIndex == index;
    return InkWell(
      onTap: () => setState(() => _chartTypeIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  double _getMaxY(List<int> data) {
    int maxVal = 10;
    for (final v in data) {
      if (v > maxVal) maxVal = v;
    }
    return (maxVal * 1.2).ceilToDouble();
  }

  String _getDayLabel(int index) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - index));
    return Formatters.formatDayOfWeekShort(day.weekday);
  }

  /// Detaylı İstatistik & Analiz Raporu Bottom Sheet
  void _showReportModal(BuildContext context, StudyProvider studyProvider, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final periodLogs = studyProvider.getQuestionLogsForPeriod(_selectedPeriod);
    final periodSessions = studyProvider.getStudySessionsForPeriod(_selectedPeriod);

    final totalQ = periodLogs.fold(0, (sum, i) => sum + i.totalQuestions);
    final totalCorrect = periodLogs.fold(0, (sum, i) => sum + i.correctCount);
    final totalWrong = periodLogs.fold(0, (sum, i) => sum + i.wrongCount);
    final totalEmpty = periodLogs.fold(0, (sum, i) => sum + i.emptyCount);
    final totalNet = periodLogs.fold(0.0, (sum, i) => sum + i.netScore);
    final totalMinutes = periodSessions.fold(0, (sum, s) => sum + s.durationMinutes);

    final divisorDays = _selectedPeriod == StatisticsPeriod.weekly ? 7 : (_selectedPeriod == StatisticsPeriod.monthly ? 30 : 1);
    final dailyAvgQuestions = (totalQ / divisorDays).toStringAsFixed(1);
    final dailyAvgMinutes = (totalMinutes / divisorDays).round();

    // En Başarılı ve En Zayıf Dersleri Bul
    String bestCourse = '-';
    double bestNet = -1;
    String weakCourse = '-';
    double lowestAccuracy = 101;

    for (final c in studyProvider.courses) {
      final cLogs = periodLogs.where((l) => l.courseId == c.id).toList();
      final q = cLogs.fold(0, (sum, l) => sum + l.totalQuestions);
      final cor = cLogs.fold(0, (sum, l) => sum + l.correctCount);
      final net = cLogs.fold(0.0, (sum, l) => sum + l.netScore);

      if (q > 0) {
        if (net > bestNet) {
          bestNet = net;
          bestCourse = '${c.name} (${net.toStringAsFixed(1)} Net)';
        }
        final acc = (cor / q) * 100;
        if (acc < lowestAccuracy) {
          lowestAccuracy = acc;
          weakCourse = '${c.name} (%${acc.toInt()} Başarı)';
        }
      }
    }

    final overallAccuracy = totalQ > 0 ? ((totalCorrect / totalQ) * 100).toStringAsFixed(1) : '0';
    final isPro = userProvider.isPremium || userProvider.isAdmin;

    // Rapor metni (Kopyalama için)
    final reportText = '''
📊 SINAV KOÇUM - $_periodLabel ANALİZ RAPORU 🎓
-----------------------------------------
👤 Öğrenci: ${userProvider.displayName}
🎯 Hedef Bölüm & Puan: ${userProvider.targetDepartment} (${userProvider.targetScore.toInt()} Puan)
📚 Sınav: ${userProvider.targetExam}
📅 Dönem: $_periodLabel

📈 ÖZET PERFORMANS:
• Toplam Soru: $totalQ
• Doğru: $totalCorrect | Yanlış: $totalWrong | Boş: $totalEmpty
• Toplam Net: ${totalNet.toStringAsFixed(2)}
• Doğruluk Oranı: %$overallAccuracy
• Toplam Çalışma Süresi: ${Formatters.formatMinutesToDuration(totalMinutes)}
• Günlük Ortalama: $dailyAvgQuestions Soru / $dailyAvgMinutes Dk

🏆 En Başarılı Ders: $bestCourse
💡 Geliştirilmesi Gereken Ders: $weakCourse

Sınav Koçum ile hedefine emin adımlarla ilerle! 🚀
''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Başlık & Kapatma Butonu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.analytics_rounded, color: Color(0xFF4F46E5), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_periodLabel Analiz Raporu',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${userProvider.displayName} • ${userProvider.targetDepartment} (${userProvider.targetScore.toInt()} Puan)',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Kart 1: Özet Veriler
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildReportStat('Toplam Soru', '$totalQ', const Color(0xFF4F46E5)),
                          _buildReportStat('Toplam Net', totalNet.toStringAsFixed(1), const Color(0xFF10B981)),
                          _buildReportStat('Doğruluk', '%$overallAccuracy', const Color(0xFFF59E0B)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildReportStat('Doğru/Yanlış', '$totalCorrect D / $totalWrong Y', null),
                          _buildReportStat('Toplam Süre', Formatters.formatMinutesToDuration(totalMinutes), const Color(0xFF0EA5E9)),
                          _buildReportStat('Günlük Ort.', '$dailyAvgQuestions Soru', null),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kart 2: Ders Liderleri
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.military_tech_rounded, color: Color(0xFFF59E0B), size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            'En Başarılı Ders:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bestCourse,
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            'Geliştirilmesi Gereken:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              weakCourse,
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. PDF Olarak İndir / Yazdır Butonu
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _exportPdf(context, studyProvider, userProvider, isShare: false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'PDF Raporunu İndir / Yazdır',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (!isPro) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('👑 PRO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. PDF Paylaş ve Metin Kopyala Butonları (Yan Yana)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _exportPdf(context, studyProvider, userProvider, isShare: true);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.share_rounded, size: 18, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              const Text(
                                'PDF Paylaş',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                              ),
                              if (!isPro) ...[
                                const SizedBox(width: 4),
                                const Text('👑', style: TextStyle(fontSize: 10)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: reportText));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rapor panoya kopyalandı! 📋✅'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF4F46E5),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF4F46E5)),
                          label: const Text(
                            'Metni Kopyala',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportStat(String label, String value, Color? color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _exportPdf(BuildContext context, StudyProvider studyProvider, UserProvider userProvider, {required bool isShare}) async {
    final isPro = userProvider.isPremium || userProvider.isAdmin;
    if (!isPro) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const PremiumUpgradeModal(source: 'pdf'),
      );
      return;
    }

    final profile = userProvider.userProfile ?? UserProfileModel(
      id: 'temp',
      firstName: userProvider.displayName,
      lastName: '',
      email: userProvider.email,
      birthDate: DateTime(2005, 1, 1),
      targetExam: userProvider.targetExam,
      dailyTargetHours: userProvider.dailyTargetHours,
      createdAt: DateTime.now(),
    );

    final periodLogs = studyProvider.getQuestionLogsForPeriod(_selectedPeriod);
    final periodSessions = studyProvider.getStudySessionsForPeriod(_selectedPeriod);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📄 PDF Raporu hazırlanıyor...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final pdfBytes = await PdfReportService.generateReportPdf(
        user: profile,
        period: _selectedPeriod,
        periodLogs: periodLogs,
        periodSessions: periodSessions,
        courses: studyProvider.courses,
        mockExams: studyProvider.mockExams,
        streak: studyProvider.streak,
      );

      final fileName = 'SinavKocum_Rapor_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

      if (!context.mounted) return;

      // Hem PDF Önizleme ekranını aç hem de cihaz indirmesini tetikle
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            pdfBytes: pdfBytes,
            fileName: fileName,
          ),
        ),
      );

      // Web ve cihaz indirme / paylaşma akışını başlat
      await PdfReportService.sharePdf(
        user: profile,
        period: _selectedPeriod,
        periodLogs: periodLogs,
        periodSessions: periodSessions,
        courses: studyProvider.courses,
        mockExams: studyProvider.mockExams,
        streak: studyProvider.streak,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken bir hata oluştu: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
