import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/course_model.dart';
import '../models/mock_exam_model.dart';
import '../models/question_log_model.dart';
import '../models/study_session_model.dart';
import '../models/user_profile_model.dart';
import '../providers/study_provider.dart';
import '../utils/formatters.dart';

class PdfReportService {
  /// Fontları yükle (Arial TTF yerel varlıklarından, başarısız olursa Roboto)
  static Future<pw.Font> _loadRegularFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/arial.ttf');
      return pw.Font.ttf(fontData);
    } catch (_) {
      return await PdfGoogleFonts.robotoRegular();
    }
  }

  static Future<pw.Font> _loadBoldFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/arialbd.ttf');
      return pw.Font.ttf(fontData);
    } catch (_) {
      return await PdfGoogleFonts.robotoBold();
    }
  }

  /// PDF Dokümanını Bellekte (Uint8List) Oluşturur
  static Future<Uint8List> generateReportPdf({
    required UserProfileModel user,
    required StatisticsPeriod period,
    required List<QuestionLogModel> periodLogs,
    required List<StudySessionModel> periodSessions,
    required List<CourseModel> courses,
    required List<MockExamModel> mockExams,
    required int streak,
  }) async {
    final regularFont = await _loadRegularFont();
    final boldFont = await _loadBoldFont();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/icon/app_icon.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      debugPrint('PDF Logo yükleme hatası: $e');
    }

    final pdf = pw.Document(
      title: 'Sınav Koçum - Analiz Raporu',
      author: 'Sınav Koçum',
      creator: 'Sınav Koçum Uygulaması',
    );

    // İstatistik Hesaplamaları
    final totalQ = periodLogs.fold(0, (sum, i) => sum + i.totalQuestions);
    final totalCorrect = periodLogs.fold(0, (sum, i) => sum + i.correctCount);
    final totalWrong = periodLogs.fold(0, (sum, i) => sum + i.wrongCount);
    final totalEmpty = periodLogs.fold(0, (sum, i) => sum + i.emptyCount);
    final totalNet = periodLogs.fold(0.0, (sum, i) => sum + i.netScore);
    final totalMinutes = periodSessions.fold(0, (sum, s) => sum + s.durationMinutes);

    final divisorDays = period == StatisticsPeriod.weekly ? 7 : (period == StatisticsPeriod.monthly ? 30 : 1);
    final dailyAvgQuestions = (totalQ / divisorDays).toStringAsFixed(1);
    final dailyAvgMinutes = (totalMinutes / divisorDays).round();
    final overallAccuracy = totalQ > 0 ? ((totalCorrect / totalQ) * 100).toStringAsFixed(1) : '0';

    final periodLabel = period == StatisticsPeriod.weekly
        ? 'Haftalık (Son 7 Gün)'
        : (period == StatisticsPeriod.monthly ? 'Aylık (Son 30 Gün)' : 'Tüm Zamanlar');

    // Ders Bazlı Dağılım Hesapla
    String bestCourse = '-';
    double bestNet = -1;
    String weakCourse = '-';
    double lowestAccuracy = 101;

    final List<List<String>> courseTableRows = [];

    for (final c in courses) {
      final cLogs = periodLogs.where((l) => l.courseId == c.id).toList();
      final q = cLogs.fold(0, (sum, l) => sum + l.totalQuestions);
      final cor = cLogs.fold(0, (sum, l) => sum + l.correctCount);
      final wr = cLogs.fold(0, (sum, l) => sum + l.wrongCount);
      final emp = cLogs.fold(0, (sum, l) => sum + l.emptyCount);
      final net = cLogs.fold(0.0, (sum, l) => sum + l.netScore);
      final acc = q > 0 ? ((cor / q) * 100).toStringAsFixed(1) : '0';

      if (q > 0) {
        if (net > bestNet) {
          bestNet = net;
          bestCourse = '${c.name} (${net.toStringAsFixed(1)} Net)';
        }
        final accNum = (cor / q) * 100;
        if (accNum < lowestAccuracy) {
          lowestAccuracy = accNum;
          weakCourse = '${c.name} (%${accNum.toInt()} Doğruluk)';
        }

        courseTableRows.add([
          c.name,
          '$q',
          '$cor',
          '$wr',
          '$emp',
          net.toStringAsFixed(2),
          '%$acc',
        ]);
      }
    }

    // PDF Sayfası Ekle
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        header: (context) => _buildPdfHeader(context, periodLabel, logoImage),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          // 1. ÖĞRENCİ BİLGİ KARTI
          _buildStudentInfoCard(user, periodLabel, streak),
          pw.SizedBox(height: 14),

          // 2. METRİK KARTLARI (6'lı GRID)
          _buildMetricsGrid(
            totalQ: totalQ,
            totalNet: totalNet,
            overallAccuracy: overallAccuracy,
            totalCorrect: totalCorrect,
            totalWrong: totalWrong,
            totalEmpty: totalEmpty,
            totalMinutes: totalMinutes,
            dailyAvgQuestions: dailyAvgQuestions,
            dailyAvgMinutes: dailyAvgMinutes,
          ),
          pw.SizedBox(height: 16),

          // 3. DERS LİDERLERİ
          _buildLeadersCard(bestCourse, weakCourse),
          pw.SizedBox(height: 16),

          // 4. DERS BAZLI DETAYLI KARNE TABLOSU
          pw.Text(
            'Ders Bazlı Performans Karnesi',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
          ),
          pw.SizedBox(height: 8),

          if (courseTableRows.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Bu dönem için henüz ders bazlı soru kaydı bulunmuyor.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: ['Ders Adı', 'Soru', 'Doğru', 'Yanlış', 'Boş', 'Net Skor', 'Başarı'],
              data: courseTableRows,
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF4F46E5)),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8FAFC)),
              cellAlignment: pw.Alignment.center,
              cellAlignments: {0: pw.Alignment.centerLeft},
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            ),

          // 5. DENEME SINAVLARI (Eğer varsa)
          if (mockExams.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Son Deneme Sınavları (${mockExams.length} Deneme)',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Deneme / Yayın Adı', 'Tarih', 'Süre', 'Net Skor', 'Başarı'],
              data: mockExams.take(5).map((m) {
                return [
                  m.title,
                  DateFormat('dd.MM.yyyy').format(m.date),
                  m.durationMinutes != null ? '${m.durationMinutes} dk' : '-',
                  '${m.totalNet.toStringAsFixed(2)} Net',
                  '%${m.accuracyRate}',
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF4338CA)),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8FAFC)),
              cellAlignment: pw.Alignment.center,
              cellAlignments: {0: pw.Alignment.centerLeft},
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            ),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  // --- PDF WIDGETS ---

  static pw.Widget _buildPdfHeader(pw.Context context, String periodLabel, pw.MemoryImage? logoImage) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFF4F46E5),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoImage != null)
                pw.Container(
                  width: 38,
                  height: 38,
                  margin: const pw.EdgeInsets.only(right: 12),
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Image(logoImage),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SINAV KOCUM',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Ogrenci Performans ve Basari Analiz Raporu',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey200),
                  ),
                ],
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              DateFormat('dd.MM.yyyy').format(DateTime.now()),
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Sinav Kocum • Hedefine Emin Adimlarla Ilerle',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Sayfa ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStudentInfoCard(UserProfileModel user, String periodLabel, int streak) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF1F5F9),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFCBD5E1), width: 0.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('ÖĞRENCİ', user.fullName.isNotEmpty ? user.fullName : user.firstName),
          _buildInfoItem('HEDEF BÖLÜM & PUAN', '${user.targetDepartment} (${user.targetScore.toInt()} Puan)'),
          _buildInfoItem('HEDEF SINAV', user.targetExam),
          _buildInfoItem('ÇALIŞMA SERİSİ', '$streak Gün (Aktif Seri)'),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
      ],
    );
  }

  static pw.Widget _buildMetricsGrid({
    required int totalQ,
    required double totalNet,
    required String overallAccuracy,
    required int totalCorrect,
    required int totalWrong,
    required int totalEmpty,
    required int totalMinutes,
    required String dailyAvgQuestions,
    required int dailyAvgMinutes,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: _buildMetricBox('Toplam Soru', '$totalQ', const PdfColor.fromInt(0xFF4F46E5)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _buildMetricBox('Toplam Net', totalNet.toStringAsFixed(2), const PdfColor.fromInt(0xFF10B981)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _buildMetricBox('Doğruluk Oranı', '%$overallAccuracy', const PdfColor.fromInt(0xFFF59E0B)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _buildMetricBox('Doğru / Yanlış / Boş', '$totalCorrect D / $totalWrong Y / $totalEmpty B', const PdfColor.fromInt(0xFF64748B)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _buildMetricBox('Toplam Süre', Formatters.formatMinutesToDuration(totalMinutes), const PdfColor.fromInt(0xFF0EA5E9)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _buildMetricBox('Günlük Ortalama', '$dailyAvgQuestions Soru / $dailyAvgMinutes dk', const PdfColor.fromInt(0xFF8B5CF6)),
        ),
      ],
    );
  }

  static pw.Widget _buildMetricBox(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color),
            maxLines: 1,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildLeadersCard(String bestCourse, String weakCourse) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Text('En Başarılı Ders: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0F172A))),
                pw.Expanded(
                  child: pw.Text(
                    bestCourse,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF10B981)),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Text('Geliştirilmesi Gereken: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0F172A))),
                pw.Expanded(
                  child: pw.Text(
                    weakCourse,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFFEF4444)),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PDF Raporunu Aç / Yazdır / PDF Olarak Cihaza Kaydet
  static Future<void> printOrSavePdf({
    required UserProfileModel user,
    required StatisticsPeriod period,
    required List<QuestionLogModel> periodLogs,
    required List<StudySessionModel> periodSessions,
    required List<CourseModel> courses,
    required List<MockExamModel> mockExams,
    required int streak,
  }) async {
    final pdfBytes = await generateReportPdf(
      user: user,
      period: period,
      periodLogs: periodLogs,
      periodSessions: periodSessions,
      courses: courses,
      mockExams: mockExams,
      streak: streak,
    );

    final fileName = 'SinavKocum_Rapor_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    if (kIsWeb) {
      // Web ve Safari ortamında iframe print kilitlendiği için doğrudan indirme tetiklenir
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
        subject: '${user.fullName.isNotEmpty ? user.fullName : user.firstName} - Sınav Koçum Analiz Raporu',
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: fileName,
      );
    }
  }

  /// PDF Raporunu Doğrudan Paylaş (WhatsApp, Drive, Gmail vb.)
  static Future<void> sharePdf({
    required UserProfileModel user,
    required StatisticsPeriod period,
    required List<QuestionLogModel> periodLogs,
    required List<StudySessionModel> periodSessions,
    required List<CourseModel> courses,
    required List<MockExamModel> mockExams,
    required int streak,
  }) async {
    final pdfBytes = await generateReportPdf(
      user: user,
      period: period,
      periodLogs: periodLogs,
      periodSessions: periodSessions,
      courses: courses,
      mockExams: mockExams,
      streak: streak,
    );

    final fileName = 'SinavKocum_Rapor_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
      subject: '${user.fullName.isNotEmpty ? user.fullName : user.firstName} - Sınav Koçum Analiz Raporu',
    );
  }
}
