import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/institution_model.dart';
import '../../../models/user_profile_model.dart';
import '../../../services/firebase_service.dart';

class AdminInstitutionsView extends StatefulWidget {
  final List<UserProfileModel> allUsers;
  final VoidCallback onRefreshNeeded;

  const AdminInstitutionsView({
    super.key,
    required this.allUsers,
    required this.onRefreshNeeded,
  });

  @override
  State<AdminInstitutionsView> createState() => _AdminInstitutionsViewState();
}

class _AdminInstitutionsViewState extends State<AdminInstitutionsView> {
  final AppFirebaseService _firebaseService = AppFirebaseService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<InstitutionModel> _institutions = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tümü';

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInstitutions() async {
    setState(() => _isLoading = true);
    final list = await _firebaseService.fetchAllInstitutions();
    if (mounted) {
      setState(() {
        _institutions = list;
        _isLoading = false;
      });
    }
  }

  List<InstitutionModel> get _filteredInstitutions {
    final query = _searchCtrl.text.toLowerCase().trim();
    return _institutions.where((inst) {
      final nameLower = inst.name.toLowerCase();
      final codeLower = inst.code.toLowerCase();
      final ownerLower = inst.ownerCoachName.toLowerCase();
      final cityLower = (inst.city ?? '').toLowerCase();

      final matchesQuery = query.isEmpty ||
          nameLower.contains(query) ||
          codeLower.contains(query) ||
          ownerLower.contains(query) ||
          cityLower.contains(query);

      if (!matchesQuery) return false;

      if (_selectedFilter == 'Onay Bekleyenler') return inst.isPending;
      if (_selectedFilter == 'Aktif') return inst.isApproved;
      if (_selectedFilter == 'Askıda / Red') return inst.isSuspended || inst.isRejected;

      return true;
    }).toList();
  }

