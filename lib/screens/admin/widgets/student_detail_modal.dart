import 'package:flutter/material.dart';
import '../../../models/user_profile_model.dart';
import '../../../services/firebase_service.dart';
import '../../../utils/formatters.dart';

/// Ekran görüntüsündeki tasarımla birebir uyumlu Öğrenci Detay Modalı
class StudentDetailModal extends StatefulWidget {
  final UserProfileModel student;
  final VoidCallback onStudentUpdated;

  const StudentDetailModal({
    super.key,
    required this.student,
    required this.onStudentUpdated,
  });

  @override
  State<StudentDetailModal> createState() => _StudentDetailModalState();
}

class _StudentDetailModalState extends State<StudentDetailModal> {
  late bool _isPremium;
  DateTime? _premiumExpiresAt;
  bool _isToggling = false;
  late TextEditingController _coachNoteController;
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    _isPremium = widget.student.isPremiumActive;
    _premiumExpiresAt = widget.student.premiumExpiresAt;
    _coachNoteController = TextEditingController(text: widget.student.coachNote ?? '');
  }

  int get _remainingDays {
    if (!_isPremium) return 0;
    if (_premiumExpiresAt == null) return 90;
    final diffHours = _premiumExpiresAt!.difference(DateTime.now()).inHours;
    if (diffHours <= 0) return 0;
    return (diffHours / 24).ceil();
  }

  @override
  void dispose() {
    _coachNoteController.dispose();
    super.dispose();
  }

  Future<void> _saveCoachNote() async {
    final note = _coachNoteController.text.trim();
    setState(() => _isSavingNote = true);
    final success = await AppFirebaseService().setStudentCoachNote(
      userId: widget.student.id,
      email: widget.student.email,
      coachNote: note,
    );

    if (mounted) {
      setState(() => _isSavingNote = false);
      if (success) {
        widget.onStudentUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('👨‍🏫 Koçluk tavsiyesi öğrencinin profiline başarıyla iletildi!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not kaydedilirken bir sorun oluştu.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _grant90DaysPremium({bool extend = false}) async {
    setState(() => _isToggling = true);
    DateTime newExpiresAt;
    if (extend && _premiumExpiresAt != null && _premiumExpiresAt!.isAfter(DateTime.now())) {
      newExpiresAt = _premiumExpiresAt!.add(const Duration(days: 90));
    } else {
      newExpiresAt = DateTime.now().add(const Duration(days: 90));
    }

    final success = await AppFirebaseService().setStudentPremiumStatus(
      userId: widget.student.id,
      email: widget.student.email,
      isPremium: true,
      customExpiresAt: newExpiresAt,
      durationDays: 90,
    );

    if (mounted) {
      setState(() {
        _isToggling = false;
        if (success) {
          _isPremium = true;
          _premiumExpiresAt = newExpiresAt;
        }
      });

      if (success) {
        widget.onStudentUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '👑 ${widget.student.fullName} öğrencisine 90 Günlük PRO tanımlandı! (${Formatters.formatDateTurkish(newExpiresAt)} tarihine kadar)',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _revokePremium() async {
    setState(() => _isToggling = true);
    final success = await AppFirebaseService().setStudentPremiumStatus(
      userId: widget.student.id,
      email: widget.student.email,
      isPremium: false,
    );

    if (mounted) {
      setState(() {
        _isToggling = false;
        if (success) {
          _isPremium = false;
          _premiumExpiresAt = null;
        }
      });

      if (success) {
        widget.onStudentUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ℹ️ ${widget.student.fullName} öğrencisinin Premium üyeliği kaldırıldı.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF64748B),
          ),
        );
      }
    }
  }

  String _getLoginProviderBadge(String email) {
    final lower = email.toLowerCase();
    if (lower.contains('icloud') || lower.contains('apple')) return 'Apple';
    if (lower.contains('gmail') || lower.contains('google')) return 'Google';
    return 'E-Posta';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = widget.student;
    final provider = _getLoginProviderBadge(student.email);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFDF9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Başlık & Kapat Butonu (Resimdeki Tasarım)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Kullanıcı Detayı · ${student.fullName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Kapat',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. KULLANICI KARTI (Resimdeki Tasarım)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFBF8F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1E9DA),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFEADBCE),
                    child: Text(
                      student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'Ö',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF5A4A3B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İsim ve Rozetler
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              student.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                provider,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Aktif',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            if (_isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '👑 Premium',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // E-posta & ID
                        Text(
                          student.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@id_${student.id.replaceAll("-", "").substring(0, 10)} • Kayıt: ${Formatters.formatDateTurkish(student.createdAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. TOPLAM SÜRE & HEDEF KUTUSU (Resimdeki Tasarım)
            _buildStatCard(
              title: 'GÜNLÜK HEDEF VE ÇALIŞMA SÜRESİ',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.dailyTargetHours} sa',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Planlanan Günlük Çalışma Temposu',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 3. SINAV VE HEDEF BÖLÜM (Resimdeki Tasarım)
            _buildStatCard(
              title: 'HEDEFLENEN SINAV VE BÖLÜM',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.targetExam,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.targetDepartment,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${student.targetScore.toInt()} Taban Puan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${student.targetNet} Hedef Net',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // 4. KOÇLUK DEĞERLENDİRMESİ VE ÖZEL NOT ALANI
            _buildStatCard(
              title: '👨‍🏫 KOÇUN ÖZEL TAVSİYESİ & DEĞERLENDİRMESİ',
              content: Column(
                children: [
                  TextField(
                    controller: _coachNoteController,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Örn: Deneme netlerin çok iyi gidiyor. Bu hafta günde 40 soru geometri ve paragraf çözmeyi ihmal etme!',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _isSavingNote ? null : _saveCoachNote,
                      icon: _isSavingNote
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Koçluk Notunu Kaydet & Öğrenciye İlet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // 5. YÖNETİCİ EYLEMLERİ (90 GÜNLÜK PREMİUM TANIMLAMA & SÜRE TAKİBİ)
            if (_isPremium) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '👑 90 Günlük PRO Aktif • $_remainingDays Gün Kaldı',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (_premiumExpiresAt != null)
                            Text(
                              'Bitiş Tarihi: ${Formatters.formatDateTurkish(_premiumExpiresAt!)}',
                              style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isToggling ? null : () => _grant90DaysPremium(extend: true),
                        icon: _isToggling
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text('+90 Gün Uzat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _isToggling ? null : _revokePremium,
                        icon: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFDC2626)),
                        label: const Text('Üyeliği Kaldır', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFDC2626))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isToggling ? null : () => _grant90DaysPremium(extend: false),
                  icon: _isToggling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.star_rounded),
                  label: const Text(
                    '👑 Öğrenciye 90 Gün Premium Ver',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Kapat Butonu
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required Widget content,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}
