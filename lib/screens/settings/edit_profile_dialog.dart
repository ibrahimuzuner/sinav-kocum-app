import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/study_provider.dart';
import '../../services/target_departments_data.dart';
import '../../utils/formatters.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfileModel profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late DateTime _birthDate;
  late String _selectedExam;
  late int _dailyTargetHours;
  late String _selectedDepartment;
  late double _targetScore;
  late double _targetNet;
  final TextEditingController _customDepartmentController = TextEditingController();
  bool _isCustomDepartment = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _birthDate = widget.profile.birthDate;
    _selectedExam = widget.profile.targetExam;
    _dailyTargetHours = widget.profile.dailyTargetHours;

    final existingDep = widget.profile.targetDepartment;
    final found = TargetDepartmentsData.findDepartmentByName(existingDep);
    if (found != null) {
      _selectedDepartment = found.name;
      _targetScore = widget.profile.targetScore > 0 ? widget.profile.targetScore : found.baseScore;
      _targetNet = widget.profile.targetNet > 0 ? widget.profile.targetNet : found.targetNet;
      _isCustomDepartment = false;
    } else if (existingDep.isNotEmpty && existingDep != 'Genel Başarı Hedefi') {
      _selectedDepartment = 'custom_dep';
      _isCustomDepartment = true;
      _customDepartmentController.text = existingDep;
      _targetScore = widget.profile.targetScore;
      _targetNet = widget.profile.targetNet;
    } else {
      final def = TargetDepartmentsData.getDefaultDepartmentForExam(_selectedExam);
      _selectedDepartment = def.name;
      _targetScore = def.baseScore;
      _targetNet = def.targetNet;
      _isCustomDepartment = false;
    }
  }

  void _onExamChanged(String exam) {
    setState(() {
      _selectedExam = exam;
      final def = TargetDepartmentsData.getDefaultDepartmentForExam(exam);
      _selectedDepartment = def.name;
      _targetScore = def.baseScore;
      _targetNet = def.targetNet;
      _isCustomDepartment = false;
      _customDepartmentController.text = '';
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _customDepartmentController.dispose();
    super.dispose();
  }

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    if (now.month < _birthDate.month ||
        (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
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
        child: Form(
          key: _formKey,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profili Güncelle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 1. E-POSTA ALANI (KİLİTLİ / DEĞİŞTİRİLEMEZ)
              const Text(
                'Kayıtlı E-Posta (Değiştirilemez)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.profile.email.isNotEmpty ? widget.profile.email : 'E-posta belirtilmemiş',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Kilitli',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. AD VE SOYAD
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Adınız', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Adınızı girin' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Soyadınız', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Soyadınızı girin' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. DOĞUM TARİHİ
              const Text('Doğum Tarihi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate,
                    firstDate: DateTime(1970),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _birthDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cake_outlined, color: Color(0xFF4F46E5), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            Formatters.formatDateTurkish(_birthDate),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_calculatedAge Yaşında',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. HEDEF SINAV
              const Text('Hedef Sınav', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedExam,
                    isExpanded: true,
                    items: ExamTypes.availableExams.map((exam) {
                      return DropdownMenuItem(
                        value: exam,
                        child: Text(exam, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _onExamChanged(val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. HEDEF BÖLÜM / PROGRAM SEÇİMİ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hedef Bölüm / Program', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    '${_targetScore.toInt()} Puan Hedefi',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _isCustomDepartment ? 'custom_dep' : _selectedDepartment,
                    isExpanded: true,
                    items: [
                      ...TargetDepartmentsData.getDepartmentsForExam(_selectedExam).map((dep) {
                        return DropdownMenuItem<String>(
                          value: dep.name,
                          child: Text(
                            '${dep.name} (${dep.baseScore.toInt()} Puan)',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                      const DropdownMenuItem<String>(
                        value: 'custom_dep',
                        child: Text(
                          '✏️ Diğer / Kendi Hedefimi Belirle',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontSize: 13),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      if (val == 'custom_dep') {
                        setState(() => _isCustomDepartment = true);
                      } else {
                        final found = TargetDepartmentsData.findDepartmentByName(val);
                        setState(() {
                          _isCustomDepartment = false;
                          _selectedDepartment = val;
                          if (found != null) {
                            _targetScore = found.baseScore;
                            _targetNet = found.targetNet;
                            _dailyTargetHours = found.recommendedHours;
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
              if (_isCustomDepartment) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customDepartmentController,
                  decoration: const InputDecoration(
                    hintText: 'Bölüm veya hedef adı',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                  validator: (v) {
                    if (_isCustomDepartment && (v == null || v.trim().isEmpty)) {
                      return 'Lütfen hedef bölümünüzü yazın';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),

              // 🤖 YAPAY ZEKA HEDEF & PUAN KARTI
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      const Color(0xFF6366F1).withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4F46E5), size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Yapay Zeka Taban Puan & Net Hedefi',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Taban Puan', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                                Text('${_targetScore.toInt()} Puan', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Gereken Net', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                                Text('~${_targetNet.toStringAsFixed(1)} Net', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Önerilen', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                                Text('$_dailyTargetHours Sa/Gün', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 6. GÜNLÜK HEDEF ÇALIŞMA SÜRESİ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Günlük Hedef Çalışma Süren', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('$_dailyTargetHours Saat / Gün', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [2, 3, 4, 5, 6].map((hours) {
                  final isSelected = _dailyTargetHours == hours;
                  return ChoiceChip(
                    label: Text('$hours Saat'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _dailyTargetHours = hours),
                    selectedColor: const Color(0xFF4F46E5),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // GÜNCELLE BUTONU
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

                      final departmentToSave = _isCustomDepartment
                          ? _customDepartmentController.text.trim()
                          : _selectedDepartment;

                      final updatedProfile = widget.profile.copyWith(
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        birthDate: _birthDate,
                        targetExam: _selectedExam,
                        dailyTargetHours: _dailyTargetHours,
                        targetDepartment: departmentToSave,
                        targetScore: _targetScore,
                        targetNet: _targetNet,
                      );

                      await userProvider.updateProfile(updatedProfile);
                      await settingsProvider.setTargetMinutes(_dailyTargetHours * 60);

                      if (context.mounted) {
                        context.read<StudyProvider>().setCurrentExam(updatedProfile.targetExam);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil bilgilerin başarıyla güncellendi! ✅'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Güncellemeleri Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
