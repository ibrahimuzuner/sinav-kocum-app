import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_profile_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/url_launcher_helper.dart';

class SupportFeedbackDialog extends StatefulWidget {
  final UserProfileModel? profile;
  final bool isTeacher;

  const SupportFeedbackDialog({
    super.key,
    this.profile,
    this.isTeacher = false,
  });

  static Future<void> show(BuildContext context, {UserProfileModel? profile, bool isTeacher = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SupportFeedbackDialog(profile: profile, isTeacher: isTeacher),
    );
  }

  @override
  State<SupportFeedbackDialog> createState() => _SupportFeedbackDialogState();
}

class _SupportFeedbackDialogState extends State<SupportFeedbackDialog> {
  static const String supportEmail = 'sinavkocumapp@gmail.com';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _examController;
  late final TextEditingController _messageController;

  final List<String> _categories = const [
    '💡 Görüş & Öneri',
    '🐞 Hata Bildirimi (Bug)',
    '❓ Soru & Destek',
    '🚀 Yeni Özellik İsteği',
    '💬 Diğer',
  ];

  late String _selectedCategory;
  bool _isSending = false;
  bool _alreadySentToday = false;
  bool _checkingLimit = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _nameController = TextEditingController(text: widget.profile?.fullName ?? '');
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
    _examController = TextEditingController(
      text: widget.isTeacher ? 'Öğretmen / Koç' : (widget.profile?.targetExam ?? ''),
    );
    _messageController = TextEditingController();
    _checkDailyLimit();
  }

  Future<void> _checkDailyLimit() async {
    final userId = widget.profile?.id ?? 'guest';
    final canSend = await AppFirebaseService().canUserSendSupportFeedback(userId);
    if (mounted) {
      setState(() {
        _alreadySentToday = !canSend;
        _checkingLimit = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _examController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _buildFormattedSubject() {
    final cleanCategory = _selectedCategory.replaceAll(RegExp(r'^[^\s]+\s*'), '');
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Kullanıcı';
    final exam = _examController.text.trim().isNotEmpty ? ' [${_examController.text.trim()}]' : '';
    return '[Sınav Koçum Destek] $cleanCategory - $name$exam';
  }

  String _buildFormattedBody() {
    final buffer = StringBuffer();
    buffer.writeln('=== SINAV KOÇUM UYGULAMASI DESTEK & GERİ BİLDİRİM ===');
    buffer.writeln('');
    buffer.writeln('Ad Soyad: ${_nameController.text.trim()}');
    buffer.writeln('E-Posta: ${_emailController.text.trim()}');
    buffer.writeln('Rol / Durum: ${widget.isTeacher ? "Öğretmen / Koç" : "Öğrenci"}');
    buffer.writeln('Hedef Sınav: ${_examController.text.trim()}');
    buffer.writeln('Kategori: $_selectedCategory');
    buffer.writeln('Tarih: ${DateTime.now().toString().split(".")[0]}');
    buffer.writeln('');
    buffer.writeln('--- MESAJ / AÇIKLAMA ---');
    buffer.writeln(_messageController.text.trim());
    buffer.writeln('');
    buffer.writeln('-------------------------------------------');
    buffer.writeln('Bu bildirim Sınav Koçum uygulaması üzerinden oluşturulmuştur.');
    return buffer.toString();
  }

  Future<void> _handleSend({bool openClient = false, bool openWebmail = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final userId = widget.profile?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    // Günlük limit kontrolü
    final canSend = await AppFirebaseService().canUserSendSupportFeedback(userId);
    if (!canSend) {
      if (mounted) {
        setState(() => _alreadySentToday = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Bugün zaten 1 destek mesajı gönderdiniz. Günde en fazla 1 mesaj iletilebilir.'),
            backgroundColor: Color(0xFFD97706),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    final subject = _buildFormattedSubject();
    final body = _buildFormattedBody();

    // 1. Firebase Firestore'a kaydet ve otomatik olarak sinavkocumapp@gmail.com adresine e-posta yolla
    bool success = false;
    try {
      success = await AppFirebaseService().sendSupportFeedback(
        userId: userId,
        userName: _nameController.text.trim(),
        userEmail: _emailController.text.trim(),
        userRole: widget.isTeacher ? 'teacher' : 'student',
        targetExam: _examController.text.trim(),
        category: _selectedCategory,
        message: _messageController.text.trim(),
      );
    } catch (e) {
      debugPrint('Firestore feedback save error: $e');
    }

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _alreadySentToday = true;
    });

    // 2. İsteğe bağlı mail istemcisini açma
    if (openWebmail) {
      UrlLauncherHelper.openGmailWeb(
        to: supportEmail,
        subject: subject,
        body: body,
      );
    } else if (openClient) {
      UrlLauncherHelper.openMail(
        to: supportEmail,
        subject: subject,
        body: body,
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                success
                    ? 'Mesajınız başarıyla iletildi! sinavkocumapp@gmail.com adresine bildirildi. Teşekkür ederiz! 🎉'
                    : 'Mesajınız sisteme iletildi. Teşekkür ederiz!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyAllToClipboard() {
    final text = 'Alıcı: $supportEmail\nKonu: ${_buildFormattedSubject()}\n\n${_buildFormattedBody()}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('E-posta adresi ve mesaj panoya kopyalandı! 📋'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF4F46E5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destek ve Görüş Bildir',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'sinavkocumapp@gmail.com',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5),
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
          ),
          const Divider(height: 1),

          // Form content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destek bilgi kutucuğu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_read_rounded, color: Color(0xFF4F46E5), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                ),
                                children: const [
                                  TextSpan(text: 'Mesajınız doğrudan '),
                                  TextSpan(
                                    text: 'sinavkocumapp@gmail.com',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                                  ),
                                  TextSpan(text: ' adresine ve sistem veritabanımıza iletilir.'),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF4F46E5)),
                            tooltip: 'Mail Adresini Kopyala',
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: supportEmail));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('E-posta adresi kopyalandı: sinavkocumapp@gmail.com'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Günlük Limit & Spam Koruma Uyarısı
                    if (_alreadySentToday)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Color(0xFFF59E0B), size: 24),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bugünkü mesaj hakkınızı kullandınız. Spam ve yoğunluğu önlemek amacıyla günde en fazla 1 destek mesajı gönderilebilir. Yeni mesajınızı yarın iletebilirsiniz.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Text(
                              'Spam koruması: Her kullanıcı günde 1 destek mesajı gönderebilir.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Kategori seçimi
                    const Text(
                      'Kategori',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4F46E5),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategory = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Ad Soyad & Sınav (Row veya Column)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Adınız Soyadınız',
                              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Adınızı yazın' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _examController,
                            decoration: InputDecoration(
                              labelText: 'Hedef Sınav / Rol',
                              prefixIcon: const Icon(Icons.school_outlined, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // E-Posta
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'İletişim E-Postanız (Cevap için)',
                        hintText: 'ornek@gmail.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'E-posta adresinizi girin';
                        if (!v.contains('@') || !v.contains('.')) return 'Geçerli bir e-posta girin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Mesaj Alanı
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      minLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mesajınız / Görüşünüz / Sorunuz *',
                        hintText:
                            'Görüş, öneri, hata bildirimi veya merak ettiğiniz her şeyi buraya yazabilirsiniz...',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: Icon(Icons.edit_note_rounded, size: 22),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Lütfen iletmek istediğiniz mesajı yazın';
                        if (v.trim().length < 5) return 'Mesajınız en az 5 karakter olmalıdır';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Gönderim Butonları
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _alreadySentToday ? Colors.grey : const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: _alreadySentToday ? 0 : 2,
                        ),
                        onPressed: (_isSending || _alreadySentToday || _checkingLimit) ? null : () => _handleSend(),
                        icon: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Icon(
                                _alreadySentToday ? Icons.block_rounded : Icons.send_rounded,
                                size: 18,
                              ),
                        label: Text(
                          _alreadySentToday
                              ? 'Bugünkü Mesaj Hakkı Doldu (Günde 1 Mesaj)'
                              : (_isSending ? 'İletiliyor...' : 'Mesajı Gönder (Otomatik)'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // İkinci seçenekler
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEA4335),
                              side: const BorderSide(color: Color(0xFFEA4335)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isSending ? null : () => _handleSend(openWebmail: true),
                            icon: const Icon(Icons.mail_outline_rounded, size: 18),
                            label: const Text('Gmail Web ile Aç', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: BorderSide(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isSending ? null : () => _handleSend(openClient: true),
                            icon: const Icon(Icons.outgoing_mail, size: 18),
                            label: const Text('E-Posta Uygulaması', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Panoya Kopyala',
                          style: IconButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _copyAllToClipboard,
                          icon: const Icon(Icons.copy_rounded, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
