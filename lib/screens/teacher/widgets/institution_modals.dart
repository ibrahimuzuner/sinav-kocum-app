import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/institution_model.dart';
import '../../../models/user_profile_model.dart';
import '../../../providers/user_provider.dart';
import '../../../services/firebase_service.dart';

class InstitutionModals {
  /// Yeni Kurum Başvurusu Yapma Modalı
  static Future<void> showCreateModal(
    BuildContext context, {
    required UserProfileModel teacher,
    required VoidCallback onSuccess,
  }) async {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final logoCtrl = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.add_business_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Expanded(
                child: Text('Kurum / Merkez Başvurusu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dershane, etüt merkezi veya özel koçluk ofisinizi sisteme kaydedin. Başvurunuz süper yönetici tarafından onaylandığında kurum kodunuz aktifleşecektir.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kurum / Merkez Adı *',
                    hintText: 'Örn: Hedef Derece Akademi',
                  ),
                ),
                const SizedBox(height: 10),
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
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'İletişim Numarası',
                    hintText: 'Örn: 0555 123 4567',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: logoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Logo URL veya Base64 Kodu',
                    hintText: 'https://... (veya boş bırakılabilir)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Kurum Sloganı / Açıklama',
                    hintText: 'Örn: Başarıya giden yolda profesyonel rehberlik',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lütfen kurum adını girin.')),
                        );
                        return;
                      }

                      setModalState(() => isSubmitting = true);
                      final res = await AppFirebaseService().createInstitutionRequest(
                        name: name,
                        ownerCoach: teacher,
                        city: cityCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        logoBase64: logoCtrl.text.trim().isEmpty ? null : logoCtrl.text.trim(),
                      );
                      setModalState(() => isSubmitting = false);

                      if (!context.mounted) return;
                      if (res['success'] == true) {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        final updatedUser = teacher.copyWith(
                          institutionId: (res['institution'] as InstitutionModel).id,
                          institutionName: name,
                          institutionRole: 'owner',
                          institutionStatus: 'pending',
                          institutionLogoBase64: logoCtrl.text.trim().isEmpty ? null : logoCtrl.text.trim(),
                        );
                        await userProvider.updateProfile(updatedUser);

                        if (ctx.mounted) Navigator.pop(ctx);
                        onSuccess();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Kurum başvurunuz başarıyla alındı! ⏳ Süper yönetici onayından sonra kurum kodunuz aktifleşecektir.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message']?.toString() ?? 'Başvuru gönderilemedi.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Başvuruyu Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  /// Kurum Kodu ile Kuruma Katılma Modalı
  static Future<void> showJoinModal(
    BuildContext context, {
    required UserProfileModel teacher,
    required VoidCallback onSuccess,
  }) async {
    final codeCtrl = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.key_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text('Bir Kuruma Katıl', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Çalıştığınız kurumun veya koçluk merkezinin size verdiği "KRM-XXXXXX" formatındaki katılım kodunu girin.',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: codeCtrl,
                textCapitalization: TextCapitalization.characters,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Kurum Katılım Kodu',
                  hintText: 'Örn: KRM-841920',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final code = codeCtrl.text.trim();
                      if (code.isEmpty) return;

                      setModalState(() => isSubmitting = true);
                      final res = await AppFirebaseService().joinInstitutionByCode(
                        code: code,
                        coach: teacher,
                      );
                      setModalState(() => isSubmitting = false);

                      if (!context.mounted) return;
                      if (res['success'] == true) {
                        final inst = res['institution'] as InstitutionModel;
                        final isPending = res['pending'] == true;
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        final updatedUser = teacher.copyWith(
                          institutionId: inst.id,
                          institutionName: inst.name,
                          institutionRole: 'coach',
                          institutionStatus: isPending ? 'pending' : 'approved',
                          institutionLogoBase64: inst.logoBase64,
                        );
                        await userProvider.updateProfile(updatedUser);

                        if (ctx.mounted) Navigator.pop(ctx);
                        onSuccess();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isPending
                                ? '${inst.name} kurumuna katılım talebiniz iletildi. Kurucu onayından sonra kadroya dahil edileceksiniz! ⏳'
                                : '${inst.name} kadrosuna başarıyla katıldınız! 🎓'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: isPending ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message']?.toString() ?? 'Kuruma katılınamadı.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Kuruma Bağlan'),
            ),
          ],
        ),
      ),
    );
  }

  /// Kurum Bilgilerini & Logoyu Düzenleme Modalı (Kurum Kurucusu için)
  static Future<void> showEditModal(
    BuildContext context, {
    required InstitutionModel inst,
    required VoidCallback onSuccess,
  }) async {
    final nameCtrl = TextEditingController(text: inst.name);
    final cityCtrl = TextEditingController(text: inst.city ?? '');
    final phoneCtrl = TextEditingController(text: inst.phone ?? '');
    final descCtrl = TextEditingController(text: inst.description ?? '');
    final logoCtrl = TextEditingController(text: inst.logoBase64 ?? '');
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text('Kurum Bilgilerini Düzenle', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Kurum Adı'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'Şehir'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'İletişim Telefonu'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: logoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kurum Logosu (URL veya Base64)',
                    hintText: 'https://... veya base64 kodu',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Açıklama / Slogan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      setModalState(() => isSubmitting = true);
                      await AppFirebaseService().updateInstitutionDetails(
                        institutionId: inst.id,
                        data: {
                          'name': name,
                          'city': cityCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'logoBase64': logoCtrl.text.trim().isEmpty ? null : logoCtrl.text.trim(),
                        },
                      );
                      setModalState(() => isSubmitting = false);

                      if (ctx.mounted) Navigator.pop(ctx);
                      onSuccess();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kurum bilgileri güncellendi! 🏢'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  /// Kurum Kurucusunun onay bekleyen koç taleplerini yönettiği modal
  static Future<void> showPendingCoachesModal(
    BuildContext context, {
    required InstitutionModel inst,
    required VoidCallback onActionComplete,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return FutureBuilder<List<UserProfileModel>>(
            future: AppFirebaseService().fetchPendingInstitutionCoaches(inst.id),
            builder: (context, snapshot) {
              final pendingList = snapshot.data ?? [];
              final isLoading = snapshot.connectionState == ConnectionState.waiting;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_add_rounded, color: Color(0xFFF59E0B), size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${inst.name} • Katılım Talepleri',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Kuruma katılmak isteyen koçları onaylayın veya reddedin.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                        ),
                      )
                    else if (pendingList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text(
                                'Onay bekleyen koç talebi bulunmuyor.',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: pendingList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final coach = pendingList[idx];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                    child: Text(
                                      coach.firstName.isNotEmpty ? coach.firstName[0].toUpperCase() : '?',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          coach.fullName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          coach.teacherSpecialty,
                                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                        ),
                                        if (coach.email.isNotEmpty)
                                          Text(
                                            coach.email,
                                            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Reddet Butonu
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                                    tooltip: 'Talebi Reddet',
                                    onPressed: () async {
                                      final ok = await AppFirebaseService().rejectCoachJoinRequest(
                                        institutionId: inst.id,
                                        coachId: coach.id,
                                      );
                                      if (ok) {
                                        setModalState(() {});
                                        onActionComplete();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${coach.fullName} talebi reddedildi.'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  // Onayla Butonu
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.check_rounded, size: 16),
                                    label: const Text('Onayla', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () async {
                                      final ok = await AppFirebaseService().approveCoachJoinRequest(
                                        institutionId: inst.id,
                                        coachId: coach.id,
                                      );
                                      if (ok) {
                                        setModalState(() {});
                                        onActionComplete();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${coach.fullName} kuruma başarıyla eklendi! 🎓'),
                                              backgroundColor: const Color(0xFF10B981),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Kurumdaki Diğer Koçları Görüntüleme Modalı
  static Future<void> showCoachesListModal(
    BuildContext context, {
    required List<UserProfileModel> coaches,
    required String institutionName,
    InstitutionModel? inst,
    VoidCallback? onActionComplete,
  }) async {
    final hasPending = inst != null && inst.pendingCoachIds.isNotEmpty;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.badge_outlined, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$institutionName • Koç Kadrosu',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasPending) ...[
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  showPendingCoachesModal(
                    context,
                    inst: inst,
                    onActionComplete: onActionComplete ?? () {},
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notification_important_rounded, size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${inst.pendingCoachIds.length} Koç Katılım Onayı Bekliyor',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (coaches.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Kuruma kayıtlı başka koç bulunmuyor.')),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: coaches.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final coach = coaches[idx];
                    final isOwner = coach.isInstitutionOwner;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.14),
                        child: Text(
                          coach.firstName.isNotEmpty ? coach.firstName[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(coach.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          if (isOwner) ...[
                            const SizedBox(width: 6),
                            const Text('👑 Kurucu', style: TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                      subtitle: Text(coach.teacherSpecialty, style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
