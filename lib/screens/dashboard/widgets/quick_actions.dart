import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onStartTimer;
  final VoidCallback onAddQuestions;
  final VoidCallback onOpenSchedule;

  const QuickActions({
    super.key,
    required this.onStartTimer,
    required this.onAddQuestions,
    required this.onOpenSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionBtn(
            context,
            icon: Icons.timer_outlined,
            title: 'Sayaç',
            gradient: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
            onTap: onStartTimer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionBtn(
            context,
            icon: Icons.add_circle_outline_rounded,
            title: 'Soru Ekle',
            gradient: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
            onTap: onAddQuestions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionBtn(
            context,
            icon: Icons.calendar_month_rounded,
            title: 'Program',
            gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            onTap: onOpenSchedule,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
