import '../models/course_model.dart';
import '../models/topic_model.dart';
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
  /// konu hazırlık modu, elenen dersler ve günlük paragraf rutinine göre
  /// soru dağılımı ve müfredat sırasına odaklı akıllı çalışma programı üretir.
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
    bool addDailyParagraph = true, // Günlük 20 Paragraf Rutini (Zihin gelişimi ve net artışı)
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
      // Resmi sınav soru dağılımı ağırlığını al (Örn: KPSS Türkçe 30 soru, Geometri sadece 3 soru)
      final int qWeight = PredefinedData.getCourseQuestionWeight(targetExam, course.id);
      double mult = (qWeight / 15.0).clamp(0.4, 2.5);

      // KPSS'de Geometri sadece 3 soru çıktığı için ağırlığı sınırlanır (her güne eklenmesini engeller)
      if (targetExam.contains('KPSS') && course.id == 'geometri') {
        mult = 0.35; // Haftada en fazla 1 blok
      }

      // Bölüm odaklı derinleştirme
      if (depLower.contains('tıp') || depLower.contains('diş') || depLower.contains('eczacılık') || depLower.contains('sağlık')) {
        if (cName.contains('biyo') || cName.contains('kimya')) {
          mult *= 1.35;
        } else if (cName.contains('mat')) {
          mult *= 1.25;
        }
      } else if (depLower.contains('bilgisayar') || depLower.contains('yazılım') || depLower.contains('mühendislik') || depLower.contains('elektrik') || depLower.contains('makine')) {
        if (cName.contains('mat') || cName.contains('geo') || cName.contains('fizik')) {
          mult *= 1.35;
        }
      } else if (depLower.contains('hukuk') || depLower.contains('adalet') || depLower.contains('hakim')) {
        if (cName.contains('türk') || cName.contains('edeb') || cName.contains('tarih') || cName.contains('mat')) {
          mult *= 1.3;
        }
      } else if (depLower.contains('kpss') || depLower.contains('merkezi') || depLower.contains('müfettiş') || depLower.contains('memurluk')) {
        if (cName.contains('tarih') || cName.contains('vatan') || cName.contains('türk')) {
          mult *= 1.35;
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
          if (accuracy < 50) {
            weight = 2.8;
          } else if (accuracy < 70) {
            weight = 2.0;
          } else {
            weight = 1.2;
          }
          break;

        case ScheduleStrategy.balanced:
          weight = 1.5;
          break;

        case ScheduleStrategy.intensive:
          if (accuracy < 65) {
            weight = 2.6;
          } else {
            weight = 1.9;
          }
          break;
      }

      // Sınav katsayısıyla birleştir
      final examMult = examMultiplier[course.id] ?? 1.0;
      courseWeights[course.id] = weight * examMult;
    }

    // 3. Günlük ders blokları sayısı ve süre hesabı
    int effectiveDailyMinutes = dailyMinutes;
    if (addDailyParagraph && !excludedCourseIds.contains('turkce')) {
      // 25 dk paragraf için ayrılır, kalan süre ders bloklarına paylaştırılır
      effectiveDailyMinutes = (dailyMinutes - 25).clamp(60, 480);
    }

    int blocksPerDay = (effectiveDailyMinutes / 60).round().clamp(2, 4);
    int targetMinutesPerBlock = (effectiveDailyMinutes / blocksPerDay).round();

    // 4. Havuz oluşturma (Soru yoğunluğu ve katsayıya göre düzenlenir)
    final List<CourseModel> coursePool = [];
    courseWeights.forEach((courseId, weight) {
      final course = activeCourses.firstWhere((c) => c.id == courseId);
      int repeatCount = weight.ceil().clamp(1, 5);

      // KPSS'de Geometri sadece 3 soru olduğu için haftada 1 kez havuza girer
      if (targetExam.contains('KPSS') && courseId == 'geometri') {
        repeatCount = 1;
      }

      for (int i = 0; i < repeatCount; i++) {
        coursePool.add(course);
      }
    });

    final List<ScheduleItemModel> generatedItems = [];
    int poolIndex = 0;

    // Her dersin müfredattaki sırasını ve haftalık yerleşim sayısını takip eden sayaçlar
    final Map<String, int> courseTopicSequence = {};
    final Map<String, int> weeklyCourseCounts = {};

    for (final day in activeDays) {
      final Set<String> coursesUsedToday = {};

      // 🎯 1. GÜNLÜK 20 PARAGRAF RUTİNİ (İsteğe bağlı)
      if (addDailyParagraph && !excludedCourseIds.contains('turkce')) {
        generatedItems.add(
          ScheduleItemModel(
            id: _uuid.v4(),
            dayOfWeek: day,
            courseId: 'turkce',
            courseName: 'Türkçe / Paragraf',
            topicName: '🎯 Günlük 20 Paragraf: Zihin Gelişimi & Hızlı Okuma Rutini (20 Soru)',
            targetMinutes: 25,
            targetQuestions: 20,
            activityType: 'practice',
            lectureMinutes: 0,
            practiceMinutes: 25,
          ),
        );
      }

      // 🎯 2. MÜFREDAT SIRASINA VE SORU YOĞUNLUĞUNA GÖRE DERS BLOKLARI
      for (int b = 0; b < blocksPerDay; b++) {
        CourseModel selectedCourse = coursePool[poolIndex % coursePool.length];
        int attempts = 0;
        while (attempts < coursePool.length &&
            (coursesUsedToday.contains(selectedCourse.id) ||
             (targetExam.contains('KPSS') && selectedCourse.id == 'geometri' && (weeklyCourseCounts['geometri'] ?? 0) >= 1))) {
          poolIndex++;
          selectedCourse = coursePool[poolIndex % coursePool.length];
          attempts++;
        }

        coursesUsedToday.add(selectedCourse.id);
        weeklyCourseCounts[selectedCourse.id] = (weeklyCourseCounts[selectedCourse.id] ?? 0) + 1;
        poolIndex++;

        // Derse ve sınava ait GERÇEK müfredat konularını sıralı olarak al
        final courseTopics = PredefinedData.getTopicsForExam(targetExam, courseId: selectedCourse.id);
        final topicSeq = courseTopicSequence[selectedCourse.id] ?? 0;
        final currentTopic = courseTopics.isNotEmpty
            ? courseTopics[topicSeq % courseTopics.length]
            : TopicModel(id: '${selectedCourse.id}_genel', courseId: selectedCourse.id, name: selectedCourse.name);

        courseTopicSequence[selectedCourse.id] = topicSeq + 1;
        final topicName = currentTopic.name;

        // ÇALIŞMA ŞEKLİ VE DAKİKA / SORU HESAPLAMASI
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
            // Sıfırdan Başlıyorum -> 40 dk Video/Konu + Pekiştirme
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
