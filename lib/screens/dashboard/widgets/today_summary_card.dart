import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../utils/formatters.dart';

class TodaySummaryCard extends StatelessWidget {
  final int totalQuestions;
  final int targetQuestions;
  final double netScore;
  final int correctCount;
  final int wrongCount;
  final int emptyCount;
  final int studyMinutes;
  final int targetMinutes;

  const TodaySummaryCard({
    super.key,
    required this.totalQuestions,
    required this.targetQuestions,
    required this.netScore,
    required this.correctCount,
    required this.wrongCount,
    required this.emptyCount,
    required this.studyMinutes,
    required this.targetMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final questionPercent = (targetQuestions > 0 ? (totalQuestions / targetQuestions) : 0.0)
        .clamp(0.0, 1.0);
    final timePercent = (targetMinutes > 0 ? (studyMinutes / targetMinutes) : 0.0)
        .clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
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
              const Text(
                'Bugünün Çalışma Özeti',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Formatters.formatDateTurkish(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Soru İlerlemesi
              Expanded(
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 34.0,
                      lineWidth: 7.0,
                      percent: questionPercent,
                      center: Text(
                        '%${(questionPercent * 100).toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      progressColor: const Color(0xFF4F46E5),
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Soru Hedefi',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalQuestions / $targetQuestions',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$netScore Net',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 12),
              // Süre İlerlemesi
              Expanded(
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 34.0,
                      lineWidth: 7.0,
                      percent: timePercent,
                      center: Text(
                        '%${(timePercent * 100).toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      progressColor: const Color(0xFF0EA5E9),
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Süre Hedefi',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatMinutesToDuration(studyMinutes),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '/ ${Formatters.formatMinutesToDuration(targetMinutes)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Doğru / Yanlış / Boş rozetleri
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  context,
                  label: 'Doğru',
                  value: '$correctCount',
                  color: const Color(0xFF10B981),
                  icon: Icons.check_circle_rounded,
                ),
                _buildStatChip(
                  context,
                  label: 'Yanlış',
                  value: '$wrongCount',
                  color: const Color(0xFFEF4444),
                  icon: Icons.cancel_rounded,
                ),
                _buildStatChip(
                  context,
                  label: 'Boş',
                  value: '$emptyCount',
                  color: const Color(0xFF94A3B8),
                  icon: Icons.remove_circle_outline_rounded,
                ),
                _buildStatChip(
                  context,
                  label: 'Toplam',
                  value: '$totalQuestions',
                  color: const Color(0xFF6366F1),
                  icon: Icons.format_list_numbered_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
