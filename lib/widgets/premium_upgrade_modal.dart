import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Kullanıcıya 3 Ay Ücretsiz Deneme durumunu ve Öğrenci / Öğretmen ayrı PRO paketlerini sunan modern modal.
class PremiumUpgradeModal extends StatefulWidget {
  final String source; // 'pdf', 'mock_exam', 'coach', 'teacher', 'general'

  const PremiumUpgradeModal({
    super.key,
    this.source = 'general',
  });

  static Future<void> show(BuildContext context, {String source = 'general'}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PremiumUpgradeModal(source: source),
    );
  }

  @override
  State<PremiumUpgradeModal> createState() => _PremiumUpgradeModalState();
}

class _PremiumUpgradeModalState extends State<PremiumUpgradeModal> {
  late bool _showTeacherPlan;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _showTeacherPlan = widget.source == 'teacher' || userProvider.isTeacher;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool inTrial = userProvider.isInFreeTrial;
    final int remainingDays = userProvider.remainingTrialDays;

    String headlineTitle = _showTeacherPlan ? 'Öğretmen & Koç PRO' : 'Öğrenci PRO Paketi';
    String headlineSubtitle = _showTeacherPlan
        ? 'Öğrencilerini tek panelden yönet, takip et, mesaj at ve ödev ver!'
        : 'Sınav maratonunda rakiplerinin bir adım önüne geç!';

