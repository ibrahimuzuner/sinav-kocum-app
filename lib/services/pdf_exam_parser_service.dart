import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/mock_exam_model.dart';
import '../models/pdf_parsed_exam_model.dart';
import '../models/user_profile_model.dart';

class PdfExamParserService {
  /// PDF baytlarını okuyarak öğrencilerin deneme sonuçlarını ayrıştırır
  static Future<List<ParsedStudentExam>> parseExamPdf(
    Uint8List pdfBytes, {
    List<UserProfileModel> registeredStudents = const [],
  }) async {
    final List<ParsedStudentExam> results = [];
    PdfDocument? document;

    try {
      document = PdfDocument(inputBytes: pdfBytes);
      final extractor = PdfTextExtractor(document);
      final totalPages = document.pages.count;

      String globalExamTitle = '';

      // 1. Önce karne sayfalarını kontrol et (Sayfa bazlı ayrıntılı sonuçlar)
      final List<ParsedStudentExam> karneResults = [];

      for (int i = 0; i < totalPages; i++) {
        try {
          final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
          if (pageText.trim().isEmpty) continue;

          // Karne sayfası mı? (Soru Doğru Yanlış Boş Net ve TYT/AYT/LGS dersleri içerir)
          if (_isKarnePage(pageText)) {
            final parsed = _parseKarnePage(pageText);
            if (parsed != null) {
              karneResults.add(parsed);
              if (globalExamTitle.isEmpty && parsed.examTitle.isNotEmpty) {
                globalExamTitle = parsed.examTitle;
              }
            }
          }
        } catch (e) {
          debugPrint('Sayfa $i ayrıştırma uyarısı: $e');
        }
      }

      if (karneResults.isNotEmpty) {
        results.addAll(karneResults);
      } else {
        // 2. Eğer bireysel karne bulunamadıysa, toplu okul/şube net tablosunu tara
        for (int i = 0; i < totalPages; i++) {
          try {
            final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
            if (pageText.trim().isEmpty) continue;

            final tableResults = _parseTablePage(pageText);
            results.addAll(tableResults);
          } catch (e) {
            debugPrint('Tablo sayfa $i ayrıştırma uyarısı: $e');
          }
        }
      }

      // 3. Başlık ve Sınav türünü tamamla
      for (final r in results) {
        if (r.examTitle.isEmpty && globalExamTitle.isNotEmpty) {
          r.examTitle = globalExamTitle;
        }
        if (r.examTitle.toLowerCase().contains('ayt')) {
          r.targetExam = 'AYT';
        } else if (r.examTitle.toLowerCase().contains('lgs')) {
          r.targetExam = 'LGS';
        } else if (r.examTitle.toLowerCase().contains('kpss')) {
          r.targetExam = 'KPSS';
        } else {
          r.targetExam = 'TYT';
        }
      }

      // 4. Kurumdaki kayıtlı öğrencilerle otomatik eşleştir
      for (final r in results) {
        r.matchedStudent = matchStudent(r.rawStudentName, registeredStudents);
      }

      // Tekilleştir (Aynı öğrenci birden fazla sayfada çıktıysa en zengin olanı tut)
      final Map<String, ParsedStudentExam> uniqueMap = {};
      for (final r in results) {
        final key = r.normalizedStudentName;
        if (!uniqueMap.containsKey(key) || (r.courseScores.length > uniqueMap[key]!.courseScores.length)) {
          uniqueMap[key] = r;
        }
      }

      return uniqueMap.values.toList();
    } catch (e, stack) {
      debugPrint('PdfExamParserService genel hata: $e\n$stack');
      return [];
    } finally {
      try {
        document?.dispose();
      } catch (_) {}
    }
  }

