import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColorValue = 0xFF4F46E5;
  int _targetDailyQuestions = 30;

  static const List<int> _availableColors = [
    0xFF4F46E5, // Indigo
    0xFF2563EB, // Blue
    0xFF0284C7, // Sky
    0xFF0D9488, // Teal
    0xFF059669, // Emerald
    0xFF16A34A, // Green
    0xFFD97706, // Amber
    0xFFEA580C, // Orange
    0xFFDC2626, // Red
    0xFFE11D48, // Rose
    0xFF7C3AED, // Violet
    0xFF9333EA, // Purple
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
            const SizedBox(height: 16),
            const Text(
              'Yeni Ders Ekle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Ders Adı
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ders Adı',
                hintText: 'Örn: Edebiyat, Mantık, KPSS Vatandaşlık',
              ),
            ),
            const SizedBox(height: 16),

            // Renk Seçimi
            const Text(
              'Ders Rengi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: _availableColors.map((colorVal) {
                final isSelected = _selectedColorValue == colorVal;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorValue = colorVal),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(colorVal).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Günlük Hedef Soru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Günlük Hedef Soru:', style: TextStyle(fontWeight: FontWeight.w600)),
                DropdownButton<int>(
                  value: _targetDailyQuestions,
                  items: const [
                    DropdownMenuItem(value: 20, child: Text('20 Soru')),
                    DropdownMenuItem(value: 30, child: Text('30 Soru')),
                    DropdownMenuItem(value: 40, child: Text('40 Soru')),
                    DropdownMenuItem(value: 50, child: Text('50 Soru')),
                    DropdownMenuItem(value: 75, child: Text('75 Soru')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _targetDailyQuestions = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Kaydet
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    await studyProvider.addCourse(
                      name,
                      _selectedColorValue,
                      targetDaily: _targetDailyQuestions,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Dersi Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
