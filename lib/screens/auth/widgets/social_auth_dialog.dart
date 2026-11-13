import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile_model.dart';
import '../../../providers/study_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../services/social_auth_service.dart';

class SocialAuthHelper {
  /// Google veya Apple ile tek tıkla giriş / kayıt sürecini başlatır
  static Future<void> startSocialLogin(BuildContext context, {required bool isGoogle}) async {
    // 1. Önce telefonun açık olan yerel hesabını (Google Account Picker / Apple ID) çekmeyi dene
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: isGoogle ? const Color(0xFFEA4335) : const Color(0xFF4F46E5),
                strokeWidth: 3,
              ),
              const SizedBox(height: 18),
              Text(
                isGoogle ? 'Telefondaki Google Hesabı Alınıyor...' : 'Apple Kimliği Doğrulanıyor...',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Lütfen bekleyin, otomatik bağlanıyor...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );

    SocialAuthAccount? account;

    try {
      if (isGoogle) {
        account = await SocialAuthService.signInWithGoogle();
      } else {
        account = await SocialAuthService.signInWithApple();
      }
    } catch (e) {
      debugPrint('Native sosyal giriş hatası / Web fallback devrede: $e');
    } finally {
      // Yükleniyor dialogunu kapat
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!context.mounted) return;

    // A) Telefondan hesap başarıyla çekildi -> DOĞRUDAN BAĞLAN VE GİR!
    if (account != null) {
      await autoConnectAndLogin(
        context,
        email: account.email,
        displayName: account.displayName,
        isGoogle: isGoogle,
      );
      return;
    }

