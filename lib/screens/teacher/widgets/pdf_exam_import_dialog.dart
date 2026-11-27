import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../models/pdf_parsed_exam_model.dart';
import '../../../models/user_profile_model.dart';
import '../../../services/firebase_service.dart';
import '../../../services/pdf_exam_parser_service.dart';
import '../../../utils/formatters.dart';

class PdfExamImportDialog extends StatefulWidget {
  final List<UserProfileModel> registeredStudents;
  final VoidCallback onImportCompleted;

  const PdfExamImportDialog({
    super.key,
    required this.registeredStudents,
    required this.onImportCompleted,
  });

  @override
  State<PdfExamImportDialog> createState() => _PdfExamImportDialogState();
}

class _PdfExamImportDialogState extends State<PdfExamImportDialog> {
  bool _isPicking = false;
  bool _isParsing = false;
  bool _isSaving = false;
  String? _fileName;

  final TextEditingController _examTitleController = TextEditingController(text: 'Genel Deneme');
  DateTime _selectedDate = DateTime.now();
  String _targetExam = 'TYT';

  List<ParsedStudentExam> _parsedStudents = [];
  final Map<int, bool> _expandedState = {};

  @override
  void dispose() {
    _examTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickAndParsePdf() async {
    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isPicking = false);
        return;
      }

