import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/assignment_model.dart';
import '../../models/user_profile_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/premium_upgrade_modal.dart';
import 'widgets/teacher_student_detail_modal.dart';

class _StudentAssignmentItem {
  final UserProfileModel student;
  final AssignmentModel assignment;

  const _StudentAssignmentItem({
    required this.student,
    required this.assignment,
  });
}

class TeacherAssignmentsScreen extends StatefulWidget {
  final int refreshTrigger;
  final VoidCallback? onDataChanged;

  const TeacherAssignmentsScreen({
    super.key,
    this.refreshTrigger = 0,
    this.onDataChanged,
  });

  @override
  State<TeacherAssignmentsScreen> createState() => _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState extends State<TeacherAssignmentsScreen> {
  final AppFirebaseService _firebaseService = AppFirebaseService();
  List<UserProfileModel> _students = [];
  bool _isLoading = true;
  String _filter = 'Tümü';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant TeacherAssignmentsScreen oldWidget) {
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
    if (mounted) {
      setState(() {
        _students = list;
        _isLoading = false;
      });
    }
  }

  List<_StudentAssignmentItem> get _filteredItems {
    final List<_StudentAssignmentItem> all = [];
    for (final s in _students) {
      for (final a in s.assignments) {
        all.add(_StudentAssignmentItem(student: s, assignment: a));
      }
    }
    all.sort((a, b) => b.assignment.createdAt.compareTo(a.assignment.createdAt));

    return all.where((item) {
      final a = item.assignment;
      if (_filter == 'Bekleyenler') return !a.isCompleted && !a.isOverdue;
      if (_filter == 'Tamamlananlar') return a.isCompleted;
      if (_filter == 'Gecikenler') return a.isOverdue;
      return true;
    }).toList();
  }

  Future<void> _showQuickAssignDialog() async {
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
          content: Text('Ödev verebilmek için önce sınıfınıza öğrenci ekleyin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    UserProfileModel selectedStudent = _students.first;
    final courseCtrl = TextEditingController(text: 'Matematik');
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final qCtrl = TextEditingController(text: '40');
    final minCtrl = TextEditingController(text: '60');
    DateTime dueDate = DateTime.now().add(const Duration(days: 2));
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Hızlı Ödev Ver', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<UserProfileModel>(
                  value: selectedStudent,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Öğrenci Seçin',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  items: _students
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.fullName, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedStudent = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ders Adı',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ödev Başlığı *',
                    hintText: 'Örn: Problemler 3 Test',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (İsteğe Bağlı)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Hedef Soru'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Süre (dk)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                    );
                    if (picked != null) setModalState(() => dueDate = picked);
                  },
                  icon: const Icon(Icons.event_rounded),
                  label: Text('Son Teslim: ${Formatters.formatDateTurkish(dueDate)}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      setModalState(() => saving = true);
                      final assignment = AssignmentModel(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        teacherId: teacher.id,
                        teacherName: teacher.fullName,
                        studentId: selectedStudent.id,
                        courseName: courseCtrl.text.trim().isEmpty
                            ? 'Genel'
                            : courseCtrl.text.trim(),
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        targetQuestions: int.tryParse(qCtrl.text.trim()) ?? 0,
                        targetMinutes: int.tryParse(minCtrl.text.trim()) ?? 0,
                        dueDate: dueDate,
                        createdAt: DateTime.now(),
                      );
                      final updated = await _firebaseService.addStudentAssignment(
                        studentId: selectedStudent.id,
                        assignment: assignment,
                      );
                      setModalState(() => saving = false);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (updated != null && mounted) {
                        _loadData();
                        widget.onDataChanged?.call();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('${selectedStudent.firstName} öğrencisine ödev gönderildi 📚'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );

    courseCtrl.dispose();
    titleCtrl.dispose();
    descCtrl.dispose();
    qCtrl.dispose();
    minCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödev Takibi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickAssignDialog,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Ödev Ver'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: ['Tümü', 'Bekleyenler', 'Tamamlananlar', 'Gecikenler'].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 90),
                            const Icon(Icons.assignment_outlined, size: 54, color: Color(0xFF4F46E5)),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                _students.isEmpty
                                    ? 'Ödev vermek için önce öğrenci ekleyin.'
                                    : 'Bu filtrede ödev bulunmuyor.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final a = item.assignment;
                            final statusColor = a.isCompleted
                                ? const Color(0xFF10B981)
                                : (a.isOverdue ? Colors.redAccent : const Color(0xFFF59E0B));
                            final statusLabel = a.isCompleted
                                ? 'Tamamlandı ✓'
                                : (a.isOverdue ? 'Gecikti' : 'Bekliyor');

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: statusColor.withValues(alpha: 0.35)),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => TeacherStudentDetailModal(
                                      student: item.student,
                                      initialTab: 1,
                                      onUpdated: () {
                                        _loadData();
                                        widget.onDataChanged?.call();
                                      },
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor:
                                                const Color(0xFF4F46E5).withValues(alpha: 0.14),
                                            child: Text(
                                              item.student.firstName.isNotEmpty
                                                  ? item.student.firstName[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item.student.fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.5,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${a.courseName} • ${a.title}',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              a.isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      if (a.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          a.description,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (a.targetQuestions > 0)
                                            Text(
                                              '🎯 ${a.targetQuestions} Soru  ',
                                              style: const TextStyle(fontSize: 11.5),
                                            ),
                                          if (a.targetMinutes > 0)
                                            Text(
                                              '⏱️ ${a.targetMinutes} Dk  ',
                                              style: const TextStyle(fontSize: 11.5),
                                            ),
                                          const Spacer(),
                                          Text(
                                            '📅 ${Formatters.formatDateTurkish(a.dueDate)}',
                                            style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
