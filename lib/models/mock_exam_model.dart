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

  /// Sınav türüne ve ders netlerine göre ÖSYM standartlarında tahmini puan hesaplar
  static double calculateEstimatedScore(String targetExam, List<MockExamCourseScore> scores) {
    if (scores.isEmpty) return 0.0;
    final totalNet = scores.fold(0.0, (acc, c) => acc + c.netScore);

    // 1. KPSS (Genel Yetenek - Genel Kültür: 120 Soru) -> 100 Puan Ölçeği
    if (targetExam.contains('KPSS')) {
      final score = 35.0 + (totalNet * 0.54);
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

    final maxQ = scores.fold(0, (sum, c) => sum + c.totalQuestions);
    if (maxQ == 0) return 0.0;
    return double.parse(((totalNet / maxQ) * 100.0).clamp(0.0, 100.0).toStringAsFixed(2));
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

    if (targetExam.contains('KPSS')) {
      adviceBuffer.writeln('\n📌 KPSS Koç Analizi:');
      adviceBuffer.writeln('• Tarih (27 soru) ve Türkçe-Paragraf (18 soru) sınavın %37.5\'ini oluşturur. Bu iki derste net artışı puanı hızla yükseltir.');
      final geoScore = scores.firstWhere((s) => s.courseId == 'geometri', orElse: () => const MockExamCourseScore(courseId: '', courseName: '', correctCount: 0, wrongCount: 0, netScore: 0));
      if (geoScore.courseId.isNotEmpty && geoScore.netScore < 2) {
        adviceBuffer.writeln('• Geometride sadece 3 soru çıkar. Enerjinizi öncelikle 18 soruluk Coğrafya ve 12 soruluk Problemlere ayırın.');
      }
      final matScore = scores.firstWhere((s) => s.courseId == 'matematik', orElse: () => const MockExamCourseScore(courseId: '', courseName: '', correctCount: 0, wrongCount: 0, netScore: 0));
      if (matScore.courseId.isNotEmpty && matScore.netScore < 15) {
        adviceBuffer.writeln('• Matematikte özellikle 12 soruluk Problemler ünitesinde her gün en az 25 soru çözmelisiniz.');
      }
    } else if (targetExam.contains('LGS')) {
      adviceBuffer.writeln('\n📌 LGS Koç Analizi:');
      adviceBuffer.writeln('• Matematik ve Fen Bilimleri katsayısı (4.0) en yüksek derslerdir.');
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
