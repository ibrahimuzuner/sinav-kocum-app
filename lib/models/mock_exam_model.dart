class MockExamCourseScore {
  final String courseId;
  final String courseName;
  final int correctCount;
  final int wrongCount;
  final int emptyCount;
  final double netScore;

  const MockExamCourseScore({
    required this.courseId,
    required this.courseName,
    required this.correctCount,
    required this.wrongCount,
    this.emptyCount = 0,
    required this.netScore,
  });

  int get totalQuestions => correctCount + wrongCount + emptyCount;

  static double calculateNet(int correct, int wrong, {bool isLgs = false}) {
    final penalty = isLgs ? 3.0 : 4.0;
    final net = correct - (wrong / penalty);
    return double.parse(net.toStringAsFixed(2));
  }

  MockExamCourseScore copyWith({
    String? courseId,
    String? courseName,
    int? correctCount,
    int? wrongCount,
    int? emptyCount,
    double? netScore,
  }) {
    return MockExamCourseScore(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      emptyCount: emptyCount ?? this.emptyCount,
      netScore: netScore ?? this.netScore,
    );
  }

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'courseName': courseName,
    'correctCount': correctCount,
    'wrongCount': wrongCount,
    'emptyCount': emptyCount,
    'netScore': netScore,
  };

  factory MockExamCourseScore.fromJson(Map<String, dynamic> json) => MockExamCourseScore(
    courseId: json['courseId'] as String? ?? '',
    courseName: json['courseName'] as String? ?? '',
    correctCount: json['correctCount'] as int? ?? 0,
    wrongCount: json['wrongCount'] as int? ?? 0,
    emptyCount: json['emptyCount'] as int? ?? 0,
    netScore: (json['netScore'] as num?)?.toDouble() ?? 0.0,
  );
}

class MockExamModel {
  final String id;
  final String title;
  final String examType; // "Genel Deneme" veya "Branş Denemesi"
  final String targetExam;
  final DateTime date;
  final int? durationMinutes;
  final String? notes;
  final List<MockExamCourseScore> courseScores;
  final double? estimatedScore; // Tahmini ÖSYM / MEB Sınav Puanı
  final String? coachAdvice;    // Yapay Zeka Koç Analizi ve Ağırlık Tavsiyesi

  const MockExamModel({
    required this.id,
    required this.title,
    this.examType = 'Genel Deneme',
    required this.targetExam,
    required this.date,
    this.durationMinutes,
    this.notes,
    required this.courseScores,
    this.estimatedScore,
    this.coachAdvice,
  });

  int get totalCorrect => courseScores.fold(0, (sum, c) => sum + c.correctCount);
  int get totalWrong => courseScores.fold(0, (sum, c) => sum + c.wrongCount);
  int get totalEmpty => courseScores.fold(0, (sum, c) => sum + c.emptyCount);
  int get totalQuestions => totalCorrect + totalWrong + totalEmpty;

  double get totalNet {
    final sum = courseScores.fold(0.0, (acc, c) => acc + c.netScore);
    return double.parse(sum.toStringAsFixed(2));
  }

  double get accuracyRate {
    if (totalQuestions == 0) return 0.0;
    return double.parse(((totalCorrect / totalQuestions) * 100).toStringAsFixed(1));
  }

  MockExamModel copyWith({
    String? id,
    String? title,
    String? examType,
    String? targetExam,
    DateTime? date,
    int? durationMinutes,
    String? notes,
    List<MockExamCourseScore>? courseScores,
    double? estimatedScore,
    String? coachAdvice,
  }) {
    return MockExamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      examType: examType ?? this.examType,
      targetExam: targetExam ?? this.targetExam,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      courseScores: courseScores ?? this.courseScores,
      estimatedScore: estimatedScore ?? this.estimatedScore,
      coachAdvice: coachAdvice ?? this.coachAdvice,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'examType': examType,
    'targetExam': targetExam,
    'date': date.toIso8601String(),
    'durationMinutes': durationMinutes,
    'notes': notes,
    'courseScores': courseScores.map((c) => c.toJson()).toList(),
    'estimatedScore': estimatedScore,
    'coachAdvice': coachAdvice,
  };

