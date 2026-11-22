import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/institution_model.dart';
import '../../../models/user_profile_model.dart';

class TeacherInstitutionCard extends StatelessWidget {
  final InstitutionModel? institution;
  final UserProfileModel teacher;
  final bool isDark;
  final VoidCallback onCreateRequested;
  final VoidCallback onJoinRequested;
  final VoidCallback onManageRequested;
  final VoidCallback onViewCoachesRequested;
  final VoidCallback onLeaveRequested;
  final VoidCallback? onManagePendingCoachesRequested;
  final VoidCallback? onCancelJoinRequested;

  const TeacherInstitutionCard({
    super.key,
    required this.institution,
    required this.teacher,
    required this.isDark,
    required this.onCreateRequested,
    required this.onJoinRequested,
    required this.onManageRequested,
    required this.onViewCoachesRequested,
    required this.onLeaveRequested,
    this.onManagePendingCoachesRequested,
    this.onCancelJoinRequested,
  });

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kurum Katılım Kodu ($code) kopyalandı! 📋'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasInst = teacher.hasInstitution;

    // 1. KURUMA BAĞLI AMA KURUM BİLGİSİ YÜKLENİYORSA -> YÜKLENİYOR KARTI (ASLA KATIL GÖSTERİLMEZ)
    if (hasInst && institution == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${teacher.institutionName ?? "Kurum"} bilgileri yükleniyor...',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // 2. KURUMA HİÇ BAĞLI DEĞİLSE -> BAŞVURU VEYA KATILIM KARTI
    if (!hasInst) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
              blurRadius: 12,
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
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Color(0xFF4F46E5), size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eğitim Kurumu & Koçluk Merkezi',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Dershane veya merkezinizle ortak öğrenci havuzuna bağlanın.',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCreateRequested,
                    icon: const Icon(Icons.add_business_rounded, size: 16),
                    label: const Text('Kurum Başvurusu Yap', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onJoinRequested,
                    icon: const Icon(Icons.key_rounded, size: 16),
                    label: const Text('Kuruma Katıl', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 2. KURUMA BAĞLIYSA -> AKTİF KURUM KARTI VEYA BEKLEYEN TALEP KARTI
    final inst = institution!;
    final isOwner = inst.ownerCoachId == teacher.id;

    // Koç kuruma katılım isteği göndermiş ve kurucu onayı bekliyorsa
    final isCoachPendingApproval =
        teacher.institutionRole == 'coach' &&
        teacher.institutionStatus == 'pending' &&
        !inst.coachIds.contains(teacher.id);

    if (isCoachPendingApproval) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
              blurRadius: 12,
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
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 22),
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
                              inst.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '⏳ Onay Bekleniyor',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Katılım talebiniz kurum kurucusuna iletildi. Onaylandıktan sonra kadroya ve ortak öğrenci havuzuna bağlanacaksınız.',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onCancelJoinRequested,
                  icon: const Icon(Icons.close_rounded, size: 15),
                  label: const Text('Katılım Talebini İptal Et', style: TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (inst.isPending) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Yönetici Onayı Bekleniyor';
      statusIcon = Icons.hourglass_top_rounded;
    } else if (inst.isApproved) {
      statusColor = const Color(0xFF10B981);
      statusText = 'Aktif Kurum';
      statusIcon = Icons.verified_rounded;
    } else {
      statusColor = Colors.redAccent;
      statusText = 'Askıda';
      statusIcon = Icons.pause_circle_rounded;
    }

    Widget logoWidget;
    if (inst.logoBase64 != null && inst.logoBase64!.isNotEmpty) {
      if (inst.logoBase64!.startsWith('http')) {
        logoWidget = Image.network(
          inst.logoBase64!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 26),
        );
      } else {
        try {
          logoWidget = Image.memory(
            base64Decode(inst.logoBase64!),
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 26),
          );
        } catch (_) {
          logoWidget = const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 26);
        }
      }
    } else {
      logoWidget = const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 26);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: inst.isPending
              ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
              : const Color(0xFF4F46E5).withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 46,
                    height: 46,
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    child: Center(child: logoWidget),
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
                              inst.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isOwner ? const Color(0xFFF59E0B) : const Color(0xFF0EA5E9))
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isOwner ? '👑 Kurucu' : '👨‍🏫 Kadro',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isOwner ? const Color(0xFFF59E0B) : const Color(0xFF0EA5E9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (inst.city != null && inst.city!.isNotEmpty) ...[
                            Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 2),
                            Text(inst.city!, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 11, color: statusColor),
                                const SizedBox(width: 3),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // KURUCU: ONAY BEKLEYEN KOÇ TALEPLERİ BANNERI
            if (isOwner && inst.pendingCoachIds.isNotEmpty) ...[
              InkWell(
                onTap: onManagePendingCoachesRequested,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notification_important_rounded, size: 18, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${inst.pendingCoachIds.length} Koç Katılım Onayı Bekliyor',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'İncele / Onayla',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // KURUM KODU & KADRO ROZETLERİ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key_rounded, size: 16, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 6),
                  Text(
                    'Kurum Kodu: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    inst.code,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF4F46E5)),
                    tooltip: 'Kurum Kodunu Kopyala',
                    padding: const EdgeInsets.only(left: 4),
                    constraints: const BoxConstraints(),
                    onPressed: () => _copyCode(context, inst.code),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onViewCoachesRequested,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.groups_rounded, size: 16, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          '${inst.coachCount} Koç',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // AKSİYON BUTONLARI
            Row(
              children: [
                if (isOwner)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onManageRequested,
                      icon: const Icon(Icons.tune_rounded, size: 15),
                      label: const Text('Kurumu Yönet', style: TextStyle(fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F46E5),
                        side: const BorderSide(color: Color(0xFF4F46E5)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                if (isOwner) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewCoachesRequested,
                    icon: const Icon(Icons.badge_outlined, size: 15),
                    label: const Text('Kurum Kadrosu', style: TextStyle(fontSize: 11.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.grey),
                  tooltip: 'Kurumdan Ayrıl',
                  onPressed: onLeaveRequested,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
