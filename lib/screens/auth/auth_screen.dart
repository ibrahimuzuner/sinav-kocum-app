import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/target_departments_data.dart';
import '../../utils/formatters.dart';
import 'widgets/social_auth_dialog.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _tabIndex = 0; // 0: Giriş Yap, 1: Kayıt Ol

  // Login Form
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;
  bool _isLoggingIn = false;

  // Register Form
  final _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _regFirstNameController = TextEditingController();
  final TextEditingController _regLastNameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  bool _regObscurePassword = true;

  DateTime _birthDate = DateTime(2007, 6, 15);
  String _selectedExam = ExamTypes.availableExams.first;
  int _dailyTargetHours = 3;
  late String _selectedDepartment;
  late double _targetScore;
  late double _targetNet;
  final TextEditingController _customDepartmentController = TextEditingController();
  bool _isCustomDepartment = false;

  @override
  void initState() {
    super.initState();
    _applyDefaultDepartmentForExam(_selectedExam);
  }

  void _applyDefaultDepartmentForExam(String exam) {
    final def = TargetDepartmentsData.getDefaultDepartmentForExam(exam);
    _selectedDepartment = def.name;
    _targetScore = def.baseScore;
    _targetNet = def.targetNet;
    _dailyTargetHours = def.recommendedHours;
    _isCustomDepartment = false;
    _customDepartmentController.text = '';
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regFirstNameController.dispose();
    _regLastNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Logo & Başlık
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.22),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Column(
                  children: [
                    const Text(
                      'Sınav Koçum 🎓',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tabIndex == 0
                          ? 'Ders çalışma yolculuğuna kaldığın yerden devam et'
                          : 'Sana özel akıllı çalışma programı ve hedef takibi oluştur',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Giriş Yap / Kayıt Ol Sekmesi
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabBtn('Giriş Yap', 0),
                    ),
                    Expanded(
                      child: _buildTabBtn('Kayıt Ol', 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // FORM ALANI
              if (_tabIndex == 0) _buildLoginForm(isDark) else _buildRegisterForm(isDark),

              const SizedBox(height: 24),

              // SOSYAL GİRİŞ BUTONLARI (APPLE & GOOGLE)
              _buildSocialDivider(),
              const SizedBox(height: 20),

              _buildSocialButtons(context, isDark),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBtn(String label, int index) {
    final isSelected = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }

  // --- GİRİŞ YAP FORMU ---
  Widget _buildLoginForm(bool isDark) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('E-Posta Adresi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              hintText: 'ornek@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || !v.contains('@') || !v.contains('.')) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          const Text('Şifre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _loginObscurePassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _loginObscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _loginObscurePassword = !_loginObscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 4) {
                return 'Şifrenizi girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Giriş Yap Butonu
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoggingIn
                  ? null
                  : () async {
                      if (_loginFormKey.currentState!.validate()) {
                        setState(() => _isLoggingIn = true);
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        final success = await userProvider.loginWithEmail(
                          email: _loginEmailController.text.trim(),
                          password: _loginPasswordController.text,
                        );
                        if (!mounted) return;
                        setState(() => _isLoggingIn = false);

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Bu e-posta ile kayıtlı bir hesap bulunamadı veya bağlantı kurulamadı. Lütfen e-postayı kontrol edin.',
                              ),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: _isLoggingIn
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('E-Posta ile Giriş Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- KAYIT OL FORMU ---
  Widget _buildRegisterForm(bool isDark) {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ad Soyad
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Adınız', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _regFirstNameController,
                      decoration: const InputDecoration(
                        hintText: 'Ahmet',
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
                      controller: _regLastNameController,
                      decoration: const InputDecoration(
                        hintText: 'Yılmaz',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Soyadınızı girin' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // E-posta
          const Text('E-Posta Adresi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              hintText: 'ogrenci@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || !v.contains('@') || !v.contains('.')) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Şifre
          const Text('Şifre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _regPasswordController,
            obscureText: _regObscurePassword,
            decoration: InputDecoration(
              hintText: 'En az 6 karakter',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _regObscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _regObscurePassword = !_regObscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 6) {
                return 'Şifre en az 6 karakter olmalı';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Doğum Tarihi
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
          const SizedBox(height: 14),

          // Hedef Sınav
          const Text('Hedeflediğin Sınav', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                  if (val != null) {
                    setState(() {
                      _selectedExam = val;
                      _applyDefaultDepartmentForExam(val);
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 🎯 HEDEF BÖLÜM / PROGRAM SEÇİMİ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hedeflediğin Bölüm / Program', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                  DropdownMenuItem<String>(
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
                    setState(() {
                      _isCustomDepartment = true;
                    });
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
            const SizedBox(height: 10),
            TextFormField(
              controller: _customDepartmentController,
              decoration: const InputDecoration(
                hintText: 'Bölüm veya hedef adı (Örn: Havacılık Yönetimi)',
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.12),
                  const Color(0xFF6366F1).withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Yapay Zeka Taban Puan & Net Hedefi',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hedef Puan', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 2),
                            Text(
                              '${_targetScore.toInt()} Puan',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gereken Net', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 2),
                            Text(
                              '~${_targetNet.toStringAsFixed(1)} Net',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Önerilen', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 2),
                            Text(
                              '$_dailyTargetHours Sa/Gün',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 Yapay zeka, bu taban puanı kazanman için zayıf olduğun dersleri önceliklendirip haftalık çalışma programını bu hedefe göre hazırlar.',
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Günlük Hedef Çalışma Süresi
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
            children: [2, 3, 4, 5, 6, 7].map((hours) {
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

          // Kayıt Butonu
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                if (_registerFormKey.currentState!.validate()) {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

                  final departmentToSave = _isCustomDepartment
                      ? _customDepartmentController.text.trim()
                      : _selectedDepartment;

                  await userProvider.registerUser(
                    firstName: _regFirstNameController.text.trim(),
                    lastName: _regLastNameController.text.trim(),
                    email: _regEmailController.text.trim(),
                    birthDate: _birthDate,
                    targetExam: _selectedExam,
                    dailyTargetHours: _dailyTargetHours,
                    targetDepartment: departmentToSave,
                    targetScore: _targetScore,
                    targetNet: _targetNet,
                    password: _regPasswordController.text.trim(),
                  );

                  await settingsProvider.setTargetMinutes(_dailyTargetHours * 60);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Hoş geldin ${_regFirstNameController.text.trim()}! Doğrulama bağlantısı e-postana gönderildi.'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: const Text('Hesabımı Oluştur ve Başla 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text('veya sosyal hesapla', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        // APPLE İLE GİRİŞ YAP BUTONU
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              SocialAuthHelper.startSocialLogin(context, isGoogle: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple_rounded, size: 24),
                SizedBox(width: 10),
                Text('Apple ile Giriş Yap', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // GOOGLE İLE GİRİŞ YAP BUTONU
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              SocialAuthHelper.startSocialLogin(context, isGoogle: true);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFEA4335), shape: BoxShape.circle),
                  child: const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Text(
                  'Google ile Giriş Yap',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