    // B) Eğer kullanıcı iptal ettiyse veya native desteklenmiyorsa (Web/Safari fallback):
    // Kullanıcıya 1-tık hızlı bağlama modalını göster
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SocialAccountPickerModal(isGoogle: isGoogle),
    );
  }

  /// Hesabı doğrudan sisteme bağlar ve oturum açar (Form doldurma YOK)
  static Future<void> autoConnectAndLogin(
    BuildContext context, {
    required String email,
    String? displayName,
    required bool isGoogle,
    String role = 'student',
    String? targetExam,
    String? teacherCode,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    // 1. Kullanıcı zaten kayıtlı mı?
    final exists = await userProvider.loginWithSocialEmail(cleanEmail);

    if (exists && userProvider.userProfile != null) {
      final existing = userProvider.userProfile!;
      studyProvider.setCurrentExam(existing.targetExam);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hoş geldin, ${existing.firstName}! ${isGoogle ? "Google" : "Apple"} hesabınla otomatik bağlandın 👋',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
      return;
    }

    // 2. Yeni kullanıcı -> Form doldurtmadan 3 ay ücretsiz denemeyle anında kaydet
    final newProfile = await userProvider.registerSocialUser(
      email: cleanEmail,
      displayName: displayName,
      role: role,
      targetExam: targetExam,
      teacherCodeInput: teacherCode,
    );

    studyProvider.setCurrentExam(newProfile.targetExam);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hoş geldin, ${newProfile.firstName}! ${isGoogle ? "Google" : "Apple"} hesabın bağlandı ve 3 aylık ücretsiz üyeliğin başladı 🎓',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 4),
        ),
      );
    }
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

  String _selectedRole = 'student';
  String _selectedExam = ExamTypes.availableExams.first;
  bool _isLoading = false;
  bool _showAdminShortcuts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final lastEmail = userProvider.lastSocialEmail;
      if (lastEmail != null && lastEmail.isNotEmpty && _emailController.text.isEmpty) {
        if (mounted) {
          setState(() {
            _emailController.text = lastEmail;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitAndLogin(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await SocialAuthHelper.autoConnectAndLogin(
        context,
        email: cleanEmail,
        isGoogle: widget.isGoogle,
        role: _selectedRole,
        targetExam: _selectedExam,
      );

      if (mounted) {
        Navigator.pop(context); // Bu modalı kapat
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        child: AutofillGroup(
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.isGoogle
                            ? const Color(0xFFEA4335).withValues(alpha: 0.12)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFF0F172A).withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: widget.isGoogle
                            ? Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEA4335),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.apple_rounded,
                                size: 28,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isGoogle ? 'Google ile Otomatik Bağlan' : 'Apple Kimliği ile Bağlan',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Form doldurmadan tek tıkla doğrudan başla',
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
                const SizedBox(height: 14),

                // 3 Ay Ücretsiz Deneme Müjdesi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Text('🎁', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İlk 3 Ay Tamamen Ücretsiz!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Hesabın anında açılır, ekstra form doldurmana gerek kalmaz.',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bu Cihazda Önceden Kayıtlı Hesaplar Varsa Tek Tıkla Bağlan
                if (savedProfiles.isNotEmpty) ...[
                  Text(
                    'Kayıtlı Hesapla Tek Tıkla Bağlan',
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          profile.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          profile.email,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF4F46E5),
                        ),
                        onTap: () => _submitAndLogin(profile.email),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'veya hesabını onayla',
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Rol Seçimi: Öğrenci / Öğretmen
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedRole = 'student'),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'student'
                                ? const Color(0xFF4F46E5).withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRole == 'student'
                                  ? const Color(0xFF4F46E5)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '🎓 Öğrenciyim',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _selectedRole == 'student'
                                    ? const Color(0xFF4F46E5)
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedRole = 'teacher'),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'teacher'
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRole == 'teacher'
                                  ? const Color(0xFF10B981)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '👨‍🏫 Öğretmen / Koçum',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _selectedRole == 'teacher'
                                    ? const Color(0xFF10B981)
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sınav Türü Seçimi
                const Text(
                  'Hedef Sınav',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                          child: Text(
                            exam,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedExam = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // E-posta Giriş Alanı
                Text(
                  widget.isGoogle
                      ? 'Telefondaki Google / Gmail E-posta Adresiniz'
                      : 'Apple ID / iCloud E-posta Adresiniz',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                  decoration: InputDecoration(
                    hintText: widget.isGoogle ? 'ornek.ogrenci@gmail.com' : 'ornek.ogrenci@icloud.com',
                    prefixIcon: Icon(
                      widget.isGoogle ? Icons.mail_outline_rounded : Icons.apple_rounded,
                    ),
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
                const SizedBox(height: 8),

                // Hızlı Tamamlama Çipleri
                Wrap(
                  spacing: 6,
                  children: [
                    _buildQuickEmailChip('@gmail.com'),
                    _buildQuickEmailChip('@icloud.com'),
                    _buildQuickEmailChip('@hotmail.com'),
                    _buildQuickEmailChip('@outlook.com'),
                  ],
                ),
                const SizedBox(height: 18),

                // Tek Tıkla Otomatik Bağlan Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _submitAndLogin(_emailController.text),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.flash_on_rounded, color: Colors.white),
                    label: const Text(
                      'Tek Tıkla Bağlan ve Başla 🚀',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                // Kurucu / Yönetici Hızlı Giriş Kısayolu
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showAdminShortcuts = !_showAdminShortcuts),
                    icon: const Icon(Icons.shield_outlined, size: 15, color: Color(0xFFF59E0B)),
                    label: Text(
                      _showAdminShortcuts ? 'Yönetici Girişini Gizle' : '👑 Yönetici Hızlı Girişi',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_showAdminShortcuts) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _submitAndLogin('ibrahim.uzuner@icloud.com'),
                            icon: const Icon(Icons.apple_rounded, size: 17),
                            label: const Text(
                              'ibrahim.uzuner@icloud.com (Apple)',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _submitAndLogin('ibrahimuzumer@hotmail.com'),
                            icon: const Icon(Icons.mail_outline_rounded, size: 17),
                            label: const Text(
                              'ibrahimuzumer@hotmail.com (Hotmail)',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickEmailChip(String domain) {
    return ActionChip(
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      label: Text(domain, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        final current = _emailController.text.trim();
        if (current.isEmpty) {
          _emailController.text = domain;
        } else if (current.contains('@')) {
          final prefix = current.split('@').first;
          _emailController.text = '$prefix$domain';
        } else {
          _emailController.text = '$current$domain';
        }
        setState(() {});
      },
    );
  }
}
