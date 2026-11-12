import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/premium_upgrade_modal.dart';
import '../admin/admin_dashboard_screen.dart';
import 'widgets/teacher_student_detail_modal.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final int refreshTrigger;
  final VoidCallback? onDataChanged;

  const TeacherDashboardScreen({
    super.key,
    this.refreshTrigger = 0,
    this.onDataChanged,
  });

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final AppFirebaseService _firebaseService = AppFirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<UserProfileModel> _students = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tümü';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void didUpdateWidget(covariant TeacherDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      _loadStudents();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final teacher = userProvider.userProfile;
    if (teacher == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);
    final list = await _firebaseService.fetchStudentsForTeacher(teacher.id);
    if (mounted) {
      setState(() {
        _students = list;
        _isLoading = false;
      });
    }
  }

  void _copyCoachCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Koç kodun ($code) kopyalandı! Öğrencilerinle paylaşabilirsin 📋'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  Future<void> _showAddStudentDialog() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final teacher = userProvider.userProfile;
    if (teacher == null) return;

    if (!userProvider.hasProAccess) {
      PremiumUpgradeModal.show(context);
      return;
    }

    final emailCtrl = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text('Öğrenci Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Öğrencinin uygulamaya kayıtlı (veya kayıt olacağı) e-posta adresini girin. Öğrenci otomatik olarak sınıfınıza bağlanır.',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Öğrenci E-posta Adresi',
                  hintText: 'ornek@ogrenci.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              if (teacher.teacherCode != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alternatif: Öğrencin kayıt olurken "${teacher.teacherCode}" kodunu da girebilir.',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen geçerli bir e-posta adresi girin.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      setModalState(() => isSubmitting = true);
                      final res = await _firebaseService.linkStudentToTeacherByEmail(
                        studentEmail: email,
                        teacher: teacher,
                      );
                      setModalState(() => isSubmitting = false);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);

                      final status = res['status'] as String?;
                      String msg;
                      Color bg = const Color(0xFF10B981);
                      switch (status) {
                        case 'linked':
                          msg = 'Öğrenci başarıyla sınıfınıza eklendi! 🎓';
                          break;
                        case 'invited':
                          msg = 'Davet kaydedildi! Öğrenci $email ile giriş yaptığında otomatik bağlanacak.';
                          bg = const Color(0xFF4F46E5);
                          break;
                        case 'already_linked':
                          msg = 'Bu öğrenci zaten sizin veya başka bir öğretmenin sınıfına bağlı.';
                          bg = Colors.orange;
                          break;
                        case 'is_teacher':
                          msg = 'Bu e-posta adresi bir öğretmen hesabına ait.';
                          bg = Colors.redAccent;
                          break;
                        default:
                          msg = 'Öğrenci eklenirken bir hata oluştu.';
                          bg = Colors.redAccent;
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: bg,
                          ),
                        );
                        _loadStudents();
                        widget.onDataChanged?.call();
                      }
                    },
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Öğrenciyi Ekle'),
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
  }

  void _openStudentDetail(UserProfileModel student, {int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TeacherStudentDetailModal(
        student: student,
        initialTab: initialTab,
        onUpdated: () {
          _loadStudents();
          widget.onDataChanged?.call();
        },
      ),
    );
  }

  List<UserProfileModel> get _filteredStudents {
    final query = _searchController.text.trim().toLowerCase();
    return _students.where((s) {
      if (query.isNotEmpty) {
        final match = s.fullName.toLowerCase().contains(query) ||
            s.email.toLowerCase().contains(query) ||
            s.targetExam.toLowerCase().contains(query);
        if (!match) return false;
      }
      if (_selectedFilter == 'Bugün Çalışanlar') {
        return s.studyStats.studiedToday;
      } else if (_selectedFilter == 'Çalışmayanlar') {
        return !s.studyStats.studiedToday;
      } else if (_selectedFilter == 'YKS' || _selectedFilter == 'LGS' || _selectedFilter == 'KPSS') {
        return s.targetExam.toUpperCase().contains(_selectedFilter);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teacher = userProvider.userProfile;
    final coachCode = teacher?.teacherCode ?? 'KOC-0000';

    final studiedTodayCount = _students.where((s) => s.studyStats.studiedToday).length;
    final pendingHomeworkCount = _students.fold<int>(
      0,
      (sum, s) => sum + s.pendingAssignmentsCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Merhaba, ${userProvider.displayName} Hocam 👨‍🏫',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (userProvider.isPremium) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '👑 PRO',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                  ),
                ] else if (userProvider.isInFreeTrial) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '🎁 ${userProvider.remainingTrialDays}g Ücretsiz',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              'Öğretmen & Koçluk Paneli',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          if (userProvider.isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
                icon: const Icon(Icons.shield_rounded, size: 16, color: Colors.amber),
                label: const Text(
                  'Yönetici',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.amber, width: 1.2),
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Karanlık/Aydınlık Mod',
            icon: Icon(
              settingsProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => settingsProvider.toggleTheme(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudents,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: [
            // Deneme / Üyelik Durumu Uyarısı (Deneme bitmişse veya son 15 gün)
            if (!userProvider.hasProAccess)
              _buildExpiredTrialCard(context)
            else if (!userProvider.isPremium && userProvider.isInFreeTrial)
              _buildTrialInfoBanner(context, userProvider.remainingTrialDays),

            // Koç Kodu & Hızlı Öğrenci Ekle Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF312E81)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Öğretmen Koç Kodunuz',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          coachCode,
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Öğrencilerin bu kodu girerek sınıfına bağlanabilir veya sağ alttan e-posta ile öğrenci ekleyebilirsin.',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyCoachCode(coachCode),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 17),
                          label: const Text('Kodu Kopyala', style: TextStyle(fontSize: 12.5)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showAddStudentDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 17),
                          label: const Text('Öğrenci Ekle', style: TextStyle(fontSize: 12.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3 Özet Metrik Kutusu
            Row(
              children: [
                Expanded(
                  child: _summaryBox(
                    isDark,
                    'Öğrencilerim',
                    '${_students.length}',
                    Icons.groups_rounded,
                    const Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryBox(
                    isDark,
                    'Bugün Çalışan',
                    '$studiedTodayCount',
                    Icons.local_fire_department_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryBox(
                    isDark,
                    'Bekleyen Ödev',
                    '$pendingHomeworkCount',
                    Icons.assignment_late_outlined,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Arama ve Filtre Çubuğu
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Öğrenci adı, e-posta veya sınav ara...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Tümü',
                  'Bugün Çalışanlar',
                  'Çalışmayanlar',
                  'YKS',
                  'LGS',
                  'KPSS',
                ].map((filter) {
                  final selected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Öğrenci Listesi
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredStudents.isEmpty)
              _buildEmptyState(isDark, coachCode)
            else
              ..._filteredStudents.map((s) => _buildStudentCard(isDark, s)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialInfoBanner(BuildContext context, int remainingDays) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '3 Aylık Ücretsiz Denemen Aktif! Kalan süre: $remainingDays gün. Tüm öğretmen özellikleri açık.',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => PremiumUpgradeModal.show(context),
            child: const Text('Paketler', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredTrialCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_clock_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '3 aylık ücretsiz deneme süren sona erdi. Öğrenci ekleme ve koçluk için Öğretmen PRO paketine geçebilirsin.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => PremiumUpgradeModal.show(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Yükselt', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String coachCode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.school_outlined, size: 48, color: Color(0xFF4F46E5)),
          const SizedBox(height: 12),
          Text(
            _students.isEmpty
                ? 'Henüz sınıfınızda öğrenci yok'
                : 'Aramanızla eşleşen öğrenci bulunamadı',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _students.isEmpty
                ? 'Yukarıdaki "Öğrenci Ekle" butonundan e-posta ile öğrenci ekleyebilir veya "$coachCode" kodunu paylaşabilirsiniz.'
                : 'Arama kutusunu temizleyip filtreyi "Tümü" yapabilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(bool isDark, UserProfileModel student) {
    final stats = student.studyStats;
    final studiedToday = stats.studiedToday;
    final pendingHw = student.pendingAssignmentsCount;
    final unreadMsg = student.messages.where((m) => !m.isFromTeacher && !m.isRead).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        onTap: () => _openStudentDetail(student, initialTab: 0),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.14),
                    child: Text(
                      student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                student.fullName,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: (studiedToday ? const Color(0xFF10B981) : Colors.grey)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                studiedToday ? 'Bugün Aktif ✓' : 'Henüz Çalışmadı',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: studiedToday ? const Color(0xFF10B981) : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.targetExam} • ${student.targetDepartment}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (unreadMsg > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadMsg yeni',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Canlı Çalışma Özeti Şeridi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _miniMetric('Bugün', '${stats.todayStudyMinutes} dk'),
                    _miniMetric('Soru', '${stats.todaySolvedQuestions}'),
                    _miniMetric('Seri', '${stats.streakDays} gün'),
                    _miniMetric(
                      'Son Deneme',
                      stats.latestMockNet != null
                          ? '${stats.latestMockNet!.toStringAsFixed(1)} net'
                          : '-',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Hızlı Eylem Butonları
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openStudentDetail(student, initialTab: 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add_task_rounded, size: 16),
                      label: Text(
                        pendingHw > 0 ? 'Ödev Ver ($pendingHw)' : 'Ödev Ver',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openStudentDetail(student, initialTab: 2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('Mesaj At', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryBox(bool isDark, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
      ],
    );
  }
}
