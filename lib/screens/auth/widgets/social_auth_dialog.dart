import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile_model.dart';
import '../../../providers/study_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../services/target_departments_data.dart';
import '../../../utils/formatters.dart';

class SocialAuthHelper {
  /// Google veya Apple ile giriş / kayıt sürecini başlatır
  static void startSocialLogin(BuildContext context, {required bool isGoogle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SocialAccountPickerModal(isGoogle: isGoogle),
    );
  }
}

class SocialAccountPickerModal extends StatefulWidget {
  final bool isGoogle;

  const SocialAccountPickerModal({super.key, required this.isGoogle});

  @override
  State<SocialAccountPickerModal> createState() => _SocialAccountPickerModalState();
}

class _SocialAccountPickerModalState extends State<SocialAccountPickerModal> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onEmailSubmitted(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    // 1. Önce yerelde ve Firestore bulutunda ara
    final success = await userProvider.loginWithSocialEmail(cleanEmail);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success && userProvider.userProfile != null) {
      final existing = userProvider.userProfile!;
      studyProvider.setCurrentExam(existing.targetExam);
      Navigator.pop(context); // Bu modalı kapat

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hoş geldin, ${existing.firstName}! ${widget.isGoogle ? "Google" : "Apple"} hesabınla giriş yapıldı. 👋'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else {
      // Yeni kullanıcı -> Kimlik bilgilerini iste
      Navigator.pop(context); // Seçim modalını kapat
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => SocialIdentityCompletionModal(
          email: cleanEmail,
          isGoogle: widget.isGoogle,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedProfiles = userProvider.savedProfiles;

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
              // Sürükleme Tutamacı
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

              // Başlık & Logo
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.isGoogle
                          ? const Color(0xFFEA4335).withValues(alpha: 0.12)
                          : (isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFF0F172A).withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: widget.isGoogle
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Color(0xFFEA4335), shape: BoxShape.circle),
                              child: const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            )
                          : Icon(Icons.apple_rounded, size: 26, color: isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isGoogle ? 'Google ile Oturum Aç' : 'Apple Kimliği ile Giriş Yap',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.isGoogle
                              ? 'Sınav Koçum için Google hesabınızı seçin'
                              : 'Sınav Koçum için Apple Kimliğinizi kullanın',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 🌟 SİSTEMİN OTOMATİK TANIDIĞI HESAP KARTI
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isGoogle
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : (isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFF0F172A), const Color(0xFF1E293B)]),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isGoogle ? Icons.account_circle : Icons.apple,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isGoogle ? 'Cihazdaki Google / Hotmail Hesabı' : 'Cihazın Apple Kimliği',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.isGoogle
                                    ? 'ibrahimuzumer@hotmail.com'
                                    : 'ibrahim.uzuner@icloud.com',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Hazır',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _onEmailSubmitted(
                                  widget.isGoogle
                                      ? 'ibrahimuzumer@hotmail.com'
                                      : 'ibrahim.uzuner@icloud.com',
                                ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : Icon(
                                widget.isGoogle ? Icons.login_rounded : Icons.fingerprint,
                                color: Colors.black,
                                size: 20,
                              ),
                        label: Text(
                          widget.isGoogle
                              ? 'Bu Hesapla Tek Tıkla Giriş Yap'
                              : 'Apple ile Tek Tıkla Giriş Yap',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('veya farklı bir hesap yazın', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),

              // Varsa Cihazda Kayıtlı Önceki Hesaplar
              if (savedProfiles.isNotEmpty) ...[
                Text(
                  'Cihazdaki Hesaplar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                ...savedProfiles.map((profile) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF4F46E5),
                        radius: 18,
                        child: Text(
                          profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : 'Ö',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      title: Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(profile.email, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                      onTap: () => _onEmailSubmitted(profile.email),
                    ),
                  );
                }),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('veya farklı bir e-posta girin', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              // E-posta Giriş Alanı
              Text(
                widget.isGoogle ? 'Google / Gmail E-posta Adresi' : 'Apple ID / iCloud E-posta Adresi',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  hintText: widget.isGoogle ? 'ornek.ogrenci@gmail.com' : 'ornek.ogrenci@icloud.com',
                  prefixIcon: Icon(widget.isGoogle ? Icons.mail_outline_rounded : Icons.apple_rounded),
                  suffixIcon: _emailController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(() => _emailController.clear()),
                        )
                      : null,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Lütfen bir e-posta adresi girin';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
                onChanged: (text) => setState(() {}),
              ),
              const SizedBox(height: 10),

              // Hızlı Tamamlama Çipleri
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickEmailChip('@gmail.com'),
                  _buildQuickEmailChip('@icloud.com'),
                  _buildQuickEmailChip('@hotmail.com'),
                ],
              ),
              const SizedBox(height: 20),

              // Devam Et Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _onEmailSubmitted(_emailController.text),
                  icon: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  label: const Text(
                    'Hesapla Devam Et',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
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

  Widget _buildQuickEmailChip(String domain) {
    return ActionChip(
      label: Text(domain, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.08),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () {
        final currentText = _emailController.text.trim();
        if (currentText.isEmpty) {
          _emailController.text = domain;
        } else if (currentText.contains('@')) {
          final prefix = currentText.split('@').first;
          _emailController.text = '$prefix$domain';
        } else {
          _emailController.text = '$currentText$domain';
        }
        setState(() {});
      },
    );
  }
}