  factory MockExamModel.fromJson(Map<String, dynamic> json) => MockExamModel(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'Deneme Sınavı',
    examType: json['examType'] as String? ?? 'Genel Deneme',
    targetExam: json['targetExam'] as String? ?? 'Genel',
    date: DateTime.parse(json['date'] as String),
    durationMinutes: json['durationMinutes'] as int?,
    notes: json['notes'] as String?,
    courseScores: (json['courseScores'] as List<dynamic>?)
            ?.map((c) => MockExamCourseScore.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [],
    estimatedScore: (json['estimatedScore'] as num?)?.toDouble(),
    coachAdvice: json['coachAdvice'] as String?,
  );

  static ({
    double gyNet,
    double gkNet,
    double hukukNet,
    double iktisatNet,
    double maliyeNet,
    double muhasebeNet,
    double kamuNet,
    bool hasAlanEntry,
  }) _extractKpssNets(List<MockExamCourseScore> scores) {
    double gyNet = 0.0;
    double gkNet = 0.0;
    double hukukNet = 0.0;
    double iktisatNet = 0.0;
    double maliyeNet = 0.0;
    double muhasebeNet = 0.0;
    double kamuNet = 0.0;
    bool hasAlanEntry = false;

    for (final s in scores) {
      final id = s.courseId.toLowerCase();
      final name = s.courseName.toLowerCase();
      final entered = s.correctCount > 0 || s.wrongCount > 0;

      if (id.contains('hukuk') || name.contains('hukuk')) {
        hukukNet += s.netScore;
        if (entered) hasAlanEntry = true;
      } else if (id.contains('iktisat') || name.contains('iktisat')) {
        iktisatNet += s.netScore;
        if (entered) hasAlanEntry = true;
      } else if (id.contains('maliye') || name.contains('maliye')) {
        maliyeNet += s.netScore;
        if (entered) hasAlanEntry = true;
      } else if (id.contains('muhasebe') || name.contains('muhasebe')) {
        muhasebeNet += s.netScore;
        if (entered) hasAlanEntry = true;
      } else if (id.contains('kamu') || name.contains('kamu')) {
        kamuNet += s.netScore;
        if (entered) hasAlanEntry = true;
      } else if (id.contains('turk') ||
          id.contains('mat') ||
          id.contains('geo') ||
          name.contains('türkçe') ||
          name.contains('matematik') ||
          name.contains('geometri')) {
        gyNet += s.netScore;
      } else if (id.contains('tar') ||
          id.contains('cog') ||
          id.contains('vat') ||
          id.contains('gunc') ||
          name.contains('tarih') ||
          name.contains('coğrafya') ||
          name.contains('vatandaşlık')) {
        gkNet += s.netScore;
      } else {
        gyNet += s.netScore * 0.5;
        gkNet += s.netScore * 0.5;
      }
    }

    return (
      gyNet: gyNet,
      gkNet: gkNet,
      hukukNet: hukukNet,
      iktisatNet: iktisatNet,
      maliyeNet: maliyeNet,
      muhasebeNet: muhasebeNet,
      kamuNet: kamuNet,
      hasAlanEntry: hasAlanEntry,
    );
  }

  /// Resmi ÖSYM 2024 verileriyle KPSS P48 (Alan Bilgisi) puan hesaplama motoru
  /// Ağırlıklar: %10 GY + %10 GK + %20 Hukuk + %20 İktisat + %20 Maliye + %20 Muhasebe
  static double _computeKpssP48Score({
    required double gyNet,
    required double gkNet,
    required double hukukNet,
    required double iktisatNet,
    required double maliyeNet,
    required double muhasebeNet,
    required double kamuNet,
    required double aspMean,
    required double aspSd,
    required double aspMax,
  }) {
    final spGy = 50.0 + 10.0 * ((gyNet - 16.978) / 9.135);
    final spGk = 50.0 + 10.0 * ((gkNet - 19.533) / 10.808);
    final spHukuk = 50.0 + 10.0 * ((hukukNet - 10.952) / 7.235);
    final spIktisat = 50.0 + 10.0 * ((iktisatNet - 7.476) / 6.025);
    final spMaliye = 50.0 + 10.0 * ((maliyeNet - 9.392) / 5.838);
    final spMuhasebe = 50.0 + 10.0 * ((muhasebeNet - 6.230) / 4.685);

    double asp;
    final hasCoreP48 = hukukNet != 0 || iktisatNet != 0 || maliyeNet != 0 || muhasebeNet != 0;
    if (hasCoreP48) {
      asp = (0.10 * spGy) +
          (0.10 * spGk) +
          (0.20 * spHukuk) +
          (0.20 * spIktisat) +
          (0.20 * spMaliye) +
          (0.20 * spMuhasebe);
    } else {
      // Yalnızca Kamu Yönetimi (+ GY/GK) girilmişse P29/P30 ağırlık yaklaşımı
      final spKamu = 50.0 + 10.0 * ((kamuNet - 8.707) / 5.317);
      asp = (0.15 * spGy) + (0.15 * spGk) + (0.70 * spKamu);
    }

    final score = 70.0 + (30.0 * (2.0 * (asp - aspMean) - aspSd)) / (2.0 * (aspMax - aspMean) - aspSd);
    return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
  }

  /// Sınav türüne ve ders netlerine göre ÖSYM standartlarında tahmini puan hesaplar
  static double calculateEstimatedScore(String targetExam, List<MockExamCourseScore> scores) {
    if (scores.isEmpty) return 0.0;
    final totalNet = scores.fold(0.0, (acc, c) => acc + c.netScore);
    final lowerExam = targetExam.toLowerCase();

    // 1a. EKPSS (60 Soru) -> KPSS'den önce kontrol edilir
    if (lowerExam.contains('ekpss')) {
      if (totalNet <= 0) return 0.0;
      final score = 50.0 + (totalNet * (50.0 / 60.0));
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 1b. KPSS Alan Bilgisi (P48: GY %10, GK %10, Hukuk %20, İktisat %20, Maliye %20, Muhasebe %20)
    if (lowerExam.contains('kpss') && lowerExam.contains('alan')) {
      if (totalNet <= 0) return 0.0;
      final nets = _extractKpssNets(scores);
      if (nets.hasAlanEntry) {
        return _computeKpssP48Score(
          gyNet: nets.gyNet,
          gkNet: nets.gkNet,
          hukukNet: nets.hukukNet,
          iktisatNet: nets.iktisatNet,
          maliyeNet: nets.maliyeNet,
          muhasebeNet: nets.muhasebeNet,
          kamuNet: nets.kamuNet,
          aspMean: 52.0,
          aspSd: 8.8,
          aspMax: 96.5,
        );
      }
      // Sadece GY-GK girildiyse KPSS P3 puanını hesapla
      final p3 = 54.20 + (nets.gyNet * 0.408) + (nets.gkNet * 0.384);
      return double.parse(p3.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 1c. KPSS Eğitim Bilimleri (80 Soru)
    if (lowerExam.contains('kpss') && (lowerExam.contains('eğitim') || lowerExam.contains('egitim'))) {
      if (totalNet <= 0) return 0.0;
      final score = 40.0 + (totalNet * 0.75);
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 1d. KPSS ÖABT (75 Soru)
    if (lowerExam.contains('öabt') || lowerExam.contains('oabt')) {
      if (totalNet <= 0) return 0.0;
      final score = 40.0 + ((totalNet / 75.0) * 60.0);
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 1e. KPSS (Genel Yetenek - Genel Kültür / Ön Lisans / Ortaöğretim: 120 Soru) -> ÖSYM KPSSP3 / P93 / P94
    if (lowerExam.contains('kpss')) {
      if (totalNet <= 0) return 0.0;
      final nets = _extractKpssNets(scores);
      double gyNet = nets.gyNet;
      double gkNet = nets.gkNet;
      if (gyNet == 0 && gkNet == 0 && totalNet > 0) {
        gyNet = totalNet * 0.5;
        gkNet = totalNet * 0.5;
      }

      // ÖSYM 2024 / 2022 KPSSP94 & P3 resmi standart sapma ve ortalama formülü
      // 53 GY + 46 GK (99 Net) -> 93.48 Puan (2024 ÖSYM resmi karşılığı)
      final score = 54.20 + (gyNet * 0.408) + (gkNet * 0.384);
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 2. LGS (90 Soru) -> 500 Puan Ölçeği
    if (targetExam.contains('LGS')) {
      double rawSum = 0;
      for (final s in scores) {
        final id = s.courseId.toLowerCase();
        if (id.contains('mat') || id.contains('fen') || id.contains('türk')) {
          rawSum += s.netScore * 4.0;
        } else {
          rawSum += s.netScore * 1.0;
        }
      }
      final lgsScore = 100.0 + (rawSum * 1.45);
      return double.parse(lgsScore.clamp(100.0, 500.0).toStringAsFixed(2));
    }

    // 3. YKS (TYT & AYT) / MSÜ -> 500 Puan Ölçeği
    if (targetExam.contains('YKS') || targetExam.contains('TYT') || targetExam.contains('AYT') || targetExam.contains('MSÜ')) {
      double rawSum = 0;
      for (final s in scores) {
        final id = s.courseId.toLowerCase();
        if (id.contains('mat') || id.contains('türk')) {
          rawSum += s.netScore * 3.3;
        } else if (id.contains('fiz') || id.contains('kim') || id.contains('biyo') || id.contains('fen')) {
          rawSum += s.netScore * 3.4;
        } else {
          rawSum += s.netScore * 3.4;
        }
      }
      final tytScore = 100.0 + rawSum;
      return double.parse(tytScore.clamp(100.0, 560.0).toStringAsFixed(2));
    }

    // 4. DGS & ALES (100 Soru) -> 100 Puan Ölçeği
    if (targetExam.contains('DGS') || targetExam.contains('ALES')) {
      final score = (totalNet / 100.0) * 100.0;
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 5. HMGS (120 Soru) -> 100 Puan Ölçeği (Baraj 70)
    if (targetExam.contains('HMGS')) {
      final score = (totalNet / 120.0) * 100.0;
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 6. AGS (80 Soru) -> 100 Puan Ölçeği
    if (targetExam.contains('AGS')) {
      final score = (totalNet / 80.0) * 100.0;
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 7. EKPSS (60 Soru) -> 100 Puan Ölçeği (50 Taban + Net Katsayısı)
    if (targetExam.contains('EKPSS')) {
      final score = 50.0 + (totalNet * (50.0 / 60.0));
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 8. YDS / YÖKDİL / YDT (80 Soru) -> 100 Puan Ölçeği (Her Net 1.25 Puan)
    if (targetExam.contains('YDS') || targetExam.contains('YÖKDİL') || targetExam.contains('YDT')) {
      final score = (totalNet / 80.0) * 100.0;
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    // 9. Ehliyet (50 Soru) -> 100 Puan Ölçeği (Baraj 70 Puan / Her Soru 2 Puan)
    if (targetExam.contains('Ehliyet')) {
      final score = (totalNet / 50.0) * 100.0;
      return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
    }

    final maxQ = scores.fold(0, (sum, c) => sum + c.totalQuestions);
    if (maxQ == 0) return 0.0;
    return double.parse(((totalNet / maxQ) * 100.0).clamp(0.0, 100.0).toStringAsFixed(2));
  }

  /// KPSS için geçmiş ÖSYM sınav yılları simülasyonu üretir
  static Map<String, double> calculateKpssYearlyBreakdown(
    List<MockExamCourseScore> scores, {
    String targetExam = '',
  }) {
    if (scores.isEmpty) return {};
    final totalNet = scores.fold(0.0, (acc, c) => acc + c.netScore);
    if (totalNet <= 0) return {};

    final lowerExam = targetExam.toLowerCase();
    final nets = _extractKpssNets(scores);

    // KPSS Alan Bilgisi (P48) yıllara göre ÖSYM simülasyonu
    if (lowerExam.contains('alan') && nets.hasAlanEntry) {
      final p2024 = _computeKpssP48Score(
        gyNet: nets.gyNet,
        gkNet: nets.gkNet,
        hukukNet: nets.hukukNet,
        iktisatNet: nets.iktisatNet,
        maliyeNet: nets.maliyeNet,
        muhasebeNet: nets.muhasebeNet,
        kamuNet: nets.kamuNet,
        aspMean: 52.0,
        aspSd: 8.8,
        aspMax: 96.5,
      );
      final p2023 = _computeKpssP48Score(
        gyNet: nets.gyNet,
        gkNet: nets.gkNet,
        hukukNet: nets.hukukNet,
        iktisatNet: nets.iktisatNet,
        maliyeNet: nets.maliyeNet,
        muhasebeNet: nets.muhasebeNet,
        kamuNet: nets.kamuNet,
        aspMean: 51.2,
        aspSd: 8.9,
        aspMax: 97.6,
      );
      final p2022 = _computeKpssP48Score(
        gyNet: nets.gyNet,
        gkNet: nets.gkNet,
        hukukNet: nets.hukukNet,
        iktisatNet: nets.iktisatNet,
        maliyeNet: nets.maliyeNet,
        muhasebeNet: nets.muhasebeNet,
        kamuNet: nets.kamuNet,
        aspMean: 52.6,
        aspSd: 8.7,
        aspMax: 95.8,
      );
      final pOrt = (p2024 + p2023 + p2022) / 3.0;

      final result = <String, double>{
        '2024': p2024,
        '2023': p2023,
        '2022': p2022,
        'Ortalama': double.parse(pOrt.clamp(0.0, 100.0).toStringAsFixed(2)),
      };
      if (nets.gyNet + nets.gkNet > 0) {
        final p3 = 54.20 + (nets.gyNet * 0.408) + (nets.gkNet * 0.384);
        result['P3'] = double.parse(p3.clamp(0.0, 100.0).toStringAsFixed(2));
      }
      return result;
    }

    // KPSS Eğitim Bilimleri (80 Soru)
    if (lowerExam.contains('eğitim') || lowerExam.contains('egitim')) {
      final p2024 = 40.0 + (totalNet * 0.75);
      final p2023 = 40.6 + (totalNet * 0.745);
      final p2022 = 39.5 + (totalNet * 0.755);
      final pOrt = (p2024 + p2023 + p2022) / 3.0;
      return {
        '2024': double.parse(p2024.clamp(0.0, 100.0).toStringAsFixed(2)),
        '2023': double.parse(p2023.clamp(0.0, 100.0).toStringAsFixed(2)),
        '2022': double.parse(p2022.clamp(0.0, 100.0).toStringAsFixed(2)),
        'Ortalama': double.parse(pOrt.clamp(0.0, 100.0).toStringAsFixed(2)),
      };
    }

    // KPSS GY-GK (P3 / P93 / P94)
    double gyNet = nets.gyNet;
    double gkNet = nets.gkNet;
    if (gyNet == 0 && gkNet == 0 && totalNet > 0) {
      gyNet = totalNet * 0.5;
      gkNet = totalNet * 0.5;
    }

    // ÖSYM resmi verilerine göre kalibre edilmiş katsayılar
    final p2024 = 54.20 + (gyNet * 0.408) + (gkNet * 0.384);
    final p2022 = 54.60 + (gyNet * 0.412) + (gkNet * 0.385);
    final p2020 = 53.88 + (gyNet * 0.410) + (gkNet * 0.383);
    final p2018 = 54.50 + (gyNet * 0.410) + (gkNet * 0.385);
    final pOrt = (p2024 + p2022 + p2020 + p2018) / 4.0;

    return {
      '2024': double.parse(p2024.clamp(0.0, 100.0).toStringAsFixed(2)),
      '2022': double.parse(p2022.clamp(0.0, 100.0).toStringAsFixed(2)),
      '2020': double.parse(p2020.clamp(0.0, 100.0).toStringAsFixed(2)),
      '2018': double.parse(p2018.clamp(0.0, 100.0).toStringAsFixed(2)),
      'Ortalama': double.parse(pOrt.clamp(0.0, 100.0).toStringAsFixed(2)),
    };
  }

  /// Deneme sonuçlarına göre ağırlık verilmesi gereken alanları ve koç analizini üretir
  static String generateCoachAdvice({
    required String targetExam,
    required List<MockExamCourseScore> scores,
    double? targetScore,
    double? targetNet,
  }) {
    if (scores.isEmpty) return 'Analiz için en az 1 ders sonucu girilmelidir.';

    final totalNet = scores.fold(0.0, (acc, c) => acc + c.netScore);
    final estScore = calculateEstimatedScore(targetExam, scores);

    final sortedByAccuracy = [...scores]..sort((a, b) {
        final accA = a.totalQuestions > 0 ? (a.correctCount / a.totalQuestions) : 0.0;
        final accB = b.totalQuestions > 0 ? (b.correctCount / b.totalQuestions) : 0.0;
        return accA.compareTo(accB);
      });

    final weakest = sortedByAccuracy.first;
    final strongest = sortedByAccuracy.last;

    final adviceBuffer = StringBuffer();
    final lowerExam = targetExam.toLowerCase();

    if (targetScore != null && estScore < targetScore) {
      final scoreGap = targetScore - estScore;
      adviceBuffer.writeln('🎯 Hedef puanınıza (${targetScore.toInt()}) ulaşmak için ~${scoreGap.toStringAsFixed(1)} puana daha ihtiyacınız var.');
    } else if (targetScore != null && estScore >= targetScore) {
      adviceBuffer.writeln('🎉 Tebrikler! Tahmini puanınız ($estScore), hedef puanınızı (${targetScore.toInt()}) yakaladı.');
    }

    if (targetNet != null && totalNet < targetNet) {
      final netGap = targetNet - totalNet;
      adviceBuffer.writeln('🎯 Hedef netinize (${targetNet.toStringAsFixed(1)}) ulaşmak için +${netGap.toStringAsFixed(1)} net artırmalısınız.');
    }

    if (lowerExam.contains('kpss') && !lowerExam.contains('ekpss')) {
      final breakdown = calculateKpssYearlyBreakdown(scores, targetExam: targetExam);

      if (lowerExam.contains('alan')) {
        final nets = _extractKpssNets(scores);
        if (breakdown.isNotEmpty) {
          adviceBuffer.writeln('📊 ÖSYM KPSS P48 Sınav Yılları Simülasyonu:');
          adviceBuffer.writeln('• 2024 ÖSYM P48: ${breakdown['2024']} Puan');
          if (breakdown.containsKey('2023')) {
            adviceBuffer.writeln('• 2023 ÖSYM P48: ${breakdown['2023']} Puan');
          }
          adviceBuffer.writeln('• 2022 ÖSYM P48: ${breakdown['2022']} Puan');
          adviceBuffer.writeln('• Son Sınavlar Ortalaması: ~${breakdown['Ortalama']} P48');
          if (breakdown.containsKey('P3')) {
            adviceBuffer.writeln('• Tahmini P3 (GY-GK): ${breakdown['P3']} Puan');
          }
          adviceBuffer.writeln();
        }
        adviceBuffer.writeln('📌 KPSS Alan Bilgisi (P48) Koç Analizi:');
        adviceBuffer.writeln('• P48 puanında Hukuk (%20), İktisat (%20), Maliye (%20) ve Muhasebe (%20) toplam %80 ağırlığa sahiptir; GY (%10) ve GK (%10) %20 etkilidir.');
        final missingTests = <String>[];
        if (nets.gyNet < 1) missingTests.add('GY');
        if (nets.gkNet < 1) missingTests.add('GK');
        if (nets.hukukNet < 1) missingTests.add('Hukuk');
        if (nets.iktisatNet < 1) missingTests.add('İktisat');
        if (nets.maliyeNet < 1) missingTests.add('Maliye');
        if (nets.muhasebeNet < 1) missingTests.add('Muhasebe');
        if (nets.hasAlanEntry && missingTests.isNotEmpty) {
          adviceBuffer.writeln('• ⚠️ ÖSYM kuralı: P48 puanının hesaplanabilmesi için tüm P48 testlerinden en az 1 net gerekir (Eksik: ${missingTests.join(', ')}).');
        }
      } else if (lowerExam.contains('eğitim') || lowerExam.contains('egitim')) {
        if (breakdown.isNotEmpty) {
          adviceBuffer.writeln('📊 Eğitim Bilimleri Simülasyonu:');
          adviceBuffer.writeln('• 2024 ÖSYM: ${breakdown['2024']} Puan');
          adviceBuffer.writeln('• 2023 ÖSYM: ${breakdown['2023']} Puan');
          adviceBuffer.writeln('• 2022 ÖSYM: ${breakdown['2022']} Puan\n');
        }
        adviceBuffer.writeln('📌 Eğitim Bilimleri Koç Analizi:');
        adviceBuffer.writeln('• Öğretim Yöntem ve Teknikleri (21 soru) ile Gelişim-Öğrenme Psikolojisi (22 soru) sınavın yarısından fazlasını oluşturur.');
      } else {
        if (breakdown.isNotEmpty) {
          adviceBuffer.writeln('📊 ÖSYM Sınav Yılları Simülasyonu:');
          adviceBuffer.writeln('• 2024 ÖSYM: ${breakdown['2024']} Puan');
          adviceBuffer.writeln('• 2022 ÖSYM: ${breakdown['2022']} Puan');
          adviceBuffer.writeln('• 2020 ÖSYM: ${breakdown['2020']} Puan');
          adviceBuffer.writeln('• Son Sınavlar Ortalaması: ~${breakdown['Ortalama']} Puan\n');
        }
        adviceBuffer.writeln('📌 KPSS Koç Analizi:');
        adviceBuffer.writeln('• Tarih (27 soru) ve Türkçe-Paragraf (18 soru) sınavın %37.5\'ini oluşturur. Bu iki derste net artışı puanı hızla yükseltir.');
        final geoScore = scores.firstWhere((s) => s.courseId == 'geometri', orElse: () => const MockExamCourseScore(courseId: '', courseName: '', correctCount: 0, wrongCount: 0, netScore: 0));
        if (geoScore.courseId.isNotEmpty && geoScore.netScore < 2) {
          adviceBuffer.writeln('• Geometride sadece 3 soru çıkar. Enerjinizi öncelikle 18 soruluk Coğrafya ve 12 soruluk Problemlere ayırın.');
        }
        final matScore = scores.firstWhere((s) => s.courseId == 'matematik', orElse: () => const MockExamCourseScore(courseId: '', courseName: '', correctCount: 0, wrongCount: 0, netScore: 0));
        if (matScore.courseId.isNotEmpty && matScore.netScore < 15) {
          adviceBuffer.writeln('• Matematikte özellikle 12 soruluk Problemler ünitesinde her gün en az 25 soru çözmelisiniz.');
        }
      }
    } else if (targetExam.contains('LGS')) {
      adviceBuffer.writeln('\n📌 LGS Koç Analizi:');
      adviceBuffer.writeln('• Matematik ve Fen Bilimleri katsayısı (4.0) en yüksek derslerdir.');
    } else if (targetExam.contains('TYT')) {
      adviceBuffer.writeln('\n📌 TYT Koç Analizi:');
      adviceBuffer.writeln('• Türkçe (40 soru) ve Temel Matematik (40 soru) TYT puanının 2/3\'ünü oluşturur.');
      adviceBuffer.writeln('• Özellikle Paragraf ve Problemler TYT netlerinizin temel taşıdır. Günlük paragraf ve problem rutini şart!');
      adviceBuffer.writeln('• Fen ve Sosyal netleri standart sapmada fark yaratır, temel kavram tekrarlarını ihmal etmeyin.');
    } else if (targetExam.contains('YKS')) {
      adviceBuffer.writeln('\n📌 YKS Koç Analizi:');
      adviceBuffer.writeln('• Paragraf (22 soru) ve Problemler (12 soru) belirleyicidir. Günlük 20 paragraf rutini mutlaka korunmalı.');
    }

    adviceBuffer.writeln('\n⚡ Öncelikli Odak Alanı:');
    adviceBuffer.writeln('• ${weakest.courseName} netiniz ${weakest.netScore.toStringAsFixed(1)} seviyesinde kaldı. Bu dersteki konu eksiklerine odaklanın.');
    adviceBuffer.writeln('• En güçlü dersiniz: ${strongest.courseName} (${strongest.netScore.toStringAsFixed(1)} Net).');

    return adviceBuffer.toString();
  }
}