    if (widget.source == 'pdf') {
      headlineTitle = '📄 Renkli PDF Karne & Rapor';
      headlineSubtitle = 'Detaylı PDF karne ve analiz raporu indirme PRO üyelere özeldir.';
    } else if (widget.source == 'mock_exam') {
      headlineTitle = '🎯 Sınırsız Deneme Takibi';
      headlineSubtitle = 'Ücretsiz planda en fazla 3 deneme kaydedebilirsiniz. Sınırsız deneme için PRO\'ya geçin!';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sürükleme Tutamacı
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🎁 3 AY ÜCRETSİZ DENEME BANNERI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inTrial
                              ? 'İlk 3 Ay Ücretsiz Denemen Aktif!'
                              : 'Yeni Üyelere İlk 3 Ay Ücretsiz!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          inTrial
                              ? 'Kalan ücretsiz kullanım süren: $remainingDays gün • Tüm PRO özellikler açık'
                              : '3 ayın sonunda rolüne göre öğrenci veya öğretmen paketine geçebilirsin.',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ROL BAZLI PAKET SEÇİCİ (ÖĞRENCİ / ÖĞRETMEN AYRI)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _showTeacherPlan = false),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_showTeacherPlan ? const Color(0xFF4F46E5) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '🎓 Öğrenci Paketi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: !_showTeacherPlan
                                  ? Colors.white
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _showTeacherPlan = true),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _showTeacherPlan ? const Color(0xFF0EA5E9) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '👨‍🏫 Öğretmen Paketi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _showTeacherPlan
                                  ? Colors.white
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ana Başlık
            Text(
              headlineTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              headlineSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),

            // Seçilen Role Göre Özellikler
            if (!_showTeacherPlan) ...[
              _buildFeatureRow(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: const Color(0xFFEF4444),
                title: 'Renkli PDF Karne ve Analiz Raporu',
                subtitle: 'İstediğin an tek tıkla resmi PDF raporu indir, yazdır, öğretmeninle ve ailenle paylaş.',
                isDark: isDark,
              ),
              const SizedBox(height: 11),
              _buildFeatureRow(
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFF4F46E5),
                title: 'Sınırsız Deneme Sınavı & Net Analizi',
                subtitle: 'Kotasız TYT/AYT/KPSS/LGS denemesi kaydet, net artış grafiklerini incele.',
                isDark: isDark,
              ),
              const SizedBox(height: 11),
              _buildFeatureRow(
                icon: Icons.school_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Öğretmeninden Ödev & Birebir Mesaj',
                subtitle: 'Koç kodunla öğretmenine bağlan, ödevlerini al ve anlık mesajlaş.',
                isDark: isDark,
              ),
              const SizedBox(height: 11),
              _buildFeatureRow(
                icon: Icons.cloud_done_rounded,
                iconColor: const Color(0xFF06B6D4),
                title: 'Bulut Güvencesi & Sıfır Reklam',
                subtitle: 'Tüm verilerin Firebase bulutunda saklanır, telefon değiştirsen de kaybolmaz.',
                isDark: isDark,
              ),
            ] else ...[
              _buildFeatureRow(
                icon: Icons.group_add_rounded,
                iconColor: const Color(0xFF0EA5E9),
                title: 'Altına Sınırsız Öğrenci Ekleme',
                subtitle: 'Öğrencilerini e-posta ile ekle veya sana özel Koç Kodunu paylaşarak anında bağla.',
                isDark: isDark,
              ),
              const SizedBox(height: 11),
              _buildFeatureRow(
                icon: Icons.analytics_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Canlı Çalışma & Soru Çözüm Takibi',
                subtitle: 'Hangi öğrencin bugün kaç dakika çalıştı, kaç soru çözdü ve son deneme neti ne — anlık gör!',
                isDark: isDark,
              ),
              const SizedBox(height: 11),
              _buildFeatureRow(
                icon: Icons.assignment_add,
                iconColor: const Color(0xFF4F46E5),
                title: 'Ödev Verme & Tamamlama Kontrolü',
                subtitle: 'Ders, konu, soru hedefi ve teslim tarihi seçerek ödev ata; öğrenci yapınca anında gör.',
                isDark: isDark,
              ),
              const SizedBox(height: 11),
              _buildFeatureRow(
                icon: Icons.chat_bubble_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Öğrencilerine Anlık Mesaj & Tavsiye',
                subtitle: 'Her öğrenciye birebir motivasyon mesajı ve haftalık çalışma stratejisi gönder.',
                isDark: isDark,
              ),
            ],
            const SizedBox(height: 20),

            // Fiyat Kartı (Öğrenci & Öğretmen Ayrı)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: (_showTeacherPlan ? const Color(0xFF0EA5E9) : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (_showTeacherPlan ? const Color(0xFF0EA5E9) : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _showTeacherPlan ? Icons.workspace_premium_rounded : Icons.star_rounded,
                      color: _showTeacherPlan ? const Color(0xFF0EA5E9) : const Color(0xFFF59E0B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showTeacherPlan ? 'Öğretmen / Koçluk Paketi' : 'Öğrenci PRO Paketi',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _showTeacherPlan
                              ? 'İlk 3 Ay Ücretsiz • Sonrası ₺299 / Ay'
                              : 'İlk 3 Ay Ücretsiz • Sonrası ₺99 / Ay',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Eylem Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showContactDialog(context, userProvider, _showTeacherPlan);
                },
                icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                label: Text(
                  userProvider.isInFreeTrial
                      ? 'Bilgi Al / Üyelik Yönetimi'
                      : '🚀 PRO\'ya Yükselt / Başvur',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showTeacherPlan ? const Color(0xFF0EA5E9) : const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Kapat',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context, UserProvider userProvider, bool isTeacherPlan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: isTeacherPlan ? const Color(0xFF0EA5E9) : const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(isTeacherPlan ? 'Öğretmen PRO Üyelik' : 'Öğrenci PRO Üyelik'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProvider.isAdmin) ...[
              const Text(
                '👑 Sen sistemin Yöneticisisin! Hesabında tüm PRO, Öğretmen ve Yönetici yetkileri sınırsız olarak açıktır.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ] else if (userProvider.isInFreeTrial) ...[
              Text(
                '🎁 İlk 3 aylık ücretsiz deneme süreniz devam ediyor (${userProvider.remainingTrialDays} gün kaldı).\n\n'
                'Deneme süreniz dolduğunda ${isTeacherPlan ? "Öğretmen PRO (₺299/Ay)" : "Öğrenci PRO (₺99/Ay)"} paketini aktif etmek için destek ekibimizle iletişime geçebilirsiniz:',
              ),
              const SizedBox(height: 12),
              _buildContactInfoBox(),
            ] else ...[
              Text(
                'Sınav Koçum ${isTeacherPlan ? "Öğretmen PRO (₺299/Ay)" : "Öğrenci PRO (₺99/Ay)"} üyeliğinizi anında aktif etmek için iletişime geçebilirsiniz:',
              ),
              const SizedBox(height: 12),
              _buildContactInfoBox(),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏢 DereceLab • Sınav Koçum', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('📧 E-posta: sinavkocumapp@gmail.com'),
          SizedBox(height: 4),
          Text('👤 Yönetici: ibrahim.uzuner@icloud.com'),
        ],
      ),
    );
  }
}
