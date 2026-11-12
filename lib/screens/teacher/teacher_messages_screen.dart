import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coach_message_model.dart';
import '../../models/user_profile_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/premium_upgrade_modal.dart';
import 'widgets/teacher_student_detail_modal.dart';

class TeacherMessagesScreen extends StatefulWidget {
  final int refreshTrigger;
  final VoidCallback? onDataChanged;

  const TeacherMessagesScreen({
    super.key,
    this.refreshTrigger = 0,
    this.onDataChanged,
  });

  @override
  State<TeacherMessagesScreen> createState() => _TeacherMessagesScreenState();
}

class _TeacherMessagesScreenState extends State<TeacherMessagesScreen> {
  final AppFirebaseService _firebaseService = AppFirebaseService();
  List<UserProfileModel> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant TeacherMessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final teacher = Provider.of<UserProvider>(context, listen: false).userProfile;
    if (teacher == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (mounted) setState(() => _isLoading = true);
    final list = await _firebaseService.fetchStudentsForTeacher(teacher.id);
    list.sort((a, b) {
      final aUnread = a.messages.where((m) => !m.isFromTeacher && !m.isRead).length;
      final bUnread = b.messages.where((m) => !m.isFromTeacher && !m.isRead).length;
      if (aUnread != bUnread) return bUnread.compareTo(aUnread);
      final aLast = a.messages.isNotEmpty ? a.messages.last.createdAt : DateTime(2000);
      final bLast = b.messages.isNotEmpty ? b.messages.last.createdAt : DateTime(2000);
      return bLast.compareTo(aLast);
    });
    if (mounted) {
      setState(() {
        _students = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _showBroadcastDialog() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final teacher = userProvider.userProfile;
    if (teacher == null) return;

    if (!userProvider.hasProAccess) {
      PremiumUpgradeModal.show(context);
      return;
    }

    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mesaj göndermek için önce sınıfınıza öğrenci ekleyin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final msgCtrl = TextEditingController();
    bool sending = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.campaign_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text('Tüm Sınıfa Duyuru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: TextField(
            controller: msgCtrl,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Tüm öğrencilerine gidecek mesajı yaz...\nÖrn: Bugün 20:00\'da haftalık değerlendirme yapıyoruz!',
            ),
          ),
          actions: [
            TextButton(
              onPressed: sending ? null : () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton.icon(
              onPressed: sending
                  ? null
                  : () async {
                      final text = msgCtrl.text.trim();
                      if (text.isEmpty) return;
                      setModalState(() => sending = true);
                      for (final s in _students) {
                        final msg = CoachMessageModel(
                          id: '${DateTime.now().microsecondsSinceEpoch}_${s.id}',
                          senderId: teacher.id,
                          senderName: teacher.fullName,
                          senderRole: 'teacher',
                          message: text,
                          createdAt: DateTime.now(),
                        );
                        await _firebaseService.sendCoachMessage(studentId: s.id, message: msg);
                      }
                      setModalState(() => sending = false);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (mounted) {
                        _loadData();
                        widget.onDataChanged?.call();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('${_students.length} öğrenciye duyuru gönderildi 📣'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
              icon: sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text('Herkese Gönder'),
            ),
          ],
        ),
      ),
    );
    msgCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Mesajları', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Tüm Sınıfa Duyuru Gönder',
            onPressed: _showBroadcastDialog,
            icon: const Icon(Icons.campaign_outlined),
          ),
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _students.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 90),
                      const Icon(Icons.forum_outlined, size: 54, color: Color(0xFF4F46E5)),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Mesajlaşmak için önce öğrenci ekleyin.',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final lastMsg = student.messages.isNotEmpty ? student.messages.last : null;
                      final unread = student.messages
                          .where((m) => !m.isFromTeacher && !m.isRead)
                          .length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: unread > 0
                                ? const Color(0xFF4F46E5).withValues(alpha: 0.5)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.14),
                            child: Text(
                              student.firstName.isNotEmpty
                                  ? student.firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  student.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (lastMsg != null)
                                Text(
                                  Formatters.formatDateTurkish(lastMsg.createdAt),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            lastMsg != null
                                ? '${lastMsg.isFromTeacher ? "Siz: " : ""}${lastMsg.message}'
                                : 'Henüz mesaj yok — dokunup yazabilirsin',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                          trailing: unread > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => TeacherStudentDetailModal(
                                student: student,
                                initialTab: 2,
                                onUpdated: () {
                                  _loadData();
                                  widget.onDataChanged?.call();
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
