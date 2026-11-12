import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/assignment_model.dart';
import '../../../models/coach_message_model.dart';
import '../../../models/user_profile_model.dart';
import '../../../providers/user_provider.dart';
import '../../../services/firebase_service.dart';
import '../../../utils/formatters.dart';

class TeacherStudentDetailModal extends StatefulWidget {
  final UserProfileModel student;
  final int initialTab;
  final VoidCallback? onUpdated;

  const TeacherStudentDetailModal({
    super.key,
    required this.student,
    this.initialTab = 0,
    this.onUpdated,
  });

  @override
  State<TeacherStudentDetailModal> createState() => _TeacherStudentDetailModalState();
}

class _TeacherStudentDetailModalState extends State<TeacherStudentDetailModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppFirebaseService _firebaseService = AppFirebaseService();

  late List<AssignmentModel> _assignments;
  late List<CoachMessageModel> _messages;
  late TextEditingController _coachNoteController;
  final TextEditingController _messageController = TextEditingController();

  // Ödev ekleme formu
  final TextEditingController _courseController = TextEditingController(text: 'Matematik');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _targetQuestionsController = TextEditingController(text: '40');
  final TextEditingController _targetMinutesController = TextEditingController(text: '60');
  DateTime _dueDate = DateTime.now().add(const Duration(days: 2));
  bool _showAddAssignmentForm = false;

  bool _isSavingNote = false;
  bool _isSavingAssignment = false;
  bool _isSendingMessage = false;
  bool _isUnlinking = false;

  static const List<String> _quickCourses = [
    'Matematik',
    'Türkçe',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Geometri',
    'Tarih',
    'Coğrafya',
    'İngilizce',
    'Paragraf',
    'Genel Tekrar',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _assignments = List<AssignmentModel>.from(widget.student.assignments);
    _messages = List<CoachMessageModel>.from(widget.student.messages);
    _coachNoteController = TextEditingController(text: widget.student.coachNote ?? '');

    if (widget.initialTab == 2) {
      _markRead();
    }
    _tabController.addListener(() {
      if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        _markRead();
      }
    });
  }

  Future<void> _markRead() async {
    final hasUnread = _messages.any((m) => !m.isFromTeacher && !m.isRead);
    if (!hasUnread) return;
    final updated = await _firebaseService.markMessagesAsRead(
      studentId: widget.student.id,
      readerRole: 'teacher',
    );
    if (updated != null && mounted) {
      setState(() => _messages = updated);
      widget.onUpdated?.call();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _coachNoteController.dispose();
    _messageController.dispose();
    _courseController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _targetQuestionsController.dispose();
    _targetMinutesController.dispose();
    super.dispose();
  }

  Future<void> _saveCoachNote() async {
    setState(() => _isSavingNote = true);
    final ok = await _firebaseService.setStudentCoachNote(
      userId: widget.student.id,
      email: widget.student.email,
      coachNote: _coachNoteController.text.trim(),
    );
    if (mounted) {
      setState(() => _isSavingNote = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Koç tavsiyesi kaydedildi ✓' : 'Koç tavsiyesi kaydedilemedi.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? const Color(0xFF10B981) : Colors.redAccent,
        ),
      );
      if (ok) widget.onUpdated?.call();
    }
  }

  Future<void> _submitAssignment() async {
    final title = _titleController.text.trim();
    final course = _courseController.text.trim().isEmpty ? 'Genel' : _courseController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ödev başlığı girin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final teacher = Provider.of<UserProvider>(context, listen: false).userProfile;
    if (teacher == null) return;

    setState(() => _isSavingAssignment = true);

    final assignment = AssignmentModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      teacherId: teacher.id,
      teacherName: teacher.fullName,
      studentId: widget.student.id,
      courseName: course,
      title: title,
      description: _descController.text.trim(),
      targetQuestions: int.tryParse(_targetQuestionsController.text.trim()) ?? 0,
      targetMinutes: int.tryParse(_targetMinutesController.text.trim()) ?? 0,
      dueDate: _dueDate,
      createdAt: DateTime.now(),
    );

    final updated = await _firebaseService.addStudentAssignment(
      studentId: widget.student.id,
      assignment: assignment,
    );

    if (mounted) {
      setState(() => _isSavingAssignment = false);
      if (updated != null) {
        setState(() {
          _assignments = updated;
          _titleController.clear();
          _descController.clear();
          _showAddAssignmentForm = false;
        });
        widget.onUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödev öğrenciye başarıyla gönderildi 📚'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödev kaydedilirken hata oluştu.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _deleteAssignment(String assignmentId) async {
    final updated = await _firebaseService.deleteStudentAssignment(
      studentId: widget.student.id,
      assignmentId: assignmentId,
    );
    if (updated != null && mounted) {
      setState(() => _assignments = updated);
      widget.onUpdated?.call();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final teacher = Provider.of<UserProvider>(context, listen: false).userProfile;
    if (teacher == null) return;

    setState(() => _isSendingMessage = true);

    final msg = CoachMessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: teacher.id,
      senderName: teacher.fullName,
      senderRole: 'teacher',
      message: text,
      createdAt: DateTime.now(),
    );

    final updated = await _firebaseService.sendCoachMessage(
      studentId: widget.student.id,
      message: msg,
    );

    if (mounted) {
      setState(() => _isSendingMessage = false);
      if (updated != null) {
        setState(() {
          _messages = updated;
          _messageController.clear();
        });
        widget.onUpdated?.call();
      }
    }
  }

  Future<void> _unlinkStudent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Öğrenciyi Listeden Çıkar'),
        content: Text(
          '${widget.student.fullName} öğrencisini sınıfınızdan çıkarmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Çıkar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isUnlinking = true);
    final ok = await _firebaseService.unlinkStudentFromTeacher(widget.student.id);
    if (mounted) {
      setState(() => _isUnlinking = false);
      if (ok) {
        widget.onUpdated?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.student.fullName} listenizden çıkarıldı.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = widget.student.studyStats;
    final pendingCount = _assignments.where((a) => !a.isCompleted).length;
    final unreadCount = _messages.where((m) => !m.isFromTeacher && !m.isRead).length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Üst Tutamaç ve Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 14, 8),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.14),
                      child: Text(
                        widget.student.firstName.isNotEmpty
                            ? widget.student.firstName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.fullName,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.student.targetExam} • ${widget.student.targetDepartment}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_isUnlinking)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        tooltip: 'Öğrenciyi Çıkar',
                        onPressed: _unlinkStudent,
                        icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sekmeler
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4F46E5),
            unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF64748B),
            indicatorColor: const Color(0xFF4F46E5),
            tabs: [
              const Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: 'Çalışma Durumu'),
              Tab(
                icon: const Icon(Icons.assignment_outlined, size: 18),
                text: pendingCount > 0 ? 'Ödevler ($pendingCount)' : 'Ödevler',
              ),
              Tab(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                text: unreadCount > 0 ? 'Mesajlar ($unreadCount)' : 'Mesajlar',
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatusTab(isDark, stats),
                _buildAssignmentsTab(isDark),
                _buildMessagesTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(bool isDark, dynamic stats) {
    final totalHours = (stats.totalStudyMinutes / 60).toStringAsFixed(1);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Bugün Özeti
        Row(
          children: [
            Expanded(
              child: _statBox(
                isDark,
                'Bugün Süre',
                '${stats.todayStudyMinutes} dk',
                Icons.timer_rounded,
                const Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statBox(
                isDark,
                'Bugün Soru',
                '${stats.todaySolvedQuestions}',
                Icons.quiz_rounded,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statBox(
                isDark,
                'Seri',
                '${stats.streakDays} Gün',
                Icons.local_fire_department_rounded,
                const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Genel Toplam & Deneme Bilgileri
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Genel İstatistikler & Denemeler',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _infoRow('Toplam Çalışma Süresi', '$totalHours Saat (${stats.totalStudyMinutes} dk)'),
              _infoRow('Toplam Çözülen Soru', '${stats.totalSolvedQuestions} Soru'),
              _infoRow('Bugünkü Net', stats.todayNetScore.toStringAsFixed(1)),
              _infoRow('Girilen Deneme Sayısı', '${stats.mockExamCount} Deneme'),
              if (stats.latestMockTitle != null)
                _infoRow(
                  'Son Deneme (${stats.latestMockTitle})',
                  '${(stats.latestMockNet ?? 0).toStringAsFixed(1)} Net',
                ),
              _infoRow('En Yüksek Deneme Neti', '${stats.highestMockNet.toStringAsFixed(1)} Net'),
              _infoRow(
                'Hedef Net / Puan',
                '${widget.student.targetNet.toStringAsFixed(0)} Net • ${widget.student.targetScore.toStringAsFixed(0)} Puan',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Son Aktiviteler
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🕒 Son Çalışma Hareketleri',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (stats.recentActivities.isEmpty)
                Text(
                  'Henüz buluta senkronize edilmiş bir çalışma hareketi yok.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                )
              else
                ...stats.recentActivities.map<Widget>(
                  (act) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                        Expanded(child: Text(act, style: const TextStyle(fontSize: 12.5))),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Sabit Koçluk Notu / Tavsiye Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📌 Öğrenci Panosuna Koç Notu Bırak',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Bu not öğrencinin ana ekranında sabit tavsiye olarak görünür.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _coachNoteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Örn: Bu hafta her gün 25 paragraf + 30 problem çözmeyi ihmal etme!',
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSavingNote ? null : _saveCoachNote,
                  icon: _isSavingNote
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Koç Notunu Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        ElevatedButton.icon(
          onPressed: () => setState(() => _showAddAssignmentForm = !_showAddAssignmentForm),
          style: ElevatedButton.styleFrom(
            backgroundColor: _showAddAssignmentForm ? Colors.grey : const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: Icon(_showAddAssignmentForm ? Icons.close_rounded : Icons.add_task_rounded),
          label: Text(_showAddAssignmentForm ? 'Formu Kapat' : 'Yeni Ödev / Görev Ver'),
        ),
        if (_showAddAssignmentForm) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ders Seç veya Yaz', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _quickCourses.map((c) {
                    final selected = _courseController.text == c;
                    return ChoiceChip(
                      label: Text(c, style: const TextStyle(fontSize: 11)),
                      selected: selected,
                      onSelected: (_) => setState(() => _courseController.text = c),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Ders Adı',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Ödev Başlığı *',
                    hintText: 'Örn: Üslü Sayılar Test 1-4',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama / Yönerge (İsteğe Bağlı)',
                    hintText: 'Yanlış soruların çözümlerini videodan izle...',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _targetQuestionsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hedef Soru',
                          prefixIcon: Icon(Icons.quiz_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _targetMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hedef Süre (dk)',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded, size: 18, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 8),
                        Text('Son Teslim Tarihi: ${Formatters.formatDateTurkish(_dueDate)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSavingAssignment ? null : _submitAssignment,
                    icon: _isSavingAssignment
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                    label: const Text('Ödevi Öğrenciye Gönder'),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_assignments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Bu öğrenciye henüz ödev verilmemiş.',
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
            ),
          )
        else
          ..._assignments.map((a) {
            final statusColor = a.isCompleted
                ? const Color(0xFF10B981)
                : (a.isOverdue ? Colors.redAccent : const Color(0xFFF59E0B));
            final statusText = a.isCompleted
                ? 'Tamamlandı ✓'
                : (a.isOverdue ? 'Gecikti' : 'Bekliyor');
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          a.courseName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Ödevi Sil',
                        onPressed: () => _deleteAssignment(a.id),
                        icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      decoration: a.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (a.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      a.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      if (a.targetQuestions > 0)
                        Text('🎯 ${a.targetQuestions} Soru', style: const TextStyle(fontSize: 11.5)),
                      if (a.targetMinutes > 0)
                        Text('⏱️ ${a.targetMinutes} Dk', style: const TextStyle(fontSize: 11.5)),
                      Text(
                        '📅 Son: ${Formatters.formatDateTurkish(a.dueDate)}',
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMessagesTab(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '${widget.student.firstName} ile henüz mesajlaşma yok. İlk mesajı aşağıdan gönderebilirsin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMine = msg.isFromTeacher;
                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        decoration: BoxDecoration(
                          color: isMine
                              ? const Color(0xFF4F46E5)
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.message,
                              style: TextStyle(
                                color: isMine
                                    ? Colors.white
                                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')} • ${Formatters.formatDateTurkish(msg.createdAt)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isMine ? Colors.white70 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Öğrenciye mesaj yaz...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSendingMessage ? null : _sendMessage,
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  icon: _isSendingMessage
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(bool isDark, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
