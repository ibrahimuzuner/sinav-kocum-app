import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/mock_exam_model.dart';
import '../../providers/study_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/premium_upgrade_modal.dart';
import 'add_mock_exam_dialog.dart';

class MockExamScreen extends StatefulWidget {
  const MockExamScreen({super.key});

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  void _openAddDialog([MockExamModel? exam]) {
    final studyProvider = context.read<StudyProvider>();
    final userProvider = context.read<UserProvider>();
    final isPro = userProvider.hasProAccess;

    // Ücretsiz kullanıcılarda en fazla 3 deneme sınırı
    if (exam == null && !isPro && studyProvider.mockExams.length >= 3) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const PremiumUpgradeModal(source: 'mock_exam'),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddMockExamDialog(initialExam: exam),
    );
  }

  void _confirmDelete(BuildContext context, MockExamModel exam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Denemeyi Sil'),
        content: Text('"${exam.title}" denemesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              context.read<StudyProvider>().deleteMockExam(exam.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deneme silindi.'),
                  backgroundColor: Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPro = userProvider.hasProAccess;

    final mockExams = studyProvider.mockExams;
    final count = studyProvider.mockExamCount;
    final latest = studyProvider.latestMockExam;
    final highest = studyProvider.highestMockNet;
    final average = studyProvider.averageMockNet;
    final courseAverages = studyProvider.getCourseAverageMockNets();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Deneme Takibi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${userProvider.targetExam} • $count Kayıtlı Deneme',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Yeni Deneme Ekle',
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            onPressed: () => _openAddDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_mock_exam_fab',
        onPressed: () => _openAddDialog(),
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Deneme Ekle',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          studyProvider.loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÜCRETSİZ PLAN KOTA HATIRLATMASI
              if (!isPro)
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const PremiumUpgradeModal(source: 'mock_exam'),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ücretsiz Plan: $count/3 Deneme • Sınırsız net analizi için PRO 🚀',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFD97706)),
                      ],
                    ),
                  ),
                ),

              // 1. ÖZET METRİK KARTLARI
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Toplam',
                      value: '$count',
                      subtitle: 'Deneme',
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFF4F46E5),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Son Net',
                      value: latest != null ? latest.totalNet.toStringAsFixed(1) : '-',
                      subtitle: 'Son Sınav',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF0EA5E9),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'En Yüksek',
                      value: count > 0 ? highest.toStringAsFixed(1) : '-',
                      subtitle: 'Zirve Net',
                      icon: Icons.emoji_events_rounded,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Ortalama',
                      value: count > 0 ? average.toStringAsFixed(1) : '-',
                      subtitle: 'Genel Ort.',
                      icon: Icons.auto_graph_rounded,
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. NET GELİŞİM GRAFİĞİ (LineChart)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Net Gelişim Grafiği',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count Deneme',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (count < 2)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.show_chart_rounded, size: 36, color: Color(0xFF94A3B8)),
                              const SizedBox(height: 8),
                              Text(
                                count == 0
                                    ? 'Henüz deneme kaydetmedin.'
                                    : '1 deneme kaydedildi. Gelişim grafiği için 2. denemeni ekle!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 180,
                        child: _buildNetLineChart(mockExams, isDark),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. DERS BAZLI ORTALAMA NETLER (Eğer deneme varsa)
              if (courseAverages.isNotEmpty) ...[
                const Text(
                  'Ders Bazlı Ortalama Netler',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: courseAverages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (ctx, i) {
                      final entry = courseAverages.entries.elementAt(i);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${entry.value.toStringAsFixed(1)} Net',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. DENEMELER LİSTESİ BAŞLIĞI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Deneme Geçmişi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (count > 0)
                    Text(
                      '$count Deneme',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // DENEME LİSTESİ VEYA BOŞ DURUM
              if (mockExams.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment_add, size: 36, color: Color(0xFF4F46E5)),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Henüz Deneme Kaydı Yok',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Çözdüğün denemeleri kaydederek net artışını ve ders bazlı durumunu buradan takip edebilirsin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _openAddDialog(),
                        icon: const Icon(Icons.add_rounded, color: Colors.white),
                        label: const Text('İlk Denemeni Kaydet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...mockExams.map((exam) => _buildMockExamCard(context, exam, isDark)),

              const SizedBox(height: 80), // FAB boşluğu
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
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
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNetLineChart(List<MockExamModel> exams, bool isDark) {
    // Chronological order for chart: oldest to newest
    final chronological = exams.reversed.toList();
    final spots = <FlSpot>[];
    double minY = 0;
    double maxY = 10;

    for (int i = 0; i < chronological.length; i++) {
      final net = chronological[i].totalNet;
      spots.add(FlSpot(i.toDouble(), net));
      if (net > maxY) maxY = net;
      if (i == 0 || net < minY) minY = net;
    }

    maxY = (maxY * 1.15).ceilToDouble();
    if (minY > 10) minY = (minY - 10).floorToDouble();
    if (minY < 0) minY = 0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 4).clamp(5.0, 50.0),
          getDrawingHorizontalLine: (val) => FlLine(
            color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= chronological.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'D.${idx + 1}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: ((maxY - minY) / 4).clamp(5.0, 50.0),
              getTitlesWidget: (val, meta) {
                return Text(
                  val.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (chronological.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                final exam = (idx >= 0 && idx < chronological.length) ? chronological[idx] : null;
                final title = exam != null ? exam.title : 'Deneme';
                return LineTooltipItem(
                  '$title\n${spot.y.toStringAsFixed(2)} Net',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF4F46E5),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.28),
                  const Color(0xFF4F46E5).withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockExamCard(BuildContext context, MockExamModel exam, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.fact_check_rounded, color: Color(0xFF4F46E5), size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd.MM.yyyy').format(exam.date),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        if (exam.durationMinutes != null) ...[
                          const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8))),
                          Text(
                            '⏱️ ${exam.durationMinutes} dk',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${exam.totalNet.toStringAsFixed(2)} Net',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _buildStatPill('D: ${exam.totalCorrect}', Colors.green),
                const SizedBox(width: 6),
                _buildStatPill('Y: ${exam.totalWrong}', Colors.redAccent),
                const SizedBox(width: 6),
                _buildStatPill('B: ${exam.totalEmpty}', Colors.grey),
                const Spacer(),
                Text(
                  'Başarı: %${exam.accuracyRate}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          children: [
            const Divider(),
            if (exam.notes != null && exam.notes!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note_alt_outlined, size: 16, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        exam.notes!,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // DERS BAZLI DETAYLAR
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ders Dağılımı:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(height: 6),
            ...exam.courseScores.map((score) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        score.courseName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${score.correctCount} D  |  ${score.wrongCount} Y  |  ${score.emptyCount} B',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (score.netScore > 0 ? const Color(0xFF10B981) : Colors.grey)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${score.netScore.toStringAsFixed(1)} Net',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: score.netScore > 0 ? const Color(0xFF10B981) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            // AKSİYON BUTONLARI (Düzenle & Sil)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openAddDialog(exam),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Düzenle'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, exam),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                  label: const Text('Sil', style: TextStyle(color: Color(0xFFEF4444))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
