import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Kullanıcıya Premium / PRO özelliklerini tanıtan ve yükseltmeye teşvik eden modern modal.
class PremiumUpgradeModal extends StatelessWidget {
  final String source; // 'pdf', 'mock_exam', 'coach', 'general'

  const PremiumUpgradeModal({
    super.key,
    this.source = 'general',
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String headlineTitle = 'Sınav Koçum PRO';
    String headlineSubtitle = 'Sınav maratonunda rakiplerinin bir adım önüne geç!';

    if (source == 'pdf') {
      headlineTitle = '📄 Renkli PDF Karne & Rapor';
      headlineSubtitle = 'Detaylı PDF karne ve analiz raporu indirme PRO üyelere özeldir.';
    } else if (source == 'mock_exam') {
      headlineTitle = '🎯 Sınırsız Deneme Takibi';
      headlineSubtitle = 'Ücretsiz planda en fazla 3 deneme kaydedebilirsiniz. Sınırsız deneme için PRO\'ya geçin!';
    } else if (source == 'coach') {
      headlineTitle = '👨‍🏫 Kişisel Koçluk Desteği';
      headlineSubtitle = 'Koçun İbrahim\'den haftalık özel değerlendirme ve taktikler al!';
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
            const SizedBox(height: 18),

            // Taç İkonu ve Başlık Rozeti
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'ÖĞRENCİ PRO KULÜBÜ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Ana Başlık
            Text(
              headlineTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              headlineSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),

            // Ayrıcalık Maddeleri
            _buildFeatureRow(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: const Color(0xFFEF4444),
              title: 'Renkli PDF Karne ve Analiz Raporu',
              subtitle: 'İstediğin an tek tıkla resmi PDF raporu indir, yazdır, koçunla ve ailenle paylaş.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: Icons.assignment_turned_in_rounded,
              iconColor: const Color(0xFF4F46E5),
              title: 'Sınırsız Deneme Sınavı & Net Analizi',
              subtitle: 'Kotasız TYT/AYT/KPSS denemesi kaydet, ders bazlı net artış eğrilerini canlı incele.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: Icons.psychology_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: 'Haftalık Koç Değerlendirmesi & Tavsiye',
              subtitle: 'Koçun İbrahim çalışmalarını inceler, sana özel haftalık strateji ve motivasyon notu yazar.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: Icons.timer_rounded,
              iconColor: const Color(0xFF10B981),
              title: 'Gelişmiş Pomodoro & Odaklanma Modları',
              subtitle: 'Kütüphane ve çalışma sesleri ile derin odaklanma, ders çalışma süresini 2 katına çıkar.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: Icons.cloud_done_rounded,
              iconColor: const Color(0xFF06B6D4),
              title: 'Ömür Boyu Bulut Güvencesi & Sıfır Reklam',
              subtitle: 'Tüm soruların ve denemelerin Firebase bulutunda güvenle saklanır, asla kaybolmaz.',
              isDark: isDark,
            ),
            const SizedBox(height: 22),

            // Fiyat Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanıtıma Özel Öğrenci Paketi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sadece ₺99 / Ay • İstediğin Zaman İptal',
                          style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Eylem Butonu (Koçla İletişim / Başvuru)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showContactDialog(context, userProvider);
                },
                icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                label: const Text(
                  '🚀 PRO\'ya Yükselt / Bilgi Al',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Vazgeç Butonu
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Şimdilik Ücretsiz Devam Et',
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

  void _showContactDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('PRO Üyelik Başvurusu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProvider.isAdmin) ...[
              const Text(
                '👑 Sen sistemin Yöneticisisin (İbrahim Uzuner)! Hesabında tüm PRO ve Yönetici yetkileri zaten sınırsız olarak açıktır.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ] else ...[
              const Text(
                'Sınav Koçum PRO üyeliği koçun İbrahim tarafından tanımlanmaktadır.\n\n'
                'Üyeliğinizi hemen başlatmak veya havale/EFT ile ödeme bilgisi almak için koçunuzla iletişime geçebilirsiniz:',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('👤 Koç: İbrahim Uzuner', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('📧 E-posta: ibrahim.uzuner@icloud.com'),
                    SizedBox(height: 4),
                    Text('📱 Koçluk İletişimi: Yönetici Onayıyla Anında Aktifleşir'),
                  ],
                ),
              ),
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
}
