import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;
  final bool didStudyToday;

  const StreakCard({
    super.key,
    required this.streakDays,
    required this.didStudyToday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: didStudyToday
              ? [const Color(0xFFF97316), const Color(0xFFEA580C)] // Fire Orange
              : (isDark
                  ? [const Color(0xFF334155), const Color(0xFF1E293B)]
                  : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: didStudyToday
            ? [
                BoxShadow(
                  color: const Color(0xFFF97316).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: didStudyToday ? 0.25 : 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 38,
              color: didStudyToday ? Colors.white : const Color(0xFFF97316),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streakDays > 0
                      ? '$streakDays Günlük Çalışma Serisi! 🔥'
                      : 'Serini Başlat! 🚀',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: didStudyToday
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  didStudyToday
                      ? 'Harika gidiyorsun! Bugün serini korudun ve hedefine yaklaştın.'
                      : 'Bugün henüz çalışmadın. Seriyi korumak için biraz vakit ayır!',
                  style: TextStyle(
                    fontSize: 13,
                    color: didStudyToday
                        ? Colors.white.withValues(alpha: 0.9)
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