/// Google / Apple hesabı seçildikten sonra kimlik ve sınav bilgilerini toplayan modal
class SocialIdentityCompletionModal extends StatefulWidget {
  final String email;
  final bool isGoogle;

  const SocialIdentityCompletionModal({
    super.key,
    required this.email,
    required this.isGoogle,
  });

  @override
  State<SocialIdentityCompletionModal> createState() => _SocialIdentityCompletionModalState();
}

class _SocialIdentityCompletionModalState extends State<SocialIdentityCompletionModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  DateTime _birthDate = DateTime(2007, 6, 15);
  String _selectedExam = ExamTypes.availableExams.first;
  int _dailyTargetHours = 3;
  late String _selectedDepartment;
  late double _targetScore;
  late double _targetNet;
  final TextEditingController _customDepartmentController = TextEditingController();
  bool _isCustomDepartment = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _applyDefaultDepartmentForExam(_selectedExam);
    // E-postanın başındaki isimden otomatik ad öner
    final namePart = widget.email.split('@').first;
    if (namePart.isNotEmpty) {
      final clean = namePart.replaceAll(RegExp(r'[^a-zA-ZçÇğĞıİöÖşŞüÜ]'), '');
      if (clean.isNotEmpty) {
        _firstNameController.text = clean[0].toUpperCase() + clean.substring(1);
      }
    }
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _customDepartmentController.dispose();
    super.dispose();
  }

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    if (now.month < _birthDate.month || (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    final departmentToSave = _isCustomDepartment
        ? _customDepartmentController.text.trim()
        : _selectedDepartment;

    await userProvider.registerUser(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: widget.email,
      birthDate: _birthDate,
      targetExam: _selectedExam,
      dailyTargetHours: _dailyTargetHours,
      targetDepartment: departmentToSave,
      targetScore: _targetScore,
      targetNet: _targetNet,
    );

    studyProvider.setCurrentExam(_selectedExam);

    if (mounted) {
      Navigator.pop(context); // Bu modalı kapat

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tebrikler ${_firstNameController.text.trim()}, kaydın başarıyla oluşturuldu! Sınav hazırlığına başla 🎓'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
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
              // Sürükleme Tutamacı
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
              const SizedBox(height: 14),

              // Başlık & Bilgilendirme
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kimlik Bilgilerini Tamamla',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Koçluk programın için son bir adım kaldı',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Seçilen Sosyal Hesap Rozeti (Kilitli / Doğrulanmış)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isGoogle ? Icons.g_mobiledata_rounded : Icons.apple_rounded,
                      color: const Color(0xFF10B981),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isGoogle ? 'Google Hesabı Doğrulandı' : 'Apple Hesabı Doğrulandı',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                          Text(
                            widget.email,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Ad & Soyad Alanları
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Adınız', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _firstNameController,
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
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            hintText: 'Demir',
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

              // Doğum Tarihi & Yaş
              const Text('Doğum Tarihiniz', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          const SizedBox(width: 10),
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
                          borderRadius: BorderRadius.circular(8),
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

              // Hazırlanılan Sınav Türü
              const Text('Hazırlandığınız Sınav', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
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
                      return DropdownMenuItem<String>(
                        value: exam,
                        child: Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 18, color: Color(0xFF4F46E5)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                exam,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
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
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
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
              const SizedBox(height: 14),

              // Günlük Hedef Çalışma Saati
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Günlük Hedef Çalışma Süresi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_dailyTargetHours Saat / Gün',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _dailyTargetHours.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$_dailyTargetHours Saat',
                activeColor: const Color(0xFF4F46E5),
                onChanged: (val) {
                  setState(() => _dailyTargetHours = val.round());
                },
              ),
              const SizedBox(height: 18),

              // Kaydı Tamamla & Başla Butonu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitRegistration,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Kaydediliyor...' : 'Kaydı Tamamla & Başla 🚀',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
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