  /// Sayfanın bir bireysel öğrenci karnesi olup olmadığını test eder
  static bool _isKarnePage(String text) {
    final lower = text.toLowerCase();
    final hasMetrics = lower.contains('doğru') || lower.contains('dogru') || lower.contains('yanlış') || lower.contains('yanlis');
    final hasCourses = lower.contains('türkçe') || lower.contains('turkce') || lower.contains('matematik') || lower.contains('fen');
    final hasHeader = lower.contains('tyt') || lower.contains('ayt') || lower.contains('lgs') || lower.contains('kpss');
    return hasMetrics && hasCourses && hasHeader;
  }

  /// Tek bir karne sayfasından öğrenci ve ders netlerini ayrıştırır
  static ParsedStudentExam? _parseKarnePage(String text) {
    try {
      final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.isEmpty) return null;

      // 1. Sınav Adını Bul
      String examTitle = 'Genel Deneme';
      for (final l in lines.take(6)) {
        if (l.contains('TYT') || l.contains('AYT') || l.contains('LGS') || l.contains('TG') || l.contains('DENEME') || l.contains('SARMAL') || l.contains('ÖZDEBİR')) {
          if (!l.startsWith('OKUL') && !l.startsWith('SINIFI') && !l.contains('NET LİSTESİ')) {
            examTitle = l.replaceAll('%', '').trim();
            break;
          }
        }
      }

      // 2. Puanı Bul (örn: 221,296 veya 231.051)
      double score = 0.0;
      final scoreReg = RegExp(r'\b(\d{2,3}[,\.]\d{2,4})\b');
      for (final l in lines.take(8)) {
        final match = scoreReg.firstMatch(l);
        if (match != null) {
          final val = parseTurkishDouble(match.group(1)!);
          if (val >= 100.0 && val <= 560.0) {
            score = val;
            break;
          }
        }
      }

      // 3. Öğrenci Adını ve Toplam Değerleri Bul
      // Örnek satır: "ARDA YARAMIŞ 120 29 12 79 26 ,00" veya "DURU ÖZTÜRK 120 30 6 84 28 ,50"
      String studentName = '';
      int totalQ = 0;
      int totalD = 0;
      int totalY = 0;
      int totalB = 0;
      double totalN = 0.0;

      final summaryLineReg = RegExp(
        r'([A-ZÇĞİÖŞÜa-zçğıöşü\s]{3,35}?)\s+(\d{2,3})\s+(\d{1,3})\s+(\d{1,3})\s+(\d{1,3})\s+([0-9\-\,\s]+)',
      );

      for (final l in lines) {
        final match = summaryLineReg.firstMatch(l);
        if (match != null) {
          final candidateName = match.group(1)!.trim();
          final q = int.tryParse(match.group(2)!) ?? 0;
          if (q >= 40 && candidateName.split(' ').length >= 2 && !candidateName.contains('Soru') && !candidateName.contains('Toplam')) {
            studentName = candidateName;
            totalQ = q;
            totalD = int.tryParse(match.group(3)!) ?? 0;
            totalY = int.tryParse(match.group(4)!) ?? 0;
            totalB = int.tryParse(match.group(5)!) ?? 0;
            totalN = parseTurkishDouble(match.group(6)!);
            break;
          }
        }
      }

      // Eğer özet satırından isim çıkmadıysa sınıf altındaki satırlardan ara
      if (studentName.isEmpty) {
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains('12-') || lines[i].contains('11-') || lines[i].contains('Mezun')) {
            if (i + 1 < lines.length) {
              final next = lines[i + 1].replaceAll(RegExp(r'\d+'), '').trim();
              if (next.length >= 3 && next.split(' ').length >= 2) {
                studentName = next;
                break;
              }
            }
          }
        }
      }

      if (studentName.isEmpty) return null;

      // 4. Ders Bazlı Netleri Ayrıştır
      final List<MockExamCourseScore> courses = [];

      // Desteklenen ders kalıpları
      final coursePatterns = <String, String>{
        'turkce': r'(?:TYT\s+)?Türkçe\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'tarih': r'Tarih-?1?\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'cografya': r'Coğrafya-?1?\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'felsefe': r'Felsefe(?:\s*\(Seçmeli\))?\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'din': r'Din\s+Kül.*?\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'matematik': r'(?:TYT\s+)?Matematik-?1?\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'geometri': r'Geometri\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'fizik': r'Fizik\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'kimya': r'Kimya\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
        'biyoloji': r'Biyoloji\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([0-9\-\,\.]+)',
      };

      final courseDisplayNames = <String, String>{
        'turkce': 'Türkçe',
        'tarih': 'Tarih',
        'cografya': 'Coğrafya',
        'felsefe': 'Felsefe',
        'din': 'Din Kültürü',
        'matematik': 'Matematik',
        'geometri': 'Geometri',
        'fizik': 'Fizik',
        'kimya': 'Kimya',
        'biyoloji': 'Biyoloji',
      };

      for (final entry in coursePatterns.entries) {
        final reg = RegExp(entry.value, caseSensitive: false);
        final match = reg.firstMatch(text);
        if (match != null) {
          final cor = int.tryParse(match.group(2)!) ?? 0;
          final wrg = int.tryParse(match.group(3)!) ?? 0;
          final emp = int.tryParse(match.group(4)!) ?? 0;
          final net = parseTurkishDouble(match.group(5)!);

          courses.add(MockExamCourseScore(
            courseId: entry.key,
            courseName: courseDisplayNames[entry.key] ?? entry.key,
            correctCount: cor,
            wrongCount: wrg,
            emptyCount: emp,
            netScore: net,
          ));
        }
      }

      // 5. Sıralama bilgisi (Öğrenci Sıra No satırı)
      int? genelSira;
      int? kurumSira;
      final rankReg = RegExp(r'Öğrenci Sıra No\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)');
      final rankMatch = rankReg.firstMatch(text);
      if (rankMatch != null) {
        kurumSira = int.tryParse(rankMatch.group(2)!);
        genelSira = int.tryParse(rankMatch.group(5)!);
      }

      return ParsedStudentExam(
        rawStudentName: studentName,
        normalizedStudentName: normalize(studentName),
        examTitle: examTitle,
        score: score,
        totalQuestions: totalQ > 0 ? totalQ : 120,
        totalCorrect: totalD,
        totalWrong: totalY,
        totalEmpty: totalB,
        totalNet: totalN,
        courseScores: courses,
        generalRank: genelSira,
        schoolRank: kurumSira,
      );
    } catch (e) {
      debugPrint('_parseKarnePage hata: $e');
      return null;
    }
  }

  /// Toplu Okul / Şube Net Listesi tablosunu ayrıştırır (Sayfa 1-5 formatı)
  static List<ParsedStudentExam> _parseTablePage(String text) {
    final List<ParsedStudentExam> list = [];
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // Sınav Adını Bul
    String examTitle = 'Genel Deneme';
    for (final l in lines.take(8)) {
      if (l.contains('BİLGİ SARMAL') || l.contains('ÖZDEBİR') || l.contains('TYT') || l.contains('TG')) {
        final match = RegExp(r'(?:BİLGİ SARMAL|ÖZDEBİR|3D|LİMİT|TÜRKİYE GENELİ|TG)[A-Z0-9\s]+', caseSensitive: false).firstMatch(l);
        if (match != null) {
          examTitle = match.group(0)!.trim();
          break;
        }
      }
    }

    // Tablo satırlarını eşleştir: "1 0 SELİN YILMAZ 12-XX 25 12 22,00 ..."
    final rowReg = RegExp(
      r'^\s*(\d{1,3})\s+\d+\s+([A-ZÇĞİÖŞÜa-zçğıöşü\s]{3,30}?)\s+\d{1,2}-[A-Za-z0-9\-]+\s*(.*)$',
    );

    for (final l in lines) {
      final match = rowReg.firstMatch(l);
      if (match != null) {
        final sRank = int.tryParse(match.group(1)!) ?? 0;
        final sName = match.group(2)!.trim();
        final rawNumbers = match.group(3)!.trim();

        if (sName.isEmpty || sName.contains('Ortalama') || sName.contains('Genel')) continue;

        // Sayı dizisindeki parçaları al
        final tokens = rawNumbers.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
        if (tokens.length < 6) continue;

        // Toplam doğru/yanlış/net ve puan genellikle sondaki sayılardır
        // Örn: "... 64 22 58,50 316,898 36015"
        double score = 0.0;
        double totalNet = 0.0;
        int totalD = 0;
        int totalY = 0;
        int? genRank;

        for (int t = tokens.length - 1; t >= 0; t--) {
          final clean = tokens[t].replaceAll(',', '.');
          final numVal = double.tryParse(clean);
          if (numVal != null) {
            if (numVal > 1000 && genRank == null) {
              genRank = numVal.toInt();
            } else if (numVal >= 100.0 && numVal <= 560.0 && score == 0.0) {
              score = numVal;
            } else if (numVal >= -20.0 && numVal <= 120.0 && totalNet == 0.0 && score > 0) {
              totalNet = numVal;
              if (t >= 2) {
                totalY = int.tryParse(tokens[t - 1]) ?? 0;
                totalD = int.tryParse(tokens[t - 2]) ?? 0;
              }
              break;
            }
          }
        }

        list.add(ParsedStudentExam(
          rawStudentName: sName,
          normalizedStudentName: normalize(sName),
          examTitle: examTitle,
          score: score,
          totalQuestions: 120,
          totalCorrect: totalD,
          totalWrong: totalY,
          totalEmpty: 120 - (totalD + totalY),
          totalNet: totalNet,
          courseScores: [], // Tablo modunda ana toplamlar ve puan garanti alınır
          schoolRank: sRank > 0 ? sRank : null,
          generalRank: genRank,
        ));
      }
    }

    return list;
  }

  /// Türkçe karakter uyumlu normalizasyon (İ, ı, Ş, ş, Ğ, ğ vb.)
  static String normalize(String str) {
    return str
        .trim()
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Virgüllü Türkçe sayıları double'a çevirir (örn: "28 ,50" -> 28.5)
  static double parseTurkishDouble(String str) {
    final clean = str.replaceAll(' ', '').replaceAll(',', '.').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  /// Ayrıştırılan öğrenci ismini kurumdaki kayıtlı öğrencilerle akıllı eşleştirir
  static UserProfileModel? matchStudent(
    String parsedName,
    List<UserProfileModel> registeredStudents,
  ) {
    if (registeredStudents.isEmpty) return null;
    final normParsed = normalize(parsedName);

    // 1. Tam Ad Eşleşmesi (Ad + Soyad)
    for (final s in registeredStudents) {
      final normReg = normalize('${s.firstName} ${s.lastName}');
      if (normReg == normParsed) return s;
    }

    // 2. Kelime Bazlı Eşleşme (İlk Ad ve Son Soyad)
    final parsedWords = normParsed.split(' ').where((w) => w.length > 1).toList();
    if (parsedWords.length >= 2) {
      final firstWord = parsedWords.first;
      final lastWord = parsedWords.last;

      for (final s in registeredStudents) {
        final fn = normalize(s.firstName);
        final ln = normalize(s.lastName);

        final firstMatch = fn.contains(firstWord) || firstWord.contains(fn);
        final lastMatch = ln.contains(lastWord) || lastWord.contains(ln);

        if (firstMatch && lastMatch) {
          return s;
        }
      }
    }

    // 3. Tekil İsim / Soyisim Uyumu
    for (final s in registeredStudents) {
      final fn = normalize(s.firstName);
      final ln = normalize(s.lastName);
      if (normParsed.contains(fn) && normParsed.contains(ln)) {
        return s;
      }
    }

    return null;
  }
}
