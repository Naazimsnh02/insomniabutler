import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import 'insomnia_butler_screen.dart';
import '../main.dart';
import '../services/user_service.dart';
import '../utils/haptic_helper.dart';
import 'sleep_tracking/sleep_timer_screen.dart';
import 'sleep_tracking/manual_log_screen.dart';
import 'sleep_tracking/sleep_history_screen.dart';
import '../services/sleep_timer_service.dart';
import 'journal/journal_screen.dart';
import 'journal/journal_editor_screen.dart';
import 'account/account_screen.dart';
import 'sounds/sounds_screen.dart';
import 'sounds/widgets/playback_bar.dart';

/// Home Dashboard - Main app screen
/// Redesigned with premium high-fidelity UI inspired by modern sleep trackers
class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with SingleTickerProviderStateMixin {
  final _timerService = SleepTimerService();
  final GlobalKey<JournalScreenState> _journalKey = GlobalKey();
  final ScrollController _calendarScrollController = ScrollController();
  int _selectedNavIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  final Map<String, Map<String, dynamic>> _dataCache = {};

  // User data
  String _userName = 'User';
  int? _userId;

  // Insights data - Initialized with premium demo values
  // Insights data - Initialized to 0 to indicate no data
  int _latencyImprovement = 0;
  double _avgSleep = 0;
  int _streakDays = 0;
  int _totalSessions = 0;
  bool _isLoadingInsights = true;
  bool _showFullCalendar = false;

  // Last night's sleep data
  Duration? _lastNightDuration;
  int? _lastNightQuality;
  int _lastNightInterruptions = 0;
  double? _sleepEfficiency;
  bool _hasLastNightData = false;

  // Advanced Sleep Data
  int? _deepMinutes;
  int? _lightMinutes;
  int? _remMinutes;
  int? _awakeMinutes;
  int? _rhr;
  int? _hrv;
  int? _respiratoryRate;
  int? _consistencyScore;

  // Real data state
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _alarm = const TimeOfDay(hour: 7, minute: 0);
  String _affirmation = '"Everything meant for you is on the good way"';