  List<UserProfileModel> get _allTeachers =>
      widget.allUsers.where((u) => u.isTeacher).toList();

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kurum Kodu ($code) kopyalandı! 📋'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  Future<void> _updateStatus(InstitutionModel inst, String status) async {
    final ok = await _firebaseService.updateInstitutionStatus(
      institutionId: inst.id,
      status: status,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? '${inst.name} başarıyla onaylandı ve aktifleştirildi! 🟢'
                : '${inst.name} durumu "$status" olarak güncellendi.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: status == 'approved' ? const Color(0xFF10B981) : Colors.orange,
        ),
      );
      _loadInstitutions();
      widget.onRefreshNeeded();
    }
  }

  Future<void> _showChangeOwnerDialog(InstitutionModel inst) async {
    UserProfileModel? selectedTeacher;
    final teachers = _allTeachers;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Kurum Kurucusunu Tayin Et',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${inst.name} için yönetici / kurucu koçu seçin. Önceki kurucu normal kurum koçluğuna devam eder.',
                style: const TextStyle(fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Mevcut Kurucu: ${inst.ownerCoachName} (${inst.ownerCoachEmail})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Yeni Kurucu Koç:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<UserProfileModel>(
                value: selectedTeacher,
                isExpanded: true,
                hint: const Text('Öğretmenler arasından seçin'),
                items: teachers.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(
                      '${t.fullName} (${t.teacherSpecialty})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setModalState(() => selectedTeacher = val),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: selectedTeacher == null
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      final ok = await _firebaseService.updateInstitutionOwner(
                        institutionId: inst.id,
                        newOwnerCoach: selectedTeacher!,
                      );
                      if (!mounted) return;
                      if (ok) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '${inst.name} kurucusu "${selectedTeacher!.fullName}" olarak güncellendi! 👑',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                        _loadInstitutions();
                        widget.onRefreshNeeded();
                      }
                    },
              child: const Text('Kurucu Olarak Ata'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditInstitutionDialog(InstitutionModel? inst) async {
    final isNew = inst == null;
    final nameCtrl = TextEditingController(text: inst?.name ?? '');
    final cityCtrl = TextEditingController(text: inst?.city ?? '');
    final phoneCtrl = TextEditingController(text: inst?.phone ?? '');
    final descCtrl = TextEditingController(text: inst?.description ?? '');
    final logoCtrl = TextEditingController(text: inst?.logoBase64 ?? '');
    UserProfileModel? selectedOwner = isNew
        ? (_allTeachers.isNotEmpty ? _allTeachers.first : null)
        : null;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(isNew ? Icons.add_business_rounded : Icons.edit_note_rounded, color: const Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text(
                isNew ? 'Yeni Kurum Oluştur' : 'Kurum Bilgilerini Düzenle',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kurum Adı *',
                    hintText: 'Örn: Hedef Derece Akademi',
                  ),
                ),
                const SizedBox(height: 10),
                if (isNew) ...[
                  const Text('Kurucu Koç *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<UserProfileModel>(
                    value: selectedOwner,
                    isExpanded: true,
                    items: _allTeachers.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.fullName, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedOwner = val),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Şehir',
                    hintText: 'Örn: Ankara',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'İletişim Numarası',
                    hintText: 'Örn: 0555 123 4567',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: logoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Logo URL veya Base64',
                    hintText: 'https://... veya base64 kodu',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Kurum Sloganı / Açıklama',
                    hintText: 'Örn: Başarıya giden yolda profesyonel koçluk',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(ctx);
                if (isNew) {
                  if (selectedOwner == null) return;
                  final res = await _firebaseService.createInstitutionRequest(
                    name: name,
                    ownerCoach: selectedOwner!,
                    city: cityCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    logoBase64: logoCtrl.text.trim().isEmpty ? null : logoCtrl.text.trim(),
                  );
                  if (res['success'] == true) {
                    final newInst = res['institution'] as InstitutionModel;
                    // Süper yönetici kendisi oluşturduğu için doğrudan onaylayabiliriz
                    await _firebaseService.updateInstitutionStatus(
                      institutionId: newInst.id,
                      status: 'approved',
                    );
                    _loadInstitutions();
                    widget.onRefreshNeeded();
                  }
                } else {
                  await _firebaseService.updateInstitutionDetails(
                    institutionId: inst.id,
                    data: {
                      'name': name,
                      'city': cityCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'logoBase64': logoCtrl.text.trim().isEmpty ? null : logoCtrl.text.trim(),
                    },
                  );
                  _loadInstitutions();
                  widget.onRefreshNeeded();
                }
              },
              child: Text(isNew ? 'Kurumu Kaydet & Onayla' : 'Değişiklikleri Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteInstitution(InstitutionModel inst) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kurumu Sil'),
        content: Text(
          '${inst.name} kurumunu ve bağlı koç ilişkilerini silmek istediğinize emin misiniz? (Öğrencilerin verileri kaybolmaz, kurum bağı kaldırılır)',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Evet, Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await _firebaseService.deleteInstitution(inst.id);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${inst.name} silindi.'), behavior: SnackBarBehavior.floating),
        );
        _loadInstitutions();
        widget.onRefreshNeeded();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingCount = _institutions.where((i) => i.isPending).length;
    final approvedCount = _institutions.where((i) => i.isApproved).length;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 1. ÜST METRİK KARTLARI
        Row(
          children: [
            Expanded(
              child: _buildHeaderMetric(
                title: 'Toplam Kurum',
                value: '${_institutions.length}',
                color: const Color(0xFF4F46E5),
                icon: Icons.account_balance_rounded,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildHeaderMetric(
                title: 'Onay Bekleyen',
                value: '$pendingCount',
                color: pendingCount > 0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                icon: Icons.pending_actions_rounded,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildHeaderMetric(
                title: 'Aktif Kurum',
                value: '$approvedCount',
                color: const Color(0xFF10B981),
                icon: Icons.check_circle_rounded,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2. ARAMA & YENİ KURUM EKLE
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Kurum adı, kod (KRM-...), kurucu veya şehir ara...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showEditInstitutionDialog(null),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Kurum Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3. FİLTRELEME ÇİPLERİ
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tümü (${_institutions.length})', 'Tümü'),
              _buildFilterChip('🟡 Onay Bekleyenler ($pendingCount)', 'Onay Bekleyenler', highlight: pendingCount > 0),
              _buildFilterChip('🟢 Aktif ($approvedCount)', 'Aktif'),
              _buildFilterChip('🔴 Askıda / Red', 'Askıda / Red'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. LİSTE
        Expanded(
          child: _filteredInstitutions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFilter == 'Onay Bekleyenler'
                            ? 'Onay bekleyen kurum başvurusu yok.'
                            : 'Kayıtlı kurum bulunamadı.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredInstitutions.length,
                  itemBuilder: (context, index) {
                    final inst = _filteredInstitutions[index];
                    return _buildInstitutionCard(inst, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, {bool highlight = false}) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected || highlight ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (highlight ? const Color(0xFFEF4444) : null),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = value),
        selectedColor: const Color(0xFF4F46E5),
        backgroundColor: highlight ? const Color(0xFFFEE2E2) : null,
      ),
    );
  }

  Widget _buildHeaderMetric({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionCard(InstitutionModel inst, bool isDark) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (inst.isPending) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Onay Bekliyor';
      statusIcon = Icons.hourglass_top_rounded;
    } else if (inst.isApproved) {
      statusColor = const Color(0xFF10B981);
      statusText = 'Aktif Kurum';
      statusIcon = Icons.verified_rounded;
    } else if (inst.isSuspended) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'Askıda';
      statusIcon = Icons.pause_circle_rounded;
    } else {
      statusColor = Colors.grey;
      statusText = 'Reddedildi';
      statusIcon = Icons.cancel_rounded;
    }

    Widget logoWidget;
    if (inst.logoBase64 != null && inst.logoBase64!.isNotEmpty) {
      if (inst.logoBase64!.startsWith('http')) {
        logoWidget = Image.network(
          inst.logoBase64!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 28),
        );
      } else {
        try {
          logoWidget = Image.memory(
            base64Decode(inst.logoBase64!),
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 28),
          );
        } catch (_) {
          logoWidget = const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 28);
        }
      }
    } else {
      logoWidget = const Icon(Icons.business_rounded, color: Color(0xFF4F46E5), size: 26);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: inst.isPending
              ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
              : (isDark ? Colors.white10 : Colors.black12),
          width: inst.isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST BAŞLIK VE DURUM ROZETİ
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    child: Center(child: logoWidget),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inst.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (inst.city != null && inst.city!.isNotEmpty) ...[
                            Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade600),
                            const SizedBox(width: 2),
                            Text(
                              inst.city!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 8),
                          ],
                          InkWell(
                            onTap: () => _copyCode(inst.code),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    inst.code,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.copy_rounded, size: 11, color: Color(0xFF4F46E5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // KURUCU KOÇ BİLGİSİ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                        children: [
                          const TextSpan(text: 'Kurum Kurucusu: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${inst.ownerCoachName} (${inst.ownerCoachEmail})'),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: Color(0xFF4F46E5)),
                    tooltip: 'Kurucu Değiştir',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showChangeOwnerDialog(inst),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // KADRO ÖZETİ
            Row(
              children: [
                _buildMiniBadge(
                  icon: Icons.school_rounded,
                  label: '${inst.coachCount} Koç',
                  color: const Color(0xFF0EA5E9),
                ),
                const SizedBox(width: 8),
                _buildMiniBadge(
                  icon: Icons.people_alt_rounded,
                  label: '${inst.studentCount} Kayıtlı Öğrenci',
                  color: const Color(0xFF10B981),
                ),
                if (inst.phone != null && inst.phone!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildMiniBadge(
                    icon: Icons.phone_rounded,
                    label: inst.phone!,
                    color: Colors.grey.shade600,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // İŞLEM AKSİYONLARI (YÖNETİCİ BUTONLARI)
            Row(
              children: [
                if (inst.isPending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(inst, 'approved'),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Başvuruyu Onayla'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _updateStatus(inst, 'rejected'),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reddet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ] else if (inst.isApproved) ...[
                  OutlinedButton.icon(
                    onPressed: () => _updateStatus(inst, 'suspended'),
                    icon: const Icon(Icons.pause_circle_rounded, size: 16),
                    label: const Text('Askıya Al'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      side: const BorderSide(color: Color(0xFFF59E0B)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(inst, 'approved'),
                    icon: const Icon(Icons.play_circle_rounded, size: 16),
                    label: const Text('Yeniden Aktifleştir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, size: 20, color: Color(0xFF4F46E5)),
                  tooltip: 'Kurum Bilgilerini Düzenle',
                  onPressed: () => _showEditInstitutionDialog(inst),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                  tooltip: 'Kurumu Sil',
                  onPressed: () => _deleteInstitution(inst),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
