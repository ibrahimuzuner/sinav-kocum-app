import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/user_provider.dart';
import '../providers/study_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'timer/timer_screen.dart';
import 'questions/question_tracker_screen.dart';
import 'schedule/schedule_screen.dart';
import 'statistics/statistics_screen.dart';
import 'settings/settings_screen.dart';
import 'teacher/teacher_dashboard_screen.dart';
import 'teacher/teacher_assignments_screen.dart';
import 'teacher/teacher_messages_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _teacherRefreshTrigger = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userProvider = context.read<UserProvider>();
        if (userProvider.targetExam.isNotEmpty) {
          context.read<StudyProvider>().setCurrentExam(userProvider.targetExam);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Uygulama arka plandan ön plana geldiğinde sayacı gerçek saatle eşitle
      if (mounted) {
        context.read<TimerProvider>().syncTimeWithClock();
      }
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _teacherRefreshTrigger++;
    });
  }

  void _bumpTeacherRefresh() {
    if (mounted) {
      setState(() => _teacherRefreshTrigger++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<UserProvider>().isTeacher;

    final screens = isTeacher
        ? [
            TeacherDashboardScreen(
              refreshTrigger: _teacherRefreshTrigger,
              onDataChanged: _bumpTeacherRefresh,
            ),
            TeacherAssignmentsScreen(
              refreshTrigger: _teacherRefreshTrigger,
              onDataChanged: _bumpTeacherRefresh,
            ),
            TeacherMessagesScreen(
              refreshTrigger: _teacherRefreshTrigger,
              onDataChanged: _bumpTeacherRefresh,
            ),
          ]
        : [
            DashboardScreen(onNavigateTab: _onTabSelected),
            const TimerScreen(),
            const QuestionTrackerScreen(),
            const ScheduleScreen(),
            const StatisticsScreen(),
          ];

    final safeIndex = _currentIndex >= screens.length ? 0 : _currentIndex;

    final navItems = isTeacher
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups_rounded),
              label: 'Öğrencilerim',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Ödevler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined),
              activeIcon: Icon(Icons.forum_rounded),
              label: 'Mesajlar',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer_rounded),
              label: 'Sayaç',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Soru Takip',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Program',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'İstatistik',
            ),
          ];

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: safeIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FloatingActionButton.small(
                heroTag: 'settings_btn',
                tooltip: 'Ayarlar',
                elevation: 0,
                backgroundColor: Theme.of(context).cardTheme.color,
                foregroundColor: Theme.of(context).iconTheme.color,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                  );
                },
                child: const Icon(Icons.settings_outlined, size: 20),
              ),
            )
          : null,
    );
  }
}