  final List<Map<String, String>> _moods = [
    {'emoji': '😠', 'label': 'Angry'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😑', 'label': 'Blah'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '🥱', 'label': 'Tired'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _refreshAllData();

    // Listen to timer ticks and status changes
    _timerService.onTick.listen((_) {
      if (mounted) setState(() {});
    });
    _timerService.onStatusChange.listen((_) {
      if (mounted) setState(() {});
    });

    // Scroll to the end of the calendar strip to show the current date
    _scrollToCurrentDate();
  }

  void _scrollToCurrentDate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_calendarScrollController.hasClients) {
        _calendarScrollController.animateTo(
          _calendarScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await UserService.getCurrentUserId();
      final userName = await UserService.getCachedUserName();

      setState(() {
        _userId = userId;
        _userName = userName;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadInsights() async {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // Check if we have cached data for this date
    if (_dataCache.containsKey(dateKey)) {
      final cached = _dataCache[dateKey]!;
      setState(() {
        _lastNightDuration = cached['duration'];
        _lastNightQuality = cached['quality'];
        _sleepEfficiency = cached['efficiency'];
        _hasLastNightData = cached['hasData'];
        _lastNightInterruptions = cached['interruptions'];
        _selectedMood = cached['mood'];
        _deepMinutes = cached['deep'];
        _lightMinutes = cached['light'];
        _remMinutes = cached['rem'];
        _awakeMinutes = cached['awake'];
        _rhr = cached['rhr'];
        _hrv = cached['hrv'];
        _respiratoryRate = cached['respiratoryRate'];
        _consistencyScore = cached['consistency'];
        _isLoadingInsights = false;
      });
      // We still fetch in background to ensure data is fresh, but with no loader
    } else {
      // No cache, show loader and reset (optimistic: maybe keep old data but show loader?)
      // Professionals usually show a shimmer or keep old data while showing a small indicator.
      // For now, let's keep it simple: if no cache, show loader.
      setState(() => _isLoadingInsights = true);
    }

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) {
        setState(() => _isLoadingInsights = false);
        return;
      }

      // Fetch global insights and trend (Independent calls)
      final results = await Future.wait([
        client.insights.getUserInsights(userId),
        client.insights.getSleepTrend(userId, 30),
      ]);

      final insights = results[0] as dynamic;
      final sessions = results[1] as List<dynamic>;

      // Calculate streak
      int streak = 0;
      DateTime? lastDate;
      final reversedSessions = sessions.reversed.toList();
      for (var session in reversedSessions) {
        final sessionDate = DateTime(
          session.sessionDate.toLocal().year,
          session.sessionDate.toLocal().month,
          session.sessionDate.toLocal().day,
        );

        if (lastDate == null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final diff = today.difference(sessionDate).inDays;
          if (diff <= 1) {
            streak = 1;
            lastDate = sessionDate;
          } else {
            break;
          }
        } else {
          final diff = lastDate.difference(sessionDate).inDays;
          if (diff == 1) {
            streak++;
            lastDate = sessionDate;
          } else if (diff == 0) {
            continue;
          } else {
            break;
          }
        }
      }

      // Get target session
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDayOnly = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      dynamic targetSession;
      if (selectedDayOnly.isAtSameMomentAs(today)) {
        targetSession = await client.sleepSession.getLastNightSession(userId);
      } else {
        targetSession = await client.sleepSession.getSessionForDate(
          userId,
          _selectedDate,
        );
      }

      Duration? duration;
      double efficiency = 0.0;
      bool hasData = false;
      int? calculatedConsistency;

      if (targetSession != null && targetSession.wakeTime != null) {
        duration = targetSession.wakeTime!.difference(targetSession.bedTime);
        final tibMinutes = duration!.inMinutes;
        final latency = targetSession.sleepLatencyMinutes ?? 0;
        final awake = targetSession.awakeDuration ?? 0;
        int estimatedAwake = awake == 0 && (targetSession.interruptions ?? 0) > 0 
            ? (targetSession.interruptions ?? 0) * 10 
            : awake;
        final actualSleepMinutes = (tibMinutes - latency - estimatedAwake).clamp(0, tibMinutes);
        efficiency = tibMinutes > 0 ? (actualSleepMinutes / tibMinutes * 100) : 0.0;
        hasData = true;
      }

      // Consistency calculation
      if (sessions.isNotEmpty) {
        final recentSessions = sessions.reversed.take(7).toList();
        if (recentSessions.length >= 2) {
          double totalBedtimeDev = 0;
          double totalWakeDev = 0;
          double meanBedtime = 0;
          double meanWake = 0;
          int sessionsWithWake = 0;

          for (var s in recentSessions) {
            final bt = s.bedTime.toLocal();
            meanBedtime += (bt.hour * 60 + bt.minute);
            if (s.wakeTime != null) {
              final wt = s.wakeTime!.toLocal();
              meanWake += (wt.hour * 60 + wt.minute);
              sessionsWithWake++;
            }
          }

          meanBedtime /= recentSessions.length;
          if (sessionsWithWake > 0) meanWake /= sessionsWithWake;

          for (var s in recentSessions) {
            final bt = s.bedTime.toLocal();
            totalBedtimeDev += (bt.hour * 60 + bt.minute - meanBedtime).abs();
            if (s.wakeTime != null) {
              final wt = s.wakeTime!.toLocal();
              totalWakeDev += (wt.hour * 60 + wt.minute - meanWake).abs();
            }
          }

          double avgDev = totalBedtimeDev / recentSessions.length;
          if (sessionsWithWake > 0) avgDev = (avgDev + (totalWakeDev / sessionsWithWake)) / 2;
          calculatedConsistency = (100 - (avgDev / 1.2)).clamp(0, 100).toInt();
        }
      }

      // Cache the result
      _dataCache[dateKey] = {
        'duration': duration,
        'quality': targetSession?.sleepQuality,
        'efficiency': efficiency,
        'hasData': hasData,
        'interruptions': targetSession?.interruptions ?? 0,
        'mood': targetSession?.morningMood,
        'deep': targetSession?.deepSleepDuration,
        'light': targetSession?.lightSleepDuration,
        'rem': targetSession?.remSleepDuration,
        'awake': targetSession?.awakeDuration,
        'rhr': targetSession?.restingHeartRate,
        'hrv': targetSession?.hrv,
        'respiratoryRate': targetSession?.respiratoryRate,
        'consistency': calculatedConsistency,
      };

      if (mounted) {
        setState(() {
          _lastNightDuration = duration;
          _lastNightQuality = targetSession?.sleepQuality;
          _sleepEfficiency = efficiency;
          _hasLastNightData = hasData;
          _lastNightInterruptions = targetSession?.interruptions ?? 0;
          _selectedMood = targetSession?.morningMood;
          _deepMinutes = targetSession?.deepSleepDuration;
          _lightMinutes = targetSession?.lightSleepDuration;
          _remMinutes = targetSession?.remSleepDuration;
          _awakeMinutes = targetSession?.awakeDuration;
          _rhr = targetSession?.restingHeartRate;
          _hrv = targetSession?.hrv;
          _respiratoryRate = targetSession?.respiratoryRate;
          _consistencyScore = calculatedConsistency;

          _latencyImprovement = insights.latencyImprovement;
          _avgSleep = insights.avgLatencyWithButler > 0
              ? (insights.avgLatencyWithButler / 60).clamp(0, 12).toDouble()
              : 0;
          _streakDays = streak;
          _totalSessions = insights.totalSessions;
          _isLoadingInsights = false;
        });
        _updateAffirmationForTime();
      }
    } catch (e) {
      debugPrint('Error loading insights: $e');
      if (mounted) setState(() => _isLoadingInsights = false);
    }
  }

  Future<void> _refreshAllData() async {
    await _loadInsights();
    _journalKey.currentState?.loadData();
  }

  void _updateAffirmationForTime() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour >= 5 && hour < 12) {
        _affirmation =
            '"The morning breeze has secrets to tell you. Don\'t go back to sleep."';
      } else if (hour >= 12 && hour < 17) {
        _affirmation =
            '"Your energy is a precious resource. Use it wisely today."';
      } else if (hour >= 17 && hour < 21) {
        _affirmation = '"As the sun sets, let go of any worries from the day."';
      } else {
        _affirmation = '"Everything meant for you is on the good way"';
      }
    });
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _alarm,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              onSurface: AppColors.textPrimary,
              surface: AppColors.bgPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      HapticHelper.mediumImpact();
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _alarm = picked;
        }
      });
    }
  }

  bool get _isTodaySelected => isSameDay(_selectedDate, DateTime.now());

  String _getQualityText() {
    if (_latencyImprovement >= 80) return 'Excellent!';
    if (_latencyImprovement >= 60) return 'Very Good';
    if (_latencyImprovement >= 40) return 'Good';
    return 'Improving';
  }

  Color _getQualityColor() {
    if (_latencyImprovement >= 80) return AppColors.accentSuccess;
    if (_latencyImprovement >= 60) return AppColors.accentSkyBlue;
    if (_latencyImprovement >= 40) return AppColors.accentAmber;
    return AppColors.accentPrimary;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _calculateDuration() {
    int bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    int alarmMinutes = _alarm.hour * 60 + _alarm.minute;

    int diff;
    if (alarmMinutes >= bedMinutes) {
      diff = alarmMinutes - bedMinutes;
    } else {
      diff = (24 * 60 - bedMinutes) + alarmMinutes;
    }

    int hours = diff ~/ 60;
    int minutes = diff % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bgMainGradient,
              ),
            ),
          ),

          // Decorative background elements
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPrimary.withOpacity(0.05),
              ),
            ).animate().fadeIn(duration: 1200.ms),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLavender.withOpacity(0.03),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 1200.ms),
          ),

          // Main Content
          SafeArea(
            child: _buildBody(),
          ),

          // Bottom UI Components
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlaybackBar(),
                _buildBottomNavArea(),
              ],
            ),
          ),

          // Journal Add Button (Floating above nav)
          if (_selectedNavIndex == 2)
            Positioned(
              right: 20,
              bottom: 120,
              child: _buildJournalFAB(),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedNavIndex,
      children: [
        _buildHomeTab(),
        const SoundsScreen(),
        JournalScreen(isTab: true, key: _journalKey),
        AccountScreen(
          isTab: true,
          onDataChanged: _refreshAllData,
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildTopBar(),
        _buildCalendarStrip(),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.lg),
              _buildLastNightSummary().animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: AppSpacing.xl),
              _buildAdvancedMetrics().animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: AppSpacing.xl),
              _buildDailyAffirmation().animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: AppSpacing.xl),
              _buildSleepGauge().animate().fadeIn(delay: 450.ms, duration: 400.ms).scale(begin: const Offset(0.98, 0.98)),
              const SizedBox(height: AppSpacing.xl),
              if (_isTodaySelected) ...[
                _timerService.isRunning 
                  ? _buildActiveTimerCard().animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.05, end: 0)
                  : _buildStartTrackingButton().animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.xl),
              ],
              _buildControlPanel().animate().fadeIn(delay: 550.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: AppSpacing.xl),
              _buildMoodTracker().animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: AppSpacing.xl),
              _buildTrendInsights().animate().fadeIn(delay: 650.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: 140), // Space for fab & nav
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.accentSkyBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getGreeting(),
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0),
            Row(
              children: [
                _buildIconButton(
                  icon: Icons.history_rounded,
                  onTap: () async {
                    HapticHelper.lightImpact();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SleepHistoryScreen(),
                      ),
                    );
                    if (result == true || result == null) {
                      _refreshAllData();
                    }
                  },
                ).animate().fadeIn(delay: 100.ms).scale(duration: 300.ms),
                const SizedBox(width: 12),
                _buildIconButton(
                  icon: _showFullCalendar
                      ? Icons.view_week_rounded
                      : Icons.calendar_today_rounded,
                  onTap: () {
                    HapticHelper.lightImpact();
                    setState(() {
                      _showFullCalendar = !_showFullCalendar;
                    });
                  },
                ).animate().fadeIn(delay: 150.ms).scale(duration: 300.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    if (_showFullCalendar) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            color: AppColors.bgSecondary.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 1)),
              focusedDay: _selectedDate,
              currentDay: DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              calendarFormat: CalendarFormat.month,
              onDaySelected: (selectedDay, focusedDay) {
                HapticHelper.lightImpact();
                setState(() {
                  _selectedDate = selectedDay;
                });
                _loadInsights();
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.bodyLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.accentSkyBlue,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.accentSkyBlue,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTextStyles.label.copyWith(
                  color: AppColors.textTertiary,
                ),
                weekendStyle: AppTextStyles.label.copyWith(
                  color: AppColors.accentPrimary.withOpacity(0.7),
                ),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textPrimary,
                ),
                weekendTextStyle: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
                outsideTextStyle: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textTertiary.withOpacity(0.3),
                ),
                selectedDecoration: const BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.accentPrimary.withOpacity(0.5),
                  ),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),
        ),
      );
    }

    final now = DateTime.now();
    final days = List.generate(
      7,
      (index) => now.subtract(
        Duration(days: 6 - index),
      ), // Show last 7 days including today
    );

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          controller: _calendarScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final isSelected = isSameDay(date, _selectedDate);
            final isToday = isSameDay(date, now);

            return GestureDetector(
              onTap: () {
                HapticHelper.lightImpact();
                setState(() => _selectedDate = date);
                _loadInsights();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPrimary.withOpacity(0.15)
                      : AppColors.bgSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentPrimary.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 1.5 : 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).toUpperCase()[0],
                      style: AppTextStyles.label.copyWith(
                        color: isSelected
                            ? AppColors.accentPrimary
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected ? AppColors.gradientPrimary : null,
                        border: isToday && !isSelected
                            ? Border.all(
                                color: AppColors.accentPrimary.withOpacity(0.5),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: AppTextStyles.bodySm.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (200 + (index * 20)).ms).slideX(begin: 0.1, end: 0, duration: 300.ms);
          },
        ),
      ),
    );
  }

  Widget _buildDailyAffirmation() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Affirmation',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.accentAmber,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.accentAmber,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _affirmation,
            style: AppTextStyles.bodyLg.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppColors.textPrimary.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLastNightSummary() {
    if (_lastNightDuration == null) {
      return GlassCard(
        padding: const EdgeInsets.all(20),
        color: AppColors.bgSecondary.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.bedtime_outlined,
              color: AppColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'No sleep data yet',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your last night\'s sleep summary will appear here.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final hours = _lastNightDuration!.inHours;
    final minutes = _lastNightDuration!.inMinutes.remainder(60);
    final quality = _lastNightQuality ?? 3;

    // Quality-based colors
    Color qualityColor = AppColors.accentPrimary;
    String qualityText = 'Good';
    if (quality >= 4) {
      qualityColor = AppColors.accentSuccess;
      qualityText = 'Excellent';
    } else if (quality <= 2) {
      qualityColor = AppColors.accentError;
      qualityText = 'Poor';
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Night',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${hours}h ${minutes}m',
                            style: AppTextStyles.h2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: qualityColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: qualityColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: qualityColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              qualityText,
                              style: AppTextStyles.caption.copyWith(
                                color: qualityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      qualityColor.withOpacity(0.3),
                      qualityColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: qualityColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.bedtime_rounded,
                  color: qualityColor,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.star_rounded,
                  value: '$quality/5',
                  label: 'Quality',
                  color: qualityColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.glassBorder,
              ),
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.notifications_off_rounded,
                  value: '$_lastNightInterruptions',
                  label: 'Interruptions',
                  color: _lastNightInterruptions == 0
                      ? AppColors.accentSuccess
                      : AppColors.accentAmber,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.glassBorder,
              ),
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.trending_up_rounded,
                  value: '${_sleepEfficiency?.toStringAsFixed(0) ?? '--'}%',
                  label: 'Efficiency',
                  color: AppColors.accentSkyBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedMetrics() {
    bool hasStructure =
        _deepMinutes != null ||
        _remMinutes != null ||
        _lightMinutes != null ||
        _awakeMinutes != null;
    bool hasRecovery = _rhr != null || _hrv != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Insights',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!hasStructure || !hasRecovery)
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManualLogScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 14,
                          color: AppColors.accentSkyBlue.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Add Data',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentSkyBlue.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSleepStructure(),
        const SizedBox(height: AppSpacing.md),
        _buildRecoveryCards(),
      ],
    );
  }

  Widget _buildSleepStructure() {
    final deep = _deepMinutes ?? 0;
    final rem = _remMinutes ?? 0;
    final light = _lightMinutes ?? 0;
    final awake = _awakeMinutes ?? 0;
    final total = deep + rem + light + awake;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.3),
      borderRadius: 24,
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sleep Architecture',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              if (total > 0)
                Text(
                  '${(deep / total * 100).toStringAsFixed(0)}% Deep',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (deep > 0)
                      Expanded(
                        flex: deep,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accentPrimary,
                                AppColors.accentPrimary.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (rem > 0)
                      Expanded(
                        flex: rem,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accentSkyBlue,
                                AppColors.accentSkyBlue.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (light > 0)
                      Expanded(
                        flex: light,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.textSecondary.withOpacity(0.4),
                                AppColors.textSecondary.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (awake > 0)
                      Expanded(
                        flex: awake,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accentAmber,
                                AppColors.accentAmber.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem('Deep', AppColors.accentPrimary, '${deep}m'),
                _buildLegendItem('REM', AppColors.accentSkyBlue, '${rem}m'),
                _buildLegendItem('Light', AppColors.textSecondary, '${light}m'),
                _buildLegendItem('Awake', AppColors.accentAmber, '${awake}m'),
              ],
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No sleep architecture data logged',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildRecoveryCard(
            'Resting HR',
            _rhr != null ? '$_rhr' : '--',
            'bpm',
            Icons.favorite_rounded,
            AppColors.accentError,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildRecoveryCard(
            'HRV',
            _hrv != null ? '$_hrv' : '--',
            'ms',
            Icons.bolt_rounded,
            AppColors.accentSuccess,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildRecoveryCard(
            'Resp. Rate',
            _respiratoryRate != null ? '$_respiratoryRate' : '--',
            'brpm',
            Icons.air_rounded,
            AppColors.accentSkyBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: AppColors.bgSecondary.withOpacity(0.3),
      borderRadius: 20,
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 8,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepGauge() {
    final dateStr = DateFormat('EEE, dd MMMM').format(_selectedDate);

    // The gauge now strictly represents the goal/plan for the upcoming sleep
    final displayDuration = _calculateDuration();
    const scoreText = 'Target Score';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.3),
      borderRadius: 24,
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: AppTextStyles.h4),
              Row(
                children: [
                  Text(
                    'Tonight\'s Goal',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Glow
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPrimary.withOpacity(0.1),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Gauge Arc
                Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10, width: 2),
                  ),
                  child: CustomPaint(
                    painter: _GaugePainter(0.85), // Target goal visual
                  ),
                ),
                // Inner Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                          Icons.nights_stay_rounded,
                          color: AppColors.accentPrimary,
                          size: 48,
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(duration: 3.seconds, color: Colors.white24),
                    const SizedBox(height: 8),
                    Text(
                      scoreText,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDuration,
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Target duration',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Time Labels
                ...List.generate(4, (i) {
                  final double angle = (i * 90 - 90) * (math.pi / 180);
                  final time = ['12', '3', '6', '9'][i];
                  return Positioned.fill(
                    child: Align(
                      alignment: Alignment(
                        math.cos(angle) * 1.08,
                        math.sin(angle) * 1.08,
                      ),
                      child: Text(
                        time,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary.withOpacity(0.8),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetricItem(
                'Schedule',
                '${_bedtime.hour.toString().padLeft(2, '0')}:${_bedtime.minute.toString().padLeft(2, '0')} - ${_alarm.hour.toString().padLeft(2, '0')}:${_alarm.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(width: 32),
              _buildMetricItem(
                'Butler Mode',
                'Active',
                color: AppColors.accentSuccess,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeCard(
            'Bedtime',
            _bedtime.format(context),
            Icons.bedtime_rounded,
            onTap: () => _selectTime(context, true),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildTimeCard(
            'Alarm',
            _alarm.format(context),
            Icons.alarm_rounded,
            onTap: () => _selectTime(context, false),
          ),
        ),
      ],
    );
  }

  Widget _buildStartTrackingButton() {
    return PrimaryButton(
      text: 'Start Tracking',
      onPressed: () => _showTrackingSelector(),
      icon: Icons.play_arrow_rounded,
    );
  }

  void _showTrackingSelector() {
    HapticHelper.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TrackingSelectorSheet(onRefresh: _refreshAllData),
    );
  }

  Widget _buildTimeCard(
    String title,
    String time,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: AppColors.accentPrimary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.edit_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How do you feel now?', style: AppTextStyles.labelLg),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _moods.map((mood) {
            final isSelected = _selectedMood == mood['label'];
            return GestureDetector(
              onTap: () async {
                HapticHelper.lightImpact();
                setState(() => _selectedMood = mood['label']);

                // Save to backend
                try {
                  final userId = await UserService.getCurrentUserId();
                  if (userId != null) {
                    if (_isTodaySelected) {
                      await client.sleepSession.updateMoodForLatestSession(
                        userId,
                        mood['label']!,
                      );
                    } else {
                      // Optionally update mood for specific session if we have sessionId
                      // For now, only allow updating for today or most recent
                    }
                  }
                } catch (e) {
                  debugPrint('Error saving mood: $e');
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPrimary.withOpacity(0.3)
                      : AppColors.bgSecondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentPrimary.withOpacity(0.6)
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentPrimary.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  mood['emoji']!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTrendInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          color: AppColors.bgSecondary.withOpacity(0.3),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trend Insights',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.accentSkyBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Icon(
                    Icons.insights_rounded,
                    size: 16,
                    color: AppColors.accentSkyBlue,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildSimpleStat(
                    '⚡',
                    _totalSessions > 0 ? '$_latencyImprovement%' : '--',
                    'Faster Sleep',
                    color: AppColors.accentPrimary,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withOpacity(0.08),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  _buildSimpleStat(
                    '🎯',
                    (_totalSessions > 0 && _consistencyScore != null)
                        ? '$_consistencyScore%'
                        : '--',
                    'Consistency',
                    color: AppColors.accentSuccess,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withOpacity(0.08),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  _buildSimpleStat(
                    '🔥',
                    _totalSessions > 0 ? '${_streakDays}d' : '--',
                    'Streak',
                    color: AppColors.accentAmber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(
    String emoji,
    String value,
    String label, {
    Color? color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLg.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildBottomNavArea() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgPrimary.withOpacity(0),
            AppColors.bgPrimary.withOpacity(0.9),
            AppColors.bgPrimary,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nav Bar
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 24,
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 32,
              color: AppColors.bgSecondary.withOpacity(0.6),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              child: SizedBox(
                height: 72,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.nightlight_round, 'Home', 0),
                    _buildNavItem(Icons.music_note_rounded, 'Sounds', 1),
                    const SizedBox(width: 48), // Space for Mid FAB
                    _buildNavItem(Icons.auto_stories_rounded, 'Journal', 2),
                    _buildNavItem(Icons.person_outline_rounded, 'Account', 3),
                  ],
                ),
              ),
            ),
          ),
          // Floating Action Button (Thought Clearing)
          Positioned(
                bottom: 30,
                child: GestureDetector(
                  onTap: () {
                    HapticHelper.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InsomniaButlerScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPrimary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo/butler_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.chat_bubble_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                      ),
                    ),
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -4, duration: 1500.ms),
        ],
      ),
    );
  }

  Widget _buildJournalFAB() {
    return GestureDetector(
      onTap: () async {
        await HapticHelper.mediumImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JournalEditorScreen()),
        );
        _refreshAllData();
      },
      child:
          Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientCalm,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentSkyBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
              ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedNavIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticHelper.lightImpact();
          setState(() => _selectedNavIndex = index);
          if (index == 0) {
            _scrollToCurrentDate();
          }
        },
        child: Container(
          height: double.infinity,
          color: Colors.transparent, // Ensures hit test works on empty space
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppColors.textTertiary,
                size: isActive ? 24 : 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? Colors.white : AppColors.textTertiary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTimerCard() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 20,
      color: AppColors.accentSuccess.withOpacity(0.05),
      border: Border.all(
        color: AppColors.accentSuccess.withOpacity(0.2),
        width: 1.5,
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SleepTimerScreen()),
        );
        if (result == true) _refreshAllData();
      },
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentSuccess.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 2.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                  ),
              const Icon(
                Icons.nightlight_round,
                color: AppColors.accentSuccess,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sleep Tracking Active',
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentSuccess,
                  ),
                ),
                Text(
                  'Tap to view your silent timer',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentSuccess.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.accentSuccess,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(10),
        borderRadius: 12,
        color: AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMicroAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score; // 0.0 to 1.0

  _GaugePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2 - 2.5,
      5.0,
      false,
      trackPaint,
    );

    // Active Progress
    final progressGradient = const SweepGradient(
      colors: [
        AppColors.accentPrimary,
        AppColors.accentAmber,
        AppColors.accentSkyBlue,
      ],
      stops: [0.0, 0.4, 0.8],
      transform: GradientRotation(-3.14159 / 2 - 2.5),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final progressPaint = Paint()
      ..shader = progressGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2 - 2.5,
      score * 5.0, // Score mapped to arc (max sweep is approx 5.0 rad)
      false,
      progressPaint,
    );

    // Thumb Glow
    final thumbPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Position thumb at end of progress (trigonometry simplified)
    // For demo, just skip or draw a simple dot
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrackingSelectorSheet extends StatelessWidget {
  final VoidCallback onRefresh;
  const _TrackingSelectorSheet({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgSecondary.withOpacity(0.8),
              AppColors.bgPrimary,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('How would you like to track?', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            _buildOption(
              context,
              'Insomnia Butler',
              'Let Butler clear your thoughts for better sleep.',
              assetPath: 'assets/logo/butler_logo.png',
              AppColors.gradientPrimary,
              () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InsomniaButlerScreen(),
                  ),
                );
                if (result == true) onRefresh();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildOption(
              context,
              'Silent Timer',
              'Start a quiet timer for sleep and wake up to Butler.',
              AppColors.gradientCalm,
              () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SleepTimerScreen()),
                );
                if (result == true) onRefresh();
              },
              icon: Icons.timer_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildOption(
              context,
              'Manual Log',
              'Retroactively log sleep duration and quality.',
              AppColors.gradientLavender,
              () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManualLogScreen()),
                );
                if (result == true) onRefresh();
              },
              icon: Icons.history_edu_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    String title,
    String subtitle,
    Gradient? gradient,
    VoidCallback onTap, {
    IconData? icon,
    String? assetPath,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: assetPath != null
                ? EdgeInsets.zero
                : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null
                  ? AppColors.bgSecondary.withOpacity(0.4)
                  : null,
              shape: BoxShape.circle,
              boxShadow: gradient != null
                  ? [
                      BoxShadow(
                        color: (gradient.colors.first).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: assetPath != null
                ? ClipOval(
                    child: Image.asset(
                      assetPath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          icon ?? Icons.error_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
