import 'package:flutter_test/flutter_test.dart';
import 'package:exam_tracker/models/question_log_model.dart';
import 'package:exam_tracker/models/mock_exam_model.dart';
import 'package:exam_tracker/models/user_profile_model.dart';
import 'package:exam_tracker/services/predefined_data.dart';
import 'package:exam_tracker/services/target_departments_data.dart';
import 'package:exam_tracker/services/smart_scheduler_service.dart';
import 'package:exam_tracker/utils/formatters.dart';

void main() {
  test('QuestionLogModel calculates netScore correctly', () {
    final log = QuestionLogModel(
      id: '1',
      courseId: 'matematik',
      courseName: 'Matematik',
      correctCount: 20,
      wrongCount: 4,
      emptyCount: 1,
      date: DateTime.now(),
    );

    // 20 - (4 / 4) = 19.0
    expect(log.netScore, 19.0);
    expect(log.totalQuestions, 25);
  });

  test('Formatters formats seconds to MM:SS and HH:MM:SS', () {
    expect(Formatters.formatSecondsToTime(65), '01:05');
    expect(Formatters.formatSecondsToTime(3665), '01:01:05');
  });

  test('KPSS GK-GY courses do not contain Kimya, Fizik, or Biyoloji', () {
    final kpssCourses = PredefinedData.getCoursesForExam('KPSS (Genel Yetenek - Kültür)');
    final courseIds = kpssCourses.map((c) => c.id).toList();

    expect(courseIds.contains('kimya'), false);
    expect(courseIds.contains('fizik'), false);
    expect(courseIds.contains('biyoloji'), false);
    expect(courseIds.contains('turkce'), true);
    expect(courseIds.contains('matematik'), true);
    expect(courseIds.contains('tarih'), true);
    expect(courseIds.contains('cografya'), true);
    expect(courseIds.contains('vatandaslik'), true);
  });

  test('MockExamModel calculates totalNet and course scores correctly', () {
    final turkishScore = MockExamCourseScore(
      courseId: 'turkce',
      courseName: 'Türkçe',
      correctCount: 28,
      wrongCount: 4,
      emptyCount: 0,
      netScore: MockExamCourseScore.calculateNet(28, 4), // 28 - 1 = 27.0
    );

    final mathScore = MockExamCourseScore(
      courseId: 'matematik',
      courseName: 'Matematik',
      correctCount: 25,
      wrongCount: 2,
      emptyCount: 5,
      netScore: MockExamCourseScore.calculateNet(25, 2), // 25 - 0.5 = 24.5
    );

    final exam = MockExamModel(
      id: 'mock_1',
      title: 'Pegem TG-1',
      targetExam: 'KPSS',
      date: DateTime.now(),
      courseScores: [turkishScore, mathScore],
    );

    expect(exam.totalCorrect, 53);
    expect(exam.totalWrong, 6);
    expect(exam.totalEmpty, 5);
    expect(exam.totalQuestions, 64);
    expect(exam.totalNet, 51.5);
  });

  test('TargetDepartmentsData provides departments with valid target score and net', () {
    final yksSayDepartments = TargetDepartmentsData.getDepartmentsForExam('YKS (Sayısal)');
    expect(yksSayDepartments.isNotEmpty, true);

    final tip = yksSayDepartments.firstWhere((d) => d.id == 'yks_say_tip');
    expect(tip.name, 'Tıp Fakültesi');
    expect(tip.baseScore >= 500.0, true);
    expect(tip.targetNet >= 100.0, true);

    final kpssDepartments = TargetDepartmentsData.getDepartmentsForExam('KPSS (Genel Yetenek - Kültür)');
    expect(kpssDepartments.isNotEmpty, true);
    final kpss90 = kpssDepartments.firstWhere((d) => d.id == 'kpss_90_ustu');
    expect(kpss90.baseScore >= 90.0, true);
  });

  test('SmartSchedulerService generates target-focused schedule with department and score', () {
    final courses = PredefinedData.getCoursesForExam('YKS (Sayısal)');
    final schedule = SmartSchedulerService.generateSchedule(
      courses: courses,
      questionLogs: [],
      dailyMinutes: 180, // 3 saat
      strategy: ScheduleStrategy.focusWeak,
      includeSunday: false,
      targetExam: 'YKS (Sayısal)',
      targetDepartment: 'Tıp Fakültesi',
      targetScore: 505.0,
      targetNet: 106.0,
    );

    expect(schedule.isNotEmpty, true);
    // 6 gün (Pzt-Cmt), en az 2 blok/gün = >= 12 items
    expect(schedule.length >= 12, true);
    // Tıp fakültesi için matematik veya fen dersleri programda bulunmalı
    final hasMathOrScience = schedule.any((s) =>
        s.courseId == 'matematik' ||
        s.courseId == 'biyoloji' ||
        s.courseId == 'kimya' ||
        s.courseId == 'fizik');
    expect(hasMathOrScience, true);
    // Varsayılan hybrid modda 30 dk video/tekrar içermeli
    expect(schedule.first.activityType, 'hybrid');
    expect(schedule.first.lectureMinutes, 30);
  });

  test('SmartSchedulerService generates practiceOnly mode when user says topics are completed', () {
    final courses = PredefinedData.getCoursesForExam('YKS (Sayısal)');
    final schedule = SmartSchedulerService.generateSchedule(
      courses: courses,
      questionLogs: [],
      dailyMinutes: 180,
      strategy: ScheduleStrategy.intensive,
      includeSunday: false,
      contentMode: StudyContentMode.practiceOnly,
    );

    expect(schedule.isNotEmpty, true);
    expect(schedule.first.activityType, 'practice');
    expect(schedule.first.lectureMinutes, 0);
    expect(schedule.first.practiceMinutes > 0, true);
  });

  test('UserProfileModel serializes and deserializes targetDepartment, targetScore and membership correctly', () {
    final profile = UserProfileModel(
      id: 'test-user-123',
      firstName: 'Ahmet',
      lastName: 'Yılmaz',
      email: 'ahmet@example.com',
      birthDate: DateTime(2005, 5, 20),
      targetExam: 'YKS (Sayısal)',
      dailyTargetHours: 4,
      targetDepartment: 'Tıp Fakültesi',
      targetScore: 505.0,
      targetNet: 106.0,
      createdAt: DateTime.now(),
      isPremium: false,
      membershipPlan: 'Ücretsiz',
    );

    final json = profile.toJson();
    expect(json['id'], 'test-user-123');
    expect(json['targetDepartment'], 'Tıp Fakültesi');
    expect(json['targetScore'], 505.0);
    expect(json['targetNet'], 106.0);
    expect(json['isPremium'], false);
    expect(json['membershipPlan'], 'Ücretsiz');
    expect(json['isEmailVerified'], false);

    final parsed = UserProfileModel.fromJson(json);
    expect(parsed.id, profile.id);
    expect(parsed.fullName, 'Ahmet Yılmaz');
    expect(parsed.targetDepartment, 'Tıp Fakültesi');
    expect(parsed.targetScore, 505.0);
    expect(parsed.targetNet, 106.0);
    expect(parsed.isPremium, false);
    expect(parsed.membershipPlan, 'Ücretsiz');
    expect(parsed.isEmailVerified, false);
  });
}
