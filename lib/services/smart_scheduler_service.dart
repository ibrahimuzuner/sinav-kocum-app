import 'dart:math';
import '../models/course_model.dart';
import '../models/question_log_model.dart';
import '../models/schedule_item_model.dart';
import 'package:uuid/uuid.dart';
import 'predefined_data.dart';

enum ScheduleStrategy {
  focusWeak, // Zayıf derslere ağırlık ver (Neti düşük olan derslere daha çok süre)
  balanced,  // Dengeli dağılım (Tüm derslere eşit ve dengeli süre)
  intensive, // Yoğun kamp (Maksimum soru çözümü ve yüksek hedef)
}

/// Öğrencinin konu hazırlık ve çalışma şekli tercihi
enum StudyContentMode {
  hybrid,       // 🎯 30 dk Video / Konu Tekrarı + Soru Çözümü (Önerilen)
  practiceOnly, // 🚀 Konularım Tamam (Sadece Soru Çözümü, Test & Hız Kampı)
  conceptFocus, // 📖 Sıfırdan Başlıyorum (Ağırlıklı Video / Konu Anlatımı + Pekiştirme)
}

class SmartSchedulerService {
  static final Uuid _uuid = const Uuid();

  /// Öğrencinin seçtiği hedef bölüm, hedef puan, sınav türü, başarı durumu,
  /// konu hazırlık modu ve elenen derslere (çalışmak istenmeyen dersler) göre
  /// yapay zeka destekli akıllı çalışma programı üretir.
  static List<ScheduleItemModel> generateSchedule({
    required List<CourseModel> courses,
    required List<QuestionLogModel> questionLogs,
    required int dailyMinutes, // Öğrencinin günde ayırabileceği toplam dakika
    required ScheduleStrategy strategy,
    required bool includeSunday, // Pazar günü dinlenme mi, çalışma mı?
    String targetExam = 'YKS (Sayısal)', // Öğrencinin hazırlandığı sınav türü
    String targetDepartment = 'Genel Başarı Hedefi', // Hedeflenen bölüm / program
    double targetScore = 450.0, // Hedef taban puan
    double targetNet = 85.0, // Hedeflenen toplam net
    StudyContentMode contentMode = StudyContentMode.hybrid, // Konu/Video + Soru mu, yoksa Sadece Soru mu?
    Set<String> excludedCourseIds = const {}, // Öğrencinin elediği / çalışmak istemediği dersler
  }) {
    // Elenen / çalışılmak istenmeyen dersleri filtrele
    final activeCourses = courses.where((c) => !excludedCourseIds.contains(c.id)).toList();
    if (activeCourses.isEmpty) return [];

    final activeDays = includeSunday ? [1, 2, 3, 4, 5, 6, 7] : [1, 2, 3, 4, 5, 6]; // 1=Pzt..7=Paz

    // 1. Hedef Bölüm ve Sınav Türüne Göre Yapay Zeka Ağırlık Katsayıları
    final Map<String, double> examMultiplier = {};
    final depLower = targetDepartment.toLowerCase();

    for (final course in activeCourses) {
      final cName = course.name.toLowerCase();
      double mult = 1.0;

      // Temel Sınav Türü Öncelikleri
      if (targetExam.contains('Sayısal')) {
        if (cName.contains('mat') || cName.contains('fizik') || cName.contains('kimya') || cName.contains('biyo') || cName.contains('geo')) {
          mult = 1.6;
        } else if (cName.contains('türk')) {
          mult = 1.2;
        } else {
          mult = 0.7;
        }
      } else if (targetExam.contains('Eşit Ağırlık')) {
        if (cName.contains('mat') || cName.contains('türk') || cName.contains('edeb') || cName.contains('tarih') || cName.contains('coğ')) {
          mult = 1.6;
        } else {
          mult = 0.7;
        }
      } else if (targetExam.contains('Sözel')) {
        if (cName.contains('türk') || cName.contains('edeb') || cName.contains('tarih') || cName.contains('coğ') || cName.contains('fel')) {
          mult = 1.7;
        } else {
          mult = 0.6;
        }
      } else if (targetExam.contains('KPSS')) {
        if (cName.contains('tarih') || cName.contains('coğ') || cName.contains('türk') || cName.contains('mat') || cName.contains('vatan') || cName.contains('hukuk') || cName.contains('iktisat') || cName.contains('maliye')) {
          mult = 1.5;
        }
      } else if (targetExam.contains('LGS')) {
        if (cName.contains('mat') || cName.contains('fen') || cName.contains('türk') || cName.contains('ink') || cName.contains('ing')) {
          mult = 1.5;
        }
      }

      // 🎯 YAPAY ZEKA BÖLÜM ODAKLI DERİNLEŞTİRME:
      // Tıp, Diş, Eczacılık hedefi -> Biyoloji ve Kimya katsayısını ekstra artır
      if (depLower.contains('tıp') || depLower.contains('diş') || depLower.contains('eczacılık') || depLower.contains('sağlık')) {
        if (cName.contains('biyo') || cName.contains('kimya')) {
          mult *= 1.35;
        } else if (cName.contains('mat')) {
          mult *= 1.25;
        }
      }
      // Bilgisayar, Yazılım, Elektrik-Elektronik, Makine -> Matematik, Geometri, Fizik
      else if (depLower.contains('bilgisayar') || depLower.contains('yazılım') || depLower.contains('mühendislik') || depLower.contains('elektrik') || depLower.contains('makine')) {
        if (cName.contains('mat') || cName.contains('geo') || cName.contains('fizik')) {
          mult *= 1.35;
        }
      }
      // Hukuk, Psikoloji, PDR, YBS -> Türkçe, Edebiyat, Matematik
      else if (depLower.contains('hukuk') || depLower.contains('adalet') || depLower.contains('hakim')) {
        if (cName.contains('türk') || cName.contains('edeb') || cName.contains('tarih') || cName.contains('mat')) {
          mult *= 1.3;
        }
      }
      // KPSS Yüksek Puan / Atama -> Tarih, Vatandaşlık, Matematik
      else if (depLower.contains('kpss') || depLower.contains('merkezi') || depLower.contains('müfettiş') || depLower.contains('memurluk')) {
        if (cName.contains('tarih') || cName.contains('vatan') || cName.contains('türk')) {
          mult *= 1.35;
        }
      }
      // LGS Fen Lisesi / Galatasaray -> Matematik ve Fen
      else if (depLower.contains('fen lise') || depLower.contains('galatasaray') || depLower.contains('kabataş')) {
        if (cName.contains('mat') || cName.contains('fen')) {
          mult *= 1.4;
        }
      }

      examMultiplier[course.id] = mult;
    }

    // 2. Başarı Oranlarını ve Öğrenci Eksiklerini Hesapla
    final Map<String, double> courseWeights = {};

    for (final course in activeCourses) {
      final logs = questionLogs.where((l) => l.courseId == course.id).toList();
      final totalQuestions = logs.fold(0, (sum, l) => sum + l.totalQuestions);
      final correctCount = logs.fold(0, (sum, l) => sum + l.correctCount);

      double accuracy = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 50.0;

      double weight = 1.0;
      switch (strategy) {
        case ScheduleStrategy.focusWeak:
          // Başarısı düşük olan derse daha çok ağırlık ver
          if (accuracy < 50) {
            weight = 3.2; // Çok zayıf -> En yüksek öncelik
          } else if (accuracy < 70) {
            weight = 2.2; // Orta seviye
          } else {
            weight = 1.2; // Başarılı ders -> Pekiştirme
          }
          break;

        case ScheduleStrategy.balanced:
          weight = 1.5;
          break;

        case ScheduleStrategy.intensive:
          if (accuracy < 65) {
            weight = 2.8;
          } else {
            weight = 2.0;
          }
          break;
      }

      // Hedef Puan Seviyesi Etkisi (Yüksek puan hedefinde soru yoğunluğu ve katsayı artışı)
      double scoreFactor = 1.0;
      if (targetScore >= 480 || (targetExam.contains('KPSS') && targetScore >= 88) || (targetExam.contains('LGS') && targetScore >= 470)) {
        scoreFactor = 1.2; // Yüksek derece hedefi
      } else if (targetScore >= 430 || (targetExam.contains('KPSS') && targetScore >= 80)) {
        scoreFactor = 1.1;
      }

      // Sınav katsayısıyla birleştir
      final examMult = examMultiplier[course.id] ?? 1.0;
      courseWeights[course.id] = weight * examMult * scoreFactor;
    }

    // 3. Günlük ders blokları sayısı
    int blocksPerDay = (dailyMinutes / 60).round().clamp(2, 4);
    int targetMinutesPerBlock = (dailyMinutes / blocksPerDay).round();

    // 4. Havuz oluşturma
    final List<CourseModel> coursePool = [];
    courseWeights.forEach((courseId, weight) {
      final course = activeCourses.firstWhere((c) => c.id == courseId);
      final repeatCount = weight.ceil().clamp(1, 6);
      for (int i = 0; i < repeatCount; i++) {
        coursePool.add(course);
      }
    });

    coursePool.shuffle(Random(42));

    final List<ScheduleItemModel> generatedItems = [];
    int poolIndex = 0;
    int topicCounter = 0;

    // Tüm varsayılan müfredat konularını al
    final defaultTopics = PredefinedData.getDefaultTopics();

    for (final day in activeDays) {
      final Set<String> coursesUsedToday = {};

      for (int b = 0; b < blocksPerDay; b++) {
        CourseModel selectedCourse = coursePool[poolIndex % coursePool.length];
        int attempts = 0;
        while (coursesUsedToday.contains(selectedCourse.id) && attempts < coursePool.length) {
          poolIndex++;
          selectedCourse = coursePool[poolIndex % coursePool.length];
          attempts++;
        }

        coursesUsedToday.add(selectedCourse.id);
        poolIndex++;
        topicCounter++;

        // Derse ait gerçek müfredat konularını filtrele
        final courseTopics = defaultTopics.where((t) => t.courseId == selectedCourse.id).toList();
        final topicName = courseTopics.isNotEmpty
            ? courseTopics[topicCounter % courseTopics.length].name
            : selectedCourse.name;

        // 🎯 ÇALIŞMA ŞEKLİ VE DAKİKA / SORU HESAPLAMASI
        int lectureMinutes;
        int practiceMinutes;
        int targetQuestions;
        String activityType;
        String topicGoal;

        switch (contentMode) {
          case StudyContentMode.hybrid:
            // 30 dk Video / Konu Tekrarı + Soru Çözümü (Önerilen)
            lectureMinutes = 30.clamp(15, (targetMinutesPerBlock * 0.5).round());
            practiceMinutes = targetMinutesPerBlock - lectureMinutes;
            targetQuestions = (practiceMinutes * 0.75).round().clamp(18, 45);
            activityType = 'hybrid';
            topicGoal = '$topicName (30 dk Video/Tekrar + $targetQuestions Soru)';
            break;

          case StudyContentMode.practiceOnly:
            // Konularım Tamam -> Sadece Soru Çözümü & Deneme
            lectureMinutes = 0;
            practiceMinutes = targetMinutesPerBlock;
            targetQuestions = (practiceMinutes * 0.85).round().clamp(35, 70);
            if (strategy == ScheduleStrategy.intensive || targetScore >= 480) {
              targetQuestions = (targetQuestions * 1.2).round();
            }
            activityType = 'practice';
            topicGoal = '$topicName: Soru Kampı ($targetQuestions Soru Çözümü)';
            break;

          case StudyContentMode.conceptFocus:
            // Sıfırdan Başlıyorum / Konu Eksiğim Çok -> 40 dk Video/Konu + 15 Soru
            lectureMinutes = (targetMinutesPerBlock * 0.65).round().clamp(30, 50);
            practiceMinutes = targetMinutesPerBlock - lectureMinutes;
            targetQuestions = (practiceMinutes * 0.65).round().clamp(10, 20);
            activityType = 'lecture';
            topicGoal = '$topicName (40 dk Video Konu Anlatımı + $targetQuestions Pekiştirme)';
            break;
        }

        generatedItems.add(
          ScheduleItemModel(
            id: _uuid.v4(),
            dayOfWeek: day,
            courseId: selectedCourse.id,
            courseName: selectedCourse.name,
            topicName: topicGoal,
            targetMinutes: targetMinutesPerBlock,
            targetQuestions: targetQuestions,
            activityType: activityType,
            lectureMinutes: lectureMinutes,
            practiceMinutes: practiceMinutes,
          ),
        );
      }
    }

    return generatedItems;
  }
}
