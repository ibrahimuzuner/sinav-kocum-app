import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/formatters.dart';
import 'edit_profile_dialog.dart';
import 'manage_courses_screen.dart';
import '../mock_exams/mock_exam_screen.dart';
import '../admin/admin_dashboard_screen.dart';

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
            _buildSectionHeader('Öğrenci Profili'),
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
                        if (profile.email.isNotEmpty)
                          Text(
                            profile.email,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          profile.targetExam,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.age} Yaşında • Hedef: ${profile.dailyTargetHours} Saat/Gün',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
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
}
