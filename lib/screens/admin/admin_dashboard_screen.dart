import 'package:flutter/material.dart';
import '../../models/user_profile_model.dart';
import '../../services/firebase_service.dart';
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
  String _selectedFilter = 'Tümü'; // Tümü, KPSS, YKS, LGS, Premium

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
        // Arama filtresi
        final matchSearch = query.isEmpty ||
            student.fullName.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query) ||
            student.targetDepartment.toLowerCase().contains(query);

        // Kategori filtresi
        bool matchCategory = true;
        if (_selectedFilter == 'KPSS') {
          matchCategory = student.targetExam.toLowerCase().contains('kpss');
        } else if (_selectedFilter == 'YKS') {
          matchCategory = student.targetExam.toLowerCase().contains('yks') ||
              student.targetExam.toLowerCase().contains('tyt');
        } else if (_selectedFilter == 'LGS') {
          matchCategory = student.targetExam.toLowerCase().contains('lgs');
        } else if (_selectedFilter == 'Premium') {
          matchCategory = student.isPremium;
        }

        return matchSearch && matchCategory;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final premiumCount = _allStudents.where((s) => s.isPremium).length;
    final kpssCount = _allStudents.where((s) => s.targetExam.contains('KPSS')).length;
    final yksCount = _allStudents.where((s) => s.targetExam.contains('YKS')).length;

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
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ÖZET METRİK KARTLARI (3'lü GRID)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBox(
                      title: 'Toplam Öğrenci',
                      value: '${_allStudents.length}',
                      subtitle: 'Canlı Firestore',
                      color: const Color(0xFF4F46E5),
                      icon: Icons.people_alt_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricBox(
                      title: 'Premium Üye',
                      value: '$premiumCount',
                      subtitle: 'Aktif Koçluk',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.star_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricBox(
                      title: 'Sınav Dağılımı',
                      value: '$kpssCount KPSS',
                      subtitle: '$yksCount YKS',
                      color: const Color(0xFF10B981),
                      icon: Icons.assignment_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. ARAMA ÇUBUĞU
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Öğrenci adı, e-posta veya hedef ara...',
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

              // 3. FİLTRELEME ÇİPLERİ
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tümü'),
                    _buildFilterChip('KPSS'),
                    _buildFilterChip('YKS'),
                    _buildFilterChip('LGS'),
                    _buildFilterChip('Premium'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. ÖĞRENCİ LİSTESİ BAŞLIĞI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Öğrenciler (${_filteredStudents.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Detay için karta dokunun',
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 5. LİSTE VEYA YÜKLENİYOR
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
                        'Arama kriterine uygun öğrenci bulunamadı',
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
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
          if (selected) {
            setState(() => _selectedFilter = label);
            _applyFilters();
          }
        },
      ),
    );
  }

  Widget _buildStudentCard(UserProfileModel student, bool isDark) {
    final isApple = student.email.toLowerCase().contains('icloud') ||
        student.email.toLowerCase().contains('apple');

    return InkWell(
      onTap: () => _openStudentDetail(student),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: student.isPremium
                ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: student.isPremium ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: student.isPremium
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF4F46E5),
              child: Text(
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
                      if (student.isPremium)
                        const Tooltip(
                          message: 'Premium Öğrenci',
                          child: Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          student.targetExam,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
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
