import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/formatters.dart';
import 'edit_profile_dialog.dart';
import 'manage_courses_screen.dart';
import '../mock_exams/mock_exam_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../widgets/premium_upgrade_modal.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = userProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // BÖLÜM 0: KULLANICI PROFİLİ
          if (profile != null) ...[
            _buildSectionHeader(userProvider.isTeacher ? 'Öğretmen Profili' : 'Öğrenci Profili'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                      : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFC7D2FE),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF4F46E5),
                    child: Text(
                      profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : 'Ö',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (userProvider.isTeacher
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF4F46E5))
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            userProvider.isTeacher ? '👨‍🏫 Öğretmen / Koç' : '🎓 Öğrenci',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: userProvider.isTeacher
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                        if (profile.email.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            profile.email,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          profile.targetExam,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        if (!userProvider.isTeacher) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${profile.age} Yaşında • Hedef: ${profile.dailyTargetHours} Saat/Gün',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF4F46E5), size: 22),
                    tooltip: 'Profili Düzenle',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => EditProfileDialog(profile: profile),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'Yeniden Üye Ol / Bilgileri Sıfırla',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Profili Sıfırla'),
                          content: const Text(
                            'Üyelik bilgilerinizi sıfırlayıp giriş ekranına dönmek istediğinize emin misiniz?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await userProvider.logout();
                              },
                              child: const Text('Sıfırla', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BÖLÜM: ÜYELİK VE PRO DURUMU
            _buildSectionHeader('Üyelik Durumu'),
            if (userProvider.isPremium) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '👑 Sınav Koçum PRO Aktif',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Renkli PDF raporlar, sınırsız deneme sınavları ve koçluk ayrıcalıklarınız açık.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (userProvider.isInFreeTrial && !userProvider.isAdmin) ...[
              InkWell(
                onTap: () => PremiumUpgradeModal.show(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🎁', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İlk 3 Ay Ücretsiz Deneme • ${userProvider.remainingTrialDays} Gün Kaldı',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              userProvider.isTeacher
                                  ? 'Deneme bitiminde Öğretmen Paketi: ₺299 / Ay. Paketleri görmek için dokunun.'
                                  : 'Deneme bitiminde Öğrenci Paketi: ₺99 / Ay. Paketleri görmek için dokunun.',
                              style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
            ] else if (!userProvider.isAdmin) ...[
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const PremiumUpgradeModal(source: 'general'),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.isTeacher
                                  ? '👑 Öğretmen PRO\'ya Yükselt (₺299/Ay)'
                                  : '👑 Öğrenci PRO\'ya Yükselt (₺99/Ay)',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Tüm koçluk, ödev, mesajlaşma & PDF karne özelliklerini açın 🚀',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFF59E0B), size: 14),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // BÖLÜM: ÖĞRETMEN / ÖĞRENCİ BAĞLANTISI
            if (userProvider.isTeacher && userProvider.teacherCode != null) ...[
              _buildSectionHeader('Öğretmen Koç Kodum'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, color: Color(0xFF10B981), size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.teacherCode!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const Text(
                            'Bu kodu öğrencilerinle paylaşarak sınıfına katılmalarını sağlayabilirsin.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kopyala',
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF10B981)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: userProvider.teacherCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Koç kodun (${userProvider.teacherCode}) kopyalandı!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ] else if (userProvider.isStudent) ...[
              _buildSectionHeader('Öğretmen / Koç Bağlantısı'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      userProvider.teacherId != null ? Icons.school_rounded : Icons.qr_code_2_rounded,
                      color: const Color(0xFF4F46E5),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userProvider.teacherId != null
                            ? 'Bağlı Öğretmen: ${userProvider.teacherName ?? "Eğitim Koçu"}'
                            : 'Henüz bir öğretmene bağlı değilsin.',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (userProvider.teacherId != null)
                      TextButton(
                        onPressed: () => userProvider.disconnectTeacher(),
                        child: const Text('Ayır', style: TextStyle(color: Colors.redAccent)),
                      )
                    else
                      TextButton(
                        onPressed: () => _showConnectTeacherDialog(context, userProvider),
                        child: const Text('Kod Gir'),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (userProvider.isAdmin) ...[
              _buildSectionHeader('Yönetici Yetkisi'),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '👑 Yönetici & Koçluk Paneli',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Kayıtlı öğrencileri incele, Premium yetkisi ver ve takip et',
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.amber, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
          // BÖLÜM 1: ÇALIŞMA HEDEFLERİ
          _buildSectionHeader('Çalışma Hedefleri'),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.quiz_outlined, color: Color(0xFF4F46E5)),
                title: const Text('Günlük Hedef Soru', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${settingsProvider.targetQuestions} soru'),
                trailing: DropdownButton<int>(
                  value: settingsProvider.targetQuestions,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 50, child: Text('50')),
                    DropdownMenuItem(value: 75, child: Text('75')),
                    DropdownMenuItem(value: 100, child: Text('100')),
                    DropdownMenuItem(value: 150, child: Text('150')),
                    DropdownMenuItem(value: 200, child: Text('200')),
                  ],
                  onChanged: (val) {
                    if (val != null) settingsProvider.setTargetQuestions(val);
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: Color(0xFF0EA5E9)),
                title: const Text('Günlük Hedef Süre', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(Formatters.formatMinutesToDuration(settingsProvider.targetMinutes)),
                trailing: DropdownButton<int>(
                  value: settingsProvider.targetMinutes,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 60, child: Text('1 saat')),
                    DropdownMenuItem(value: 120, child: Text('2 saat')),
                    DropdownMenuItem(value: 180, child: Text('3 saat')),
                    DropdownMenuItem(value: 240, child: Text('4 saat')),
                    DropdownMenuItem(value: 300, child: Text('5 saat')),
                    DropdownMenuItem(value: 360, child: Text('6 saat')),
                  ],
                  onChanged: (val) {
                    if (val != null) settingsProvider.setTargetMinutes(val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BÖLÜM 2: BİLDİRİMLER VE HATIRLATICI
          _buildSectionHeader('Hatırlatıcı & Bildirimler'),
          _buildCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFFF59E0B)),
                title: const Text('Çalışmadığım Günlerde Uyar', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('O gün henüz ders çalışmadıysan akşam motivasyon hatırlatıcısı al'),
                value: settingsProvider.notificationsEnabled,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (val) => settingsProvider.toggleNotifications(val),
              ),
              if (settingsProvider.notificationsEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule_rounded, color: Color(0xFF4F46E5)),
                  title: const Text('Hatırlatma Saati', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${settingsProvider.reminderHour.toString().padLeft(2, '0')}:${settingsProvider.reminderMinute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: settingsProvider.reminderTime,
                    );
                    if (picked != null) {
                      settingsProvider.setReminderTime(picked);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.send_rounded, color: Color(0xFF10B981)),
                  title: const Text('Bildirimi Test Et', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Telefonuna hemen bir test bildirimi gönderir'),
                  trailing: const Icon(Icons.play_arrow_rounded, color: Color(0xFF10B981)),
                  onTap: () async {
                    await settingsProvider.testNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test bildirimi gönderildi! 🔔'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // BÖLÜM 3: DERS VE İÇERİK YÖNETİMİ
          _buildSectionHeader('İçerik Yönetimi'),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_stories_rounded, color: Color(0xFF8B5CF6)),
                title: const Text('Dersler ve Konular', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Yeni dersler ekle, renklerini ve konularını yönet'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const ManageCoursesScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF4F46E5)),
                title: const Text('Deneme Sınavlarım', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Deneme sınavı sonuçları ve net gelişim analizi'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const MockExamScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BÖLÜM 4: GÖRÜNÜM VE TEMA
          _buildSectionHeader('Görünüm'),
          _buildCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: Icon(
                  settingsProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: const Color(0xFF0EA5E9),
                ),
                title: const Text('Karanlık Mod', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(settingsProvider.isDarkMode ? 'Açık' : 'Kapalı'),
                value: settingsProvider.isDarkMode,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (_) => settingsProvider.toggleTheme(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BÖLÜM 5: UYGULAMA BİLGİSİ
          _buildSectionHeader('Hakkında'),
          _buildCard(
            isDark: isDark,
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8)),
                title: Text('Sınav Çalışma Takip Asistanı', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Versiyon 1.0.0 • iOS & Android Uyumlu'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BÖLÜM 6: OTURUM VE ÇIKIŞ
          _buildSectionHeader('Oturum'),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text(
                  'Hesaptan Çıkış Yap',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                subtitle: const Text('Bu cihazdaki oturumu kapatır ve giriş ekranına döner'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.redAccent),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Çıkış Yap'),
                      content: const Text(
                        'Bu cihazdaki oturumunuzu kapatıp giriş ekranına dönmek istediğinize emin misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await userProvider.logout();
                          },
                          child: const Text('Çıkış Yap'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Future<void> _showConnectTeacherDialog(BuildContext context, UserProvider userProvider) async {
    final codeCtrl = TextEditingController();
    bool loading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Koç Kodu ile Bağlan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: codeCtrl,
            textCapitalization: TextCapitalization.characters,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Öğretmen Koç Kodu',
              hintText: 'Örn: KOC-4821',
              prefixIcon: Icon(Icons.qr_code_2_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final code = codeCtrl.text.trim();
                      if (code.isEmpty) return;
                      setModalState(() => loading = true);
                      final err = await userProvider.connectWithTeacherCode(code);
                      setModalState(() => loading = false);
                      if (!ctx.mounted) return;
                      if (err == null) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${userProvider.teacherName ?? "Öğretmenin"} ile bağlandın! 🎓'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Bağlan'),
            ),
          ],
        ),
      ),
    );
    codeCtrl.dispose();
  }
}