      final file = result.files.first;
      final Uint8List? bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dosya okunamadı veya boş.'), backgroundColor: Colors.redAccent),
          );
        }
        setState(() => _isPicking = false);
        return;
      }

      setState(() {
        _isPicking = false;
        _isParsing = true;
        _fileName = file.name;
      });

      final parsedList = await PdfExamParserService.parseExamPdf(
        bytes,
        registeredStudents: widget.registeredStudents,
      );

      if (mounted) {
        setState(() {
          _isParsing = false;
          _parsedStudents = parsedList;

          if (parsedList.isNotEmpty) {
            _examTitleController.text = parsedList.first.examTitle;
            _targetExam = parsedList.first.targetExam;
          }
        });

        if (parsedList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF içerisinde deneme sonuç tablosu veya karne tespit edilemedi.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPicking = false;
          _isParsing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF işleme hatası: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _saveAllSelectedExams() async {
    final toSave = _parsedStudents.where((s) => s.isSelected && s.matchedStudent != null).toList();

    if (toSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaydedilecek ve kurumdaki öğrencilerle eşleşmiş en az bir sonuç seçmelisiniz.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    int successCount = 0;
    final title = _examTitleController.text.trim().isEmpty ? 'Genel Deneme' : _examTitleController.text.trim();

    try {
      for (final item in toSave) {
        item.examTitle = title;
        item.targetExam = _targetExam;

        final newExam = item.toMockExamModel(
          id: const Uuid().v4(),
          examDate: _selectedDate,
        );

        final res = await AppFirebaseService().addStudentMockExam(
          studentId: item.matchedStudent!.id,
          exam: newExam,
        );

        if (res != null) {
          successCount++;
        }
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
        widget.onImportCompleted();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 $successCount öğrencinin "$title" deneme sınavı başarıyla kaydedildi!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt sırasında hata oluştu: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final matchedCount = _parsedStudents.where((s) => s.matchedStudent != null).length;
    final selectedCount = _parsedStudents.where((s) => s.isSelected && s.matchedStudent != null).length;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 820),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF4F46E5), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PDF ile Toplu Sınav Yükle',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Optik karne veya okul net listesini tek tıkla öğrencilere aktarın',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
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
              const Divider(height: 24),

              // İçerik Alanı
              Expanded(
                child: _isParsing || _isSaving
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF4F46E5)),
                            const SizedBox(height: 16),
                            Text(
                              _isSaving
                                  ? 'Öğrencilerin hesaplarına deneme sonuçları işleniyor...'
                                  : 'PDF ayrıştırılıyor ve öğrenciler eşleştiriliyor...',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : _parsedStudents.isEmpty
                        ? _buildUploadPlaceholder(isDark)
                        : _buildParsedResultsView(isDark, matchedCount),
              ),

              const Divider(height: 20),

              // Alt Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_parsedStudents.isNotEmpty) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: const Text('Farklı Dosya Seç'),
                      onPressed: _isSaving ? null : _pickAndParsePdf,
                    ),
                    const SizedBox(width: 10),
                  ],
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 10),
                  if (_parsedStudents.isNotEmpty)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(
                        selectedCount > 0
                            ? '$selectedCount Öğrenciyi Kaydet'
                            : 'Kayıt Yapılacak Öğrenci Yok',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: selectedCount > 0 && !_isSaving ? _saveAllSelectedExams : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF4F46E5), size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Optik Sınav Sonuç PDF\'ini Seçin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bilgi Sarmal, Özdebir, 3D, Limit, K12, Netbil vb.\ntüm optik karne ve net listeleri otomatik okunur.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isPicking
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.file_open_rounded),
              label: Text(_isPicking ? 'Açılıyor...' : 'PDF Dosyası Seç (.pdf)'),
              onPressed: _isPicking ? null : _pickAndParsePdf,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsedResultsView(bool isDark, int matchedCount) {
    return ListView(
      children: [
        // Sınav Bilgileri Kartı
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _examTitleController,
                      decoration: InputDecoration(
                        labelText: 'Sınav Başlığı / Adı',
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _targetExam,
                      decoration: InputDecoration(
                        labelText: 'Sınav Türü',
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'TYT', child: Text('TYT')),
                        DropdownMenuItem(value: 'AYT', child: Text('AYT')),
                        DropdownMenuItem(value: 'LGS', child: Text('LGS')),
                        DropdownMenuItem(value: 'KPSS', child: Text('KPSS')),
                        DropdownMenuItem(value: 'MSÜ', child: Text('MSÜ')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _targetExam = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (_fileName != null)
                    Expanded(
                      child: Text(
                        '📁 Dosya: $_fileName',
                        style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.calendar_today_rounded, size: 14),
                    label: Text(
                      Formatters.formatDateTurkish(_selectedDate),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Özet Barı
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tespit Edilen Öğrenciler (${_parsedStudents.length})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                _badge('$matchedCount Eşleşti', const Color(0xFF10B981)),
                const SizedBox(width: 6),
                _badge('${_parsedStudents.length - matchedCount} Eşleşmedi', const Color(0xFFF59E0B)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Öğrenci Kartları
        ..._parsedStudents.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isExpanded = _expandedState[idx] ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: item.matchedStudent != null
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: item.isSelected && item.matchedStudent != null,
                        activeColor: const Color(0xFF4F46E5),
                        onChanged: item.matchedStudent == null
                            ? null
                            : (val) {
                                setState(() => item.isSelected = val ?? false);
                              },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.rawStudentName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            // Eşleşen Kayıtlı Öğrenci Seçici
                            DropdownButtonHideUnderline(
                              child: DropdownButton<UserProfileModel?>(
                                value: item.matchedStudent,
                                isDense: true,
                                hint: const Text(
                                  '⚠️ Sistemdeki Öğrenciyi Seçin',
                                  style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                                ),
                                items: [
                                  const DropdownMenuItem<UserProfileModel?>(
                                    value: null,
                                    child: Text('Eşleşmeyi Kaldır (Kaydetme)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ),
                                  ...widget.registeredStudents.map((st) {
                                    return DropdownMenuItem<UserProfileModel?>(
                                      value: st,
                                      child: Text(
                                        '👤 ${st.firstName} ${st.lastName} (${st.email})',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    item.matchedStudent = val;
                                    item.isSelected = val != null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rozetler
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _badge('${Formatters.formatNet(item.totalNet)} Net', const Color(0xFF10B981)),
                          const SizedBox(height: 4),
                          if (item.score > 0)
                            _badge('~${item.score.toStringAsFixed(1)} Puan', const Color(0xFF4F46E5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Doğru-Yanlış-Boş Özeti
                  Row(
                    children: [
                      const SizedBox(width: 48),
                      Text(
                        '${item.totalCorrect}D  ${item.totalWrong}Y  ${item.totalEmpty}B',
                        style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                      ),
                      if (item.generalRank != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• Genel Sıra: ${item.generalRank}',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                        ),
                      ],
                      const Spacer(),
                      if (item.courseScores.isNotEmpty)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedState[idx] = !isExpanded;
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                isExpanded ? 'Dersleri Gizle' : 'Dersleri Göster (${item.courseScores.length})',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 16,
                                color: const Color(0xFF4F46E5),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Genişletilmiş Ders Netleri Tablosu
                  if (isExpanded && item.courseScores.isNotEmpty) ...[
                    const Divider(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: item.courseScores.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '${c.courseName}: ${c.correctCount}D ${c.wrongCount}Y (${Formatters.formatNet(c.netScore)}N)',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
