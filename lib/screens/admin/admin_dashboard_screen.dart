import 'package:flutter/material.dart';
import '../../models/user_profile_model.dart';
import '../../services/firebase_service.dart';
import 'support_messages_modal.dart';
import 'widgets/admin_institutions_view.dart';
import 'widgets/student_detail_modal.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserProfileModel> _allStudents = [];
  List<UserProfileModel> _filteredStudents = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tümü';
  int _selectedMainTab = 0; // 0: Kullanıcılar & Sınavlar, 1: Kurum Yönetimi (B2B)

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final users = await AppFirebaseService().fetchAllUsers();
    if (mounted) {
      setState(() {
        _allStudents = users;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final examLower = student.targetExam.toLowerCase();
        final deptLower = student.targetDepartment.toLowerCase();

        // Arama filtresi (Ad, e-posta, bölüm ve sınav türü)
        final matchSearch = query.isEmpty ||
            student.fullName.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query) ||
            examLower.contains(query) ||
            deptLower.contains(query);

        if (!matchSearch) return false;

        // Kategori / Sınav filtresi
        if (_selectedFilter == 'Tümü') return true;
        if (_selectedFilter == 'Premium') return student.isPremiumActive;
        if (_selectedFilter == 'Öğretmenler') return student.isTeacher;
        if (_selectedFilter == 'YKS') {
          return !student.isTeacher && (examLower.contains('yks') || examLower.contains('tyt'));
        }
        if (_selectedFilter == 'Sayısal') {
          return examLower.contains('sayısal') || examLower.contains('sayisal');
        }
        if (_selectedFilter == 'Eşit Ağırlık') {
          return examLower.contains('eşit') || examLower.contains('esit');
        }
        if (_selectedFilter == 'Sözel') {
          return examLower.contains('sözel') || examLower.contains('sozel');
        }
        if (_selectedFilter == 'Sadece TYT') {
          return examLower.contains('tyt');
        }
        if (_selectedFilter == 'KPSS') {
          return !student.isTeacher && examLower.contains('kpss');
        }
        if (_selectedFilter == 'GY-GK') {
          return examLower.contains('kpss') &&
              (examLower.contains('genel') || examLower.contains('kültür') || examLower.contains('kultur'));
        }
        if (_selectedFilter == 'Alan Bilgisi') {
          return examLower.contains('alan');
        }
        if (_selectedFilter == 'LGS') {
          return examLower.contains('lgs');
        }
        if (_selectedFilter == 'AGS & Diğer') {
          final isMain = examLower.contains('yks') ||
              examLower.contains('tyt') ||
              examLower.contains('kpss') ||
              examLower.contains('lgs') ||
              student.isTeacher;
          return !isMain;
        }

        // Birebir dinamik sınav adı eşleşmesi
        if (student.targetExam.trim() == _selectedFilter.trim()) return true;

        return true;
      }).toList();
    });
  }

  void _openStudentDetail(UserProfileModel student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StudentDetailModal(
        student: student,
        onStudentUpdated: _loadStudents,
      ),
    );
  }

  Color _getExamColor(String examName) {
    final lower = examName.toLowerCase();
    if (lower.contains('öğretmen') || lower.contains('ogretmen') || lower.contains('koç')) {
      return const Color(0xFF0EA5E9);
    }
    if (lower.contains('sayısal') || lower.contains('sayisal')) {
      return const Color(0xFF4F46E5);
    }
    if (lower.contains('eşit') || lower.contains('esit') || lower.contains('ea')) {
      return const Color(0xFF7C3AED);
    }
    if (lower.contains('tyt')) {
      return const Color(0xFFF59E0B);
    }
    if (lower.contains('sözel') || lower.contains('sozel')) {
      return const Color(0xFFEC4899);
    }
    if (lower.contains('dil') || lower.contains('ydt')) {
      return const Color(0xFF8B5CF6);
    }
    if (lower.contains('alan')) {
      return const Color(0xFF0D9488);
    }
    if (lower.contains('genel') || lower.contains('kültür') || lower.contains('kultur')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('ön lisans') || lower.contains('on lisans') || lower.contains('ortaöğretim') || lower.contains('eğitim')) {
      return const Color(0xFF059669);
    }
    if (lower.contains('kpss')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('ags')) {
      return const Color(0xFFEA580C);
    }
    if (lower.contains('lgs')) {
      return const Color(0xFF06B6D4);
    }
    if (lower.contains('dgs') || lower.contains('ales')) {
      return const Color(0xFF2563EB);
    }
    if (lower.contains('msü') || lower.contains('msu')) {
      return const Color(0xFFDC2626);
    }
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final teachers = _allStudents.where((s) => s.isTeacher).toList();
    final students = _allStudents.where((s) => !s.isTeacher).toList();
    final studentCount = students.length;
    final teacherCount = teachers.length;
    final premiumCount = _allStudents.where((s) => s.isPremiumActive).length;

    // YKS Grubu
    final yksStudents = students.where((s) {
      final e = s.targetExam.toLowerCase();
      return e.contains('yks') || e.contains('tyt');
    }).toList();
    final yksSayCount = yksStudents.where((s) => s.targetExam.toLowerCase().contains('sayısal') || s.targetExam.toLowerCase().contains('sayisal')).length;
    final yksEaCount = yksStudents.where((s) => s.targetExam.toLowerCase().contains('eşit') || s.targetExam.toLowerCase().contains('esit')).length;
    final yksTytCount = yksStudents.where((s) => s.targetExam.toLowerCase().contains('tyt')).length;
    final yksSozCount = yksStudents.where((s) => s.targetExam.toLowerCase().contains('sözel') || s.targetExam.toLowerCase().contains('sozel')).length;

    // KPSS Grubu
    final kpssStudents = students.where((s) => s.targetExam.toLowerCase().contains('kpss')).toList();
    final kpssGkGyCount = kpssStudents.where((s) => s.targetExam.toLowerCase().contains('genel') || s.targetExam.toLowerCase().contains('kültür') || s.targetExam.toLowerCase().contains('kultur')).length;
    final kpssAlanCount = kpssStudents.where((s) => s.targetExam.toLowerCase().contains('alan')).length;

    // Diğer Sınavlar
    final otherStudents = students.where((s) {
      final e = s.targetExam.toLowerCase();
      return !e.contains('yks') && !e.contains('tyt') && !e.contains('kpss');
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text('Yönetici & Koçluk Paneli', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            Text('Kayıtlı Öğrenciler ve Canlı Veri Takibi', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_unread_rounded, color: Colors.amber),
            tooltip: 'Gelen Destek Mesajları',
            onPressed: () => SupportMessagesModal.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: _loadStudents,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedMainTab = 0),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedMainTab == 0 ? const Color(0xFF4F46E5) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_alt_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Kullanıcılar (${_allStudents.length})',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: _selectedMainTab == 0 ? FontWeight.bold : FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedMainTab = 1),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedMainTab == 1 ? const Color(0xFF4F46E5) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_rounded, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Kurum Yönetimi (B2B)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _selectedMainTab == 1
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: AdminInstitutionsView(
                allUsers: _allStudents,
                onRefreshNeeded: _loadStudents,
              ),
            )
          : RefreshIndicator(
        onRefresh: _loadStudents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ÖZET METRİK KARTLARI (3'lü Eşit ve Simetrik Grid)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBox(
                      title: 'Toplam Öğrenci',
                      value: '$studentCount',
                      subtitle: 'Canlı Firestore',
                      color: const Color(0xFF4F46E5),
                      icon: Icons.people_alt_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricBox(
                      title: 'Öğretmen & Koç',
                      value: '$teacherCount',
                      subtitle: 'Aktif Sınıf/Koç',
                      color: const Color(0xFF0EA5E9),
                      icon: Icons.school_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricBox(
                      title: 'Premium Üye',
                      value: '$premiumCount',
                      subtitle: 'Aktif VIP Koçluk',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.star_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Destek ve Görüş Mesajları Bildirim Kartı
              InkWell(
                onTap: () => SupportMessagesModal.show(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E1B4B), const Color(0xFF1E293B)]
                          : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_unread_rounded, color: Color(0xFF6366F1), size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Öğrenci Destek & Görüş Mesajları (Canlı Gelen Kutusu)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF6366F1), size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. GELİŞMİŞ VE DETAYLI SINAV DAĞILIMI KARTI
              _buildExamDistributionSection(
                students: students,
                teachers: teachers,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // 3. ARAMA ÇUBUĞU
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Öğrenci adı, e-posta, bölüm veya sınav ara...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. HIZLI FİLTRELEME ÇİPLERİ
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tümü (${_allStudents.length})', 'Tümü'),
                    _buildFilterChip('🎓 YKS (${yksStudents.length})', 'YKS'),
                    _buildFilterChip('📐 Sayısal ($yksSayCount)', 'Sayısal'),
                    _buildFilterChip('⚖️ EA ($yksEaCount)', 'Eşit Ağırlık'),
                    _buildFilterChip('⚡ TYT ($yksTytCount)', 'Sadece TYT'),
                    _buildFilterChip('📖 Sözel ($yksSozCount)', 'Sözel'),
                    _buildFilterChip('🏛️ KPSS (${kpssStudents.length})', 'KPSS'),
                    _buildFilterChip('💼 Alan ($kpssAlanCount)', 'Alan Bilgisi'),
                    _buildFilterChip('📋 GY-GK ($kpssGkGyCount)', 'GY-GK'),
                    _buildFilterChip('👨‍🏫 Öğretmenler ($teacherCount)', 'Öğretmenler'),
                    _buildFilterChip('⭐ Premium ($premiumCount)', 'Premium'),
                    _buildFilterChip('📚 Diğer (${otherStudents.length})', 'AGS & Diğer'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. ÖĞRENCİ LİSTESİ BAŞLIĞI & FİLTRE BİLGİSİ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Öğrenciler (${_filteredStudents.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (_selectedFilter != 'Tümü') ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() => _selectedFilter = 'Tümü');
                            _applyFilters();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.close_rounded, size: 13, color: Colors.redAccent),
                                SizedBox(width: 3),
                                Text(
                                  'Filtreyi Temizle',
                                  style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Detay için dokunun',
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 6. LİSTE VEYA YÜKLENİYOR
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4F46E5)),
                        SizedBox(height: 12),
                        Text('Firestore öğrencileri yükleniyor...', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
              else if (_filteredStudents.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_search_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Arama kriterine uygun kullanıcı bulunamadı',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final student = _filteredStudents[index];
                    return _buildStudentCard(student, isDark);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExamDistributionSection({
    required List<UserProfileModel> students,
    required List<UserProfileModel> teachers,
    required bool isDark,
  }) {
    final totalStudents = students.length;
    if (totalStudents == 0) return const SizedBox.shrink();

    // Sınav frekanslarını topla
    final Map<String, int> examFrequency = {};
    for (final s in students) {
      final exam = s.targetExam.trim().isNotEmpty ? s.targetExam.trim() : 'Genel Hazırlık';
      examFrequency[exam] = (examFrequency[exam] ?? 0) + 1;
    }

    final sortedExams = examFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // YKS toplamı
    final yksCount = students.where((s) {
      final e = s.targetExam.toLowerCase();
      return e.contains('yks') || e.contains('tyt');
    }).length;

    // KPSS toplamı
    final kpssCount = students.where((s) => s.targetExam.toLowerCase().contains('kpss')).length;

    // Diğer sınavlar
    final otherCount = totalStudents - yksCount - kpssCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık & Rozet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.pie_chart_rounded, size: 18, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sınav & Branş Dağılımı',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Filtrelemek için sınava dokunun',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$totalStudents Öğrenci',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Ana Aile Özet Kartları (YKS, KPSS, Diğer)
          Row(
            children: [
              _buildFamilyPill(
                title: '🎓 YKS Ailesi',
                count: yksCount,
                percent: (yksCount / totalStudents) * 100,
                color: const Color(0xFF4F46E5),
                isDark: isDark,
                filterKey: 'YKS',
              ),
              const SizedBox(width: 8),
              _buildFamilyPill(
                title: '🏛️ KPSS Ailesi',
                count: kpssCount,
                percent: (kpssCount / totalStudents) * 100,
                color: const Color(0xFF10B981),
                isDark: isDark,
                filterKey: 'KPSS',
              ),
              const SizedBox(width: 8),
              _buildFamilyPill(
                title: '📚 Diğer Sınavlar',
                count: otherCount,
                percent: (otherCount / totalStudents) * 100,
                color: const Color(0xFFEA580C),
                isDark: isDark,
                filterKey: 'AGS & Diğer',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Renkli Oransal İlerleme Çubuğu (Multi-Segment Progress Bar)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 9,
              child: Row(
                children: sortedExams.map((entry) {
                  final color = _getExamColor(entry.key);
                  return Expanded(
                    flex: entry.value,
                    child: Tooltip(
                      message: '${entry.key}: ${entry.value} Öğrenci',
                      child: Container(color: color),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Tüm Sınavların Eşit ve Detaylı Listesi (Wrap / Grid)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortedExams.map((entry) {
              final examName = entry.key;
              final count = entry.value;
              final percent = (count / totalStudents) * 100;
              final color = _getExamColor(examName);
              final isSelected = _selectedFilter == examName;

              return InkWell(
                onTap: () {
                  setState(() {
                    if (_selectedFilter == examName) {
                      _selectedFilter = 'Tümü';
                    } else {
                      _selectedFilter = examName;
                    }
                  });
                  _applyFilters();
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.18)
                        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : color.withValues(alpha: 0.25),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        examName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? color : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$count (%${percent.toStringAsFixed(0)})',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.check_circle_rounded, size: 13, color: color),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyPill({
    required String title,
    required int count,
    required double percent,
    required Color color,
    required bool isDark,
    required String filterKey,
  }) {
    final isSelected = _selectedFilter == filterKey;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = _selectedFilter == filterKey ? 'Tümü' : filterKey;
          });
          _applyFilters();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.2),
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '%${percent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$count Öğrenci',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterKey) {
    final isSelected = _selectedFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF4F46E5),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
        onSelected: (selected) {
          setState(() => _selectedFilter = selected ? filterKey : 'Tümü');
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildStudentCard(UserProfileModel student, bool isDark) {
    final isApple = student.email.toLowerCase().contains('icloud') ||
        student.email.toLowerCase().contains('apple');
    final examColor = _getExamColor(student.targetExam);

    return InkWell(
      onTap: () => _openStudentDetail(student),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: student.isTeacher
                ? const Color(0xFF0EA5E9).withValues(alpha: 0.4)
                : (student.isPremiumActive
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            width: (student.isPremiumActive || student.isTeacher) ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: student.isTeacher
                  ? const Color(0xFF0EA5E9)
                  : (student.isPremiumActive
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF4F46E5)),
              child: student.isTeacher
                  ? const Icon(Icons.school_rounded, color: Colors.white, size: 20)
                  : Text(
                      student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'Ö',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (student.isTeacher)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.school_rounded, size: 12, color: Color(0xFF0EA5E9)),
                              SizedBox(width: 2),
                              Text(
                                'KOÇ',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0EA5E9),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (student.isPremiumActive)
                        Tooltip(
                          message: 'PRO Aktif (${student.remainingPremiumDays} Gün Kaldı)',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 2),
                                Text(
                                  '${student.remainingPremiumDays}g',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isApple)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.apple_rounded, size: 14, color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: examColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: examColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          student.targetExam,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: examColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          student.targetDepartment,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }
}
